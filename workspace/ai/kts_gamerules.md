# Kick the Snowball (KTS) Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_KTS = 13` (defined in `common/const.h`)
- **String ID**: `"kts"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Kick the Snowball"` — team-based soccer with a snowball
- **Source**: `src/dlls/kts_gamerules.cpp`, `src/dlls/kts_gamerules.h`
- **Weapon Integration**: `src/dlls/gravitygun.cpp`
- **Class**: `CHalfLifeKickTheSnowball : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (BotKtsThink), `grave-bot-src/dlls/bot.cpp` (pre-update block, movement), `grave-bot-src/dlls/bot_navigate.cpp` (BotFindWaypointGoal KTS paths)

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, the cross-DLL `fuser4` / `RADAR_*` conventions, the [`v_goal` Preservation Contract](gamerules.md#critical--v_goal-preservation-contract), and the bot integration checklist that every mode (including KTS) must satisfy.

## Win Condition
- First team to reach `scorelimit` combined `m_iRoundWins` wins
- Score tracked as sum of all team members' `m_iRoundWins`
- Calls `GoToIntermission()` via `UpdateHud()` when threshold is reached

## Teams
- **Blue (Iceman)**: `TEAM_BLUE = 0`, `pev->fuser4 = 0`, model = `iceman`
- **Red (Santa)**: `TEAM_RED = 1`, `pev->fuser4 = 1`, model = `santa`
- `UTIL_GetTeam` returns: `1 = blue`, `2 = red` (1-indexed; differs from `TEAM_BLUE/TEAM_RED`)
- Auto-join balances team sizes; team change kills the player and respawns
- Only `iceman` and `santa` models allowed; enforced in `ClientUserInfoChanged`

## Spectator Behavior

> Foundation: see the [Spectator System](gamerules.md#spectator-system) section in the hub document. KTS is **non-round-based** (`IsRoundBased()` not overridden → `FALSE`).

KTS is **team-based + non-round-based**, same pattern as CTF and Cold Spot.

### Connection
- `ClientPutInServer` sets `iuser3 = OBS_UNDECIDED_SIMPLE`.
- Player issues `menu` → `iuser3 = OBS_UNDECIDED_BOTH` (team-aware menu).
- `auto_join` / `join_blue` / `join_red` commit through `ExitObserver()` and the base `PlayerSpawn` assigns model + team.
- `spectate` parks in `OBS_ROAMING`.
- Bots auto-promote via the `FL_FAKECLIENT + iuser3 > 0` fast path.

### Mid-Match — Dribbler Cleanup
The snowball entity caches its dribbler via `m_hDribbler` (an `EHANDLE`) and `pev->euser1` (raw edict pointer for cross-DLL bot reads). Both are cleared when:
- The dribbler dies (`PlayerKilled` → `DropCharm`).
- The dribbler disconnects (`ClientDisconnected` → `DropCharm` if they were the active dribbler).
- The dribbler issues `spectate` mid-match — `DropCharm` should be called from the spectate handler path; check `m_hDribbler == pPlayer` before letting `iuser3 = 0`.

### Pitfalls Specific to KTS
- **`pev->euser1` on the snowball must match `m_hDribbler`** — the dual storage is the cross-DLL bridge (bots read `euser1`, server reads `m_hDribbler`). Forgetting to clear `euser1` on dribbler-spectate leaves a stale pointer that bot code will read as "this player is still dribbling".
- **Goal-AABB check ignores spectators implicitly** because `m_hDribbler` is cleared when the dribbler enters spectator. But a `spectate` command path that *doesn't* go through `DropCharm` (custom handler regression) would let a dribbling spectator score by phasing through the goal AABB.

## Snowball Entity (`CKtsSnowball`, classname `"kts_snowball"`)
- **Model**: `models/w_weapons.mdl` (body = `WEAPON_SNOWBALL - 1`), scale 4.0
- **Sounds**: `ball_bounce.wav` (wall/floor impact), `dribble.wav` (looped while dribbling)
- **Physics**: `MOVETYPE_BOUNCE`, `SOLID_BBOX`, `DAMAGE_YES` (hp 9999), friction 0.2
- **Bbox**: `Vector(-12, -12, -12)` to `Vector(12, 12, 12)`
- **Radar**: `pev->fuser4 = RADAR_SNOWBALL`

### State Tracking
| Field | Type | Purpose |
|-------|------|---------|
| `m_hLastToucher` | EHANDLE | Last player who kicked/touched the ball (used for goal credit) |
| `m_hDribbler` | EHANDLE | Active dribbling player (NULL when loose) |
| `m_fDribbleSoundTime` | float | Next dribble sound emission time |
| `m_fLastThinkSpeed` | float | Ball speed cached at start of BallThink (pre-collision) |
| `m_fLastPlayerTouchTime` | float | Time of last player contact (idle reset clock) |
| `m_fStuckTime` | float | Time ball became motionless (-1 = not stuck) |
| `m_fBounceTime` | float | Debounce for bounce sound |
| `m_vLastContactVelocity` | Vector | Previous-tick velocity for ΔV bounce sound gating |
| `m_fNoAutoCaptureUntil` | float | Global no-auto-capture window after strip/release |
| `m_iNoRecaptureEntIndex` | int | Controller entity index blocked from immediate recapture |
| `m_fNoRecaptureUntil` | float | Expiry time for same-controller recapture block |
| `m_bWasGravityHeld` | BOOL | Transition flag: gravity-held in previous think tick |
| `pev->euser1` | edict_t* | Points to dribbler's edict (authoritative; used by bot code) |
| `pev->iuser1` | int | Forcegrab state: 0 = attract, 1 = repel |
| `pev->iuser2` | int | Gravity gun operator entity index (syncs last-toucher) |
| `pev->iuser3` | int | Gravity gun hold latch on the ball (1 = held, 0 = released) |
| `pev->owner` | edict_t* | Forcegrab owner (engine collision semantics — NOT used for dribble) |

### Ball States
1. **Loose** (`MOVETYPE_BOUNCE`, `SOLID_BBOX`, `m_hDribbler = NULL`): Normal bouncing physics. Players walk into it to kick or auto-acquire dribble.
2. **Dribbling** (`MOVETYPE_NOCLIP`, `SOLID_NOT`, `m_hDribbler != NULL`): Ball tracks ahead of dribbler via spring-damper system. `pev->euser1` set to dribbler's edict.
3. **Forcegrabbed** (`pev->owner != NULL`): Ball is pulled toward the grabbing player at 350 u/s. Auto-releases at 60u and slams in view direction at 1500 u/s.

### Gravity Gun Handoff (KTS-specific)
- If the player is dribbling (foot possession via `pev->euser1`) and taps **primary** or **secondary** with `weapon_gravitygun` while not already holding an entity, the ball is auto-promoted into gravity-gun hold even if not in trace/range checks.
- The handoff path explicitly calls `DropCharm` first, then marks the ball held by gravity gun (`pev->iuser3 = 1`) and stamps `pev->iuser2` with the holder entity index.
- While holding the KTS ball, **primary** behavior is unchanged: launch/fire away.
- While holding the KTS ball, tapping **secondary** returns the ball to foot possession by clearing hold state and calling `CaptureCharm` for the same player.
- While gravity-held (`pev->iuser3 != 0`), dribble/touch possession paths are suppressed entirely.
- On gravity-held -> loose transitions, anti-huddle repossession gates are applied before any auto-acquire can run (same parity as dribble release).
- This gives a deterministic flow: dribble -> tap (primary/secondary) -> gun-hold -> secondary -> back to dribble.

### Anti-Huddle Repossession Gates
- `KTS_STRIP_NEUTRAL_TIME` (0.35s): no player may auto-capture immediately after strip/release.
- `KTS_REACQUIRE_COOLDOWN_SAME_PLAYER` (0.60s): previous controller is blocked from instant recapture.
- Gates are enforced in both auto-acquire code paths (`BallThink` scan and `BallTouch` slow-ball capture).
- Gates are stamped by `DropCharm` and by gravity-held -> loose transitions to keep repossession parity.

### BallThink (runs every 0.1s)
1. Cache `m_fLastThinkSpeed` before collision modifies velocity
2. **Auto-acquire**: If no dribbler and no forcegrab, and speed < `KTS_DRIBBLE_ACQUIRE_SPEED`, find nearest eligible player within `KTS_DRIBBLE_ACQUIRE_DIST` (72u) and pass repossession gates → `CaptureCharm`
3. **Dribble maintain**: Track ball ahead of dribbler via spring-damper (`springSpeed = tdist * 18.0f`, capped at `KTS_DRIBBLE_TRACK_SPEED` 600 u/s), 50% player velocity feed-forward
4. **Anti-huddle dribble rule**: passive overlap no longer strips dribble; release is explicit
5. **Kick detection**: If `m_fKickEndTime > gpGlobals->time` or player is sliding → fire ball in clamped view direction at `KTS_FORCE_TOUCH` (600) or `KTS_FORCE_SLIDE` (900)
6. **Dribble-to-goal AABB check**: Manually checks ball origin against red/blue goal `absmin/absmax` (since `MOVETYPE_NOCLIP` skips trigger touches) → `OnGoalScored`
7. **Dribble distance break**: If ball > 128u from target position → `DropCharm`
8. **Forcegrab logic**: Attract at 350 u/s; repel at 1500 u/s in view direction
9. **Reset checks**: Falls below `KTS_FALLING_Z_LIMIT` (-4096) → reset; idle > `KTS_IDLE_RESET_TIME` (20s) → reset; stuck > `KTS_STUCK_TIMEOUT` (3s) → reset

### BallTouch (player contact)
- **Non-player**: Bounce sound if ΔV > 120 (debounced 0.2s)
- **Player while dribbled**: ignored for possession transfer (anti-huddle); dribbler release is explicit
- **Slow ball** (`m_fLastThinkSpeed < KTS_DRIBBLE_ACQUIRE_SPEED` 350 u/s): Auto-acquire only if repossession gates allow it
- **Fast ball**: Kick — direction = normalized(ball-player) blended with 75% player movement direction + upward tilt. Force = `KTS_FORCE_SLIDE` (900) if sliding, else `KTS_FORCE_TOUCH` (600)

### TakeDamage (weapon/explosion hits)
- Breaks active dribble (`DropCharm`)
- Bullets: `flDamage * KTS_FORCE_BULLET_MULT` (20) ≈ 160 per 9mm
- Explosions/melee: `flDamage * KTS_FORCE_DAMAGE_MULT` (3) ≈ 300 for rocket
- Direction: away from inflictor origin

### ResetToMidpoint
- Drops dribble, clears all state
- Finds safe spawn near midpoint between goals (uses `FindSafeBallSpawn` — nearest `info_player_deathmatch`, `weapon_*`, or `ammo_*` entity)
- Broadcasts "Ball reset to mid field!" if ball moved > 128u

## Goal Entity (`CKtsGoal`, classname `"kts_goal"`)
- **Model**: `models/teleporter_orange_rings.mdl` (animated, translucent)
- **Trigger bbox**: `Vector(-32, -32, -72)` to `Vector(32, 32, 72)` — 64w × 64d × 144h (symmetric)
- **Team**: `pev->body` — `0 = TEAM_BLUE`, `1 = TEAM_RED`
- **Radar**: `RADAR_BASE_RED` or `RADAR_BASE_BLUE` via `pev->fuser4`
- **Scoring**: Ball enters goal → OPPOSING team scores (blue bot scores in red goal, red bot in blue goal)

### GoalTouch
- Only fires for `kts_snowball` that matches the active `pBall` pointer
- Delegates to `OnGoalScored(opposingTeam, ball)`

### Dual scoring paths
1. **GoalTouch**: Engine trigger touch for `MOVETYPE_BOUNCE` ball (kicked/loose)
2. **BallThink AABB check**: Manual check every 0.1s for `MOVETYPE_NOCLIP` ball (dribbled)

## Gamerules Class (`CHalfLifeKickTheSnowball`)

### Key Members
| Field | Type | Purpose |
|-------|------|---------|
| `pRedGoal` | EHANDLE | Red goal entity |
| `pBlueGoal` | EHANDLE | Blue goal entity |
| `pBall` | EHANDLE | Active snowball (NULL between goal and respawn) |
| `m_fBallRespawnTime` | float | Scheduled ball respawn time (-1 = not pending) |
| `m_iBlueScore` / `m_iRedScore` | int | Cached team scores |
| `m_iBlueMode` / `m_iRedMode` | int | HUD mode flags for CtfInfo message |
| `m_DisableDeathPenalty` | BOOL | Suppresses PlayerKilled during team-change kill |

### CaptureCharm (begin dribble)
1. Show `cam_dribble` status icon
2. Play `CLIENT_SOUND_LEVEL_UP`
3. Set `m_hDribbler`, `pev->euser1 = ENT(pPlayer->pev)`
4. Switch ball to `MOVETYPE_NOCLIP`, `SOLID_NOT`
5. Snap ball to dribble position ahead of player (trace-down for slope)
6. Block auto-melee for 300s

### DropCharm (end dribble)
1. Clear `m_hDribbler`, `pev->euser1 = NULL`
2. Stop dribble sound
3. Restore `MOVETYPE_BOUNCE`, `SOLID_BBOX`
4. Lift origin +20u to prevent floor embedding
5. Zero velocity (callers apply push separately)
6. Resume auto-melee after 3s

### OnGoalScored
1. Play `CLIENT_SOUND_GOL`
2. Identify scorer (last toucher on scoring team) vs own-goal
3. Drop active dribble
4. Remove ball entity, set `pBall = NULL`
5. Award 1 `m_iRoundWins` to all scoring team members; bonus +1 to the scorer
6. Celebrate animation for scoring team
7. Banner: "GOAL! {Team} Team Scores!"
8. Schedule ball respawn (`KTS_BALL_RESPAWN_DELAY` = 6s)
9. UpdateHud → check scorelimit → GoToIntermission if reached

### Think (per-frame)
- Spawn goals from configured spawn points (`ktsspawn1`/`ktsspawn2` cvars) with 2s retry
- Goals replace the spawn point entity (set SOLID_NOT, EF_NODRAW)
- Spawn ball at midpoint once both goals exist
- Handle scheduled ball respawn after goal

### PlayerKilled
- If inflictor is `kts_snowball`: resolve kill credit from `m_hLastToucher`
  - Enemy last-toucher → they get the kill
  - Same team or self → self-kill
- Otherwise delegates to `CHalfLifeMultiplay::PlayerKilled`

### FPlayerCanTakeDamage
- Returns `TRUE` for `trigger_hurt` (void/pit/kill-brush map hazards)
- Returns `FALSE` for all other attackers (players can't be damaged by weapons directly)
- Side-effect on blocked non-`trigger_hurt` damage attempts: if the victim is dribbling, calls `DropCharm` only for valid strip attackers
- Same-team strip attempts are blocked (teammates cannot break dribble possession by damage path)

### FPlayerTookDamage
- If victim is dribbling → `DropCharm` + push ball away from attacker
- Same-team strip attempts are blocked here as well (enemy-only explicit strip rule)

### Spawn/Weapons
- Players spawn with `weapon_fists` and `weapon_gravitygun` only
- `CanHaveNamedItem` restricts to these two weapons
- `DeadPlayerWeapons` / `DeadPlayerAmmo` return 0 (no drops)
- Rune spawns blocked
- Third-person mutator blocked
- Spawn points within 1024u of a `kts_goal` are excluded

## Key Constants
```cpp
#define TEAM_BLUE 0
#define TEAM_RED  1

// Ball damage
#define KTS_DAMAGE_MIN_SPEED  150.0f
#define KTS_DAMAGE_SCALE      (200.0f / 150.0f)

// Ball force
#define KTS_FORCE_TOUCH       600.0f    // walk kick
#define KTS_FORCE_SLIDE       900.0f    // slide kick
#define KTS_FORCE_DAMAGE_MULT 3.0f      // explosion/melee → force
#define KTS_FORCE_BULLET_MULT 20.0f     // bullet → force

// Ball reset
#define KTS_STUCK_TIMEOUT     3.0f      // motionless seconds before reset
#define KTS_IDLE_RESET_TIME   20.0f     // no-contact seconds before reset
#define KTS_FALLING_Z_LIMIT   -4096.0f  // z below which ball resets

// Ball respawn
#define KTS_BALL_RESPAWN_DELAY 6.0f     // seconds after goal before new ball

// Dribble system
#define KTS_DRIBBLE_ACQUIRE_SPEED  350.0f  // max ball speed to auto-acquire
#define KTS_DRIBBLE_ACQUIRE_DIST   72.0f   // proximity for auto-acquire / tackle
#define KTS_DRIBBLE_BALL_OFFSET    64.0f   // distance ahead of player
#define KTS_DRIBBLE_TRACK_SPEED    600.0f  // spring-damper velocity cap
#define KTS_DRIBBLE_LOSE_DV        200.0f  // geometry ΔV that breaks dribble

// Anti-huddle repossession
#define KTS_STRIP_NEUTRAL_TIME             0.35f  // global no-auto-capture after strip/release
#define KTS_REACQUIRE_COOLDOWN_SAME_PLAYER 0.60f  // previous controller cannot instantly recapture
```

## Bot Behavior (grave-bot-src)

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"kts"` via `strstr` or `atoi == GAME_KTS`
- Sets `is_team_play = TRUE`
- Sets `is_gameplay = GAME_KTS`
- **CRITICAL**: Without this entry, `is_gameplay` stays at 0 (default FFA), and ALL `GAME_KTS` checks in bot code are dead. Every game mode MUST have a corresponding entry in `BotCheckTeamplay()` (`bot_combat.cpp`).

### Dribbler Identification
- `pev->euser1` on the snowball entity is the authoritative dribbler check
- `b_kts_has_ball` (per-bot bool) is set once per tick in the pre-update block: `pBall->v.euser1 == pEdict`
- Replaces old `pev->owner` usage which had engine collision side-effects

### BotKtsThink Priority (bot_combat.cpp)
| Case | Condition | Behavior |
|------|-----------|----------|
| 1 | `b_kts_has_ball` | Navigate to enemy goal; `v_goal = goal origin`; yaw override + direct-steer when close (< 300u) OR visible (`FVisible`); follow waypoints otherwise. Elevated-goal jump+kick and same-level stall+kick sequences when stuck near goal (see below) |
| 2 | Teammate dribbling | Escort/support instead of contesting ball: `v_goal` becomes a flank/lead support point around the carrier to reduce pile-ups and open the lane |
| 3 | Opponent dribbling | `v_goal = carrier`; if carrier is elevated and near in XY, try hook first then multi-jump recovery; deliberate close-range kick attempts (`impulse 206`) on cooldown for strip parity |
| 4 | Ball loose, < 120u | Face enemy goal and run into ball; if the loose ball is elevated and nearby, try hook/multi-jump recovery first |
| 5 | Ball loose, > 120u | `v_goal = ball`; face ball; waypoint routing via BotFindWaypointGoal; applies the same elevated-ball hook/multi-jump recovery |

### KTS Teammate Support (bot_combat.cpp)
- When `kts_snowball` is dribbled by an allied player (`movetype == MOVETYPE_NOCLIP`, `euser1` same team), non-carrier bots do not chase the ball.
- Support goal is computed from carrier-to-enemy-goal direction with lane splitting by bot entindex:
  - one lane leads slightly ahead,
  - two lanes flank left/right with slight trailing offset.
- If a supporter is crowding the carrier (<72u), it forces lateral separation to break body-block pile-ups.
- If the carrier is elevated, supporters may still use vertical recovery (hook/jump) to maintain support.

### KTS Vertical Recovery (bot_combat.cpp)
- Trigger window: objective is above the bot (`zDelta >= 48`) and horizontally near (`xyDist <= 384`).
- Order of actions: hook first on tall ledges (`zDelta >= 96`, via `BotConsiderHookForItem`), then fallback to `BotGoalElevatedJump` (double/triple jump phases).
- Traversal safety: recovery is skipped while standing on traversal waypoints (`W_FL_LADDER`, `W_FL_LIFT`, `W_FL_JUMP`, `W_FL_DUCKJUMP`, `W_FL_DOUBLEJUMP`) so ladder/lift/jump routing is not disrupted.
- Applied to both elevated carrier chase and elevated loose-ball chase.

### Bot Strip Parity Field (bot.h)
- `f_kts_tackle_attempt_time` throttles deliberate strip attempts while chasing enemy carrier.

### BotFindWaypointGoal KTS Paths (bot_navigate.cpp)
- **Dribbling**: Pure-distance search for nearest waypoint to enemy goal (no LOS requirement — goal entities often in recessed trigger volumes)
- **Teammate dribbling**: Pure-distance search for nearest waypoint to computed support/flank target around the allied carrier
- **Ball-chasing**: Pure-distance search for nearest waypoint to ball position (no LOS, no range cap) when ball is loose
- Both paths return explicitly — never fall through to tour/health waypoints
- Health waypoints only used if bot health < 25

### Movement Direction Block (bot.cpp)
- `ktsDirectSteer`: When dribbling and goal is close (< 300u) OR visible (`FVisible`) → bypass waypoints, steer directly at goal. The 300u distance fallback is needed because the `kts_goal` trigger origin often sits at floor level, causing eye-to-origin `FVisible` traces to clip geometry.
- `ktsBallChase`: When ball is loose and close (< 300u) OR visible → direct-steer toward ball. Same distance fallback rationale — ball at floor level clips `FVisible` traces.
- Both `ktsDirectSteer` and `ktsBallChase` set `bGoGoal = true`, which makes the movement direction block use `v_goal` instead of `curr_waypoint_index` for direction. This keeps `direction` aligned with `ideal_yaw` (set by BotKtsThink), preventing `cos(dgrad) ≈ 0` stalls.
- When neither condition: follow `curr_waypoint_index` via normal waypoint routing

### Waypoint Re-evaluation
- Runs every 0.5s in KTS (`f_waypoint_goal_time`)
- `curr_waypoint_index` reset via `WaypointFindReachable` only when ball-chasing AND `waypoint_goal` actually changes (prevents back-and-forth oscillation)
- Skipped entirely when dribbling (bot follows waypoint graph normally)

### Yaw Override (bot_navigate.cpp — BotHeadTowardWaypoint)
- When not dribbling (`!b_kts_has_ball`): skip waypoint-facing yaw — let BotKtsThink / movement block control yaw toward ball
- When dribbling: normal waypoint-facing yaw applies (BotKtsThink Case 1 overrides when close < 300u or goal is visible)

### Elevated-Goal Scoring (bot_combat.cpp — Case 1)
When the goal origin is > 36u above the bot and within 300u:
1. **Phase 1 — Jump attempts**: Bot jumps up to 3 times (0.6s cooldown) while running forward. If a jump carries the ball into the trigger volume, normal scoring fires.
2. **Phase 2 — Kick fallback**: After 3 failed jumps, bot backs up for 0.8s (reversed movement, aiming up at goal), then fires `impulse 206` (kick) to launch the ball upward.
3. **State reset**: Kick/jump state resets when the goal drops to the same level, when the kick fires, or when the bot loses the ball.

### Same-Level Stall Detection (bot_combat.cpp — Case 1)
When the goal is at the same level (< 36u height diff) and the bot stays within 100u for > 1.5s without scoring:
1. **Phase 1 — Walk in** (first 1.5s): Forces `f_move_speed = max` to push the bot through the trigger volume.
2. **Phase 2 — Kick fallback**: After 1.5s of lingering near the goal, bot enters the same back-up-and-kick sequence as the elevated-goal case.
Stall detection uses proximity duration (not instantaneous velocity) to handle oscillating/fidgeting bots that never reach 0 speed.

### Bot Fields for Goal Scoring (bot.h)
| Field | Type | Purpose |
|-------|------|---------|
| `b_kts_has_ball` | bool | Dribbler detection (set in pre-update block) |
| `f_kts_jump_time` | float | Next allowed jump attempt time |
| `i_kts_jump_count` | int | Consecutive jump attempts at current goal approach |
| `f_kts_kick_time` | float | Scheduled kick time (0.8s after entering kick sequence) |
| `b_kts_kick_pending` | bool | True while in the back-up-and-kick sequence |
| `f_kts_stall_time` | float | Time when the bot first entered the 100u stall zone |

### Team Mapping for Goals
- `UTIL_GetTeam` returns `1 = blue`, `2 = red`
- `kts_goal pev->body`: `0 = TEAM_BLUE`, `1 = TEAM_RED`
- Blue bot (team 1) scores in red goal (body == 1)
- Red bot (team 2) scores in blue goal (body == 0)
- Formula: `enemyGoalBody = (botTeam == 1) ? 1 : 0`

### Combat in KTS
- `BotFindEnemy`: When bot has ball → no enemies (focus on scoring). Otherwise only targets the active dribbler (`pev->euser1` check). Enemy cleared when they stop dribbling.
- Engage/disengage: KTS resets `waypoint_goal = -1` and `f_waypoint_goal_time = 0` instead of restoring `old_waypoint_goal`
- `BotFindItem`: Returns early in ALL KTS modes — clears `pBotPickupItem` and `item_waypoint`
