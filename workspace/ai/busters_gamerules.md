# Busters Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_BUSTERS = 3` (defined in `common/const.h`)
- **String ID**: `"busters"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Cold Busters"` — Reverse-deathmatch where the lowest-scoring player becomes "the Buster" with the egon and hunts everyone else.
- **Source**: `src/dlls/busters_gamerules.cpp`, `src/dlls/busters_gamerules.h`
- **Class**: `CMultiplayBusters : public CHalfLifeMultiplay`
- **Bot Source** (planned): `grave-bot-src/dlls/bot_combat.cpp` (`BotBustersThink`, `BotBustersPreUpdate`, `BotBustersFindEntities`, `BotFindEnemy` Busters filters), `grave-bot-src/dlls/bot.cpp` (spawn init, `BotFindItem` bypass, think dispatch, direct-steer), `grave-bot-src/dlls/bot_navigate.cpp` (frequent re-routing, waypoint goal, snap, random-waypoint variance)
- **Summary line** (from `redist/modes/busters.txt`): *"A player with the least frags is granted the egon. Bust the skeletons. If the buster dies, the egon is up for grabs. If time passes without a new owner, it begins again."*

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, the cross-DLL `fuser4` / `RADAR_*` conventions, the [`v_goal` Preservation Contract](gamerules.md#critical--v_goal-preservation-contract), and the bot integration checklist that every mode (including Busters) must satisfy.

## Win Condition
- First player to reach `scorelimit` in `m_iRoundWins` wins. Checked each `Think()` tick in `busters_gamerules.cpp::Think` — calls `GoToIntermission()` when threshold crossed.
- Score tracked per-player via `m_iRoundWins` (NOT `pev->frags`; frags are used to pick the next Buster).

## Teams
- **Busters**: Team name `"busters"`, team index 1. Exactly one live player at a time (the current Buster). Model forced to `frost` (blue HEV suit). `pev->fuser4 = RADAR_BUSTER`.
- **Ghosts**: Team name `"ghosts"`, team index 0. All other players. Model forced to `skeleton`. `pev->fuser4 = 0`.
- `IsTeamplay()` returns **TRUE**. The scoreboard and friendly-fire handling treat ghosts as a team, so ghosts cannot hurt each other when `friendlyfire` cvar is 0.
- `PlayerRelationship`: returns `GR_TEAMMATE` when both entities share the same non-empty `TeamID()` string, else `GR_NOTTEAMMATE`. Since the Buster is the only member of "busters", buster-vs-ghost is always `GR_NOTTEAMMATE`.
- `FPlayerCanTakeDamage`: blocks damage when `pev->fuser4` matches between attacker and victim (i.e., both are ghosts), unless `friendlyfire` is enabled or it's self-damage. Buster (`fuser4 = RADAR_BUSTER`) vs any ghost (`fuser4 = 0`) always passes through.
- Team selection is automatic; no team menu. Teams are rewritten every frame via `SetPlayerModel` based on egon possession.

## Egon (the Buster's weapon)
- **Weapon id**: `WEAPON_EGON` (VALVE_WEAPON_EGON = 24 in bot code).
- **Classname when loose**: Egons drop as a `weaponbox` entity, not a raw `weapon_egon`. Bots must inspect weaponbox contents to identify a dropped egon (`CWeaponBox::m_rgpPlayerItems[]` → `pWeapon->m_iId == WEAPON_EGON`).
- **Respawn**: Blocked via `WeaponShouldRespawn` returning `GR_WEAPON_RESPAWN_NO`.
- **Randomization**: Blocked via `CanRandomizeWeapon` returning FALSE.
- **Auto-switch**: `FShouldSwitchWeapon` always returns TRUE for the egon — picking one up forces selection.
- **Ammo**: Buster starts with 100 egon cells (`m_iDefaultAmmo = 100`). The Buster cannot pick up ammo at all (`CanHavePlayerAmmo` returns FALSE for anyone with `fuser4 == RADAR_BUSTER`).

## Gamerules Class (`CMultiplayBusters`)

### Key Members
| Field | Type | Purpose |
|-------|------|---------|
| `m_flEgonBustingCheckTime` | float | Countdown before re-granting the egon when no Buster exists. `-1` = reset; else `gpGlobals->time + EGON_BUSTING_TIME` (10s) |
| `m_flCheckForWeapons` | float | Next tick (1s) to re-sync model/render for any player on the `"busters"` team who no longer holds the egon (handles stolen-weapon edge cases) |

### Think (runs every server tick, not gated)
1. Early-out while `g_fGameOver`.
2. Calls `CheckForEgons()` (see below).
3. Walks all live clients:
   - Resets `cam_buster` status icon after `m_fCameraDelay` expires.
   - Triggers intermission if any player's `m_iRoundWins >= scorelimit.value`.
   - Shows `gmsgBanner` "You are a Ghost / Defeat the buster..." to newly spawned non-bot players via `m_iShowGameModeMessage`.
4. Delegates to `CHalfLifeMultiplay::Think()`.

### CheckForEgons (the core state machine)
1. **Every 1s** (`m_flCheckForWeapons`): for every player whose team is `"busters"` but who is NOT currently busting (lost the egon to a pickup by someone else), re-run `SetPlayerModel` to restore them to ghosts.
2. **First call** after a Buster dies/disconnects: set `m_flEgonBustingCheckTime = gpGlobals->time + EGON_BUSTING_TIME` (10s) and return.
3. **When timer expires**:
   - If any player is already busting, return (timer stays cleared).
   - Walk all `weaponbox` entities; if any contain a `WEAPON_EGON`, return (the dropped egon is still up for grabs — don't create another).
   - Otherwise find all live players tied at the lowest `pev->frags`, random-pick one, `RemoveAllItems(false)`, set `fuser4 = RADAR_BUSTER`, `GiveNamedItem("weapon_egon")`.
   - Finally, walk `weaponbox` entities again and `Kill()` any containing the now-redundant egon.

### PlayerGotWeapon (fired when any weapon is picked up)
If the weapon is the egon:
1. If another player is already busting (double-grant race), remove the weapon and `Kill()` it.
2. Reset `m_flEgonBustingCheckTime = -1`.
3. Broadcast "Long live the new Buster!", play `CLIENT_SOUND_PICKUPYOURWEAPON`, show `cam_buster` icon.
4. **Promote `pev->fuser4 = RADAR_BUSTER` immediately**, then fire a radial purge blast (TE_EXPLOSION sprite + TE_BEAMCYLINDER halo) and `::RadiusDamage(origin, pPlayer->pev, pPlayer->pev, 500, 256, CLASS_NONE, DMG_BLAST | DMG_ALWAYSGIB, TRUE)` — clears any nearby ghosts crowding the new Buster on pickup.
5. Call `SetPlayerModel(pPlayer)` — changes team to `"busters"`, sets model to `frost`, re-asserts `fuser4 = RADAR_BUSTER`.
6. Fully heal to `max_health`, armor to 100, blue glow shell (`kRenderFxGlowShell`, (0, 75, 250), renderamt 25).
7. Force `m_iDefaultAmmo = 100` and refill the primary egon ammo slot.

> ⚠️ **Ordering is load-bearing.** `PlayerGotWeapon` is invoked from `CBasePlayer::AddPlayerItem` *before* the egon is inserted into `m_rgpPlayerItems`. That means `IsPlayerBusting()` returns FALSE for the duration of this callback, and `SetPlayerModel` will overwrite `fuser4` back to `0` if it runs before the radius damage. The blast block must (a) write `fuser4 = RADAR_BUSTER` itself, and (b) execute *before* `SetPlayerModel`, otherwise `FPlayerCanTakeDamage` rejects every hit as same-team friendly fire and the explosion does zero damage.

### PlayerKilled (Buster died)
1. Broadcasts "The Buster is dead!!" center-screen + `gmsgObjective` panel.
2. Plays `CLIENT_SOUND_MASSACRE`.
3. Resets `m_flEgonBustingCheckTime = -1` (the timer will be re-armed on the next `CheckForEgons` call, giving ghosts a ~10s window to pick up the dropped egon).
4. Credits killer with `m_iRoundWins++` (suicide does not award a point).
5. Clears the victim's glow shell render state.
6. Delegates to `CHalfLifeMultiplay::PlayerKilled` which drops the Buster's inventory — producing the `weaponbox` containing `WEAPON_EGON` on the ground.

### Scoring (`IPointsForKill`)
- Attacker is busting → returns **1** per ghost kill.
- Victim is busting → attacker earns **2**.
- Otherwise → **0** (ghost-on-ghost kills in friendly-fire mode award nothing).
- Note: `IPointsForKill` outputs are added to `pev->frags`, not `m_iRoundWins`. `m_iRoundWins` is only incremented directly in `PlayerKilled` when a ghost kills the Buster (and in `PlayerGotWeapon`? no — only `PlayerKilled`). **The score that ends the match is `m_iRoundWins`, so the primary progression is `ghost kills Buster → +1 win`.**

### DeathNotice
- Suppressed unless victim OR killer is the Buster — keeps the HUD obituary feed focused on objective kills.

### SetPlayerModel
- Called on spawn, userinfo change, and whenever `CheckForEgons` re-syncs state.
- Rewrites `pev->fuser4`, `m_szTeamName`, the user's `"model"` keyvalue, and broadcasts `gmsgTeamInfo` + `gmsgScoreInfo`.

### PlayerSpawn
- Delegates to base multiplay spawn; saves original model.
- For brand-new joiners (`iuser3 == 0`), assigns team `"ghosts"`, schedules the game-mode banner in 0.5s.
- Always calls `SetPlayerModel` to re-apply ghost/buster skin based on current egon possession.

### Weapon/Item/Mutator Restrictions
- `BustingCanHaveItem(pPlayer, pItem)`: returns FALSE when the player is busting AND the item classname begins with `weapon_` or `ammo_`. Wired through `CanHavePlayerItem` and `CanHaveItem`.
- `CanHaveNamedItem("weapon_egon")`: returns FALSE if anyone is already busting (prevents server-code-triggered double grants).
- `CanHavePlayerAmmo`: Busters cannot pick up ammo.
- `IsAllowedToDropWeapon`: Busters cannot manually drop (the egon only leaves them on death).
- `WeaponShouldRespawn`: egon never respawns via the normal weapon recycler.
- `CanRandomizeWeapon`: egon excluded from the randomweapon mutator.
- `MutatorAllowed` blocks: `MUTATOR_RANDOMWEAPON`, `MUTATOR_INVISIBLE`, `MUTATOR_BUSTERS` (self), `MUTATOR_THIRDPERSON`.

### ClientDisconnected
- If the disconnecting player was the Buster, reset `m_flEgonBustingCheckTime = -1` and broadcast "The Buster disconnected!!" so `CheckForEgons` re-grants immediately on next tick.

## Key Constants
```cpp
#define EGON_BUSTING_TIME 10                // seconds the dropped egon stays up for grabs
// cvar: scorelimit                         // m_iRoundWins needed to win
// cvar: friendlyfire                       // if 0, ghosts cannot hurt each other
// RADAR_BUSTER                             // value written to Buster's pev->fuser4
```

## Key Detection Flags
| Check | Value | Meaning |
|-------|-------|---------|
| `pev->fuser4 == RADAR_BUSTER` | non-zero | Player is the current Buster |
| `pev->fuser4 == 0` | 0 | Player is a ghost |
| `current_weapon.iId == VALVE_WEAPON_EGON` (bot-side) | int | Bot is holding the egon — authoritative self-check |
| `m_szTeamName == "busters"` vs `"ghosts"` | string | Team identity (also mirrored by `TeamID()`) |
| `weaponbox` with any child `pWeapon->m_iId == WEAPON_EGON` | entity | Dropped egon is loose on the map |
| Model keyvalue `frost` vs `skeleton` | string | Visual identity (set in `SetPlayerModel`) |

## Bot Behavior (grave-bot-src) — Current State

> Most items below labeled "Planned" have shipped. Where a section remains aspirational the label is preserved; everything else describes the working implementation as of the latest build.


### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Matches `"busters"` in `mp_gamemode` string OR `atoi == GAME_BUSTERS (3)`.
- Sets `is_gameplay = GAME_BUSTERS` and `is_team_play = TRUE` (ghosts are teammates).
- Without this entry all `GAME_BUSTERS` code paths are dead; bots default to FFA behavior.

### Team Detection (`util.cpp` — `UTIL_GetTeam`)
- For `GAME_BUSTERS`, returns `2` when `pEntity->v.fuser4 > 0` (Buster), else `1` (ghost). Bot team-filtering in `BotFindEnemy` already respects this split.

### Enemy Filtering (`bot_combat.cpp` — `BotFindEnemy`)
**Current**: No Busters-specific filters. Bots treat teammates (same `UTIL_GetTeam`) as non-targets but otherwise engage anyone visible like standard deathmatch.

**Planned filters**:
- Ghost bots should prioritize the Buster; other ghosts are filtered out as teammates (already works via `UTIL_GetTeam`).
- Buster bot should treat every visible ghost as a valid target and never disengage at long range while it has the egon.

### Combat Engagement (`bot_combat.cpp` — `BotShouldEngageEnemy`)
**Current**: Standard ammo/visibility checks.

**Planned**:
- Buster: always engage ghosts (no backing off). Optionally tighten the random-aggressiveness gate.
- Ghost Hunter: force `i_engage_aggressiveness` up to ≥85 while the Buster is the target to discourage timid bot wandering.

### Weapon Switching (`bot_combat.cpp` — `BotFireWeapon`)
- Buster inventory only contains the egon (gamerules-enforced), so `FShouldSwitchWeapon` has nothing to pick from. No changes needed beyond verifying `BotChangeWeapon` doesn't attempt to swap.

### Item Finding (`bot.cpp` — `BotFindItem`)
**Current**: Generic weapon/ammo scan. In Busters this is counterproductive for the Buster (who can't pick anything up) and misleading for ghosts (they should not detour to random ammo when they could be hunting).

**Planned**: Early gate on `is_gameplay == GAME_BUSTERS`:
- Buster role: always clear `pBotPickupItem` / `item_waypoint`.
- Ghost role: allow `item_health*` and `item_battery*` pickups only; skip all `weapon_*`/`ammo_*` unless the object is the dropped-egon weaponbox — which is surfaced through `BotBustersThink`, not `BotFindItem`.

### Pre-Update Block (`bot.cpp` — `BotThink`)
**Planned `BotBustersPreUpdate`** (mirrors `BotCtfPreUpdate`):
- Runs `BotBustersFindEntities` to refresh cached pointers: dropped-egon weaponbox, current Buster.
- Computes the bot's role every ~0.75s:
  - Has egon (`current_weapon.iId == VALVE_WEAPON_EGON`) → `BUSTERS_ROLE_BUSTER`.
  - Egon is loose AND bot is one of the two closest ghosts → `BUSTERS_ROLE_GHOST_GRABBER`.
  - Buster alive → `BUSTERS_ROLE_GHOST_HUNTER`.
  - None of the above (intermission, lull) → no role, fall through.
- Pre-sets `v_goal` so the movement block always has a target even when `BotFindEnemy` claims the frame.

### Think Dispatch (`bot.cpp` — no-enemy branch)
**Planned**: Insert `BotBustersThink(pBot)` in the else-if chain after the `GAME_COLDSPOT` branch and before the `pBotPickupItem` fallback (~`bot.cpp` L2257). Returns `true` when movement intent is set, `false` to fall through to normal waypoint nav.

### Navigation (`bot_navigate.cpp` — `BotFindWaypoint`)
**Planned anti-stalemate tweak**: when `is_gameplay == GAME_BUSTERS`, raise the random-waypoint chance from 20% to ~40% and shorten the cooldown from 10s to ~4s. Prevents the common "two bots run the same loop forever" scenario on small maps.

### Waypoint Goal (`bot_navigate.cpp` — `BotFindWaypointGoal`)
**Planned**: Add `GAME_BUSTERS` to the 0.5s recalculation set (alongside KTS/Coldskull/CTC). Buster hunts toward enemy-clustered waypoints; ghost grabber routes toward the weaponbox waypoint; ghost hunter routes toward the Buster's last-known location.

### Bot Struct Fields (`bot.h` — `bot_t`) — Planned Additions
| Field | Type | Purpose |
|-------|------|---------|
| `i_busters_role` | int | `BUSTERS_ROLE_NONE / _BUSTER / _GHOST_GRABBER / _GHOST_HUNTER` |
| `f_busters_role_eval_time` | float | Next role re-evaluation tick (~0.75s cadence) |
| `f_busters_egon_scan_time` | float | Next per-bot egon proximity re-score |
| `p_busters_egon_cache` | edict_t* | Last-seen dropped-egon weaponbox |
| `v_busters_last_seen` | Vector | Buster's last observed origin (for hunt fallback) |
| `f_busters_last_seen_time` | float | When `v_busters_last_seen` was captured |
| `f_busters_juke_time` | float | Next evasive jump/duck/strafe burst |
| `f_busters_pace_time` | float | Next time to re-roll pace scale |
| `f_busters_pace_scale` | float | 0.65–1.0 multiplier on `f_move_speed` for per-bot desync |

## Bot Behavior — Implementation Details (Planned)

### BotBustersThink Priority (`bot_combat.cpp`)
| Case | Condition | Behavior |
|------|-----------|----------|
| 1 | `i_busters_role == BUSTERS_ROLE_BUSTER` | Hunt: pick nearest visible ghost; set `v_goal = enemy.origin`, `f_goal_proximity = 64`, full speed. Force `pBotEnemy` when visible. Fall back to `BotFindWaypointGoal(WPT_GOAL_ENEMY)` when blind. Force `i_engage_aggressiveness = 100`. Skip pause. |
| 2 | `i_busters_role == BUSTERS_ROLE_GHOST_GRABBER` | Sprint to the egon weaponbox: `v_goal = box.origin`, `f_goal_proximity = 20`, full speed. Apply `BotGoalElevatedJump` when the box is on a ledge. Suppress combat inside 400u of the box. |
| 3 | `i_busters_role == BUSTERS_ROLE_GHOST_HUNTER` | Pursue Buster: `v_goal = buster.origin`, proximity 96. If Buster not visible, route via waypoints to `v_busters_last_seen`. Keep normal item pickup enabled (ghosts need guns). Aggressiveness clamped ≥ 85. |
| 4 | No role resolved | Return false — fall through to wander/deathmatch nav. |

### Pace & Juke (all roles, triggered in `BotBustersThink`)
- **Pace scale**: every 1.5–4s, `f_busters_pace_scale = RANDOM_FLOAT(0.65, 1.0)`; multiply into `f_move_speed` (not `f_max_speed`, to preserve strafing).
- **Evasive jukes** (when no enemy visible and moving):
  - 25% chance `IN_JUMP` for one frame.
  - 20% chance `IN_DUCK` for 0.3s (slide via `impulse 208` if `sv_botsmelee` is set and speed is high).
  - 15% chance short strafe burst (`IN_MOVELEFT` / `IN_MOVERIGHT`) for 0.25s.
- **Look-scan**: while steering toward `v_goal`, every 1–2s rotate `ideal_yaw` by ±15–30° for 0.3s so enemies approaching off-path get spotted.

### Role Evaluation (`BotBustersPreUpdate`)
- Cadence: `f_busters_role_eval_time = gpGlobals->time + 0.75` after each pass.
- Two-closest-ghosts rule for `GHOST_GRABBER`: iterate all ghost players, rank by distance to the cached egon weaponbox, pick top 2. Keeps the rest of the team from abandoning map control.
- If the dropped egon moves (unlikely but possible when physics nudge the box), the 0.5s `f_busters_egon_scan_time` re-scoring keeps `v_goal` fresh.

### Direct-Steer & v_goal Preservation (`bot.cpp`)
- Add `GAME_BUSTERS` to the exclusion list that currently protects KTS/Coldskull/CtC `v_goal` from the "always forget goal" reset.
- Add `bustersChase` style bool: when within 300u of `v_goal` with line of sight, steer directly (same pattern as CtC chasers, KTS seekers).

### Combat Tuning
- Buster: scale the new-enemy reaction delay by 0.75 so the egon beam locks on faster (`react_time_min/max` still apply, just shortened for this role).
- Ghost Hunter: forcibly raise `i_engage_aggressiveness` to max(85, current) for the duration of the role.
- All: leave existing `aim_tracking_*`, `pitch_speed`, `yaw_speed` arrays untouched — global skill remains the floor.

## Recent Implementation Notes & Lessons Learned

### Egon-pickup radial purge (`busters_gamerules.cpp::PlayerGotWeapon`)
- TE_EXPLOSION (`MSG_PAS`, `g_sModelIndexFireball` / `sprites/zerogxplode.spr`, scale 30, framerate 15, `TE_EXPLFLAG_NONE`) + TE_BEAMCYLINDER halo (`MSG_PVS`, `g_sModelLightning` / `sprites/lgtning.spr`, life 12, width 16, RGB 100/180/255, brightness 200, height z+256).
- `::RadiusDamage(vecBlast, pPlayer->pev, pPlayer->pev, 500.0f, 256.0f, CLASS_NONE, DMG_BLAST | DMG_ALWAYSGIB, TRUE)` — `inflictor == attacker == new Buster`, so self-damage is filtered by `FPlayerCanTakeDamage`.
- **Critical ordering**: `pPlayer->pev->fuser4 = RADAR_BUSTER;` must be assigned inside the blast block *before* `RadiusDamage`, and the entire blast block must run *before* `SetPlayerModel(pPlayer)`. Reason: `PlayerGotWeapon` fires from `CBasePlayer::AddPlayerItem` before the egon enters `m_rgpPlayerItems`, so `IsPlayerBusting()` returns FALSE; if `SetPlayerModel` runs first it rewrites `fuser4 = 0` and every blast hit is rejected as ghost-on-ghost friendly fire.

### Reaction-time pause fix (`bot_combat.cpp::BotShootAtEnemy` ~L2390)
- Symptom: Buster vs ghost first contact froze for ~2–3s.
- Root cause: shared `react_delay` formula scales the (already 0.5–0.7s) base delay by enemy distance.
- Fix: in `GAME_BUSTERS`, `react_delay = RANDOM_FLOAT(min,max) * 0.4f;` clamped to `<= 0.5f`.

### Multi-jump combo helper (`bot_combat.cpp::BotGoalElevatedJump`)
- Signature: `static bool BotGoalElevatedJump( bot_t *pBot, Vector vecGoal, bool bForceTrigger = false );`
- Phases (stored on `bot_t`: `i_goal_jump_phase`, `f_goal_jump_time`, `f_goal_jump_stall_time`):
  - Phase 0 → press IN_JUMP on the ground, advance to phase 1, schedule next press +0.15s.
  - Phase 1 → press IN_JUMP airborne (double-jump), advance to phase 2, +0.15s.
  - Phase 2 → press IN_JUMP airborne (triple-jump → flip), advance to phase 3, +1.0s cooldown.
  - Phase 3 → reset to phase 0 once cooldown elapses.
- Default mode (CTF flag pursuit / egon weaponbox pursuit): gated on `horzDist <= 300 && heightDiff >= 20` plus a 0.5s pre-wait so waypoint nav gets a chance.
- `bForceTrigger = true` (combat stuck-jump): bypasses the gate and the pre-wait. The caller is responsible for its own stall detector.
- **Every frame the combo is active**, the helper re-faces the goal and sets `f_move_speed = f_max_speed`. This is what makes the player flip on phase 3 — `CBasePlayer::Jump` requires `m_iJumpCount == 3 && velocity.Length2D() > 100`, and the player only reaches that velocity if the bot keeps pushing forward toward the goal between jump frames.
- Companion helper `BotGoalJumpPhaseTick(bot_t *)` exists for callers that want bare phase advancement without facing/speed re-assertion (currently unused; kept available for non-pursuit callers).

### Egon-grab stuck-jump (`bot_combat.cpp::BotBustersThink` Case 3, ~L1316)
- When pursuing the dropped egon weaponbox and horizontal distance hasn't shrunk for 1s on the ground: seed `f_goal_jump_stall_time = gpGlobals->time - 1.0f; pEdict->v.button |= IN_JUMP; i_goal_jump_phase = 1; f_goal_jump_time = gpGlobals->time + 0.15f;`. Subsequent calls to `BotGoalElevatedJump` (or `BotGoalJumpPhaseTick`) advance the combo.
- `BotBustersPreUpdate` (~L1131) clears `f_busters_stuck_check_time / f_busters_stuck_since` when `s_pBusterWeaponbox == NULL` so a future drop starts fresh.

### Combat stuck-jump (`bot_combat.cpp::BotShootAtEnemy` ~L3370)
- When `pBotEnemy` is visible at 80–512u and `horzDist` hasn't dropped 16u in 1s on the ground, hand off to the helper: `BotGoalElevatedJump(pBot, pBot->pBotEnemy->v.origin, true);`.
- Once `i_goal_jump_phase > 0`, the same branch re-invokes the helper every frame so the per-frame facing/max-speed assertion runs and phases 1→2→3 advance with the velocity required for the flip. This mirrors how CTF flag pursuit reliably clears ledges.

### Wall-mash yaw override (`bot_combat.cpp::BotShootAtEnemy` ~L3357)
- `GAME_BUSTERS`-only: when the bot has an enemy + a current waypoint + `!FHullClear(enemy, self)`, restore `ideal_yaw` from `v_curr_direction` so the bot keeps routing around the wall instead of grinding into it (the `cos(yaw - waypoint_dir)` factor in the movement code would otherwise collapse forward speed).
- **Gated on `pBot->i_goal_jump_phase == 0`** so an active combat stuck-jump combo can keep the enemy-facing velocity required for the phase-3 flip.

### Bot-struct fields used by the above (`bot.h::bot_t`, all initialized to `0.0f` in `BotSpawnInit`)
```cpp
float f_busters_stuck_check_time;   // egon weaponbox stall sampler
float f_busters_stuck_last_dist;
float f_busters_stuck_since;
float f_combat_stuck_check_time;    // combat enemy stall sampler
float f_combat_stuck_last_dist;
float f_combat_stuck_since;
```

### Sprite & globals reference
- `g_sModelIndexFireball` → `sprites/zerogxplode.spr` (precached in `weapons.cpp`).
- `g_sModelLightning` → `sprites/lgtning.spr` (precached in `weapons.cpp`).
- Bot button reset: `pEdict->v.button = 0;` runs every frame at `bot.cpp` ~L1707, which provides the IN_JUMP release edge between consecutive presses required by `FBitSet(m_afButtonPressed, IN_JUMP)` in `CBasePlayer::Jump`.

## Technical Notes
- **Dropped egon is in a weaponbox, not a raw `weapon_egon`**. `UTIL_FindEntityByClassname(..., "weapon_egon")` after the Buster's death will return NULL; scanning must iterate `weaponbox` entities and walk the `m_rgpPlayerItems[]` linked lists. Bot-side equivalent: iterate entities with classname `weaponbox`, read their weapon-id arrays via the shared engine interface, or fall back to a distance-based heuristic using the drop origin captured at kill time.
- **`RADAR_BUSTER` is the authoritative cross-DLL signal** (analogous to `RADAR_CHUMTOAD` in CtC). Prefer this over `m_szTeamName` string compares, which are set only on state transitions.
- **The Buster's self-check uses `current_weapon.iId == VALVE_WEAPON_EGON`** — more reliable than `fuser4` reads off the bot's own edict, because the bot DLL owns the weapon state struct directly.
- **All Busters fields initialized in `BotSpawnInit`** (`bot.cpp`): `i_busters_role = BUSTERS_ROLE_NONE`, all timers to `0.0f`, pointers to `NULL`, `f_busters_pace_scale = 1.0f`.
- **`MAKE_VECTORS` vs `UTIL_MakeVectors`** — same pitfall as CtC: bot DLL must use the engine callback macro.

## Key Pitfalls (Expected)
1. **10-second auto-regrant window.** If no ghost touches the dropped egon within `EGON_BUSTING_TIME`, it's removed and the current lowest-fragger becomes the new Buster. Ghost Grabber bots must be fast — `f_move_speed = f_max_speed`, no pause, elevated-jump helper for pedestals. Missing the window flips the role assignment unexpectedly.
2. **Lowest-fragger Buster rotation.** Because the Buster is the player with fewest frags, and ghost-on-Buster kills award +2 frags, a skilled ghost quickly becomes ineligible and the target rotates. Role re-evaluation must run every tick that possession changes, not just on the 0.75s timer, or the Buster bot could briefly try to hunt after losing the egon.
3. **Dropped-egon detection asymmetry.** `weapon_egon` classname never appears loose on the ground — the engine always wraps it in a `weaponbox`. Writing bot detection against the weapon classname silently fails. Always scan `weaponbox`.
4. **`fuser4` identity check for friendly fire.** Ghosts share `fuser4 == 0`, so `FPlayerCanTakeDamage` blocks their splash/projectile hits against each other when `friendlyfire` is off. Bot engagement must skip same-team players (already handled by `UTIL_GetTeam`), but explosive weapons (MP5 grenade, RPG) can still waste ammo via area effects — consider filtering secondary-fire usage for ghost hunters when teammates are in the blast radius.
5. **Buster inventory is locked.** `CanHavePlayerItem` returns FALSE for anything other than the egon. A Buster bot that tries to detour to a weapon/ammo pickup is wasting time — hence the `BotFindItem` early-out.
6. **Auto-switch on pickup.** `FShouldSwitchWeapon` always selects the egon on pickup, so the new-Buster bot will have the egon equipped before `BotBustersPreUpdate` next runs. The role eval must use `current_weapon.iId` for same-frame correctness.
7. **No `weapon_egon` respawn and no random-weapon spawn.** There is only ever *one* egon in play. The Buster-is-dead state is the only time it's loose. Caching stale pointers beyond a death/pickup event is safe for a few ticks but must be re-validated before use.
8. **Team rewrite every frame.** `CheckForEgons` re-runs `SetPlayerModel` once per second for anyone stuck on the `"busters"` team without the egon. Bot logic keying off `m_szTeamName` may see stale values for up to one second after a drop — `pev->fuser4` and `current_weapon.iId` are more immediate.
9. **Intermission cleanup.** At `GoToIntermission`, gamerules do not explicitly clear the dropped weaponbox. Bots should not chase an egon once `g_fGameOver` (or the Busters-side equivalent) is signaled; guard the think dispatch against this.
10. **Two-bot stalemate.** Without per-bot pace variance and jukes, two bots running waypoint loops at `f_max_speed` never catch each other. The pace/juke/random-waypoint-boost triple is essential — single changes in isolation are insufficient.
11. **Distance-scaled reaction delay caused fake "pauses".** `BotShootAtEnemy` multiplies the base reaction delay (`react_time_min/max`, ~0.5–0.7s) by enemy distance, producing 2–3s freezes when Buster and ghost first spot each other across a room. Cap and shrink the multiplier in `GAME_BUSTERS` (`react_delay = RANDOM_FLOAT(min,max) * 0.4f` clamped at 0.5s, ~`bot_combat.cpp` L2390). Without this, gameplay reads as "the bots are paused".
12. **Player flip needs sustained forward velocity.** The triple-jump → flip in `CBasePlayer::Jump` only fires when `m_iJumpCount == 3 && velocity.Length2D() > 100`. A bot that sets IN_JUMP three frames in a row but doesn't keep pushing forward will get two rising hops and *never* the flip. The combo helper must re-assert `f_move_speed = f_max_speed` and forward-facing yaw every single frame between phases, exactly the way CTF flag pursuit does.
13. **Wall-yaw override fights the combo.** The Busters wall-mash override (face waypoint when an enemy is visible through a wall) is correct for routing, but during an active jump combo it cancels enemy-facing and collapses forward speed via `cos(yaw - waypoint_dir)`. Gate it on `pBot->i_goal_jump_phase == 0` so the combo can keep its enemy-facing velocity through phase 3.
