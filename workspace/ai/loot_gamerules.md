# Loot Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_LOOT = 14` (defined in `common/const.h`)
- **String ID**: `"loot"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Loot"` — 4-team, round-based crate-smashing objective
- **Source**: `src/dlls/loot_gamerules.cpp`, `src/dlls/loot_gamerules.h`
- **Class**: `CHalfLifeLoot : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (BotLootThink, BotLootPreUpdate, BotLootFindEntities, BotLootGetHolder, BotLootPickNearestCrate, BotLootFindBestVisibleCrate, BotLootIsOnTopOfCrate, BotLootCrateOccupiedByOtherBot, BotLootHandleOnTopOfCrate, GAME_LOOT carrier-pacify in BotFindEnemy, `loot_crate` un-excluded from BotAssessGrenades), `bot.cpp` (state init, dispatch, pre-update, GAME_LOOT skip in BotFindItem, on-top dismount call, synthetic-enemy injection + LoS swap + walk-by visible crate engagement), `bot_navigate.cpp` (GAME_LOOT waypoint goal selection + waypoint reset on role flip), `bot.h` (LOOT_ROLE_* enum + Loot state fields), `bot_func.h` (declarations)

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, the cross-DLL `fuser4` / `RADAR_*` conventions, the [`v_goal` Preservation Contract](gamerules.md#critical--v_goal-preservation-contract), and the bot integration checklist that every mode (including Loot) must satisfy.

## Win Condition
- Round-based: `IsRoundBased()` returns `TRUE`.
- A round ends when the loot **holder** touches `loot_goal` (`OnGoalReached`), the timer expires (tiebreaker by accumulated `m_flTeamHoldTime`), or only one team remains alive.
- Holder's team scores the round; aggregated `m_iRoundWins` per team determines map win once `scorelimit` is reached.

## Round Lifecycle
1. **StartRound**: assigns 4 teams (`iceman`/`santa`/`gina`/`frost`), positions players at team spawn anchors, gives team weapons, writes `pPlayer->pev->fuser4 = teamIdx (0..3)`.
2. **Crate spawn (deferred 3 s)**: `SpawnLootEntities` creates many `loot_crate` entities at random map locations; one is randomly tagged with `m_bHasLoot = TRUE`. Spawns `loot_goal` at one randomized position too.
3. **Crate broken**: when the loot-bearing crate dies (`OnCrateBroken` → `SpawnLootAtPosition`), a `loot_entity` (touchable charm) appears at its origin.
4. **Pickup**: `CLootEntity::Touch` calls `CHalfLifeLoot::CaptureCharm(pPlayer)` which sets `m_bHoldingLoot = TRUE`, `pPlayer->pev->fuser4 = RADAR_LOOT`, attaches the loot model, and removes the `loot_entity` from world view.
5. **Goal touch**: `CLootGoal::Touch` → `CHalfLifeLoot::OnGoalReached` → schedules `EndRound` after a 4-second celebration window.
6. **Loot exposure**: if no pickup happens within ~5 minutes (or with 60 s remaining), `ExposeLoot` shatters all crates and drops `loot_entity` at a deathmatch spawn point.

## Teams (4-way)
- `TEAM_ICEMAN = 0`, `TEAM_SANTA = 1`, `TEAM_GINA = 2`, `TEAM_FROST = 3`.
- Names: `s_TeamNames[4] = { "iceman", "santa", "gina", "frost" }`.
- `pPlayer->pev->fuser4 = teamIdx (0..3)` while not carrying — overwritten to `RADAR_LOOT (16)` when carrying, restored to team idx on drop/death/score.
- `IsTeamplay()` returns `TRUE`. `PlayerRelationship` returns `GR_TEAMMATE` when `m_szTeamName` matches.

## Entities

### `loot_crate` (`CLootCrate`)
- `pev->classname = "loot_crate"`, `pev->fuser4 = RADAR_BASE_BLUE` (12).
- Solid breakable; `pev->health > 0` while alive, `pev->solid = SOLID_NOT` mid-break.
- One crate per round has `m_bHasLoot = TRUE` (server-only flag, NOT visible to bot DLL).

### `loot_entity` (`CLootEntity`)
- `pev->classname = "loot_entity"`, `pev->fuser4 = RADAR_LOOT` (16).
- Spawned only when the loot-bearing crate is destroyed.
- `MOVETYPE_TOSS` + `SOLID_TRIGGER`. `Touch` filters to `IsAlive() && m_bHoldingLoot == FALSE` and dispatches to `CaptureCharm`.
- Becomes invisible (`EF_NODRAW` + `SOLID_NOT`) while held — bots must skip those.

### `loot_goal` (`CLootGoal`)
- `pev->classname = "loot_goal"`, `pev->fuser4 = RADAR_BASE_RED` (13).
- `MOVETYPE_NONE`, `SOLID_TRIGGER`. Touch-filters to `m_bHoldingLoot == TRUE`.

## Cross-DLL Signals

| Signal | Set by | Read by | Meaning |
|---|---|---|---|
| `pPlayer->pev->fuser4 == RADAR_LOOT (16)` | `CaptureCharm` | bot DLL | This player IS the carrier. **Authoritative**. |
| `pPlayer->pev->fuser4 ∈ {0,1,2,3}` | `StartRound`, `DropCharm`, `OnGoalReached` | bot DLL | Player's team index when not carrying. |
| `pLootEntity->pev->effects & EF_NODRAW` | `CaptureCharm` | bot DLL | Loot is held; ignore the entity. |
| `pCrate->pev->solid == SOLID_NOT` | `CLootCrate::Killed` mid-break | bot DLL | Crate already broken; skip. |
| `m_bHoldingLoot` | server | server only | NOT exposed to bot DLL — must use fuser4. |
| `m_hLootHolder` | server | server only | NOT exposed to bot DLL — must scan players for fuser4 == 16. |

> **Important**: Loot players carry team-index 0..3 in `fuser4`. CTC's "fuser4 > 0" pattern is wrong here — bot code MUST compare against `RADAR_LOOT (16)` exactly.

## Bot AI Implementation (grave-bot-src)

### Files Modified
| File | What was added |
|------|---------------|
| `bot.h` | `LOOT_ROLE_*` enum (NONE/CARRIER/RECOVERER/ESCORT/GRABBER/BREAKER); `b_loot_has_loot`, `i_loot_role`, `f_loot_role_eval_time`, `f_loot_crate_target_time`, `i_loot_crate_target_index` fields |
| `bot_combat.cpp` | `RADAR_LOOT_VAL = 16`; tuning constants; per-frame entity cache (`s_pLootEntity`, `s_pLootGoal`, `s_loot_crates[]`); `BotLootFindEntities()`; `BotLootGetHolder()`; `BotLootPickNearestCrate()`; `BotLootPreUpdate()`; `BotLootThink()`; carrier-pacify branch in `BotFindEnemy`; removed `loot_crate` from the `BotAssessGrenades` exclusion list |
| `bot.cpp` | State init in `BotSpawnInit`; GAME_LOOT early-return in `BotFindItem`; `BotLootPreUpdate` calls in both `BotThink` PreUpdate clusters; GAME_LOOT branch in post-engage waypoint reset and pickup-clear; `BotLootThink` dispatch after Horde |
| `bot_func.h` | Declarations for `BotLootThink`, `BotLootPreUpdate` |

### Architecture
1. **Entity caching** (`BotLootFindEntities`): per-frame coalesced scan caches the `loot_entity`, `loot_goal`, and a vector of live crates (≤ `MAX_LOOT_CRATES = 32`). Held loot (`EF_NODRAW`) and dead crates (`SOLID_NOT` or `health <= 0`) are filtered out.
2. **Carrier detection** (`BotLootGetHolder`): scans clients for `pPlayer->pev->fuser4 == RADAR_LOOT_VAL`. Returns the holder edict or NULL.
3. **Crate pick caching** (`BotLootPickNearestCrate`): picks nearest live crate; caches the choice for `LOOT_CRATE_PICK_CADENCE = 0.75 s` to prevent thrashing.
4. **Pre-update** (`BotLootPreUpdate`): runs every frame before `BotFindEnemy`. Sets `b_loot_has_loot`, then pre-seeds `v_goal` based on the *current* role so movement still works on frames where enemy combat runs instead of `BotLootThink`.
5. **Role-based AI** (`BotLootThink`): re-evaluates role every `LOOT_ROLE_EVAL_CADENCE = 0.75 s`. Priority: CARRIER > RECOVERER > ESCORT > GRABBER > BREAKER. Each role sets `v_goal`, `f_move_speed`, `f_goal_proximity`. Returns `true` to suppress fallthrough.
6. **Carrier pacifism** (`BotFindEnemy`): if `health > 25` AND `pev->fuser4 == RADAR_LOOT_VAL`, the bot voids its enemy so it keeps running to the goal instead of dueling on the way. Mirrors CTC.
7. **Crates as targets** (`BotAssessGrenades`): `loot_crate` is intentionally NOT excluded from grenade-target scanning — bots opportunistically shoot crates that cross their line of sight. The `BREAKER` role also force-targets the picked crate when no enemy is set.

### Loot Bot Roles (Priority Order)
1. **CARRIER** — `b_loot_has_loot == TRUE` → run to `loot_goal`, suppress enemies above 25 HP, pickup-clear, `BotGoalElevatedJump` for raised goals.
2. **RECOVERER** — enemy holder exists → force-target the carrier when in LoS, run them down.
3. **ESCORT** — teammate holds loot → trail at a flank offset perpendicular to the carrier→goal vector (entindex-parity left/right split), proximity `LOOT_ESCORT_PROXIMITY = 128 u`.  Suppressed when sole-survivor on team.
4. **GRABBER** — `loot_entity` is loose in the world → run to grab it, bypass waypoint detours when visible.
5. **BREAKER** — default — pick nearest live `loot_crate`, walk to it, fire at it within `LOOT_BREAKER_FIRE_DIST = 1024 u` when visible and no enemy is engaged.

### Tuning Knobs (defined in `bot_combat.cpp`)
| Constant | Default | Purpose |
|---|---|---|
| `LOOT_ROLE_EVAL_CADENCE` | `0.75 s` | Throttle for role re-evaluation |
| `LOOT_CRATE_PICK_CADENCE` | `0.75 s` | Hysteresis for nearest-crate selection |
| `LOOT_CARRIER_PACIFY_HP` | `25.0` | Health floor below which carrier still defends |
| `LOOT_ESCORT_PROXIMITY` | `128.0 u` | Hard-trail radius for escorts |
| `LOOT_BREAKER_FIRE_DIST` | `1024.0 u` | Range at which BREAKER will shoot a crate |
| `MAX_LOOT_CRATES` | `32` | Cache size for live crates |

### State Cleared on Spawn (`BotSpawnInit`)
- `b_loot_has_loot = FALSE`
- `i_loot_role = LOOT_ROLE_NONE`
- `f_loot_role_eval_time = 0.0`
- `f_loot_crate_target_time = 0.0`
- `i_loot_crate_target_index = -1`

### `BotFindItem` GAME_LOOT Bypass
GAME_LOOT bots return early from `BotFindItem` (mirroring CTC) so the generic item-pickup heuristic does not detour them away from objective-driven `v_goal` targets. The `loot_entity` is reached via the `GRABBER` role's direct `v_goal` placement, not via item routing.

## Pitfalls & Lessons Learned
1. **`fuser4` is NOT a "is carrier?" boolean here**. All Loot players carry their team index `0..3` in `fuser4` outside of carry. Use `== RADAR_LOOT_VAL` exactly. CTC's "> 0" pattern would mistake every player for a carrier.
2. **`m_bHoldingLoot` and `m_hLootHolder` are server-side only** (CBasePlayer / CHalfLifeLoot members). The bot DLL must derive carrier status from `pev->fuser4 == RADAR_LOOT_VAL`.
3. **Held loot is invisible**: `loot_entity` gets `EF_NODRAW` while held. Filter on `pev->effects & EF_NODRAW` so bots don't path to a phantom entity.
4. **Mid-break crates are `SOLID_NOT`**: filter crates on `pev->solid != SOLID_NOT && pev->health > 0`.
5. **Round resets clear `fuser4` back to team index** (`StartRound` writes `plr->pev->fuser4 = t`). Holder detection is automatically reset between rounds — no per-round bookkeeping needed in the bot DLL.
6. **`v_goal` preservation**: `BotLootPreUpdate` always runs before the enemy branch and pre-seeds `v_goal` from the current role. Without this, frames where `BotLootThink` doesn't run (because `BotFindEnemy` consumed the slot) would leave `v_goal == g_vecZero` and the bot would idle.
7. **Role hysteresis**: re-evaluating roles every frame caused thrash when a teammate briefly lost LoS to the holder. Cadence of 0.75 s is short enough to feel responsive without chattering.
8. **BREAKER aggression**: pre-version, BREAKERs would walk past visible crates because `pBotEnemy` was always NULL (no players nearby). Solution: when no enemy is engaged AND the picked crate is visible within `LOOT_BREAKER_FIRE_DIST`, set `pBotEnemy = pCrate`. The grenade-target scan picks it up too via the un-exclusion in `BotAssessGrenades`.
9. **Carrier pacify threshold**: 25 HP is the same line CTC uses. Below that, the carrier engages defensively rather than running blindly into the goal trigger.
10. **`loot_entity` direct-steer**: when the loose loot is visible, `f_ignore_wpt_time` is bumped 0.5 s ahead so the bot's waypoint detour doesn't pull it past the entity on the final approach.

## Stuck-Game Resolutions (Iterative Defect Fixes)

The base 5-role design above is correct but exposed several deadlocks during live testing.  Each fix is implemented as a small, surgical addition rather than a redesign.

### 1. BREAKER — Synthetic-Enemy Injection
Bots reached a crate (`v_goal`-driven) but never fired because `BotLootThink` only sets `pBotEnemy = pCrate` in the no-enemy else-branch *after* the shoot block has already run.  Fix: in `bot.cpp` `BotThink`, immediately after `BotFindEnemy`, when role is BREAKER and no real enemy was found, set `pBotEnemy = BotLootFindBestVisibleCrate(pBot, 1024)`.  Also performs an LoS-priority swap: if the player enemy is currently occluded but a crate is visible, prefer the crate so the bot makes objective progress.

### 2. BREAKER — Walk-By Visible-Crate Engagement
The cached "nearest crate" pick can miss elevated/secondary crates.  `BotLootFindBestVisibleCrate(pBot, maxDist)` scans every live crate for the closest *visible* one within range (no `FInViewCone` gate — bots can fire at side/elevated crates as they pass).  Used by both the synthetic-enemy injection and the LoS-priority swap.

### 3. BREAKER — Elevated-Crate Goal Jump
Visible crates above the bot needed a multi-jump to reach.  Re-added `BotGoalElevatedJump` for crates only when `heightDiff > 32 && horzDist < 200` so it doesn't fire on ground crates (which previously caused weapon thrash on top of crates).

### 4. BREAKER — On-Top-of-Crate Dismount
**Root cause**: when the bot ends up standing on a crate, an eye-trace down to the crate origin clips the crate brush itself → `FVisible` returns false → both `BotShootAtEnemy`'s `IN_ATTACK` gate and the synthetic-enemy injection skip the crate.  Forcing the button without aim resolution produced wild swings at empty air.

**Fix**: `BotLootHandleOnTopOfCrate(pBot)` — called every frame from `BotThink` *before* the shoot block (NOT in the else-if chain).  When standing on the cached crate it dismounts:
- Compute a horizontal away-from-crate vector (or parity-based fallback if dead-center).
- Override `v_goal` to a point ~256 u along that vector with `f_goal_proximity = 0`.
- Force `ideal_yaw` toward away-direction so forward-motion translates correctly.
- `f_ignore_wpt_time = +1.5 s` so waypoint nav can't pull the bot back onto the crate.
- Press `IN_JUMP` only on the FIRST on-top frame (subsequent frames RUN — no bunny-hop).
- Add the crate to a per-bot ignore list (`i_loot_crate_ignore_index` + `f_loot_crate_ignore_until = +2.0 s`) and invalidate the cached pick.
- Both `BotLootPickNearestCrate` and `BotLootFindBestVisibleCrate` skip a crate matching the bot's active ignore entry.  After 2 s expires it can be re-targeted from ground level.

**Detection** (`BotLootIsOnTopOfCrate`): `groundentity == crate` OR (`FL_ONGROUND` + bot origin inside crate's `absmin/absmax` ± 16 u XY slop + feet-Z ≥ crate top − 12).  Bbox-based — handles non-cubic crates.

### 5. Crate Claim De-Confliction
Two bots routinely converged on the same crate, ended up stuck looking down at each other.  `BotLootCrateOccupiedByOtherBot(pCrate, pSelf)` scans `extern bot_t bots[32]` and returns true if any peer is currently `BotLootIsOnTopOfCrate` that crate.  Both crate pickers (`BotLootPickNearestCrate` and `BotLootFindBestVisibleCrate`) skip occupied crates (with a self-fallback if every crate is camped).

### 6. CARRIER — "Deposit Radius" Goal Priority
A low-HP carrier could engage combat instead of running for the score.  When `loot_goal` is visible within 1500 u, *unconditionally* clear `pBotEnemy` regardless of HP (the "deposit radius").  Outside that radius the original pacify-above-25-HP rule still applies, so a low-HP carrier still defends itself when the goal is far / occluded.

### 7. CARRIER — Anti-Blocker Stall Detection
Teammate parks in front of carrier → carrier just bumps into them.  Three new fields (`f_loot_carrier_stuck_since`, `f_loot_carrier_check_time`, `f_loot_carrier_last_dist`) sample distance-to-goal every 0.4 s.  If it hasn't decreased by ≥ 8 u, mark stalled.
- **0.6 s stall**: `IN_JUMP` + alternate strafe direction by entindex parity (so two adjacent stuck carriers peel apart instead of mirroring).
- **1.2 s stall + blocker in 80 u forward arc**: hand off to `BotGoalElevatedJump(..., true /*force*/)` for the multi-jump combo, then reset stall timers to give the combo a fair window.

### 8. ESCORT — Flank Offset (Carrier Pile-Up Fix)
Witnessed in 2-team endgame: carrier jumping in place against an escort that wasn't moving.  Root cause: `ESCORT` ran straight to `pHolder->v.origin`, stacking on top of the carrier.

**Fix** (both `BotLootPreUpdate` and `BotLootThink`): compute a flank offset perpendicular to the carrier→`loot_goal` vector (fallback: carrier's `v_angle`/`angles` via `MAKE_VECTORS`), split escorts left/right by entindex parity, with a slight backward bias.  Goal target = `holder.origin + side*96 - forward*32`.

> **`MAKE_VECTORS` requirement**: the fallback path MUST call `MAKE_VECTORS(pHolder->v.v_angle)` (with `pHolder->v.angles` as a secondary fallback when `v_angle` is all-zero, which happens for human players) before reading `gpGlobals->v_forward`.  Without this, `v_forward` is whatever was last set by another entity's call — usually stale and unrelated.  This was a real latent bug fixed by code review (commit `c38f2bd`).

### 9. ESCORT — Sole-Survivor Role Override
When an entire team is dead except one player whose role is `ESCORT` (or any defensive role), the bot would pace back-and-forth with nothing to defend.  In `BotLootThink`'s role-eval block, count living teammates (excluding self).  If `aliveMates == 0`, suppress `LOOT_ROLE_ESCORT` and fall through to `RECOVERER` / `GRABBER` / `BREAKER` (forward roles).  A lone survivor now picks up loose loot, chases enemy carriers, or hunts crates instead of pacing.

### 10. `BotFindWaypointGoal` — GAME_LOOT Case (Critical)
**Root cause of the "two bots pacing between two waypoints" stuck-game**: `BotLootPreUpdate` correctly set `v_goal`, but `BotFindWaypointGoal` had no GAME_LOOT case → `waypoint_goal` fell through to the generic tour/health waypoint picker.  The bot's *route* had nothing to do with the objective.

**Fix** (`bot_navigate.cpp`, mirroring the HORDE block): when `is_gameplay == GAME_LOOT` and `v_goal != g_vecZero`, find the waypoint nearest to `v_goal` (pure distance, team-filtered, skipping `W_FL_DELETED` / `W_FL_AIMING`) and return it as `wpt_goal_type = WPT_GOAL_LOCATION`.  Now CARRIER routes to `loot_goal`, BREAKER routes to its crate, GRABBER routes to loose loot, RECOVERER routes to enemy holder — all via real waypoint paths.

### 11. Misc Gating
- Combat-stuck-jump in `BotShootAtEnemy` is gated to `(FL_CLIENT | FL_MONSTER)` so it doesn't fire when the "enemy" is a crate (which has no `FL_CLIENT`).
- GAME_LOOT in `bot_navigate.cpp` waypoint-reset block: when `index != waypoint_goal`, snap `curr_waypoint_index` to nearest reachable so the bot doesn't walk to a stale waypoint before re-routing on a role flip.
- After combat (`b_engaging_enemy` falling false) GAME_LOOT clears `waypoint_goal`/`old_waypoint_goal`/`f_waypoint_goal_time` so the bot resumes loot objective rather than returning to a stale frag-chase waypoint.

### 12. New Bot State Fields (added incrementally)
| Field | Purpose |
|---|---|
| `f_loot_ontop_until` | (reserved) duck-attack window — currently unused after switch to dismount-only |
| `i_loot_crate_ignore_index` | crate entindex temporarily off-limits after dismount |
| `f_loot_crate_ignore_until` | expiry for the ignore (2 s post-dismount) |
| `f_loot_carrier_stuck_since` | carrier stall start time (0 = not stuck) |
| `f_loot_carrier_check_time` | next progress sample time |
| `f_loot_carrier_last_dist` | last sampled distance to `loot_goal` |

All fields zeroed in `BotSpawnInit`.

### 13. Frame Ordering (Critical)
The Loot AI is sensitive to call order in `BotThink`:
1. `pev->button = 0` reset
2. `BotLootPreUpdate` (seeds `v_goal`)
3. `BotFindEnemy`
4. **Synthetic-enemy injection** (player-priority + LoS swap + walk-by visible crate)
5. **`BotLootHandleOnTopOfCrate(pBot)`** — called BEFORE shoot block, NOT in else-if chain.  Returns true when it took control; ignored return value because the dismount overrides movement intent for the rest of the frame anyway.
6. Shoot block: `if (pBotEnemy != NULL) BotShootAtEnemy(...)`
7. else-branch: `BotLootThink`, `BotCtfThink`, etc.

Reordering any of these breaks at least one defect fix.

## Mutators Allowed
Inherits `MutatorAllowed` from `CHalfLifeLoot::MutatorAllowed` — see `loot_gamerules.cpp` for the explicit allow/block matrix.
