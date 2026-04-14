# Cold Skulls Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_COLDSKULL = 5` (defined in `common/const.h`)
- **String ID**: `"coldskull"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Cold Skulls"` — FFA collection mode
- **Source**: `workspace/src/dlls/coldskull_gamerules.cpp`, `workspace/src/dlls/coldskull_gamerules.h`
- **Class**: `CHalfLifeColdSkull : public CHalfLifeMultiplay`

## Win Condition
- First player to reach `fraglimit` skulls wins (default 100 if fraglimit == 0)
- Calls `g_pGameRules->EndMultiplayerGame()` when threshold is reached
- Score tracked via `pPlayer->m_iRoundWins`
- HUD shows objective: "Collect the skulls" with progress bar (X of Y)

## Skull Entity (`CSkullCharm`, classname `"skull"`)
- **Model**: `models/w_runes.mdl` (body = 10)
- **Sound**: `rune_pickup.wav` (0.5 volume to reduce message overhead)
- **Lifetime**: 25 seconds before fade (`pev->dmgtime = gpGlobals->time + 25.0`)
- **Max skulls in world**: 100 (hard cap in `CreateSkull()`)
- **Solid after**: 0.5s delay (ThinkSolid transitions SOLID_NOT → SOLID_TRIGGER)
- **Physics**: MOVETYPE_TOSS (gravity), switches to MOVETYPE_FLY during magnetism

### Value Tiers & Colors
| Points | Color | RGB |
|--------|-------|-----|
| 1 | Bronze | (255, 128, 128) |
| 5 | Silver | (128, 128, 128) |
| 10 | Gold | (255, 215, 0) |
| 20 | Purple Crystal | (128, 0, 255) |
| 40+ | Flaming Red Crystal | (255, 0, 0) |

Point value stored in `pev->fuser1`.

### Spawn Mechanics (`CreateSkull()`)
- **Origin**: Victim's gun position (`pVictim->GetGunPosition()`)
- **Spread**: Tight clustering — X/Y: ±150, Z: 0–200
- **Safe position**: Victim's origin -32 Z stored in `pev->vuser1` (fallback if skull falls into solid)
- **Killer reference**: 50% chance to assign killer to `pev->euser1` for magnetism priority

### Magnetism System (`SkullMagnetThink`)
Two-tier priority, runs every 0.15–0.25s (randomized to spread network load):

1. **Priority 1 — Killer magnetism**: If `pev->euser1` is set and the killer is alive, skull flies toward them
2. **Priority 2 — Player magnetism**: Any living player with `m_iRoundWins >= 2` (SKULL_MAGNET_THRESHOLD) within 512u (SKULL_MAGNET_RADIUS) attracts the skull

**Physics**:
- Target point: `Player.origin + Vector(0, 0, -28)` (lower body)
- Speed: `flDist < 128u ? flDist * 3.0f : 500.0f` (ease-in when close)
- Lerp: `velocity += (desired - velocity) * 0.4f` (smooth glide)
- Falls back to `MOVETYPE_TOSS` when no target (rests on ground)

### Pickup (`SkullTouch`)
- Adds `pev->fuser1` to `pPlayer->m_iRoundWins`
- Screen fade effect using skull's render color
- Updates ScoreInfo for all players
- Sends progress objective to collecting player
- Plays `CLIENT_SOUND_LEVEL_UP`
- Removes skull entity after pickup

## Death Penalty (`PlayerKilled`)
- **Formula**: `m_iRoundWins = (m_iRoundWins * 2) / 3` — lose 33%, keep 67%
- Only applied if victim != killer (no self-kill penalty beyond normal)
- Remaining balance dropped as skull entities in optimal chunks:
  - ≥40 remaining → one 40-point skull (loop subtracts 40)
  - 20–39 → one 20-point skull
  - 10–19 → one 10-point skull
  - 5–9 → one 5-point skull
  - 1–4 → individual 1-point skulls
- Each skull has 50% chance of being magnetically linked to the killer

## Player Spawn (`PlayerSpawn`)
- `pev->iuser3 > 0`: New player, already set to simple in client.cpp
- `pev->iuser3 == 0`: Spectator now joining — set `iuser3 = -1`, schedule game mode message
- Game mode banner: "Collect The Skulls" / "Frag your opponents and their heads will come to you."

## Key Constants
```cpp
#define SKULL_MAGNET_THRESHOLD 2      // Min skulls a player needs to attract loose skulls
#define SKULL_MAGNET_RADIUS 512.0f    // Detection radius for magnetism
```

## Bot Relevance
- Skulls are classname `"skull"` — bots can find them via `UTIL_FindEntityByClassname`
- Score is `m_iRoundWins` — not `pev->frags` (frags are separate kill count)
- Skull magnetism means bots with ≥2 skulls naturally attract more — collecting begets collecting
- High-value skulls (gold/purple/red) are much more impactful than bronze — bots should prefer them
- Skulls cluster at death sites due to tight spawn spread — navigating to kill sites is efficient
- 25s lifetime means skulls don't persist forever — urgency matters
- **Not all skulls are magnetic** — only ~50% get killer magnetism, and general magnetism only activates for players with ≥2 skulls within 512u. Non-magnetic skulls sit on the ground and must be physically walked into.
- Skulls have a **zero-size bounding box** (`SOLID_TRIGGER` + `UTIL_SetSize(g_vecZero, g_vecZero)`) — the bot must overlap the skull's point origin to trigger `SkullTouch`. Stopping near the skull is not enough.

## Bot Implementation (grave-bot-src)

### Shared Helper (`bot_combat.cpp` — `BotFindBestSkull`)
- **Per-frame entity cache**: walks the `"skull"` entity list once per server frame (static time guard, up to 128 skulls), same pattern as `BotGetKtsSnowballCached`
- **Per-bot scoring**: `fuser1 / sqrt(distance)` — balances value vs proximity, evaluated per-bot against the cached list
- Returns best skull edict + optional `float *pflDist` out-param
- Declared in `bot_func.h`, used by all three callsites below

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"coldskull"` via `strstr` or `atoi == GAME_COLDSKULL`
- Sets `is_gameplay = GAME_COLDSKULL`

### Think Function (`bot_combat.cpp` — `BotColdskullThink`)
- Called from `BotThink`'s no-enemy else branch
- Uses `BotFindBestSkull` to get best skull + distance
- Sets `v_goal` to best skull, `f_move_speed = max`, `f_goal_proximity = 20`
- Always runs at full speed toward the skull (no proximity stop)
- Suppresses `pBotEnemy` when skull is within 200u
- Falls back to normal nav (`return false`) when health ≤ 25 or no skulls exist

### Pre-Scan (`bot.cpp` — before `BotFindEnemy`)
- Runs every tick even when the enemy branch takes priority
- Uses `BotFindBestSkull` — sets `v_goal` toward best skull, `f_goal_proximity = 0`
- Gated on `health > 25` (same threshold as BotColdskullThink)
- Ensures `v_goal` is always fresh for the movement block, even on combat ticks

### Enemy Suppression (`bot_combat.cpp` — `BotFindEnemy`)
- Uses `BotFindBestSkull` to verify a real skull entity is within 300u (not trusting stale `v_goal`)
- Gated on `health > 25` — respects the "seek health" threshold
- Clears `pBotEnemy` and returns NULL to prevent combat from interrupting collection

### Item Bypass (`bot.cpp` — `BotFindItem`)
- Early return clears `pBotPickupItem` and `item_waypoint`
- Prevents generic item scan from setting stale weapon/ammo targets

### Waypoint Routing (`bot_navigate.cpp` — `BotFindWaypointGoal`)
- Uses `BotFindBestSkull` to get best skull, finds nearest waypoint by pure distance (no LOS)
- Added to goal recalc gate and 0.5s timer list for frequent updates
- Resets waypoint routing on goal change via `WaypointFindReachable`

### Movement Block (`bot.cpp` — direction calc)
- `skullChase` flag: enables `bGoGoal = true` (direct-steer toward `v_goal`)
- Close skulls (< 300u): skip `FVisible` check — skull may be at floor level causing trace clip
- Far skulls: require `FVisible` to prevent wall-walking
- `v_goal` is **not** wiped by the generic `"always forget goal"` reset (skipped for both Cold Skulls and KTS)

### Post-Combat Reset (`bot.cpp` — `b_engaging_enemy` branch)
- Clears `waypoint_goal`, `old_waypoint_goal`, forces `f_waypoint_goal_time = 0`
- Prevents bot from returning to stale weapon/ammo waypoints after a kill

### Key Pitfalls (Debugging History)
1. **`v_goal` wipe** — `bot.cpp` has `pBot->v_goal = g_vecZero` ("always forget goal") that runs after the think functions but before the movement block. Skipped for both Cold Skulls and KTS since both modes refresh `v_goal` every tick via pre-scans.
2. **`FVisible` floor clips** — Skulls rest at floor level; `FVisible` traces from eye height to ground, clipping geometry. Use distance fallback for close skulls.
3. **Proximity stop vs. zero-size bbox** — Stopping near a non-magnetic skull creates a deadlock where both bot and skull are stationary. Bot must always walk into the skull.
4. **Goal recalc timer** — Default is 120s. Cold Skulls needs 0.5s updates like KTS.
5. **`SOLID_NOT` initial state** — Skulls start as `SOLID_NOT` for 0.5s. Don't filter them out in scans; they transition to `SOLID_TRIGGER` quickly.
6. **`UTIL_TraceLine` vs `SOLID_TRIGGER`** — GoldSrc traces do not hit `SOLID_TRIGGER` entities (they only fire on entity movement/touch). Cannot use trace-based visibility to detect skulls. Use `BotFindBestSkull` distance checks instead.
