# Arena (1 vs. 1) Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_ARENA = 1` (defined in `common/const.h`)
- **String ID**: `"arena"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Arena"` — 1v1 champion-defense duel
- **Source**: `src/dlls/arena_gamerules.cpp`, `src/dlls/arena_gamerules.h`
- **Class**: `CHalfLifeArena : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (BotArenaPreUpdate, BotArenaThink, BotCheckTeamplay registration, BotFindEnemy arena enhancements), `grave-bot-src/dlls/bot.cpp` (4-hook dispatch, BotSpawnInit, BotFindItem bypass, arenaChase direct-steer, post-synthesis speed variation), `grave-bot-src/dlls/bot_navigate.cpp` (fast recalc, dead-end escape), `grave-bot-src/dlls/bot.h` (arena struct fields), `grave-bot-src/dlls/bot_func.h` (declarations)

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
- **Blue**: Player 1 (champion or first selected), `m_szTeamName = "blue"`, `pev->fuser4 = RADAR_ARENA_BLUE`
- **Red**: Player 2 (challenger), `m_szTeamName = "red"`, `pev->fuser4 = RADAR_ARENA_RED`
- Two team names registered via `gmsgTeamNames`: `"blue"` and `"red"`
- `IsTeamplay()` returns `TRUE` (for scoreboard display)
- `GetTeamIndex`: `"red"` → 1, anything else → 0
- Bot team detection: `UTIL_GetTeam` returns `1 = blue`, `2 = red` (1-indexed)

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

### Files Modified
| File | What was added |
|------|---------------|
| `bot.h` | `i_arena_opponent`, `f_arena_seek_time`, `f_arena_vary_time`, `i_arena_approach_style`, `f_arena_approach_switch_time`, `f_arena_speed_factor` fields in `bot_t` struct |
| `bot_combat.cpp` | `BotArenaPreUpdate()`, `BotArenaThink()`, `BotCheckTeamplay` arena registration, `BotFindEnemy` arena edge-case fixes |
| `bot.cpp` | 4-hook dispatch in `BotThink`, `BotSpawnInit` field init, `BotFindItem` early return, `arenaChase` direct-steer, post-synthesis speed variation, `v_goal` wipe exclusion |
| `bot_navigate.cpp` | `GAME_ARENA` in fast 0.5s recalc, snap-to-nearest on goal change, dead-end waypoint escape |
| `bot_func.h` | `BotArenaThink`, `BotArenaPreUpdate` declarations |

### Architecture
1. **Detection** (`BotCheckTeamplay`): Runs once per-frame before bot think. Pre-sets `v_goal` toward opponent so movement works even on combat frames.
2. **Pre-update** (`BotArenaPreUpdate`): Finds the one alive opponent on the other team, caches entity index, sets `v_goal`, routes `waypoint_goal` every 0.5s, clears pickup items.
3. **Think** (`BotArenaThink`): Rotates approach styles (direct/flank/wander), overrides waypoint goal for non-direct styles, sets `v_goal` to opponent position. Returns `true` to prevent fallthrough to generic nav.
4. **Post-synthesis speed variation** (bot.cpp): After the movement synthesis block, applies speed variation via `f_arena_speed_factor` — 40% full speed, 25% 0.8×, 20% 0.6×, 15% jump burst. Tactical jumps 12% chance. Rotates every 0.5–2s.
5. **Direct-steer** (`arenaChase` in bot.cpp): Within 500u of opponent or when visible, bot steers directly via `bGoGoal = true`, bypassing waypoint routing for final approach.

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"arena"` via `strstr` or `atoi == GAME_ARENA`
- Sets `is_team_play = TRUE` (arena assigns blue/red teams)
- Sets `is_gameplay = GAME_ARENA`
- **CRITICAL**: Without this entry, `is_gameplay` stays at 0 (default FFA), and ALL `GAME_ARENA` checks in bot code are dead. This was the root cause of the original "bots behave identically to FFA" bug.

### Pre-Update (`bot_combat.cpp` — `BotArenaPreUpdate`)
- Runs every frame before `BotFindEnemy`
- Scans all players for the one alive opponent on a different team (`UTIL_GetTeam`)
- Caches opponent entity index in `i_arena_opponent`
- Sets `v_goal` to opponent's `pev->origin`
- Every 0.5s: routes `waypoint_goal` via `WaypointRouteFromTo` using `team = -1` (unfiltered)
- Clears `pBotPickupItem` and `item_waypoint` every frame

### Think Function (`bot_combat.cpp` — `BotArenaThink`)
- Called from `BotThink`'s no-enemy else branch
- Rotates approach style every 5–8s: direct (60%), flank (25%), random wander (15%)
- Direct: waypoint goal already set by PreUpdate
- Flank: picks waypoint near but not closest to opponent
- Wander: random waypoint for 3–4s, then reverts to direct
- Sets `v_goal` to opponent, `f_move_speed = max`, `f_goal_proximity = 20`
- Returns `true` when movement intent is set

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

### Waypoint Routing (`bot_navigate.cpp`)
- `GAME_ARENA` added to 0.5s frequent recalculation condition (alongside KTS/CTF/CtC/ColdSkulls)
- Snap-to-nearest-reachable on goal change: prevents backtracking to stale waypoints
- Dead-end escape: when bot reaches a pathless waypoint, scans for nearby connected waypoint to jump to

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

### Post-Combat Reset (`bot.cpp` — `b_engaging_enemy` branch)
- Clears `waypoint_goal = -1`, forces `f_waypoint_goal_time = 0` to trigger immediate recalc toward opponent
- Resets `old_waypoint_goal = -1` (don't return to stale item goal)

### Key Pitfalls & Lessons Learned
1. **`BotCheckTeamplay` registration is mandatory**: Every game mode MUST have a corresponding entry in `BotCheckTeamplay()` (`bot_combat.cpp`) that sets `is_gameplay` to its `GAME_*` constant, or ALL bot-side game mode logic is completely dead code. Arena was missing this entry for the entire development cycle — all `is_gameplay == GAME_ARENA` checks silently evaluated to false.
2. **Team 0 is valid**: `UTIL_GetTeam` returns 1 (blue) or 2 (red), but team index 0 exists. An early bug had `otherTeam != 0` which excluded blue (team 0 in some contexts), so red bots never found their opponent. Fix: removed team 0 exclusion.
3. **Waypoint routing needs `team = -1`**: Team-filtered waypoint searches (`WaypointFindNearest` with team param) can fail on maps with no team-specific waypoints. Arena uses `team = -1` for unfiltered searches.
4. **Speed variation must be post-synthesis**: Setting `f_move_speed` in `BotArenaThink` gets overwritten by the movement synthesis block. The arena speed factor (`f_arena_speed_factor`) is applied AFTER synthesis to ensure it takes effect.
5. **`v_goal` must be set before `BotHeadTowardWaypoint`**: PreUpdate runs before `BotFindEnemy` to ensure `v_goal` is fresh for the movement block.
6. **Dead-end waypoints cause infinite spin**: Waypoints without outgoing paths trap the bot in a spin loop. The dead-end escape logic scans for nearby connected waypoints to break out.
