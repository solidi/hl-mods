# Busters Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_BUSTERS = 3` (defined in `common/const.h`)
- **String ID**: `"busters"` (mp_gamemode cvar)
- **Buster Count Cvar**: `mp_busterscount` (default 1, min 1, max 3; runtime-capped by active players)
- **Description**: `"Cold Ice Cold Busters"` — Reverse-deathmatch where the lowest-scoring player becomes "the Buster" with the egon and hunts everyone else.
- **Source**: `src/dlls/busters_gamerules.cpp`, `src/dlls/busters_gamerules.h`
- **Class**: `CMultiplayBusters : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (`BotBustersThink`, `BotBustersPreUpdate`, `BotBustersFindEntities`, `BotFindEnemy` Busters interactions), `grave-bot-src/dlls/bot.cpp` (spawn init, `BotFindItem` bypass for Buster role, think dispatch, direct-steer), `grave-bot-src/dlls/bot_navigate.cpp` (frequent re-routing, waypoint goal, snap, random-waypoint variance)
- **Summary line** (from `redist/modes/busters.txt`): *"A player with the least frags is granted the egon. Bust the skeletons. If the buster dies, the egon is up for grabs. If time passes without a new owner, it begins again."*

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, the cross-DLL `fuser4` / `RADAR_*` conventions, the [`v_goal` Preservation Contract](gamerules.md#critical--v_goal-preservation-contract), and the bot integration checklist that every mode (including Busters) must satisfy.

## Win Condition
- First player to reach `scorelimit` in `m_iRoundWins` wins. Checked each `Think()` tick in `busters_gamerules.cpp::Think` — calls `GoToIntermission()` when threshold crossed.
- Score tracked per-player via `m_iRoundWins` (NOT `pev->frags`; frags are used to pick the next Buster).

## Teams
- **Busters**: Team name `"busters"`, team index 1. Supports multiple live busters up to the dynamic target count (`mp_busterscount`, capped by the 2:1 ghost-to-buster ratio). Model forced to `frost` (blue HEV suit). `pev->fuser4 = RADAR_BUSTER`.
- **Ghosts**: Team name `"ghosts"`, team index 0. All other players. Model forced to `skeleton`. `pev->fuser4 = 0`.
- `IsTeamplay()` returns **TRUE**. The scoreboard and friendly-fire handling treat ghosts as a team, so ghosts cannot hurt each other when `friendlyfire` cvar is 0.
- `PlayerRelationship`: returns `GR_TEAMMATE` when both entities share the same non-empty `TeamID()` string, else `GR_NOTTEAMMATE`. With multi-buster enabled, buster-vs-buster counts as teammates (friendly-fire gated by `friendlyfire`).
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
| `m_flEgonBustingCheckTime` | float | Countdown before granting the next replacement egon when total egons (held + loose) are below target. `-1` = idle; else `gpGlobals->time + EGON_BUSTING_TIME` (10s) |
| `m_flCheckForWeapons` | float | Next tick (1s) to re-sync model/render for any player on the `"busters"` team who no longer holds the egon (handles stolen-weapon edge cases) |
| `m_flObjectiveUpdateTime` | float | Next per-mode objective HUD refresh (`gmsgObjective`). Runs at 1s cadence in `Think`; set to `0` to force immediate recompute next tick |

### Think (runs every server tick, not gated)
1. Early-out while `g_fGameOver`.
2. Calls `CheckForEgons()` (see below).
3. Runs objective HUD refresh when `m_flObjectiveUpdateTime <= gpGlobals->time`:
   - Calls `SendObjectiveUpdate()` (per-client `gmsgObjective` with role-aware heading and count-aware status line).
   - Re-arms timer to `now + 1.0f`.
4. Walks all live clients:
   - Resets `cam_buster` status icon after `m_fCameraDelay` expires.
   - Triggers intermission if any player's `m_iRoundWins >= scorelimit.value`.
   - Shows `gmsgBanner` "You are a Ghost / Defeat the buster..." to newly spawned non-bot players via `m_iShowGameModeMessage`.
5. Delegates to `CHalfLifeMultiplay::Think()`.

### Objective HUD (`SendObjectiveUpdate`, `BustersObjectiveStatusText`)
- Busters now mirrors CtC-style status reporting: objective text is recomputed from aggregate mode state (`playerCount`, `targetBusters`, `holderCount`, `looseCount`) instead of only one-off pickup/death broadcasts.
- Heading line is role-aware:
  - Spectator: `Watching Busters`
  - Buster: `You Are Busting!` (or `You Are The Buster!` when target is single)
  - Ghost: `Defeat the busters` (or `Defeat the buster` when target is single)
- Status line is count/plural aware:
  - Single-target mode: `<name> is busting!`, `The egon is free`, or `Selecting a buster...`
  - Multi-target mode: `%d of %d busters are busting.`, `%d of %d egons are free.`, or `Selecting busters...`
- Waiting state when insufficient players: `Busters waiting for players`.
- Broadcast style: per-client `MSG_ONE_UNRELIABLE` sends once per second (or sooner when forced), not a static global line.

### CheckForEgons (the core state machine)
1. **Every 1s** (`m_flCheckForWeapons`): for every player whose team is `"busters"` but who is NOT currently busting (lost the egon to a pickup by someone else), re-run `SetPlayerModel` to restore them to ghosts.
2. **Compute dynamic target** every tick:
  - `configured = clamp(mp_busterscount, 1..3)`
  - `target = min(configured, floor(playerCount / 3))` to enforce at least **2 ghosts per buster**.
  - If `playerCount < 3`, target is `0`.
3. **Count environment state**: `holderCount = players holding egon`, `looseCount = weaponboxes containing egon`, `totalEgons = holderCount + looseCount`.
4. **Trim overflow immediately** when `totalEgons > target`:
  - Remove loose egon weaponboxes first.
  - If still over, demote random holder(s) by removing `weapon_egon` and restoring ghost model/render state.
5. **Staggered refill** when `totalEgons < target`:
  - Arm `m_flEgonBustingCheckTime = now + EGON_BUSTING_TIME` (10s) if idle.
  - On expiry, grant one egon to a random lowest-frag eligible live player (`RemoveAllItems(false)` + `GiveNamedItem("weapon_egon")`).
  - If still below target, re-arm another 10s timer; otherwise clear timer (`-1`).

### PlayerGotWeapon (fired when any weapon is picked up)
If the weapon is the egon:
1. If holder cap is already reached (`holders >= target`), remove the weapon and `Kill()` it.
2. Reset `m_flEgonBustingCheckTime = -1`.
3. Broadcast "Long live the new Buster!", play `CLIENT_SOUND_PICKUPYOURWEAPON`, show `cam_buster` icon.
4. Set `m_flObjectiveUpdateTime = 0.0f` to force objective recompute on the next `Think` tick (important because this callback runs before egon ownership is fully committed in inventory).
5. **Promote `pev->fuser4 = RADAR_BUSTER` immediately**, then fire a radial purge blast (TE_EXPLOSION sprite + TE_BEAMCYLINDER halo) and `::RadiusDamage(origin, pPlayer->pev, pPlayer->pev, 500, 256, CLASS_NONE, DMG_BLAST | DMG_ALWAYSGIB, TRUE)` — clears any nearby ghosts crowding the new Buster on pickup.
6. Call `SetPlayerModel(pPlayer)` — changes team to `"busters"`, sets model to `frost`, re-asserts `fuser4 = RADAR_BUSTER`.
7. Fully heal to `max_health`, armor to 100, blue glow shell (`kRenderFxGlowShell`, (0, 75, 250), renderamt 25).
8. Force `m_iDefaultAmmo = 100` and refill the primary egon ammo slot.

> ⚠️ **Ordering is load-bearing.** `PlayerGotWeapon` is invoked from `CBasePlayer::AddPlayerItem` *before* the egon is inserted into `m_rgpPlayerItems`. That means `IsPlayerBusting()` returns FALSE for the duration of this callback, and `SetPlayerModel` will overwrite `fuser4` back to `0` if it runs before the radius damage. The blast block must (a) write `fuser4 = RADAR_BUSTER` itself, and (b) execute *before* `SetPlayerModel`, otherwise `FPlayerCanTakeDamage` rejects every hit as same-team friendly fire and the explosion does zero damage.

### PlayerKilled (Buster died)
1. Broadcasts center text with singular/plural awareness:
  - single-target: `The Buster is dead!!`
  - multi-target: `A Buster is dead!!`
2. Plays `CLIENT_SOUND_MASSACRE`.
3. Resets `m_flEgonBustingCheckTime = -1` (the timer will be re-armed on the next `CheckForEgons` call, giving ghosts a ~10s window to pick up the dropped egon).
4. Credits killer with `m_iRoundWins++` (suicide does not award a point).
5. Clears the victim's glow shell render state.
6. Delegates to `CHalfLifeMultiplay::PlayerKilled` which drops the Buster's inventory — producing the `weaponbox` containing `WEAPON_EGON` on the ground.
7. Immediately forces objective refresh (`m_flObjectiveUpdateTime = 0.0f; SendObjectiveUpdate();`) **after** base kill processing so holder/loose counts are accurate.

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
- `CanHaveNamedItem("weapon_egon")`: returns FALSE when dynamic target is `0` OR when total egons in environment (holders + loose) already meets/exceeds target.
- `CanHavePlayerAmmo`: Busters cannot pick up ammo.
- `IsAllowedToDropWeapon`: Busters cannot manually drop (the egon only leaves them on death).
- `WeaponShouldRespawn`: egon never respawns via the normal weapon recycler.
- `CanRandomizeWeapon`: egon excluded from the randomweapon mutator.
- `MutatorAllowed` blocks: `MUTATOR_RANDOMWEAPON`, `MUTATOR_INVISIBLE`, `MUTATOR_BUSTERS` (self), `MUTATOR_THIRDPERSON`.

### ClientDisconnected
- If a disconnecting player was busting, reset `m_flEgonBustingCheckTime = -1` and broadcast "The Buster disconnected!!" so `CheckForEgons` can refill any missing slot(s).

## Spectator Behavior

> Foundation: see the [Spectator System](gamerules.md#spectator-system) section in the hub document. Busters is **non-round-based** (`IsRoundBased()` not overridden → `FALSE`).

Busters uses the **standard FFA-style join flow**: connecting players land on the simple join menu, and `auto_join` is the action that commits them into play. Because Busters is FFA from the menu's perspective, only the simple menu (`OBS_UNDECIDED_SIMPLE`) is shown — there is no team-pick because the Buster role is assigned dynamically by lowest-frags scoring, not by player choice. Choosing `spectate` follows the hub spectator flow instead: the player remains an observer and does not commit/spawn until they later choose to join.

### Connection
- `ClientPutInServer` sets `iuser3 = OBS_UNDECIDED_SIMPLE` (Limbo — same for all multiplayer modes). `PlayerSpawn` gate branch 3 returns; player parks in `OBS_ROAMING` with the simple menu.
- Player issues `auto_join` → `m_iObserverWeapon = 2` → `ExitObserver()` → next `Spawn()` succeeds and `SetPlayerModel()` assigns them to `"ghosts"` team initially.
- Player issues `spectate` → remains in observer via the standard spectator system; no `ExitObserver()` commit and no spawn until they later choose `auto_join`.
- Bots auto-promote via the `FL_FAKECLIENT + iuser3 > 0` fast path.

### Mid-Match Death
- Standard FFA respawn: `FPlayerCanRespawn` returns `TRUE`. No force-to-spectator. Dead players just respawn at the next deathmatch start after the respawn timer.
- A new connection mid-match is treated identically to a connect at game-start: simple menu, then auto-join into ghost role.

### Buster Role Transitions Are Independent of Spectator State
Become-the-Buster is driven entirely by `CheckForEgons()` polling `pev->frags` (lowest fragger after a 10-second window). It does **not** call `ExitObserver` or touch `IsInArena` — those fields are not used in non-round-based modes. The role swap is just a `RemoveAllItems` + `GiveNamedItem("weapon_egon")` + `SetPlayerModel`.

### Pitfalls Specific to Busters
- **Don't gate Buster assignment on `IsInArena`** — it stays `FALSE` for the entire match in non-round-based modes. Use `IsAlive()` and `IsSpectator()` checks instead.
- **`spectate` console command is allowed.** Limbo + Chose-Spectate are always available regardless of `allow_spectators` cvar in any mode; for Busters specifically, mid-match a player who `spectate`s drops to `iuser3 = 0` and `OBS_ROAMING` — they're invisible to `CheckForEgons` because of the `IsAlive()` filter, so the Buster pool isn't disturbed.

## Key Constants
```cpp
#define EGON_BUSTING_TIME 10                // seconds the dropped egon stays up for grabs
// objective refresh cadence: 1.0s            // via m_flObjectiveUpdateTime / SendObjectiveUpdate
// cvar: mp_busterscount                     // desired buster count, clamped 1..3
// runtime cap: floor(playerCount / 3)       // enforces 2 ghosts per buster
// cvar: scorelimit                         // m_iRoundWins needed to win
// cvar: friendlyfire                       // if 0, ghosts cannot hurt each other
// RADAR_BUSTER                             // value written to Buster's pev->fuser4
```

## Key Detection Flags
| Check | Value | Meaning |
|-------|-------|---------|
| `pev->fuser4 == RADAR_BUSTER` | non-zero | Player is currently a Buster |
| `pev->fuser4 == 0` | 0 | Player is a ghost |
| `current_weapon.iId == VALVE_WEAPON_EGON` (bot-side) | int | Bot is holding the egon — authoritative self-check |
| `m_szTeamName == "busters"` vs `"ghosts"` | string | Team identity (also mirrored by `TeamID()`) |
| `weaponbox` with any child `pWeapon->m_iId == WEAPON_EGON` | entity | Dropped egon is loose on the map |
| Model keyvalue `frost` vs `skeleton` | string | Visual identity (set in `SetPlayerModel`) |

## Bot Behavior (grave-bot-src) — Current State

> Sections below describe current behavior as implemented. Aspirational ideas are explicitly called out as optional follow-ups.


### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Matches `"busters"` in `mp_gamemode` string OR `atoi == GAME_BUSTERS (3)`.
- Sets `is_gameplay = GAME_BUSTERS` and `is_team_play = TRUE` (ghosts are teammates).
- Without this entry all `GAME_BUSTERS` code paths are dead; bots default to FFA behavior.

### Team Detection (`util.cpp` — `UTIL_GetTeam`)
- For `GAME_BUSTERS`, returns `2` when `pEntity->v.fuser4 > 0` (Buster), else `1` (ghost). Bot team-filtering in `BotFindEnemy` already respects this split.

### Enemy Filtering (`bot_combat.cpp` — `BotFindEnemy`)
- Bots use the shared team filter path (`UTIL_GetTeam`) so ghosts skip ghosts and Buster-vs-ghost targeting works through normal enemy selection.
- There is no separate Busters-only `BotFindEnemy` fork; objective priority is driven by `BotBustersPreUpdate` + `BotBustersThink` via `v_goal` and role-specific movement intent.

### Combat Engagement (`bot_combat.cpp` — `BotShouldEngageEnemy`)
- Shared engagement checks still apply (ammo/visibility), but Busters role logic biases behavior:
- Buster role sets `i_engage_aggressiveness = 100`.
- Ghost hunter role clamps `i_engage_aggressiveness` to at least 85.

### Weapon Switching (`bot_combat.cpp` — `BotFireWeapon`)
- Buster inventory only contains the egon (gamerules-enforced), so `FShouldSwitchWeapon` has nothing to pick from. No changes needed beyond verifying `BotChangeWeapon` doesn't attempt to swap.

### Item Finding (`bot.cpp` — `BotFindItem`)
- Buster role: `BotFindItem` clears `pBotPickupItem` / `item_waypoint` immediately (cannot pick up non-egon items).
- Ghost role: still uses normal item scanning.
- During loose-egon windows (`s_pBusterWeaponbox` exists), `BotBustersThink` clears generic pickup detours so ghosts sprint objective-first to the dropped weaponbox.

### Pre-Update Block (`bot.cpp` — `BotThink`)
`BotBustersPreUpdate` runs every frame before enemy selection:
- Refreshes cached pointers for live Buster and dropped weaponbox.
- Pre-sets `v_goal`/`f_goal_proximity` for both Buster and ghost roles so movement has objective context even if the enemy branch claims the frame.
- Ghost hunter tracking now uses direct-track gating: refreshes immediate Buster position only when the Buster is visible or within close proximity; otherwise retains last-seen goal briefly.
- Resets egon-grab stuck sampling when no dropped weaponbox is active.

### Think Dispatch (`bot.cpp` — no-enemy branch)
`BotBustersThink(pBot)` is active in the no-enemy think chain (after `GAME_COLDSPOT`, before generic pickup fallback). It returns `true` when it has set movement intent, otherwise falls through to normal waypoint navigation.

### Navigation (`bot_navigate.cpp` — `BotFindWaypoint`)
Anti-stalemate tweak is active: for `GAME_BUSTERS`, random-waypoint chance is increased (40%) and cooldown is shortened (4s), reducing mirrored loop behavior.

### Waypoint Goal (`bot_navigate.cpp` — `BotFindWaypointGoal`)
`GAME_BUSTERS` is included in frequent goal recalculation. Routing follows `v_goal`: Buster hunts ghost-side objectives, ghost grabber routes to the loose weaponbox, and ghost hunter routes to direct-track or last-seen Buster targets.

### Bot Struct Fields (`bot.h` — `bot_t`) — State Fields
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

## Bot Behavior — Implementation Details (Current)

### BotBustersThink Priority (`bot_combat.cpp`)
| Case | Condition | Behavior |
|------|-----------|----------|
| 1 | `i_busters_role == BUSTERS_ROLE_BUSTER` | Hunt nearest ghost; set `v_goal` to that target, `f_goal_proximity = 64`, full speed, and force strong aggression (`i_engage_aggressiveness = 100`). Yaw is driven toward the active target during pursuit. |
| 2 | `i_busters_role == BUSTERS_ROLE_GHOST_GRABBER` | Sprint to the egon weaponbox: `v_goal = box.origin`, `f_goal_proximity = 20`, full speed, and apply `BotGoalElevatedJump` for ledge/pedestal grabs. |
| 3 | `i_busters_role == BUSTERS_ROLE_GHOST_HUNTER` | Pursue Buster with contextual tracking: direct-track when visible or close (<=300u); otherwise keep waypoint routing toward `v_busters_last_seen` for a short window (6s). Yaw is only hard-overridden during direct-track so unseen Busters do not stall waypoint movement. Aggressiveness clamped >= 85. |
| 4 | No role resolved | Return false — fall through to wander/deathmatch nav. |

### Pace & Juke (all roles, triggered in `BotBustersThink`)
- **Pace scale**: every 1.5–4s, `f_busters_pace_scale = RANDOM_FLOAT(0.65, 1.0)`; multiply into `f_move_speed` (not `f_max_speed`, to preserve strafing).
- **Evasive jukes** (when no enemy visible and moving):
  - 25% chance `IN_JUMP` for one frame.
  - 20% chance `IN_DUCK` for 0.3s (slide via `impulse 208` if `sv_botsmelee` is set and speed is high).
  - 15% chance short strafe burst (`IN_MOVELEFT` / `IN_MOVERIGHT`) for 0.25s.
- **Yaw discipline**: ghost hunters keep waypoint-driven yaw unless direct-track is active (visible or <=300u), preventing hidden-target face-lock stalls.

### Role Evaluation (`BotBustersPreUpdate`)
- Cadence: each frame (called from `BotThink` pre-update path).
- Direct-track helper (`BotBustersGhostHasDirectTrack`) gates immediate Buster tracking to `FVisible(...)` or <=300u proximity.
- Last-seen pursuit window is 6s (`BUSTERS_GHOST_LAST_SEEN_AGE`) so ghosts stay context-aware without pinning yaw to occluded/far Busters.

### Direct-Steer & v_goal Preservation (`bot.cpp`)
- `GAME_BUSTERS` is in the `v_goal` preservation exclusion list, so the always-forget-goal reset does not wipe objective targets each frame.
- `bustersChase` style direct-steer is active: when the goal is close or visible, movement can commit directly to `v_goal` instead of waypoint-only steering.

### Combat Tuning
- Buster: scale first-sight reaction delay by 0.4 and clamp to 0.5s max so egon reactions stay snappy.
- Ghost Hunter: forcibly raise `i_engage_aggressiveness` to max(85, current) for the duration of the role.
- All: leave existing `aim_tracking_*`, `pitch_speed`, `yaw_speed` arrays untouched — global skill remains the floor.

## Recent Implementation Notes & Lessons Learned

### Objective HUD refresh + plural state (`busters_gamerules.cpp::SendObjectiveUpdate`)
- Busters now updates `gmsgObjective` once per second from aggregate state (`targetBusters`, `holderCount`, `looseCount`) instead of relying on singular one-off broadcasts.
- Multi-buster reads mirror CtC's count-forward style: `X of Y busters are busting.` / `X of Y egons are free.`.
- `PlayerGotWeapon` sets `m_flObjectiveUpdateTime = 0.0f` (defer to next `Think`) because egon ownership has not fully committed yet in `AddPlayerItem`.
- `PlayerKilled` forces `SendObjectiveUpdate()` after `CHalfLifeMultiplay::PlayerKilled` so dropped-egon / holder counts are accurate in the same frame.

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

### Ghost hunter direct-track yaw guard (`bot_combat.cpp::BotBustersPreUpdate/BotBustersThink`)
- Added helper constants and gate:
  - `BUSTERS_GHOST_DIRECT_TRACK_DIST = 300.0f`
  - `BUSTERS_GHOST_LAST_SEEN_AGE = 6.0f`
- `BotBustersPreUpdate` and `BotBustersThink` now refresh live Buster goaling only when direct-track is true (visible or close); otherwise they preserve/use `v_busters_last_seen`.
- `ideal_yaw` override in ghost-hunter mode is now conditional on direct-track, which fixes the hidden-target face-lock that caused pauses and waypoint under-following.

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
1. **10-second staggered refill window.** Missing buster slots are replenished one-at-a-time every `EGON_BUSTING_TIME` (10s), but only while `totalEgons < target`. Ghost Grabber bots must be fast during loose-egon windows so the refill loop does not keep creating new holders.
2. **Lowest-fragger Buster rotation.** Because the Buster is the player with fewest frags, and ghost-on-Buster kills award +2 frags, a skilled ghost quickly becomes ineligible and the target rotates. Role/goal state must be refreshed every tick that possession changes so bots do not continue stale hunt behavior.
3. **Dropped-egon detection asymmetry.** `weapon_egon` classname never appears loose on the ground — the engine always wraps it in a `weaponbox`. Writing bot detection against the weapon classname silently fails. Always scan `weaponbox`.
4. **`fuser4` identity check for friendly fire.** Ghosts share `fuser4 == 0`, so `FPlayerCanTakeDamage` blocks their splash/projectile hits against each other when `friendlyfire` is off. Bot engagement must skip same-team players (already handled by `UTIL_GetTeam`), but explosive weapons (MP5 grenade, RPG) can still waste ammo via area effects — consider filtering secondary-fire usage for ghost hunters when teammates are in the blast radius.
5. **Buster inventory is locked.** `CanHavePlayerItem` returns FALSE for anything other than the egon. A Buster bot that tries to detour to a weapon/ammo pickup is wasting time — hence the `BotFindItem` early-out.
6. **Auto-switch on pickup.** `FShouldSwitchWeapon` always selects the egon on pickup, so the new-Buster bot will have the egon equipped before `BotBustersPreUpdate` next runs. The role eval must use `current_weapon.iId` for same-frame correctness.
7. **No `weapon_egon` respawn and no random-weapon spawn.** Egons only exist via holder drops and staggered refill grants, and can now exist in multiple copies up to the dynamic cap. Caching stale pointers beyond death/pickup/trim events is safe for a few ticks but must be re-validated before use.
8. **Team rewrite every frame.** `CheckForEgons` re-runs `SetPlayerModel` once per second for anyone stuck on the `"busters"` team without the egon. Bot logic keying off `m_szTeamName` may see stale values for up to one second after a drop — `pev->fuser4` and `current_weapon.iId` are more immediate.
9. **Intermission cleanup.** At `GoToIntermission`, gamerules do not explicitly clear the dropped weaponbox. Bots should not chase an egon once `g_fGameOver` (or the Busters-side equivalent) is signaled; guard the think dispatch against this.
10. **Two-bot stalemate.** Without per-bot pace variance and jukes, two bots running waypoint loops at `f_max_speed` never catch each other. The pace/juke/random-waypoint-boost triple is essential — single changes in isolation are insufficient.
11. **Distance-scaled reaction delay caused fake "pauses".** `BotShootAtEnemy` multiplies the base reaction delay (`react_time_min/max`, ~0.5–0.7s) by enemy distance, producing 2–3s freezes when Buster and ghost first spot each other across a room. Cap and shrink the multiplier in `GAME_BUSTERS` (`react_delay = RANDOM_FLOAT(min,max) * 0.4f` clamped at 0.5s, ~`bot_combat.cpp` L2390). Without this, gameplay reads as "the bots are paused".
12. **Player flip needs sustained forward velocity.** The triple-jump → flip in `CBasePlayer::Jump` only fires when `m_iJumpCount == 3 && velocity.Length2D() > 100`. A bot that sets IN_JUMP three frames in a row but doesn't keep pushing forward will get two rising hops and *never* the flip. The combo helper must re-assert `f_move_speed = f_max_speed` and forward-facing yaw every single frame between phases, exactly the way CTF flag pursuit does.
13. **Wall-yaw override fights the combo.** The Busters wall-mash override (face waypoint when an enemy is visible through a wall) is correct for routing, but during an active jump combo it cancels enemy-facing and collapses forward speed via `cos(yaw - waypoint_dir)`. Gate it on `pBot->i_goal_jump_phase == 0` so the combo can keep its enemy-facing velocity through phase 3.
