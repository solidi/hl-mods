# Capture The Flag (CTF) Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_CTF = 8` (defined in `common/const.h`)
- **String ID**: `"ctf"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Capture The Flag"` — team-based flag capture
- **Source**: `src/dlls/ctf_gamerules.cpp`, `src/dlls/ctf_gamerules.h`
- **Class**: `CHalfLifeCaptureTheFlag : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (BotCtfThink, BotCtfPreUpdate, BotCtfFindEntities, helpers), `bot.cpp` (dispatch, pre-update, direct-steer), `bot_navigate.cpp` (CTF waypoint routing), `bot.h` (CTF fields), `bot_func.h` (declarations)

## Win Condition
- First team to reach `scorelimit` combined `m_iRoundWins` wins
- Score tracked as sum of all team members' `m_iRoundWins`
- 1 point awarded per flag capture (player carries enemy flag to own base)
- Calls `GoToIntermission()` from `UpdateHud()` when threshold is reached

## Scoring Prerequisites
All three conditions must be true simultaneously:
1. Player is **touching their own base** (CFlagBase trigger)
2. Player is **carrying enemy flag** (`pPlayer->pFlag != NULL`)
3. Player's **own flag is at home** (`base->pev->iuser4 == TRUE`)

If condition 3 fails, player sees: `"Cannot score while flag is missing!"`

## Teams
- **Blue (Iceman)**: `TEAM_BLUE = 0`, `pev->fuser4 = 0`, model = `iceman`
- **Red (Santa)**: `TEAM_RED = 1`, `pev->fuser4 = 1`, model = `santa`
- `UTIL_GetTeam` returns: `1 = blue`, `2 = red` (1-indexed; differs from `TEAM_BLUE/TEAM_RED`)
- Auto-join balances team sizes; team change kills the player and respawns
- Only `iceman` and `santa` models allowed; enforced in `ClientUserInfoChanged`
- `IsTeamplay()` returns `TRUE`
- `PlayerRelationship`: `GR_TEAMMATE` if same team name, `GR_NOTTEAMMATE` otherwise
- `FPlayerCanTakeDamage`: blocked between teammates when `friendlyfire == 0`
- `ShouldAutoAim`: disabled against teammates

## Flag Entity (`CFlagCharm`, classname `"flag"`)
- **Model**: `models/flag.mdl`
- **Sound**: `rune_pickup.wav`
- **Physics**: `MOVETYPE_TOSS` (gravity; switches to `MOVETYPE_FOLLOW` when carried)
- **Initial solid**: `SOLID_NOT` for 0.25s, then transitions to `SOLID_TRIGGER` via `SolidThink`
- **Bbox** (when solid): `Vector(-16, -16, 0)` to `Vector(16, 16, 72)`
- **Rendering**: Glow shell (`kRenderFxGlowShell`, `renderamt = 5`)
  - Blue flag: `rendercolor = (0, 0, 255)`, `fuser4 = RADAR_FLAG_BLUE` (10)
  - Red flag: `rendercolor = (255, 0, 0)`, `fuser4 = RADAR_FLAG_RED` (11)
- **Lifetime**: Permanent — never removed, only repositioned

### State Tracking
| Field | Type | Purpose |
|-------|------|---------|
| `pev->aiment` | edict_t* | Player edict carrying the flag (NULL/0 when not carried) |
| `pev->fuser4` | float | Radar identifier: `RADAR_FLAG_BLUE` (10) or `RADAR_FLAG_RED` (11) |
| `pev->body` | int | Team owner: `TEAM_BLUE` (0) or `TEAM_RED` (1) |
| `pev->sequence` | int | Animation/state: `ON_GROUND` (0), `CARRIED` (2), `FLAG_POSITIONED` (4) |
| `m_fReturnTime` | float | Auto-return timer (gpGlobals->time + 30.0 when dropped; 0 when at base or carried) |

### Flag States
| Value | Name | Meaning |
|-------|------|---------|
| 0 | `ON_GROUND` | Dropped by carrier (on ground, awaiting return) |
| 1 | `NOT_CARRIED` | Unused in practice |
| 2 | `CARRIED` | Being carried by a player (`pev->aiment` set) |
| 3 | `WAVE_IDLE` | Unused in practice |
| 4 | `FLAG_POSITIONED` | At home base (default/reset state) |

### Pickup Mechanism (`FlagTouch`)
- Triggered when a player physically overlaps the flag entity (`SOLID_TRIGGER` touch)
- **Conditions**: Player must be alive, `m_fFlagTime < gpGlobals->time` (cooldown expired), no one else carrying this flag
- **Enemy flag pickup** (flag team != player team):
  1. `pev->aiment = pOther->edict()` — set carrier
  2. `pPlayer->pFlag = this` — mark player as flag holder
  3. `pev->movetype = MOVETYPE_FOLLOW` — flag follows player
  4. `pev->sequence = CARRIED`
  5. `m_fReturnTime = 0` — cancel auto-return
  6. `pMyBase->pev->iuser4 = FALSE` — mark that team's flag as NOT at home
  7. `CaptureCharm(pPlayer)` — shows `cam_flag` status icon
  8. Play `CLIENT_SOUND_CTF_TAKEN`
  9. HUD/objective broadcasts to all players
- **Same-team flag return** (flag team == player team, flag NOT at base):
  1. `pev->aiment = 0` — clear carrier
  2. `pev->movetype = MOVETYPE_TOSS`
  3. `pev->sequence = FLAG_POSITIONED`
  4. `UTIL_SetOrigin(pev, baseOrigin)` — instantly teleport flag to home base
  5. `pMyBase->pev->iuser4 = TRUE` — flag is home again
  6. Play `CLIENT_SOUND_NOPE`
  7. Print: `"%s flag returned by %s!"`
- **Cannot return while holding enemy flag**: If player already has a flag (`pPlayer->pFlag != NULL`), touching own team's dropped flag shows `"Cannot return while holding a flag!"` and sets 1.0s cooldown

### Auto-Return (`ReturnThink`, runs every 1.0s)
- If flag is not at base AND not carried: starts 30-second timer (`m_fReturnTime = gpGlobals->time + 30.0`)
- When timer expires: teleports flag to home base, resets `pMyBase->pev->iuser4 = TRUE`
- Timer resets to 0 whenever flag returns to base origin
- Plays `CLIENT_SOUND_EBELL`, prints `"%s flag returned to base!"`

## Flag Base Entity (`CFlagBase`, classname `"base"`)
- **Model**: `models/flagbase.mdl`
- **Physics**: `MOVETYPE_NONE`, `SOLID_TRIGGER`
- **Bbox**: `Vector(-32, -32, 0)` to `Vector(32, 32, 96)`
- **Radar**:
  - Blue base: `fuser4 = RADAR_BASE_BLUE` (12)
  - Red base: `fuser4 = RADAR_BASE_RED` (13)

### State Tracking
| Field | Type | Purpose |
|-------|------|---------|
| `pev->fuser4` | float | Radar identifier: `RADAR_BASE_BLUE` (12) or `RADAR_BASE_RED` (13) |
| `pev->body` | int | Team owner: `TEAM_BLUE` (0) or `TEAM_RED` (1) |
| `pev->iuser4` | int | **Flag-at-home boolean**: `TRUE` = flag is at base, `FALSE` = flag is taken/dropped |
| `m_fNextTouch` | float | Debounce for scoring touches (1.0s cooldown) |

### Scoring Touch (`CTFTouch`)
- Triggered when a player with a flag touches a base
- **Conditions**: Player must be alive, carrying an enemy flag (`pPlayer->pFlag != NULL`), `m_fFlagTime` cooldown expired
- **Flag check**: `pFlag->pev->fuser4 != (pev->fuser4 - 2)` — verifies carried flag is enemy flag
  - `RADAR_BASE_BLUE (12) - 2 = RADAR_FLAG_BLUE (10)` — blue base expects NON-blue flag
  - `RADAR_BASE_RED (13) - 2 = RADAR_FLAG_RED (11)` — red base expects NON-red flag
- **Own flag must be home**: `pev->iuser4 == TRUE`
- **Scoring steps**:
  1. Return captured flag to its home base (`UTIL_SetOrigin` to enemy base origin)
  2. `pFlag->pev->aiment = 0`, `pFlag->pev->sequence = FLAG_POSITIONED`
  3. `pPlayer->pFlag = NULL` — clear from player
  4. `pOtherBase->pev->iuser4 = TRUE` — enemy base flag restored
  5. `++pPlayer->m_iRoundWins` — award 1 point
  6. `pPlayer->Celebrate()` — celebration animation
  7. Play `CLIENT_SOUND_CTF_CAPTURE`
  8. Clear `cam_flag` status icon
  9. `UpdateHud()` — aggregate team scores — check `scorelimit` — `GoToIntermission()` if reached

## Gamerules Class (`CHalfLifeCaptureTheFlag`)

### Key Members
| Field | Type | Purpose |
|-------|------|---------|
| `pRedBase` | EHANDLE | Red base entity |
| `pBlueBase` | EHANDLE | Blue base entity |
| `m_fSpawnBlueHardware` | float | Scheduled blue base spawn time (-1 = already spawned) |
| `m_fSpawnRedHardware` | float | Scheduled red base spawn time (-1 = already spawned) |
| `m_iBlueScore` / `m_iRedScore` | int | Cached team scores (aggregated from `m_iRoundWins`) |
| `m_iBlueMode` / `m_iRedMode` | int | HUD mode flags for CtfInfo message (0=idle, 1=taken, 2=dropped, 3=carrying) |
| `m_DisableDeathPenalty` | BOOL | Suppresses PlayerKilled during team-change kill |

### Constructor
- Initializes all member variables
- Sets both hardware spawn timers to `gpGlobals->time + 2.0`
- Precaches `"flag"` and `"base"` entities

### Think (per-frame)
- Spawn blue flag + base from `ctfspawn1` cvar entity class (default `weapon_9mmAR`)
- Spawn red flag + base from `ctfspawn2` cvar entity class (default `weapon_shotgun`)
- Both spawn at picked entity position; spawn entity is hidden (`SOLID_NOT`, `EF_NODRAW`)
- Bases must be `ctfdistance` (default 512) units apart from each other
- Retries every 2.0s if spawn point not found

### CaptureCharm (player picks up flag)
- Shows `cam_flag` status icon to the carrier

### DropCharm (flag released on death/disconnect)
1. `pFlag->pev->movetype = MOVETYPE_TOSS` — enables gravity
2. `pFlag->pev->aiment = 0` — clear carrier reference
3. `pFlag->pev->sequence = ON_GROUND`
4. Drop at `origin.z -= 32` (below player)
5. `pPlayer->pFlag = NULL` — clear from player
6. `pPlayer->m_fFlagTime = gpGlobals->time + 0.25` — brief cooldown
7. Updates HUD mode to `2` (dropped) for the flag's team
8. Broadcasts objective update to all players

### PlayerKilled
- If `m_DisableDeathPenalty` is FALSE: delegates to `CHalfLifeMultiplay::PlayerKilled`
- Flag drop handled by caller (player.cpp calls `DropCharm` on death)

### ClientDisconnected
- If disconnecting player has flag: calls `DropCharm` at player's current origin

### UpdateHud
- Aggregates all players' `m_iRoundWins` by team to compute `m_iBlueScore` / `m_iRedScore`
- Broadcasts `gmsgCtfInfo` to all non-bot players
- HUD modes: `0` = idle (flag at base), `1` = taken (enemy has flag), `2` = dropped (flag on ground), `3` = carrying (sent to the carrier)
- Checks if either team's score >= `scorelimit` — `GoToIntermission()`

### Spawn Point Selection (`EntSelectSpawnPoint`)
- Searches for entities matching the cvar classname string
- Randomizes start index (1-5 iterations)
- Validates via `IsSpawnPointValid` — rejects if another `"base"` entity is within `ctfdistance` units

## Player CTF Fields (`CBasePlayer`)
| Field | Type | Purpose |
|-------|------|---------|
| `pFlag` | EHANDLE | Pointer to carried flag entity (NULL if not carrying) |
| `m_fFlagTime` | float | Cooldown timer for flag interactions |
| `m_fCelebrateTime` | float | Celebration animation timing |
| `pev->fuser4` | float | Player team: `TEAM_BLUE` (0) or `TEAM_RED` (1) |
| `m_szTeamName` | char[] | `"blue"` or `"red"` |
| `m_iRoundWins` | int | Individual capture count (aggregated into team score) |

### How to detect flag carrier (cross-DLL)
- **From flag entity**: `pFlag->v.aiment` — if non-null, that's the carrier's edict
- **From player entity**: Not directly accessible from bot DLL. Must scan flag entities.
- **Check if THIS bot carries flag**: Scan both flag entities, check `pFlag->v.aiment == pBot->pEdict`

## Key Constants
```cpp
#define TEAM_BLUE 0
#define TEAM_RED  1

#define RADAR_FLAG_BLUE    10    // pev->fuser4 on blue flag entity
#define RADAR_FLAG_RED     11    // pev->fuser4 on red flag entity
#define RADAR_BASE_BLUE    12    // pev->fuser4 on blue base entity
#define RADAR_BASE_RED     13    // pev->fuser4 on red base entity

// Cvars
// mp_ctfspawn1     default "weapon_9mmAR"    — entity class for blue base spawn point
// mp_ctfspawn2     default "weapon_shotgun"   — entity class for red base spawn point
// mp_ctfdistance   default "512"              — minimum distance between bases
// scorelimit                                  — captures needed to win
```

## Key Detection Flags
| Check | Value | Meaning |
|-------|-------|---------|
| `pFlag->v.aiment != 0` | edict_t* | Flag is being carried by that player |
| `pFlag->v.aiment == 0` | NULL | Flag is not carried (at base or on ground) |
| `pFlag->v.fuser4` | RADAR_FLAG_BLUE/RED | Which team's flag this is |
| `pFlag->v.sequence` | int | Flag animation state (ON_GROUND/CARRIED/FLAG_POSITIONED) |
| `pBase->v.iuser4 == TRUE` | int | Flag is at this base (required for scoring) |
| `pBase->v.iuser4 == FALSE` | int | Flag has been taken or is dropped |
| `pBase->v.fuser4` | RADAR_BASE_BLUE/RED | Which team's base this is |
| `pPlayer->v.fuser4` | TEAM_BLUE/TEAM_RED | Player's team (0 or 1) |

## Bot AI Implementation (grave-bot-src)

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"ctf"` via `strstr` or `atoi == GAME_CTF`
- Sets `is_team_play = TRUE`
- Sets `is_gameplay = GAME_CTF`
- **CRITICAL**: Without this entry, `is_gameplay` stays at 0 (default FFA), and ALL `GAME_CTF` checks in bot code are dead. Every game mode MUST have a corresponding entry in `BotCheckTeamplay()` (`bot_combat.cpp`).

### Files Modified
| File | What was added |
|------|---------------|
| `bot.h` | `CTF_ROLE_*` enum (NONE, CARRIER, RETRIEVER, ESCORT, DEFENDER, SEEKER); `b_ctf_has_flag`, `i_ctf_role`, `f_ctf_role_eval_time` fields; `i_goal_jump_phase`, `f_goal_jump_time`, `f_goal_jump_stall_time` multi-jump fields |
| `bot_combat.cpp` | `RADAR_*` defines; static entity cache (`s_pBlueFlag/RedFlag/BlueBase/RedBase`); `BotCtfFindEntities()`, team/enemy flag/base helpers; `BotCtfPreUpdate()`; `BotGoalElevatedJump()`; `BotCtfThink()` (role-based AI); CTF enemy-clearing block in `BotFindEnemy` |
| `bot.cpp` | State init in `BotSpawnInit` (all CTF + jump + `old_waypoint_goal` fields); CTF pre-update call; item bypass; dispatch chain hook; `v_goal` preservation; direct-steer condition (`ctfChase`) |
| `bot_navigate.cpp` | `GAME_CTF` branch in `BotFindWaypointGoal` (role-based waypoint routing); frequent recalc; waypoint reset on goal change |
| `bot_func.h` | Declarations for `BotCtfThink`, `BotCtfPreUpdate` |

### Architecture
1. **Entity caching** (`BotCtfFindEntities`): Per-frame scan caches both flag and both base entity pointers. Uses `gpGlobals->time` guard to scan once per frame. Safe across map changes — pointers are nulled before each re-scan.
2. **Pre-update** (`BotCtfPreUpdate`): Runs before `BotFindEnemy` every frame. Detects carrier status via `pFlag->v.aiment == pBot->pEdict`. Pre-sets `v_goal` based on current role so movement works even on frames where enemy combat runs instead of `BotCtfThink`.
3. **Role-based AI** (`BotCtfThink`): Evaluates role every 0.5s. Priority: CARRIER > RETRIEVER > ESCORT > DEFENDER > SEEKER. Each role sets `v_goal`, `f_move_speed`, `f_goal_proximity`, and yaw. Returns `true` to prevent fallthrough to generic nav.
4. **Waypoint routing** (`BotFindWaypointGoal` CTF branch): Finds nearest waypoint to `v_goal` by Euclidean distance. Bot follows pre-computed Floyd-Warshall shortest path waypoint-to-waypoint. On goal change, `curr_waypoint_index` is snapped to nearest reachable waypoint to prevent walking to stale waypoints.
5. **Direct-steer** (`ctfChase` in bot.cpp): Within 300 units of `v_goal`, bot switches from waypoint following to direct movement toward the goal. No `FVisible` requirement — flags/bases may be on platforms or behind minor geometry. Waypoint routing handles all long-distance pathfinding; direct-steer is only for the final approach.
6. **Multi-jump** (`BotGoalElevatedJump`): 3-phase jump sequence (ground → double → triple/flip) for elevated flags/bases. Height threshold 20u (above engine's 18u auto-step). Called by CARRIER, RETRIEVER, and SEEKER roles.

### Enemy Disengagement in CTF
- `BotFindEnemy` has a CTF-specific condition: the generic "not visible" handler runs for CTF even when `b_engaging_enemy` is TRUE (other modes skip it, causing infinite enemy lock).
- The engage re-lock (`if pNewEnemy == NULL && b_engaging_enemy ...`) excludes CTF, so the bot returns to objective play when enemies go out of sight.
- Bots remember the enemy for 2 seconds via `pRemember` (standard behavior), then clear and resume CTF routing.

### State Cleared on Spawn (`BotSpawnInit`)
All CTF and navigation state is reset on every spawn (including map change respawns):
- `b_ctf_has_flag`, `i_ctf_role`, `f_ctf_role_eval_time`
- `i_goal_jump_phase`, `f_goal_jump_time`, `f_goal_jump_stall_time`
- `v_goal`, `waypoint_goal`, `old_waypoint_goal`, `f_waypoint_goal_time`
- `pBotEnemy`, `b_engaging_enemy`, `f_bot_see_enemy_time`
- `bot_has_flag`

### CTF Bot Roles (Priority Order)
1. **CARRIER**: Bot carrying enemy flag → rush to own base to score
2. **RETRIEVER**: Own flag is dropped/stolen → touch it to return it (scoring is blocked without it)
3. **ESCORT/DEFENDER**: Teammate carrying flag → half escort carrier, half defend own base (split by edict index parity)
4. **SEEKER**: No other role applies → go grab enemy flag (default)

### Entity Scanning for Bots
```
Flag entities:  classname "flag",  pev->fuser4 = RADAR_FLAG_BLUE (10) or RADAR_FLAG_RED (11)
Base entities:  classname "base",  pev->fuser4 = RADAR_BASE_BLUE (12) or RADAR_BASE_RED (13)
```

**Team mapping (bot perspective)**:
- `UTIL_GetTeam(pEdict)` returns `1` (blue) or `2` (red)
- Bot team 1 (blue): own flag = `RADAR_FLAG_BLUE`, own base = `RADAR_BASE_BLUE`, enemy flag = `RADAR_FLAG_RED`, enemy base = `RADAR_BASE_RED`
- Bot team 2 (red): own flag = `RADAR_FLAG_RED`, own base = `RADAR_BASE_RED`, enemy flag = `RADAR_FLAG_BLUE`, enemy base = `RADAR_BASE_BLUE`

### Key Differences from CtC/KTS
- **Two flags**: CTF has TWO flag entities (one per team) vs one chumtoad/snowball. Must cache both.
- **Two bases**: Two base entities with scoring zones. Carrier must navigate to OWN base, not enemy's.
- **Carrier detection**: Via `pFlag->v.aiment` (flag entity points to carrier). Not via player's `pev->fuser4` (which is team ID, not flag status).
- **Flag return**: Same-team player touches dropped flag — instant return to base. Creates RETRIEVER role.
- **Scoring gate**: Can't score unless own flag is at home (`base->v.iuser4 == TRUE`). Creates DEFENDER role urgency.
- **No auto-drop**: Flag only drops on death/disconnect. No velocity or idle mechanic for dropping.
- **Team roles**: Multiple bots on same team should cooperate — carrier, escort, defender, retriever, seeker.

### Pitfalls & Lessons Learned
1. **`pev->fuser4` dual usage**: On PLAYERS, `fuser4` is team ID (0 or 1). On FLAGS, `fuser4` is radar type (10 or 11). On BASES, `fuser4` is radar type (12 or 13). Do not confuse these.
2. **Carrier detection is on the flag, not the player**: Bot DLL cannot access `pPlayer->pFlag` (server-side CBasePlayer member). Must scan flag entities and check `pFlag->v.aiment`.
3. **`SOLID_NOT` initial state**: Flags start as `SOLID_NOT` for 0.25s after creation/return. Don't filter them out in entity scans.
4. **Flag at base check**: `pBase->v.iuser4 == TRUE` is authoritative.
5. **Cannot return while carrying**: A player holding an enemy flag CANNOT return their own dropped flag. The retriever must be a non-carrier teammate.
6. **`v_goal` wipe**: `bot.cpp` has `pBot->v_goal = g_vecZero` ("always forget goal") that runs after think functions. CTF is in the exclusion list (same pattern as KTS/CTC/Coldskull).
7. **30-second auto-return**: Dropped flags return automatically after 30 seconds. Bot retriever urgency is bounded by this timer.
8. **Touch-based interactions**: Both flag pickup and base scoring require physical overlap (`SOLID_TRIGGER`). `f_goal_proximity` must be small enough (20-32u) to ensure the bot walks into the trigger volume.
9. **Team mapping offset**: `UTIL_GetTeam` returns 1-indexed (1=blue, 2=red) while `TEAM_BLUE=0`, `TEAM_RED=1`. Map carefully.
10. **`b_engaging_enemy` circular lock**: In the default bot code, `b_engaging_enemy` prevents the "not visible → clear after 2s" logic from firing, and `BotShouldEngageEnemy` almost never returns FALSE (weapon comparison is commented out). This creates an infinite enemy lock. CTF overrides this by allowing the not-visible handler to run regardless of `b_engaging_enemy`, and by excluding CTF from the re-lock guard.
11. **`old_waypoint_goal` must be cleared on spawn**: This field stores the bot's previous waypoint goal when engaging an enemy. If not reset, stale waypoint indices from a previous map can be restored after disengagement, sending the bot to an invalid waypoint. Now cleared in `BotSpawnInit`.
12. **Direct-steer must not require FVisible**: Flags/bases may sit on elevated platforms or behind minor geometry where an eye-level traceline fails. Using `FVisible` as a gate caused bots to pause at the last waypoint. The direct-steer condition now uses distance-only (< 300 units).
13. **Direct-steer must not fire at long range**: The original implementation used `(distance < 300 || FVisible)` which caused bots to steer directly into walls when the goal was visible from far away through gaps. Changed to distance-only with a 300u threshold so waypoint routing handles all long-distance navigation.
14. **Waypoint coverage matters**: If no waypoint exists near the flag/base, the bot may route to a distant waypoint and then struggle with the final approach. Ensure waypoints cover all approach routes close to scoring triggers.
15. **CTF enemy clearing must not reset navigation unconditionally**: An early implementation cleared `waypoint_goal` and `b_engaging_enemy` every frame when any enemy was not visible. This wiped navigation before the bot could take a step. The fix: only reset navigation state when `b_engaging_enemy` was actually TRUE (the deadlock case), not on every not-visible check.
16. **Floyd-Warshall routing was dead code**: `WaypointRouteFromTo` had a spurious check `pFromTo[team] == 0` that always triggered for team 0 (the default/fallback routing table). The check was meant to detect empty tables but read `from_to[0][0]` — the self-route from waypoint 0 to itself, which is always 0. This made ALL goal-directed waypoint routing return -1. FFA bots were unaffected (they wander via `BotFindWaypoint`), but CTF bots need Floyd routing to navigate to distant/hidden flags. Fix: removed the check; NULL checks above are sufficient.
17. **Waypoint index 0 was excluded from routing**: The route result check `i > 0` excluded waypoint 0 as a valid next hop. Changed to `i >= 0`.
18. **`v_goal` must be set before `BotHeadTowardWaypoint`**: `BotCtfPreUpdate` (which sets `v_goal`) ran at line 2046, after `BotHeadTowardWaypoint` at line 1845. On the first frame after spawn, `v_goal` was still `g_vecZero`, causing `BotFindWaypointGoal` to return -1 with a 0.5s cooldown — the bot wandered aimlessly for 0.5s. Fix: added an early `BotCtfPreUpdate` call before `BotHeadTowardWaypoint`.
19. **`f_waypoint_goal_time` 1-second spawn delay killed CTF routing**: `BotSpawnInit` set `f_waypoint_goal_time = gpGlobals->time + 1.0` — a 1-second delay before any waypoint goal could be selected. Without a goal, the bot wandered via random `BotFindWaypoint` hops. After engaging an enemy, the disengage reset set it to `0.0f`, which unlocked goal selection and made the bot appear to "wake up" after combat. Fix: changed to `f_waypoint_goal_time = 0.0` so goal selection fires immediately on the first frame.
20. **`BotGoalElevatedJump` height check reset mid-jump sequence**: The initial implementation checked `heightDiff < 20.0f` every frame, including during active jump phases. After the Phase 0 ground jump raised the bot's Z, `heightDiff` dropped below 20u, triggering a full state reset before Phase 1 (double-jump) could fire. Fix: the height/distance guard now only applies when `i_goal_jump_phase == 0` (starting a new sequence). Once in-progress (phases 1-2), the check is skipped and the sequence runs to completion.
21. **Proximity-based DEFENDER role caused bots to idle at spawn**: Priority 4 in role evaluation assigned `CTF_ROLE_DEFENDER` to any bot within 800u of its own base. Since spawns are typically near the base, the only bot would immediately become a defender (with `f_goal_proximity = 256.0f`), walk to the base, and idle there — never seeking the enemy flag. Fix: removed the proximity-based auto-defend; DEFENDER is now only assigned under Priority 3 (when a teammate carries the enemy flag, half escort and half defend).
22. **Multi-jump physics — dual systems**: The game has TWO parallel jump implementations. `CBasePlayer::Jump()` in the game DLL handles `m_iJumpCount` (1=ground, 2=double, 3=flip) using `m_afButtonPressed` rising-edge detection. `PM_Jump()` in `pm_shared.c` handles the shared physics with `pmove->iuser4` and `pmove->oldbuttons`. The bot must produce a button RELEASE between jump presses — the engine computes `m_afButtonPressed = (m_afButtonLast ^ pev->button) & pev->button`, so IN_JUMP must be absent for at least one frame between presses. The bot's `pEdict->v.button = 0` at the start of each frame naturally provides this release, so the 0.15s timer between phases is sufficient.

## Mutators Blocked
- `MUTATOR_THIRDPERSON` — blocked by `MutatorAllowed`
