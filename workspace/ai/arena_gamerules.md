# Arena (1 vs. 1) Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_ARENA = 1` (defined in `common/const.h`)
- **String ID**: `"arena"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Arena"` — 1v1 champion-defense duel
- **Source**: `src/dlls/arena_gamerules.cpp`, `src/dlls/arena_gamerules.h`
- **Class**: `CHalfLifeArena : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (BotArenaPreUpdate, BotArenaThink, BotCheckTeamplay registration, BotFindEnemy arena enhancements), `grave-bot-src/dlls/bot.cpp` (4-hook dispatch, death state cleanup, BotSpawnInit, BotFindItem bypass, arenaChase direct-steer, post-synthesis speed variation), `grave-bot-src/dlls/bot_navigate.cpp` (fast recalc, opponent-dead fallthrough, dead-end escape), `grave-bot-src/dlls/bot.h` (arena struct fields), `grave-bot-src/dlls/bot_func.h` (declarations)

## Win Condition
- First player to reach `roundfraglimit` frags wins the round
- If `roundtimelimit` expires, highest frag count wins; tied frags = draw (no champion)
- Winner becomes the **reigning champion** and defends against the next challenger
- Overall match ends after `roundlimit` total rounds (cvar); calls `GoToIntermission()`

## Scoring
- Standard frag-based scoring: kills increment `pev->frags`, suicides decrement
- Score tracked via `pev->frags` (per-round, reset to 0 each round) and `m_iRoundWins` (cumulative wins)
- `SendScoreInfo` broadcasts frags, deaths, round wins, and team index to all clients
- `PlayerKilled` updates both players' HUD objectives with frags-to-go and progress bar (0–100%)

## Teams
- **Blue**: Player 1 (champion or first selected), `m_szTeamName = "blue"`, `pev->fuser4 = RADAR_ARENA_BLUE` (15)
- **Red**: Player 2 (challenger), `m_szTeamName = "red"`, `pev->fuser4 = RADAR_ARENA_RED` (14)
- Constants defined in `src/common/const.h` (lines 990–991)
- Two team names registered via `gmsgTeamNames`: `"blue"` and `"red"`
- `IsTeamplay()` returns `TRUE` (for scoreboard display)
- `GetTeamIndex`: `"red"` → 1, anything else → 0
- Bot team detection: `UTIL_GetTeam` in `grave-bot-src/dlls/util.cpp` checks `pEntity->v.fuser4 == 14` → return 2 (red), else return 1 (blue). 1-indexed.

### `fuser4` Lifecycle
- **Set once at match start**: `arena_gamerules.cpp` ~line 488/491 assigns `RADAR_ARENA_BLUE` / `RADAR_ARENA_RED`
- **NOT reset on mid-round respawn**: `PlayerSpawn` in `multiplay_gamerules.cpp` does not touch `fuser4`
- **Cleared between rounds**: `CountPlayersInArena()` in `multiplay_gamerules.cpp` ~line 976 sets `pev->fuser4 = 0` for all players
- **Cleared on bot disconnect**: `multiplay_gamerules.cpp` ~line 1625 sets `pev->fuser4 = 0`
- This means `UTIL_GetTeam` works correctly for the entire duration of a round, including after respawns

## Match Flow

### State Machine
```
WAITING (g_GameInProgress = FALSE)
  │
  ├─ clients < 2 → "Waiting for other players"
  │
  ├─ clients >= 2 → countdown (5, 4, 3, 2, "Prepare to fight")
  │
  ├─ Build/refresh opponent pool
  │   ├─ No champion (m_iReigningChampion == 0): select 2 random players
  │   └─ Champion exists: champion = Player1, random pool pick = Player2
  │
  └─ Start match:
      ├─ g_GameInProgress = TRUE
      ├─ RestoreMutators()
      ├─ Both players: frags=0, deaths=0, IsInArena=TRUE, ExitObserver()
      ├─ All others: SuckToSpectator()
      └─ SetRoundLimits() (frag limit + time limit)

MATCH IN PROGRESS (g_GameInProgress = TRUE)
  │
  ├─ Player disconnect → survivor wins, becomes champion
  ├─ Player reaches roundfraglimit → wins, becomes champion
  ├─ Timer expires → highest frags wins (or draw)
  │
  └─ Match ends:
      ├─ g_GameInProgress = FALSE
      ├─ PauseMutators()
      ├─ m_iSuccessfulRounds++
      ├─ Winner → m_iReigningChampion = winner index
      └─ flUpdateTime = gpGlobals->time + 3.0 (3-second break)
```

### Think Loop Update Rate
- During match (`g_GameInProgress`): every 1.5 seconds
- Waiting for players: every 1.0 seconds
- Post-match break: 3.0 seconds

## Champion & Opponent Pool System

### Key Members
| Field | Type | Purpose |
|-------|------|---------|
| `m_iPlayer1` | int | Entity index of Player 1 (blue) |
| `m_iPlayer2` | int | Entity index of Player 2 (red) |
| `m_iReigningChampion` | int | Entity index of current champion (0 = none) |
| `m_iOpponentPool[32]` | int[] | Array of available opponent entity indices |
| `m_iOpponentPoolSize` | int | Current pool size (0–32) |

### Pool Management
1. **First round** (`m_iReigningChampion == 0`): All eligible players added to pool. Two random players selected and removed.
2. **Subsequent rounds**: Champion auto-becomes Player1. Random opponent selected from pool and removed.
3. **Pool exhausted** (`m_iOpponentPoolSize == 0`): Rebuilt with all eligible players excluding the champion.
4. **Champion disconnect**: Pool and champion reset to 0, restarts from first-round logic.
5. **Stale pool entry**: If selected opponent has disconnected, retry on next tick without disturbing champion.

## Player States

| Field | Type | Purpose |
|-------|------|---------|
| `IsInArena` | bool | `TRUE` when selected for active match; `FALSE` when spectating |
| `m_flForceToObserverTime` | float | Timer to force non-competing players to observer (3s delay) |
| `m_iRoundWins` | int | Cumulative arena round wins across all rounds |
| `m_iRoundPlays` | int | Total arena matches played |
| `HasDisconnected` | bool | Checked to invalidate players/champions |
| `pev->frags` | float | Per-round frag count (reset to 0 each round) |
| `m_iDeaths` | int | Per-round death count (reset to 0 each round) |

## Respawn Rules (`FPlayerCanRespawn`)
- Only returns `TRUE` if ALL conditions met:
  1. `g_GameInProgress == TRUE`
  2. Player IS one of the two active arena combatants (`pPlayer1` or `pPlayer2`)
  3. The opponent has NOT yet reached `roundfraglimit` (opponent's frags < limit)
- Dead non-combatants get `m_flForceToObserverTime = gpGlobals->time + 3.0` → forced to spectator

## HasGameTimerExpired
- Called from `Think()` when `m_flRoundTimeLimit` is set
- Scans both `IsInArena` players for highest `pev->frags`
- Starts from `-9999` so even 0 or negative frags can win
- **Tie**: If frags equal → draw, no champion set, both lose
- **Winner**: Becomes `m_iReigningChampion`, `DisplayWinnersGoods()` called
- Resets: `g_GameInProgress = FALSE`, `PauseMutators()`, `m_iSuccessfulRounds++`

## PlayerKilled
- Calls `CHalfLifeMultiplay::PlayerKilled()` first (standard frag accounting)
- If `g_GameInProgress`: updates both players' HUD objectives:
  - Shows opponent name, frags needed to win, progress bar percentage
  - Switches to "You Defeated X!" / "You are the WINNER!" when frag limit reached

## Key CVars
| CVar | Purpose |
|------|---------|
| `roundfraglimit` | Frags needed to win a round |
| `roundtimelimit` | Time limit per round (0 = no limit) |
| `roundlimit` | Total rounds before intermission (0 = unlimited) |
| `roundwaittime` | Seconds to wait before starting when players are present |

---

## Bot AI Implementation (grave-bot-src)

### Build
```powershell
cd c:\hl-mods\workspace\grave-bot-src\dlls
& "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" grave_bot.sln /v:normal
```
Solution file: `grave-bot-src/dlls/grave_bot.sln` (VS 2022, MSBuild)

### Key Globals
Defined in `grave-bot-src/dlls/dll.cpp` (NOT per-bot — shared across all bots):
- `float is_team_play` — set by `BotCheckTeamplay()`; nonzero means team game
- `int is_gameplay` — set by `BotCheckTeamplay()`; `GAME_ARENA = 1`, default 0 (FFA)

### Files Modified
| File | What was added |
|------|---------------|
| `bot.h` | `i_arena_opponent`, `f_arena_seek_time`, `f_arena_vary_time`, `i_arena_approach_style`, `f_arena_approach_switch_time`, `f_arena_speed_factor` fields in `bot_t` struct |
| `bot_combat.cpp` | `BotArenaPreUpdate()`, `BotArenaThink()`, `BotCheckTeamplay` arena registration, `BotFindEnemy` arena edge-case fixes |
| `bot.cpp` | 4-hook dispatch in `BotThink`, death state cleanup in dead block, early `BotArenaPreUpdate` call, `BotSpawnInit` field init, `BotFindItem` early return, `arenaChase` direct-steer, post-synthesis speed variation, `v_goal` wipe exclusion |
| `bot_navigate.cpp` | `GAME_ARENA` in `BotFindWaypointGoal` (opponent-dead fallthrough to FFA), fast 0.5s recalc, snap-to-nearest on goal change, dead-end waypoint escape |
| `util.cpp` | `GAME_ARENA` case in `UTIL_GetTeam` — checks `pev->fuser4 == 14` for red team |
| `bot_func.h` | `BotArenaThink`, `BotArenaPreUpdate` declarations |

### Architecture

Execution pipeline in `BotThink()` — order matters:

```
1. Dead check (health < 1 || deadflag != DEAD_NO)
   └─ Arena: clear pBotEnemy/v_goal/i_arena_opponent (every frame)
   └─ BotSpawnInit (once via need_to_initialize)
   └─ early-return (skip everything below)

2. need_to_initialize = TRUE (arm for next death)

3. Early PreUpdate
   └─ CTF:   BotCtfPreUpdate()
   └─ Arena: BotArenaPreUpdate()       ← sets v_goal before waypoint routing

4. BotHeadTowardWaypoint()
   └─ calls BotFindWaypointGoal()      ← arena section finds nearest wpt to opponent

5. Game-mode PreUpdate calls (before BotFindEnemy)
   └─ KTS / ColdSkulls / CtC / CTF / Arena PreUpdate

6. BotFindEnemy()

7. if enemy: BotShootAtEnemy()
   else:
     a. Engagement reset (waypoint_goal = -1, force recalc)
     b. Pickup clearing (pBotPickupItem = NULL)
     c. BotArenaThink()                ← refreshes v_goal to opponent

8. Movement / direction synthesis
   └─ arenaChase direct-steer          ← <300u or <500u+visible

9. Post-synthesis speed variation       ← f_arena_speed_factor applied

10. v_goal wipe (arena excluded)

11. pfnRunPlayerMove()
```

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"arena"` via `strstr` or `atoi == GAME_ARENA`
- Sets `is_team_play = TRUE` (arena assigns blue/red teams)
- Sets `is_gameplay = GAME_ARENA`
- **CRITICAL**: Without this entry, `is_gameplay` stays at 0 (default FFA), and ALL `GAME_ARENA` checks in bot code are dead. This was the root cause of the original "bots behave identically to FFA" bug.

### Death State Cleanup (`bot.cpp` — dead block)
- Runs every frame while the bot is dead (`deadflag != DEAD_NO`), BEFORE `BotSpawnInit`
- Immediately clears: `pBotEnemy = NULL`, `b_engaging_enemy = FALSE`, `v_goal = g_vecZero`, `i_arena_opponent = -1`
- Fires unconditionally (not gated by `need_to_initialize`), so state is wiped starting from `DEAD_DYING` — not just `DEAD_DEAD`
- Prevents the bot from visually tracking its dead opponent during its own death animation
- `BotSpawnInit` still fires once via `need_to_initialize` to clear all remaining fields

### `need_to_initialize` Flow
- `bot_t::need_to_initialize` (`bool`, declared in `bot.h`)
- Set to `FALSE` at bot creation (line 850)
- Set to `TRUE` on the first alive frame after death (line 1756) — arms the initializer for the next death
- When dead and `need_to_initialize == TRUE`: fires `BotSpawnInit()` once, then sets `FALSE` (line 1705–1710)
- After that single fire, the dead block early-returns every frame without re-initializing
- This means arena death-state cleanup MUST be placed BEFORE the `need_to_initialize` check to run every dead frame

### Pre-Update (`bot_combat.cpp` — `BotArenaPreUpdate`)
- Runs in **two call sites**:
  1. **Early** (bot.cpp): Before `BotHeadTowardWaypoint`, matching the CTF `BotCtfPreUpdate` pattern. Ensures `v_goal` is set on the first frame after spawn so `BotFindWaypointGoal` has a valid target immediately.
  2. **Main** (bot.cpp): Before `BotFindEnemy`, refreshing `v_goal` each frame.
- Scans all players for the one alive opponent on a different team (`UTIL_GetTeam`)
- Caches opponent entity index in `i_arena_opponent`
- Sets `v_goal` to opponent's `pev->origin`, `f_goal_proximity = 0.0`
- Clears `pBotPickupItem` and `item_waypoint` every frame

### Think Function (`bot_combat.cpp` — `BotArenaThink`)
- Called from `BotThink`'s no-enemy else branch
- Validates cached opponent (`i_arena_opponent`); returns `false` if opponent is dead/disconnected
- Refreshes `v_goal` to opponent's `pev->origin`, `f_goal_proximity = 0.0`
- Waypoint goal selection delegated entirely to `BotFindWaypointGoal` (arena section in `bot_navigate.cpp`)
- Returns `true` when valid opponent exists to prevent fallthrough to generic nav

### BotFindEnemy Arena Enhancements (`bot_combat.cpp`)
- **5-second memory**: Enemy retained for 5s out of sight (vs default 2s) — `is_gameplay == GAME_ARENA` adds 3s to visibility timeout
- **Auto-engage**: `b_engaging_enemy = TRUE` set immediately when enemy found, bypassing `i_engage_aggressiveness` chance gate
- **Enemy retention**: Generic "not visible → clear" handler is gated with `&& is_gameplay != GAME_ARENA` to prevent premature enemy loss
- **Weapon switch lock**: Weapon switching during combat disabled for arena (`is_gameplay != GAME_ARENA` guard)

### Item Bypass (`bot.cpp` — `BotFindItem`)
- Early return for `GAME_ARENA`: clears `pBotPickupItem` and `item_waypoint`
- Bot never detours to health/armor/weapon pickups; sole objective is the opponent

### Post-Synthesis Speed Variation (`bot.cpp`)
- After the movement synthesis block computes `f_move_speed`, arena multiplier applied:
  - 40% full speed (factor 1.0)
  - 25% 0.8× speed
  - 20% 0.6× speed
  - 15% jump burst (full speed + `IN_JUMP`)
- Tactical jumps: 12% chance per variation tick
- Factor stored in `f_arena_speed_factor`, rotated every 0.5–2s via `f_arena_vary_time`
- Breaks "both bots loop at same speed" anti-pattern

### Waypoint Goal (`bot_navigate.cpp` — `BotFindWaypointGoal` arena section)
- Finds the one alive opponent on the other team (same scan as PreUpdate)
- Finds the nearest waypoint to opponent's position by pure distance (no LOS requirement)
- Sets `wpt_goal_type = WPT_GOAL_LOCATION` and returns the waypoint index
- **Opponent-dead fallthrough**: When no alive opponent is found (opponent is respawning), the `if (pOpponent)` guard is not entered and the entire `GAME_ARENA` block is skipped — code falls through to normal FFA waypoint logic (health/weapon/random) so the bot keeps navigating instead of standing still

### Waypoint Routing (`bot_navigate.cpp`)
- `GAME_ARENA` added to 0.5s frequent recalculation condition (alongside KTS/CTF/CtC/ColdSkulls)
- Snap-to-nearest-reachable on goal change: prevents backtracking to stale waypoints
- Dead-end escape: when bot reaches a pathless waypoint, scans for nearby connected waypoint to jump to

### Floyd Routing & `from_to[]` (`waypoint.cpp`)
- `unsigned short *from_to[4]` — Floyd-Warshall routing tables, indexed by team (0–3)
- `WaypointRouteFromTo(src, dest, team)`: `team = -1` is normalized to 0. If `from_to[team] == NULL`, falls back to `from_to[0]`.
- Arena bots with `UTIL_GetTeam` returning 2 (red) use `from_to[2]`; since most maps have no team-specific waypoints, `from_to[2]` is NULL and falls back to `from_to[0]` — this is correct behavior, not a bug.

### State Cleared on Spawn (`BotSpawnInit`)
All arena fields reset on every spawn:
- `i_arena_opponent = 0`
- `f_arena_seek_time = 0.0`
- `f_arena_vary_time = 0.0`
- `i_arena_approach_style = 0`
- `f_arena_approach_switch_time = 0.0`
- `f_arena_speed_factor = 1.0`

### `v_goal` Wipe Exclusion
- `bot.cpp` has a generic `pBot->v_goal = g_vecZero` ("always forget goal") line that runs after think functions
- Arena is in the exclusion list (same pattern as KTS/CtC/CTF/ColdSkulls) since `BotArenaPreUpdate` refreshes `v_goal` every frame

### Direct-Steer (`arenaChase` in `bot.cpp`)
- Local bool `arenaChase` in the movement/direction block (~line 2896)
- Activates when `is_gameplay == GAME_ARENA && v_goal != g_vecZero`
- **< 300u**: unconditional direct-steer (always `arenaChase = true`)
- **300–500u**: only if `FVisible(v_goal, pEdict)` passes — prevents wall-walking through windows/gaps the bot can't physically traverse
- **> 500u**: waypoint routing only (no direct-steer)
- When `arenaChase` is true, sets `bGoGoal = true` which bypasses waypoint-following and steers directly toward `v_goal`

### Post-Combat Reset (`bot.cpp` — `b_engaging_enemy` branch)
- Clears `waypoint_goal = -1`, forces `f_waypoint_goal_time = 0` to trigger immediate recalc toward opponent
- Resets `old_waypoint_goal = -1` (don't return to stale item goal)

### Key Pitfalls & Lessons Learned
1. **`BotCheckTeamplay` registration is mandatory**: Every game mode MUST have a corresponding entry in `BotCheckTeamplay()` (`bot_combat.cpp`) that sets `is_gameplay` to its `GAME_*` constant, or ALL bot-side game mode logic is completely dead code. Arena was missing this entry for the entire development cycle — all `is_gameplay == GAME_ARENA` checks silently evaluated to false.
2. **Team 0 is valid**: `UTIL_GetTeam` returns 1 (blue) or 2 (red), but team index 0 exists. An early bug had `otherTeam != 0` which excluded blue (team 0 in some contexts), so red bots never found their opponent. Fix: removed team 0 exclusion.
3. **Waypoint routing needs `team = -1`**: Team-filtered waypoint searches (`WaypointFindNearest` with team param) can fail on maps with no team-specific waypoints. Arena uses `team = -1` for unfiltered searches.
4. **Speed variation must be post-synthesis**: Setting `f_move_speed` in `BotArenaThink` gets overwritten by the movement synthesis block. The arena speed factor (`f_arena_speed_factor`) is applied AFTER synthesis to ensure it takes effect.
5. **`v_goal` must be set before `BotHeadTowardWaypoint`**: PreUpdate must run *early* (before `BotHeadTowardWaypoint`) — not just before `BotFindEnemy` — so that `v_goal` is valid on the very first frame after spawn. Without the early call, `BotFindWaypointGoal` fires with `v_goal == g_vecZero`, returns -1, and the 0.5s cooldown leaves the bot wandering aimlessly. This is the same pattern CTF uses with `BotCtfPreUpdate`.
6. **Dead-end waypoints cause infinite spin**: Waypoints without outgoing paths trap the bot in a spin loop. The dead-end escape logic scans for nearby connected waypoints to break out.
7. **Death animation keeps enemy state alive**: The dead block (`deadflag != DEAD_NO`) fires `BotSpawnInit` only once (via `need_to_initialize`), then early-returns every subsequent frame. Without explicit clearing, `pBotEnemy`, `v_goal`, and `i_arena_opponent` persist through the entire death animation — the bot keeps tracking its dead opponent. Fix: clear arena combat state unconditionally (every frame) at the top of the dead block, before the `need_to_initialize` check.
8. **Opponent temporarily dead breaks waypoint goal**: When the opponent is respawning, `BotFindWaypointGoal`'s arena section can't find an alive opponent. If this sets `waypoint_goal = -1` and returns, the bot loses all navigation. Fix: guard the waypoint-setting code with `if (pOpponent)` and let the `!pOpponent` case fall through to normal FFA waypoint logic (health/weapon/random) so the bot keeps moving during the brief respawn window.
