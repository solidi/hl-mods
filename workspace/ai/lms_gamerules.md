# Last Man Standing (Battle Royale) Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_LMS = 2` (defined in `common/const.h`)
- **String ID**: `"lms"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Battle Royale"` — round-based survival mode with a shrinking safe zone
- **Source**: `src/dlls/lms_gamerules.cpp`, `src/dlls/lms_gamerules.h`
- **Class**: `CHalfLifeLastManStanding : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (`BotLmsPreUpdate` / `BotLmsThink`)

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, the cross-DLL `fuser4` / `RADAR_*` conventions, the [`v_goal` Preservation Contract](gamerules.md#critical--v_goal-preservation-contract), and the bot integration checklist that every mode (including LMS) must satisfy. The bot integration here is a direct sibling of [coldspot_gamerules.md](coldspot_gamerules.md) and reuses the same role-evaluator / waypoint-snap pattern.

## Concept
Each round, every committed player is inserted into the "arena" with a fixed number of lives (`mp_startwithlives`, default 5). A `safespot` entity spawns somewhere on the map and shrinks over the round's duration. Any player outside `256 * pev->body` units of the safe spot takes 2 `DMG_SHOCK` every 2 seconds; any player inside heals +2 HP per tick (capped at `max_health`). When a player runs out of lives (`pev->frags <= 0`), they are eliminated for the round (forced to observer after 3s). The round ends when only one player / one team remains, or the round time limit expires (frag totals are then aggregated to pick a winner / draw).

Mode is **team-based** when `mp_royaleteam = 1` (default), **FFA** when `0`. Team mode locks models to `iceman` (blue) / `santa` (red) and resolves the round when either team is wiped out.

## Win Condition
- **Round win (FFA)**: last living player with `pev->frags > 0` and `IsInArena`.
- **Round win (Team)**: opposing team wiped out, OR last living player when only one survives across both teams.
- **Time-limit fallback** (`HasGameTimerExpired`): team mode sums `pev->frags` across each team — highest total wins, equal is a draw; FFA picks the highest `frags` player.
- Round wins accumulate into `m_iRoundWins`; `mp_roundlimit` (default 10) drives intermission.
- `IPointsForKill()` returns `0` — only lives (`frags`) matter, not frag score.

## Eligibility Prerequisites
For a player to be "in the round" on any think tick:
1. Alive (`IsAlive()`) and not spectating (`pev->iuser1 == 0`)
2. `IsInArena == TRUE` (set by `InsertClientsIntoArena` at round start)
3. `pev->frags > 0` (still has lives)
4. `!HasDisconnected`

The bot DLL cannot read `IsInArena` or `HasDisconnected` directly (CBasePlayer privates). The reliable cross-DLL proxy is **`pev->iuser1 == 0 && pev->frags > 0`** — once the round starts, both are true; before the round starts or after elimination, at least one fails. This is the same idiom used in the Cold Spot zone-eligibility filter.

## Cvars
| Cvar | Default | Type | Purpose |
|------|---------|------|---------|
| `mp_royaleteam` | `1` | FCVAR_SERVER | Team-based (1) vs FFA (0); also enforces blue/red model lock |
| `mp_royaledamage` | `1` | FCVAR_SERVER | When 0, the SafeSpot `SafeSpotThink` returns early — **no damage and no heal**. Zone is purely cosmetic. |
| `mp_startwithlives` | `5` | FCVAR_SERVER | Initial lives per player (stored in `pev->frags`) |
| `mp_roundwaittime` | `10` | FCVAR_SERVER | Lobby wait before countdown |
| `mp_roundtimelimit` | (multiplay) | FCVAR_SERVER | Round duration; **shrink cadence = `(roundtimelimit * 60) / 15`** |
| `mp_roundlimit` | `10` | FCVAR_SERVER | Total rounds before intermission |
| `mp_friendlyfire` | (multiplay) | FCVAR_SERVER | Team mode blocks teammate damage when `0` |

## Teams (when `mp_royaleteam = 1`)
- **Blue (Iceman)**: `TEAM_BLUE = 0`, `pev->fuser4 = 0`, model = `iceman`
- **Red (Santa)**: `TEAM_RED = 1`, `pev->fuser4 = 1`, model = `santa`
- `UTIL_GetTeam` (bot-side) returns `1 = blue`, `2 = red` (1-indexed; differs from `TEAM_BLUE/TEAM_RED`)
- Auto-join balances team sizes; model change during a round kills the player
- Only `iceman` and `santa` models allowed; enforced in `ClientUserInfoChanged` (kills + respawns on violation)
- `IsTeamplay()` returns `m_TeamBased` (1 in team mode, 0 in FFA)
- `PlayerRelationship`: `GR_TEAMMATE` if same team name (team mode only), otherwise `GR_NOTTEAMMATE`
- `FPlayerCanTakeDamage`: blocked between teammates when `friendlyfire == 0`
- `ShouldAutoAim`: disabled against teammates

In FFA mode, all players are on team `"Active"` and `PlayerRelationship` short-circuits to `GR_NOTTEAMMATE`.

## Safe Spot Entity (`CSafeSpot`, classname `"safespot"`)
- **Model**: `models/coldspot.mdl` (same model as Cold Spot — the body group encodes the size)
- **Physics**: `MOVETYPE_NONE`, `SOLID_NOT`
- **Bbox**: `g_vecZero` to `g_vecZero` (zero-size marker; **no touch trigger**, eligibility is purely positional)
- **Think**: `CSafeSpot::SafeSpotThink` — 2.0s after spawn, then every 2.0s

### State Tracking
| Field | Type | Purpose |
|-------|------|---------|
| `pev->origin` | Vector | Center of the safe zone |
| `pev->fuser4` | float | Radar identifier: `RADAR_COLD_SPOT` (5) — **shared with Cold Spot**; the classname disambiguates |
| `pev->classname` | string | `"safespot"` (entity lookup key) |
| `pev->body` | int | Current size index — **8 at round start**, decremented by 1 on every shrink down to **1**. Zone radius = `256 * pev->body`. |

### Damage / Heal Tick (`SafeSpotThink`, every 2.0s)
Gated by `royaledamage.value` — when 0, the tick is a no-op (no damage, no heal). Otherwise, for each player passing the eligibility test (`IsPlayer && IsInArena && IsAlive && !HasDisconnected`):

- Enumerate entities in `UTIL_FindEntityInSphere(pev->origin, 256 * pev->body)`. If the player's own edict is in the list (`bInZone = TRUE`):
  - Heal `+2 HP` (capped at `max_health`).
- Otherwise (`bInZone = FALSE`):
  - `TakeDamage(worldspawn, pev, 2, DMG_SHOCK)`
  - Center-print: `"Taking damage - find the green zone!"`
  - `gmsgStatusIcon` with `"cam_danger"` (1=show), and `m_fCameraDelay = gpGlobals->time + 2.0` so `PlayerThink` clears the icon after the cooldown.

Zone radius is "spherical" in the sense that `UTIL_FindEntityInSphere` uses true 3D distance — vertical offset matters. Bots can be in 2D range but vertically out-of-zone.

## Shrink Cycle (Gamerules `Think`)
- Cadence: `m_fNextShrinkTime = gpGlobals->time + ((roundtimelimit.value * 60) / 15)`. 
- On each shrink tick:
  - `pSpot->pev->body -= 1` (effective radius drops by 256u)
  - Broadcast `gmsgSafeSpot` with the new body value (radar UI tracks the size)
  - Print `"[Royale] The safe spot has shrunk!"`
- The zone's `pev->origin` is set once per round on first relocation (`m_fSpawnSafeSpot`, 1s after countdown). It does **not** wander mid-round; only its radius changes. (Contrast: Cold Spot relocates periodically.)
- Bots must treat `pev->body` as **volatile** — when it drops, a previously-safe position can become red and they need to re-path inward. The cached origin can be trusted within a round.

## Round Flow

### Pre-round (`g_GameInProgress == FALSE`)
- `SuckAllToSpectator()` keeps everyone parked.
- `m_fWaitForPlayersTime = gpGlobals->time + roundwaittime.value` (default 10s).
- `RemoveAndFillItems()` resets weapon pickups.
- Objective HUD shows `"Battle Royale" / "Waiting for other players"`.
- Bots in this phase have `pev->iuser1 != 0` (parked in observer) and **must not act** — the bot side detects "no spot yet" / "iuser1 != 0" and idles.

### Countdown
- Triggered when committed player count ≥ 2 and `m_fWaitForPlayersTime` has elapsed.
- `m_iCountDown = 5`; one-second decrements with center-printed countdown and `CLIENT_SOUND_PICKUPYOURWEAPON` at 3.
- On reaching 0:
  - `g_GameInProgress = TRUE`
  - `RestoreMutators()`
  - `InsertClientsIntoArena(startwithlives.value)` → for every committed player: `pev->frags = startwithlives`, `IsInArena = TRUE`, `ExitObserver()`, `m_iRoundPlays++`
  - SafeSpot spawned at `pev->body = 8` via the next tick's `m_fSpawnSafeSpot` (1s offset)
  - Broadcast `"Battle Royale has begun!"`

### In-round
- `Think` runs every 1.5s while in progress. Each tick:
  - Counts `clients_alive`, per-team head counts.
  - Fires shrink tick when `m_fNextShrinkTime` elapses.
  - Decides victory (FFA: `clients_alive == 1`; team: one team has 0 alive).

### Round end
- `g_GameInProgress = FALSE`, `m_flRoundTimeLimit = 0`
- `pSafeSpot->pev->nextthink = gpGlobals->time + 5.0` (pause damage during celebration)
- `PauseMutators()`, `m_iSuccessfulRounds++`
- If `m_iSuccessfulRounds >= roundlimit` → `GoToIntermission()`

### Elimination (`FPlayerCanRespawn`)
- Returns `FALSE` while `!g_GameInProgress` or `pev->frags <= 0`.
- When a player's `frags` drops to 0 and they die, `m_flForceToObserverTime = gpGlobals->time + 3.0` is scheduled; `SuckToSpectator` runs after the timer.
- **Bots eliminated mid-round** become `pev->iuser1 != 0` again and must idle until the next round's `InsertClientsIntoArena` re-promotes them.

## Network Messages
| Message | Payload | Purpose |
|---------|---------|---------|
| `gmsgObjective` | strings + roundlimit count | HUD objective strip (per-client, ~1.5s cadence) |
| `gmsgTeamNames` | 2 teams `"blue"`/`"red"` (team) or 1 team `"Active"` (FFA) | Scoreboard team list |
| `gmsgTeamInfo` | playerIndex, teamName | Scoreboard color on entry / team change |
| `gmsgSpecialEntity` | slotIndex, active, origin, `RADAR_COLD_SPOT` (5) | Radar marker for the safe spot |
| `gmsgSafeSpot` | new `body` value (1–8) | Radar zone-size update on each shrink |
| `gmsgStatusIcon` | `"cam_danger"` | Outside-zone warning icon |
| `gmsgBanner` | round / team intro text | On-screen banner |
| `gmsgShowTimer` | byte | Hides the round timer on victory |
| `gmsgScoreInfo` | playerIndex, frags, deaths, wins, teamIndex | Scoreboard (frags here = lives) |
| `gmsgPlayClientSound` | sound id | `CLIENT_SOUND_LMS`, etc. |

Bots read the safe spot directly (`UTIL_FindEntityByClassname`) and do not subscribe to `gmsgSafeSpot` — `pev->body` on the cached edict is the canonical zone size.

## Key Constants
```cpp
#define TEAM_BLUE 0
#define TEAM_RED  1

#define RADAR_COLD_SPOT 5       // pev->fuser4 on safespot entity (shared with Cold Spot)

// Cvars
// mp_royaleteam      — 1 = team mode (iceman/santa), 0 = FFA
// mp_royaledamage    — 0 disables damage AND heal (zone becomes cosmetic only)
// mp_startwithlives  — initial pev->frags for each player at round start
// mp_roundtimelimit  — round duration; shrink interval = (roundtimelimit * 60) / 15
```

## Key Detection Flags (Bot Side)
| Check | Value | Meaning |
|-------|-------|---------|
| `pEnt->v.classname == "safespot"` | string | Entity is the safe spot (disambiguates from `"coldspot"`) |
| `pEnt->v.fuser4 == RADAR_COLD_SPOT` | 5 | Confirms radar identity |
| `pEnt->v.body` | 1..8 | Current zone size index; radius = `256 * body` |
| `pPlayer->v.iuser1 == 0 && pPlayer->v.frags > 0` | bool | Player is in the round (proxy for `IsInArena && lives>0`) |
| `pPlayer->v.fuser4` | TEAM_BLUE / TEAM_RED | Player's team (team mode only; meaningless in FFA) |
| Distance to `spot->v.origin` | <= `256 * body` | Inside safe zone |

## Bot Relevance
- A single `safespot` entity exists per round — cache one edict (invalidate cleanly when it disappears between rounds).
- `pev->body` decrements **mid-round** in 15 steps; bots must re-check distance against the current radius every tick.
- `pev->origin` is **stable within a round** but cleared between rounds; the zone may relocate to a different point on each new round. Treat origin changes between ticks as a relocation (same wipe-routing pattern as Cold Spot).
- The zone is `SOLID_NOT` with zero bbox — no touch trigger. Bots navigate to `pev->origin` geometrically.
- `+2 HP` per tick inside, `-2 HP` per tick outside, both gated on `royaledamage`. Even with damage off, the spot is the safest fight venue (other bots converge there).
- **Lives, not frags, win the round.** A bot with low HP standing in the green zone is winning; a bot fragging in the red zone is losing.
- **No team coordination protocol** — team behavior is emergent from the role split (HOLDER stays, HUNTER pushes intruders), not from explicit comms.

## Bot AI Implementation (grave-bot-src)

### Current Status
**Fully implemented.** `BotLmsPreUpdate` and `BotLmsThink` are live in `bot_combat.cpp`, dispatched from `bot.cpp` alongside the other objective gamemodes. Bots cache the `safespot` edict, evaluate a per-bot role every ~0.75s, and route toward `pev->origin` via the shared waypoint system with `v_goal` preservation. Role state is reset in `BotSpawnInit`; a dedicated relocation / shrink guard in `BotLmsPreUpdate` clears stale waypoint fields whenever the spot moves between rounds or `pev->body` drops.

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"lms"` via `strstr` or `atoi == GAME_LMS`
- Always sets `is_gameplay = GAME_LMS`
- Sets `is_team_play = TRUE` only when `mp_royaleteam != 0` (FFA-LMS still runs the role evaluator, just without HOLDER/HUNTER team roles)
- **CRITICAL**: Without this entry, `is_gameplay` stays at 0 (default DM), and all `GAME_LMS` checks elsewhere are dead — bots play it as deathmatch.

### Architecture (mirrors Cold Spot pattern)

#### State (`bot.h`)
```cpp
// Role enum (alongside CSPOT_ROLE_*)
enum {
    LMS_ROLE_NONE = 0,
    LMS_ROLE_SURVIVOR,    // default — drift toward zone center
    LMS_ROLE_HOLDER,      // (team mode only) in zone with allies, hold the perimeter
    LMS_ROLE_HUNTER,      // (team mode only) enemy inside zone, rush in to clear
    LMS_ROLE_RETREATER    // low HP / outside zone / taking ring damage → bail inward
};

// bot_t fields
int   i_lms_role;             // current role (LMS_ROLE_*)
float f_lms_role_eval_time;   // throttle for re-evaluating role (~0.75s)
float f_lms_last_in_zone;     // last gpGlobals->time the bot was inside the current radius
Vector v_lms_last_origin;     // last cached safespot origin (for relocation detection)
int   i_lms_last_body;        // last observed pev->body (for shrink detection)
float f_lms_last_health;      // last health sample (zone-damage delta probe)
```

All six are reset in `BotSpawnInit`.

#### Entity Caching (`bot_combat.cpp`)
```cpp
static float   s_lms_cache_time = -1.0f;
static edict_t *s_pSafeSpot = NULL;

static void BotLmsFindEntity()
{
    if (s_lms_cache_time == gpGlobals->time) return;
    s_lms_cache_time = gpGlobals->time;
    s_pSafeSpot = NULL;
    edict_t *pEnt = NULL;
    while ((pEnt = UTIL_FindEntityByClassname(pEnt, "safespot")) != NULL)
    {
        if ((int)pEnt->v.fuser4 == RADAR_COLD_SPOT) { s_pSafeSpot = pEnt; break; }
    }
}
```

Helpers:
- `BotLmsCurrentRadius(pSpot)` → `256.0f * max(1, body)`.
- `BotLmsFindZoneIntruder(pSpot, botTeam)` — nearest living, non-spectator, non-eliminated enemy inside the current radius. Returns `NULL` when the zone is clear or the bot is on the FFA side.

#### Pre-Update (`BotLmsPreUpdate`, called every frame before `BotFindEnemy`)
- If no spot exists (pre-round / between rounds) OR the bot is in observer (`pev->iuser1 != 0`) OR eliminated (`pev->frags <= 0`):
  - Clear `v_goal`, `pBotEnemy`, set role to `LMS_ROLE_NONE`, suppress combat goal, return. The fake-client auto-promotion path handles re-entry.
- **Relocation invalidation**: when `v_lms_last_origin != g_vecZero` and the origin moved > 32u, wipe stale routing (same fields as Cold Spot: `waypoint_goal`, `old_waypoint_goal`, `f_waypoint_goal_time`, `curr_waypoint_index`, `f_waypoint_time`, `prev_waypoint_distance`, `prev_waypoint_index[0..4]`, `f_pause_time`, `wpt_goal_type`).
- **Shrink invalidation**: when `pSpot->v.body < i_lms_last_body`, also wipe routing so the new (smaller) radius gets a fresh path. Update `i_lms_last_body` either way.
- Compute distance to center, current radius, and `bInZone = distance < radius - LMS_ZONE_SLACK` (the slack creates hysteresis so a bot teetering on the edge isn't flipping roles every tick).
- **Zone-damage probe**: `bZoneHurt = !bInZone && pEdict->v.health < f_lms_last_health`; then refresh `f_lms_last_health = pEdict->v.health`. Combat damage inside the zone won't trip this — clean source disambiguation without parsing damage flags.
- Role evaluation, throttled to ~0.75s, in priority order:
  1. **RETREATER** when `health <= LMS_RETREAT_HP` (25 HP) OR `bZoneHurt` OR `!bInZone`. Goal = origin (push toward center).
  2. **HOLDER** (team mode only): `bInZone` AND at least one teammate alive. Goal = `vecSpot` (anchor). Modulates speed near edge.
  3. **HUNTER** (team mode only): an enemy is currently inside the zone. Goal = the intruder's origin. Combat priority bumped (see `BotFindEnemy`).
  4. **SURVIVOR** (default; FFA and team fallback). Goal = origin.
- **Per-bot center jitter** (FFA pile-up mitigation): SURVIVOR / RETREATER `v_goal` is biased to `origin + Vector(cos(entindex), sin(entindex), 0) * radius * 0.3` so multiple bots don't stack on a single pixel. The bias is deterministic per bot so the target is stable from tick to tick.
- Always pre-set `v_goal` + `f_goal_proximity` (small proximity ~32u for SURVIVOR/RETREATER, larger ~96u for HOLDER perimeter point) so the movement layer has a target even on combat ticks. `BotGoalElevatedJump(pBot, vecSpot)` runs from PreUpdate for every role except HOLDER (HOLDER stays put rather than climbing onto an elevated spot).
- Suppress random item detours: `pBotPickupItem = NULL`, `item_waypoint = -1`.

#### Think (`BotLmsThink`, else-if in the `BotThink` dispatch chain)
```cpp
else if (is_gameplay == GAME_LMS && BotLmsThink(pBot))
{
    // BotLmsThink sets v_goal + f_move_speed for all LMS cases.
}
```
- Returns `false` (defer to default nav) when no spot exists or bot is in pre-round / eliminated state.
- Per-role movement:
  - **SURVIVOR / RETREATER**: `f_move_speed = f_max_speed`, `v_goal = (origin + per-bot jitter)`, `f_goal_proximity = 32`. `BotGoalElevatedJump(pBot, vecSpot)` to clear ledges.
  - **HOLDER**: anchor inside zone. If far from center, sprint in; once inside, slow to `0.35 * f_max_speed`. Face nearest intruder (or center if none).
  - **HUNTER**: full speed toward the intruder's origin (`BotLmsFindZoneIntruder` result).
- Updates `f_lms_last_in_zone = gpGlobals->time` while inside.
- **HOLDER perimeter overshoot guard**: when role is HOLDER and `!bInZone` for > 0.75s, demote to RETREATER for one tick so chase momentum doesn't drag the holder into the red zone.

#### Enemy Prioritization (`BotFindEnemy`)
- In the `GAME_LMS` block:
  - Enemies inside the current radius get a strong distance bonus (`-1500u`).
  - Enemies within `LMS_NEARBY_RADIUS` (768u) get a moderate bonus (`-500u`).
  - When the bot's own HP ≤ `LMS_RETREAT_HP`, **deprioritize** every engagement (`+2000u`) so RETREATER actually disengages.

#### Forget-Enemy Exception (`BotFindEnemy`)
- `GAME_LMS` joins `GAME_CTF` / `GAME_ARENA` / `GAME_COLDSPOT` in the list that **does not** re-target a fading enemy. Keeps RETREATER from being yanked back into a fight while bleeding out into the red zone.

#### Direct-Steer Condition (`bot.cpp` movement block)
- `lmsChase` joins the `coldspotChase` / `ctfChase` / `arenaChase` family. When `is_gameplay == GAME_LMS` and `v_goal` is non-zero: direct-steer if within 128u unconditionally, or within `LMS_DIRECT_STEER` (400u) with `FVisible(v_goal, pEdict)`.

#### Pre-Round / Eliminated Idle (`bot.cpp` `BotThink`)
- Before the combat dispatch, when `is_gameplay == GAME_LMS` AND (no spot OR `pev->iuser1 != 0` OR `pev->frags <= 0`):
  - `pBot->pBotEnemy = NULL`
  - `pBot->v_goal = g_vecZero`
  - Suppress `IN_ATTACK` for one frame.
  - Skip the rest of the combat / nav block this tick.

#### Waypoint Routing (`bot_navigate.cpp`)
- `GAME_LMS` is added to the **0.5s recalc gate** (~L572 / L584) so the route refreshes responsively across shrinks and role flips.
- `GAME_LMS` is added to the **waypoint snap** branch (~L717) so when `BotFindWaypointGoal` returns a different `index` than the previous goal, `WaypointFindReachable` re-anchors `curr_waypoint_index`.
- `BotFindWaypointGoal` (~L2145) has a `GAME_LMS` branch right after Cold Spot: pick the nearest waypoint to `pBot->v_goal` by pure distance (no LOS — the zone can straddle obstacles). **Do not assign `pBot->waypoint_goal = index`** — the change-detection in the caller depends on the old value.

#### `v_goal` Preservation
- `GAME_LMS` is added to the "always forget goal" exclusion list in `bot.cpp` so the per-role pre-set survives between PreUpdate and the movement block.

### Tunables
| Constant | Value | Purpose |
|----------|-------|---------|
| `LMS_ZONE_SLACK` | 96u | Hysteresis margin inside the radius; bot considers itself "in zone" only when ≥ `radius - slack` from edge |
| `LMS_NEARBY_RADIUS` | 768u | `BotFindEnemy` "near-zone" threat bonus radius |
| `LMS_DIRECT_STEER` | 400u | Direct-steer radius (with visibility) |
| `LMS_RETREAT_HP` | 25 HP | Low-life threshold; flips role to RETREATER and deprioritizes combat |
| `LMS_RETREAT_HOLD_TIME` | 4.0s | Stay in RETREATER for at least this long after a zone-damage event |
| Relocation delta | 32u | `pev->origin` delta that triggers waypoint invalidation (between rounds) |
| Role eval interval | 0.75s | Throttle role transitions |
| HOLDER overshoot grace | 0.75s | How long HOLDER may sit outside zone before demoting to RETREATER |

### Key Differences from Cold Spot
- **Lives system**: `pev->frags` is the lives counter, not a score — drops monotonically and ends the player's round at 0. Cold Spot has no such gate; a Cold Spot bot can die freely and respawn.
- **Shrinking radius**: zone size is volatile via `pev->body` (8 → 1). Cold Spot's radius is fixed at 256u.
- **Stable origin**: within a single round, the safe spot does not move — only its size changes. Cold Spot's origin is volatile.
- **Damage outside**: standing in the wrong place actively kills you. Cold Spot only rewards being inside; standing outside is neutral.
- **FFA path**: LMS supports both team and FFA modes via `mp_royaleteam`. Cold Spot is team-only.
- **Round-based**: `g_GameInProgress` controls arena entry. Cold Spot is non-round-based (continuous play).
- **No LoS gate**: damage / heal eligibility is pure distance — Cold Spot adds a traceline LoS check.

### Implementation Notes / Lessons Learned
1. **`pev->iuser1 == 0 && pev->frags > 0` is the eligibility idiom**: `IsInArena` is a `CBasePlayer` private and unreachable from the bot DLL. The proxy is exact because both fields are only set by gamerules at round start (`InsertClientsIntoArena`) and reset on elimination / disconnect.
2. **Shrink detection must invalidate routing**: when `pev->body` drops, the same origin that was "inside" can become "outside" — but the waypoint path was computed against the old radius. Without the shrink-detect wipe, bots will happily walk to a waypoint that's now in the red zone and stay there.
3. **`BotFindWaypointGoal` change-detection contract**: same as Cold Spot — the LMS branch must NOT assign `pBot->waypoint_goal = index` before returning. The caller compares `index != pBot->waypoint_goal` to trigger the `curr_waypoint_index` refresh.
4. **PreUpdate / Think must agree on `v_goal`**: a HOLDER on a combat tick would otherwise get direct-steered toward `vecSpot` (sprint into center) when its intended target is the perimeter anchor. The role-aware switch in PreUpdate mirrors `BotLmsThink`.
5. **`pSpot == NULL` is the normal pre-round state** — not an error. The bot side must handle it cleanly (idle) rather than spamming `ALERT`s or wiping state every tick.
6. **Zone-damage probe via HP delta** disambiguates ring damage from combat damage: combat damage can happen inside the zone, ring damage cannot. `bZoneHurt = !bInZone && health dropped` is reliable enough that we don't need to parse `DMG_SHOCK` flags or hook server-side `TakeDamage`.
7. **Per-bot center jitter** is essential in FFA — without it, every bot drifts to identical `vecSpot` coordinates and pile-ups jam waypoint nav. The jitter uses `entindex()` (stable across the round) so the target doesn't oscillate.
8. **HOLDER overshoot grace**: combat momentum (chase, knockback) routinely pulls HOLDERs across the perimeter. Demoting to RETREATER after 0.75s of being out-of-zone forces them back without losing the role state permanently.
9. **`f_lms_last_health` baseline**: must be initialized from `pev->health` on first non-NULL spot tick, otherwise the first PreUpdate triggers a spurious `bZoneHurt`. The reset in `BotSpawnInit` sets it to 0 — the PreUpdate seeds it on first contact.
10. **Items off the table**: LMS rounds rarely benefit from a weapon detour, and leaving the zone for a pickup is usually fatal. The unconditional `pBotPickupItem = NULL` matches Cold Spot's approach. (Optional future tweak: allow detours when the item is within 1.0× current radius.)

## Mutators Blocked
- Not currently overridden in gamerules. Mutators are paused during pre-round (`PauseMutators()`) and restored when the round starts (`RestoreMutators()`).

## Pitfalls (Quick Reference)
- **Don't compare bot-team values directly to `fuser4`**: bot-side `UTIL_GetTeam()` returns 1/2 (blue/red); `fuser4` is 0/1. Always go through `UTIL_GetTeam(pPlayer)` for zone-occupancy counts.
- **Don't expect a spot before `g_GameInProgress`**: the safe spot is created 1s into the round, not at map load. Pre-round PreUpdate must idle gracefully on `pSpot == NULL`.
- **Body 0 doesn't happen** (gamerules clamps shrinks at body ≥ 1 by the round-end check, but for safety the bot's `BotLmsCurrentRadius` uses `max(1, body)`).
- **Model change kills you in team mode**: bots should never attempt model swaps in LMS team mode. The mode's `ClientUserInfoChanged` enforces this server-side, so the worst-case is a free death — but it's still avoidable.
- **`royaledamage 0` makes the zone cosmetic**: heal and damage both pause. Bots still converge on the zone (it's the predicted fight venue), but RETREATER triggers only when low HP, not when outside zone.
- **Eliminated bots are observers, not dead players**: `pev->iuser1` becomes non-zero and `pev->frags` is 0. The fake-client auto-promotion path handles re-entry on the next round; LMS bot code only needs to **not act** while eliminated.
