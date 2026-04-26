# Cold Spot Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_COLDSPOT = 6` (defined in `common/const.h`)
- **String ID**: `"coldspot"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Cold Spot"` — team-based zone-hold mode
- **Source**: `src/dlls/coldspot_gamerules.cpp`, `src/dlls/coldspot_gamerules.h`
- **Class**: `CHalfLifeColdSpot : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (Cold Spot bot logic is implemented, including `BotColdSpotPreUpdate` and `BotColdSpotThink`)

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, the cross-DLL `fuser4` / `RADAR_*` conventions, the [`v_goal` Preservation Contract](gamerules.md#critical--v_goal-preservation-contract), and the bot integration checklist that every mode (including Cold Spot) must satisfy.

## Concept
A single "cold spot" entity spawns on the map. Any player standing within 256 units of the spot, alive, not spectating, and with clear line-of-sight to the spot center contributes to their team's **hold counter** on each 1-second think tick. When a team's counter reaches **10 consecutive uncontested ticks** (~10 seconds of sole possession), every eligible teammate in the zone is awarded 1 `m_iRoundWins` point and the counter resets. If players from **both** teams are present in the zone simultaneously the spot is **contested** and neither counter advances that tick (counters are retained, not cleared). The spot periodically relocates (driven by the `coldspottime` cvar) to force map movement; relocation resets both counters to 0.

## Win Condition
- First team to reach `scorelimit` combined `m_iRoundWins` wins
- Score tracked per player via `m_iRoundWins`; team totals aggregated in `UpdateHud()`
- `GoToIntermission()` fires when a team hits the threshold

## Scoring Prerequisites
All of the following must be true for a given player to be counted as "present in the zone" on a think tick:
1. Alive (`IsAlive()`) and not spectating (`pev->iuser1 == 0`)
2. Within 256 units of the coldspot origin (`UTIL_FindEntityInSphere` radius 256)
3. Clear line of sight to the spot center (`UTIL_TraceLine`, dont_ignore_monsters, ignore_glass, must hit the player entity itself)

Only when a team has **at least one** eligible player present AND the other team has **zero** eligible players does that team's counter advance. A point is awarded on the tick that bumps the counter to 10, at which point the counter resets to 0.

When contested, eligible players see: `"Spot contested. Hold it alone to score!"`
When LoS fails: `"To score, see the cold spot center!"`

## Teams
- **Blue (Iceman)**: `TEAM_BLUE = 0`, `pev->fuser4 = 0`, model = `iceman`
- **Red (Santa)**: `TEAM_RED = 1`, `pev->fuser4 = 1`, model = `santa`
- `UTIL_GetTeam` (bot-side) returns `1 = blue`, `2 = red` (1-indexed; differs from `TEAM_BLUE/TEAM_RED`)
- Auto-join balances team sizes; model change kills the player and respawns
- Only `iceman` and `santa` models allowed; enforced in `ClientUserInfoChanged`
- `IsTeamplay()` returns `TRUE`
- `PlayerRelationship`: `GR_TEAMMATE` if same team name, `GR_NOTTEAMMATE` otherwise
- `FPlayerCanTakeDamage`: blocked between teammates when `friendlyfire == 0`
- `ShouldAutoAim`: disabled against teammates

## Cold Spot Entity (`CColdSpot`, classname `"coldspot"`)
- **Model**: `models/coldspot.mdl`
- **Physics**: `MOVETYPE_NONE`, `SOLID_NOT`
- **Bbox**: `g_vecZero` to `g_vecZero` (zero-size — it is a marker, not a trigger)
- **Body**: set at creation (`CreateColdSpot(vecOrigin, body)`), currently always `0`
- **Think**: `CColdSpot::ColdSpotThink` — initial tick 2.0s after spawn, then every 1.0s

### State Tracking
| Field | Type | Purpose |
|-------|------|---------|
| `pev->origin` | Vector | Position of the scoring zone center |
| `pev->fuser4` | float | Radar identifier: `RADAR_COLD_SPOT` (5) |
| `pev->classname` | string | `"coldspot"` (entity lookup key) |
| `pev->body` | int | Reserved (currently unused for gameplay) |
| `m_iBlueCounter` | int | Consecutive uncontested ticks with Blue alone in zone. Awards 1 team point on reaching 10, then resets. Paused (retained) when contested / empty. Cleared on spot relocation. |
| `m_iRedCounter` | int | Same as above for Red. |
| `m_iHoldingTeam` | int | Current hold state: `TEAM_BLUE` / `TEAM_RED` = that team is alone and scoring; `-1` = empty or contested (counters paused). Updated every tick by `ColdSpotThink`; read by `UpdateHud` to decide which counter's progress line to display. |

### Scoring Tick (`ColdSpotThink`, every 1.0s)
Two-pass algorithm over all entities in a 256u sphere around `pev->origin`:

**Pass 1 — Eligibility & contest detection**:
- Gather every living, non-spectator player with clear LoS
- Record `bBluePresent` / `bRedPresent` flags based on each player's `pev->fuser4`
- Cap tracked players at 32
- Set `bContested = bBluePresent && bRedPresent`
- Update `m_iHoldingTeam` from the three flags (`TEAM_BLUE` / `TEAM_RED` / `-1`)

**Pass 2 — Per-player status feedback**:
- Show `cam_zone` status icon for ~3s (refreshed every tick the player is in zone)
- If `bContested`: center-print `"Spot contested. Hold it alone to score!\n"` to each in-zone player

**Pass 3 — Counter advance**:
- Skip entirely if `bContested` (counters retained, not cleared).
- Otherwise, increment the counter for the lone team (`m_iBlueCounter` or `m_iRedCounter`).
- If the incremented counter reaches `>= 10`, set `scoringTeam` and reset that counter to 0.

**Pass 4 — Point award (only when `scoringTeam != -1`)**:
For every eligible player on `scoringTeam`:
- `WRITE_SHORT(++pPlayer->m_iRoundWins)` via `gmsgScoreInfo` broadcast
- Regen +2 HP (capped at `max_health`) — passive reward for zone control
- Green screen fade (`UTIL_ScreenFade`, 0.25s, 2s hold, alpha 32)
- `CLIENT_SOUND_LEVEL_UP` to human clients (skipped for `FL_FAKECLIENT`)

Then broadcast a single `UTIL_ClientPrintAll` center message: `"Blue Team Scored N Point(s)!"` / `"Red Team Scored N Point(s)!"`.

**Every tick**: call `CHalfLifeColdSpot::UpdateHud()` to refresh the objective strip (HUD decides internally whether to actually resend — see below).

**Reschedule**: `pev->nextthink = gpGlobals->time + 1.0;`

## Spot Relocation (Gamerules `Think`)
- Driven by `coldspottime` cvar (default per `game.cpp`)
- On the first tick and every `coldspottime` seconds thereafter:
  - `EntSelectSpawnPoint(coldspotspawn.string)` picks a new spawn marker entity
  - First relocation creates the `CColdSpot`; subsequent relocations just `UTIL_SetOrigin`
  - Special-entity message broadcast (`gmsgSpecialEntity`, slot 0, `RADAR_COLD_SPOT`) updates all clients' radars
  - **Counter reset**: `pSpot->m_iBlueCounter = 0; pSpot->m_iRedCounter = 0;` — in-progress hold progress does not carry between locations
  - `UpdateHud()` called immediately so the objective strip reflects the reset
  - Plays `CLIENT_SOUND_EBELL` globally
  - Prints `"[ColdSpot] The cold spot has moved!"`
- Bots must treat `pev->origin` as **volatile** — it changes during a match and they should re-path on relocation.

### Spawn Point Validation (`IsSpawnPointValid`)
- Rejects any spot within 2048 units of another entity of the same class (ensures spread)

## Gamerules Class (`CHalfLifeColdSpot`)

### Key Members
| Field | Type | Purpose |
|-------|------|---------|
| `pColdSpot` | EHANDLE | Active coldspot entity (single per match) |
| `pLastSpawnPoint` | EHANDLE | Most recent spawn marker used for relocation |
| `m_fSpawnColdSpot` | float | Next relocation time (0 = never) |
| `m_fColdSpotTime` | float | Cached value of `coldspottime` cvar |
| `m_iBlueScore` / `m_iRedScore` | int | Cached team totals (aggregated from `m_iRoundWins`) |
| `m_DisableDeathPenalty` | BOOL | Suppresses PlayerKilled during team-change kill |
| `m_iLastHudHoldingTeam` | int | Last `m_iHoldingTeam` value sent to clients. Seeded to `-2` in the ctor so the first `UpdateHud` call always broadcasts. |
| `m_iLastHudBlueCounter` / `m_iLastHudRedCounter` | int | Last counter values broadcast, for change detection. |
| `m_iLastHudBlueScore` / `m_iLastHudRedScore` | int | Last aggregated team totals broadcast, for change detection. |
| `m_bLastHudValid` | bool | `false` until the first successful broadcast, then `true`. Prevents the gate from suppressing the initial send. |

### Constructor
- Precaches `"coldspot"` entity class
- `m_fSpawnColdSpot = gpGlobals->time + 2.0` (initial spawn delay)
- `m_fColdSpotTime = coldspottime.value`
- `m_iBlueScore = m_iRedScore = 0`
- All `m_iLastHud*` fields zeroed; `m_iLastHudHoldingTeam = -2`; `m_bLastHudValid = false`

### UpdateHud
Called every 1s from `ColdSpotThink` and on every spot relocation. Responsibilities:
1. Aggregate `m_iRoundWins` per team into `m_iBlueScore` / `m_iRedScore`.
2. Select the primary objective line from `pSpot->m_iHoldingTeam` (**not** from "whichever counter is > 0"):
   - `TEAM_BLUE` → `"Blue Scoring: N of 10"` (uses `m_iBlueCounter`)
   - `TEAM_RED`  → `"Red Scoring: N of 10"`  (uses `m_iRedCounter`)
   - `-1`        → `"Hold the cold spot"`
   This is important because counters are **retained** across contested / empty ticks, so after the spot changes hands both counters can be non-zero; selecting by `m_iHoldingTeam` guarantees the line reflects the team that is *currently* scoring (or shows the neutral label when nobody is).
3. **Change-gated broadcast**: build the state signature `{m_iHoldingTeam, m_iBlueCounter, m_iRedCounter, m_iBlueScore, m_iRedScore}` and compare to `m_iLastHud*` + `m_bLastHudValid`. If identical, skip the per-client `gmsgObjective` loop entirely — typical idle / contested ticks do not touch the network at all. On a change, broadcast to every connected, non-`FL_FAKECLIENT` player (writes STRING primary, STRING line2, BYTE color 0, STRING line3; lines 2/3 carry the two team totals, ordered so the local player's team is line2), then copy the signature into `m_iLastHud*` and set `m_bLastHudValid = true`.
4. **Always** (outside the gate) check `scorelimit` → `GoToIntermission()` so end-of-session is not delayed by HUD suppression.

### Team Entry (`AutoJoin`)
- Balances by counting `fuser4`-based team membership across all clients
- Forces `model` to `iceman` (blue) or `santa` (red)
- Broadcasts `gmsgTeamInfo` / `gmsgScoreInfo` on assignment

### ClientUserInfoChanged
- Locks models to `iceman`/`santa`; any other model is corrected and the player is killed+respawned
- `pev->fuser4` is updated to match the new team's ID (`TEAM_BLUE`/`TEAM_RED`)

## Key Constants
```cpp
#define TEAM_BLUE 0
#define TEAM_RED  1

#define RADAR_COLD_SPOT 5       // pev->fuser4 on coldspot entity (and special-entity slot type)

// Cvars
// coldspottime        — seconds between spot relocations (0 = never relocate)
// coldspotspawn       — entity classname used as relocation anchors (spawn markers)
// scorelimit          — team points required to win
// friendlyfire        — non-zero allows teammate damage
```

## Key Detection Flags
| Check | Value | Meaning |
|-------|-------|---------|
| `pEnt->v.classname == "coldspot"` | string | Entity is the coldspot |
| `pEnt->v.fuser4 == RADAR_COLD_SPOT` | 5 | Confirms radar identity |
| `pPlayer->v.fuser4` | TEAM_BLUE / TEAM_RED | Player's team (0 or 1) |
| Distance to `spot->v.origin` | <= 256 | Inside scoring zone |
| LoS spot → player eye | `tr.pHit == pPlayer` | Player can score |

## Bot Relevance
- A single coldspot entity exists on the map at any time — cache one edict.
- `pev->origin` is **not stable across the match** — the spot relocates on `coldspottime` intervals. Bots must re-cache whenever the origin changes (or simply invalidate every frame).
- Scoring requires LoS to the spot center — geometry matters. Bots cannot score from behind cover, even inside the 256u radius.
- Zone is zero-size / `SOLID_NOT` — no touch trigger. Bots must enter the radius geometrically (no `SOLID_TRIGGER` overlap needed).
- `+2 HP` per scoring tick rewards holding, which feeds back into willingness to stay and fight.
- Contested zones score nobody — clearing enemies out of the zone is strictly better than standing next to them while they also score nothing.
- Spot relocation is broadcast via `gmsgSpecialEntity` for HUD radars; bots instead read the entity directly.

## Bot AI Implementation (grave-bot-src)

### Current Status
**Fully implemented.** `BotColdSpotPreUpdate` and `BotColdSpotThink` are live in `bot_combat.cpp`, dispatched from `bot.cpp` alongside the other teamplay gamemodes. Bots cache the `coldspot` edict, evaluate a per-bot role every ~0.75s, and route to `pev->origin` via the shared waypoint system with `v_goal` preservation. Role state is reset in `BotSpawnInit` and a dedicated relocation branch in `BotColdSpotPreUpdate` clears stale waypoint fields whenever `pev->origin` changes between ticks.

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"coldspot"` via `strstr` or `atoi == GAME_COLDSPOT`
- Sets `is_team_play = TRUE`
- Sets `is_gameplay = GAME_COLDSPOT`
- **CRITICAL**: Without this entry, `is_gameplay` stays at 0 (default FFA), and all `GAME_COLDSPOT` checks would be dead.

### Architecture (mirrors CTF / KTS / Cold Skulls patterns)

#### State (`bot.h`)
```cpp
// Role enum (alongside CTF_ROLE_*)
enum {
    CSPOT_ROLE_NONE = 0,
    CSPOT_ROLE_SEEKER,      // no other bot in zone; take the spot
    CSPOT_ROLE_HOLDER,      // already in zone; stay to score
    CSPOT_ROLE_DEFENDER,    // ally scoring; approach perimeter to intercept intruders
    CSPOT_ROLE_HUNTER       // enemy holding zone; rush in to clear
};

// bot_t fields
int   i_coldspot_role;           // current role (CSPOT_ROLE_*)
float f_coldspot_role_eval_time; // throttle for re-evaluating role (~0.75s)
float f_coldspot_last_in_zone;   // last gpGlobals->time the bot was inside the 256u zone
```

All three are reset in `BotSpawnInit` (role → `CSPOT_ROLE_NONE`, timers → 0).

#### Entity Caching (`bot_combat.cpp`)
```cpp
static float   s_coldspot_cache_time = -1.0f;
static edict_t *s_pColdSpot = NULL;

static void BotColdSpotFindEntity()
{
    if (s_coldspot_cache_time == gpGlobals->time) return;
    s_coldspot_cache_time = gpGlobals->time;
    s_pColdSpot = NULL;
    edict_t *pEnt = NULL;
    while ((pEnt = UTIL_FindEntityByClassname(pEnt, "coldspot")) != NULL)
    {
        if ((int)pEnt->v.fuser4 == RADAR_COLD_SPOT) { s_pColdSpot = pEnt; break; }
    }
}
```

Helpers:
- `BotColdSpotFindZoneIntruder(pSpot, botTeam)` — returns the nearest living enemy player inside `CSPOT_ZONE_RADIUS` so HOLDERs can face the most pressing threat. Returns `NULL` when the zone is clear.

#### Pre-Update (`BotColdSpotPreUpdate`, called every frame before `BotFindEnemy`)
- Refresh cache; if no spot exists, bail (fall back to deathmatch).
- **Relocation invalidation**: compare `pSpot->v.origin` to `pBot->v_coldspot_last_origin`. On any delta > 32u, wipe stale routing state so the next `BotHeadTowardWaypoint` re-paths cleanly: `waypoint_goal = -1`, `old_waypoint_goal = -1`, `f_waypoint_goal_time = 0`, `curr_waypoint_index = -1`, `f_waypoint_time = 0`, `prev_waypoint_distance = 0`, `prev_waypoint_index[0..4] = -1`, `f_pause_time = 0`, `wpt_goal_type = WPT_GOAL_NONE`.
- Compute `bInZone = (distance < 256u)` for this bot; update `f_coldspot_last_in_zone`.
- Evaluate role every ~0.75s (counts allies / enemies in the zone):
  - `bInZone` + enemy-in-zone → `HOLDER` (fight intruders, don't leave)
  - `bInZone` + no enemy-in-zone → `HOLDER` (keep feeding the counter)
  - `!bInZone` + enemy-in-zone, no allies → `HUNTER` (rush zone, clear it)
  - `!bInZone` + allies-in-zone, no enemies → `DEFENDER` (cover perimeter)
  - else → `SEEKER`
- **Role-aware pre-set of `v_goal` / `f_goal_proximity`** — must match what `BotColdSpotThink` would set, otherwise combat-tick routing can contradict the intended behavior (e.g. direct-steer a DEFENDER into the zone and cause a contest):
  - `HOLDER`   → `v_goal = vecSpot`, proximity `CSPOT_HOLDER_RADIUS` (128u)
  - `DEFENDER` → `v_goal = vecSpot + (botPos - vecSpot).Normalize() * CSPOT_DEFEND_RADIUS` (perimeter point on the bot's own side of the spot), proximity `64u`
  - `HUNTER` / `SEEKER` (default) → `v_goal = vecSpot`, proximity `0u` (run through it)
- **Elevated-jump advance** — call `BotGoalElevatedJump(pBot, vecSpot)` for every role except `DEFENDER`. This is the same helper CTF uses: 3-phase jump sequence (ground jump → double jump → triple jump / flip) with a 0.5s stall wait and a 300u horizontal / 20u vertical activation gate. Running it from `PreUpdate` instead of only from `BotColdSpotThink` means the sequence also advances on **combat ticks**, so a bot engaged with an enemy while standing directly below an elevated coldspot can still double/triple-jump up onto it. DEFENDER is intentionally skipped because its goal is the perimeter offset, not the spot itself.
- Suppress random item detours: `pBotPickupItem = NULL`, `item_waypoint = -1`.

#### Think (`BotColdSpotThink`, else-if in the `BotThink` dispatch chain)
Inserted after the `GAME_ARENA` branch in `bot.cpp`:
```cpp
else if (is_gameplay == GAME_COLDSPOT && BotColdSpotThink(pBot))
{
    // BotColdSpotThink sets v_goal + f_move_speed for all Cold Spot cases.
}
```
Role movement (runs on non-combat ticks; combat ticks use the PreUpdate pre-set):
- **SEEKER / HUNTER**: `f_move_speed = f_max_speed`, `v_goal = vecSpot`, `f_goal_proximity = 0`; `BotGoalElevatedJump(pBot, vecSpot)`.
- **HOLDER**: stay within `CSPOT_HOLDER_RADIUS` (128u) of center. If outside, run toward `vecSpot` at full speed; once inside, slow to `0.35 * f_max_speed` so the bot doesn't drift out of LoS. Face the nearest zone intruder via `BotColdSpotFindZoneIntruder`, falling back to facing the spot. `BotGoalElevatedJump(pBot, vecSpot)`.
- **DEFENDER**: `f_move_speed = f_max_speed`, `v_goal = vecSpot + (botPos - vecSpot).Normalize() * CSPOT_DEFEND_RADIUS` (perimeter), `f_goal_proximity = 64`. Intentionally **no** elevated-jump call — the goal is outside the zone, not on the spot.
- Returns `true` whenever a spot exists; `false` lets normal nav take over.

#### Enemy Prioritization (`BotFindEnemy`)
- In the `GAME_COLDSPOT` block, score each candidate enemy with a distance-to-spot bonus: enemies inside `CSPOT_ZONE_RADIUS` (256u) get the strongest priority boost, enemies inside `CSPOT_NEARBY_RADIUS` (512u) get a partial boost. This biases target selection toward zone threats so bots converge on whoever is contesting / occupying the spot instead of chasing random frags across the map.

#### Direct-Steer Condition (`bot.cpp` movement block)
- `coldspotChase` joins the existing `ktsDirectSteer` / `ctfChase` / `arenaChase` family. When `is_gameplay == GAME_COLDSPOT` and `v_goal` is non-zero: direct-steer is enabled if the bot is within `128u` of `v_goal` unconditionally, or within `500u` with `FVisible(v_goal, pEdict)`. This makes the final approach to the zone go straight rather than relying on a nearby waypoint.

#### Waypoint Routing (`bot_navigate.cpp` — `BotFindWaypointGoal`)
- A `GAME_COLDSPOT` branch treats `v_goal` (the current per-role coldspot target set by `BotColdSpotPreUpdate`) as the destination and picks the nearest waypoint by pure Euclidean distance (no LOS, no team-flag mismatch).
- **Do not assign `pBot->waypoint_goal = index` inside this branch.** The caller (`BotHeadTowardWaypoint`) compares the returned `index` against the **previous** `waypoint_goal` to detect a goal change and snap `curr_waypoint_index` to the nearest reachable waypoint. If the callee mutates `waypoint_goal` first, that equality check is always false and stale routing is never cleared after a spot relocation. The caller performs the final `pBot->waypoint_goal = index` after the change-detection block.
- `GAME_COLDSPOT` is also added to the 0.5s recalc gate and the `v_goal` preservation list so the generic "forget goal" reset in `bot.cpp` does not wipe the coldspot target.

### Team mapping (bot perspective)
- `UTIL_GetTeam(pEdict)` returns `1` (blue) or `2` (red) — same as CTF / KTS.
- Gamerules `TEAM_BLUE = 0` / `TEAM_RED = 1` are player `fuser4` values, **not** bot team IDs.
- When counting zone occupancy with `UTIL_FindEntityInSphere`, translate via `UTIL_GetTeam(pPlayer)` to avoid mixing the two systems.

### Tunables
| Constant | Value | Purpose |
|----------|-------|---------|
| `CSPOT_ZONE_RADIUS` | 256u | Matches gamerules `UTIL_FindEntityInSphere` |
| `CSPOT_HOLDER_RADIUS` | 128u | HOLDER anchor to center; in-zone detection for role eval |
| `CSPOT_DEFEND_RADIUS` | 200u | Perimeter offset used by DEFENDER `v_goal` |
| `CSPOT_NEARBY_RADIUS` | 512u | `BotFindEnemy` "near-zone" threat bonus radius |
| `CSPOT_DIRECT_STEER` | 300u | (reserved; actual direct-steer uses 128u / 500u-visible) |
| Relocation delta | 32u | `pev->origin` delta that triggers waypoint invalidation |
| Role eval interval | 0.75s | Throttle role transitions |
| Elevated-jump horz gate | 300u | Max horizontal distance to start a jump sequence |
| Elevated-jump vert gate | 20u | Minimum goal-above-bot height to start a jump sequence |

### Key Differences from CTF / KTS / Cold Skulls
- **Volatile goal origin**: The coldspot **moves mid-match**. CTF flags/bases and KTS goals are static. Bots must refresh `v_goal` every tick, not only on role change.
- **LoS-gated scoring**: Unlike touch-trigger objectives (flag pickup, base capture, chumtoad touch), scoring here requires a clear traceline from spot to player eyes. Bots must stand in open line-of-sight, not just inside the radius.
- **Zero-size, non-solid entity**: Unlike CTF flags (`SOLID_TRIGGER` bbox) or skulls (touch), the coldspot is `SOLID_NOT`. Bots navigate to its origin point; there's no trigger to fire. `f_goal_proximity` can be as loose as 64–128u for HOLDERs without missing any "capture".
- **Passive team scoring**: Unlike CTF (one-shot captures) or Cold Skulls (pickup-per-skull), scoring accrues continuously while in zone. This means **prolonged presence** matters more than rapid movement; role balancing should favor HOLDERs over SEEKERs once the zone is secured.
- **Contest mechanic**: Two-team presence zeros out scoring for everyone — a HOLDER can be "denied" by a single intruder even without dying. Clearing intruders is as valuable as standing in the zone.
- **No carrier concept**: There's no analog to `pFlag->v.aiment` — no carry state, no drop mechanic. Role evaluation is purely positional.

### Implementation Notes / Lessons Learned
1. **`v_goal` wipe**: `bot.cpp` has a `pBot->v_goal = g_vecZero` ("always forget goal") block. `GAME_COLDSPOT` is in the exclusion list alongside `GAME_CTF` / `GAME_KTS` / `GAME_COLDSKULL` / `GAME_CTC` / `GAME_ARENA` so the per-role pre-set survives each tick.
2. **Relocation invalidation**: After the spot moves, any cached waypoint-to-goal routing is stale. `BotColdSpotPreUpdate` compares `pSpot->v.origin` to `pBot->v_coldspot_last_origin` (32u delta threshold) and clears every field that could pin the bot to the old waypoint — not just `waypoint_goal`/`old_waypoint_goal`, but also `curr_waypoint_index`, the 5-slot `prev_waypoint_index` history, `f_waypoint_goal_time`, `f_waypoint_time`, `prev_waypoint_distance`, `f_pause_time`, and `wpt_goal_type`. Missing any of these leaves the bot walking toward the old zone.
3. **`BotFindWaypointGoal` change-detection contract**: The Cold Spot branch must **not** assign `pBot->waypoint_goal = index` before returning — the caller's `index != pBot->waypoint_goal` check is what triggers the `curr_waypoint_index` refresh when the goal changes. Mutate only `wpt_goal_type` and return the index.
4. **PreUpdate / Think must agree on `v_goal`**: `BotColdSpotThink` only runs on non-combat ticks. If `BotColdSpotPreUpdate` sets `v_goal = vecSpot` unconditionally, a DEFENDER on a combat tick gets direct-steered into the zone and contests it. The fix is a role-aware switch in PreUpdate that mirrors `BotColdSpotThink`'s per-role targets.
5. **Elevated-jump from PreUpdate**: `BotGoalElevatedJump` is called from both `BotColdSpotThink` (non-combat ticks) and `BotColdSpotPreUpdate` (every tick, excluding DEFENDER). Without the PreUpdate call, a bot fighting directly below an elevated coldspot never advances its jump phases and cannot reach the zone. The helper is idempotent (state lives in `pBot->i_goal_jump_phase` / `f_goal_jump_time`), so being called from both paths on the same frame is safe.
6. **Contested-zone behavior**: Bots should not "camp stalemates" — when contested, HOLDERs push intruders out rather than stand still. `BotFindEnemy` prioritizes zone intruders via the `CSPOT_NEARBY_RADIUS` distance bonus.
7. **LoS-gated scoring**: Gamerules requires a clear traceline from `spot.origin` to the player entity. Bots trace against `spot->v.origin`, not the edict (it is `SOLID_NOT` with a zero bbox). `coldspotChase` uses `FVisible(v_goal, pEdict)` on the final approach so direct-steer only kicks in when the bot has a usable line.
8. **Team mapping**: Gamerules uses `fuser4 = TEAM_BLUE(0) / TEAM_RED(1)`; the bot layer uses `UTIL_GetTeam() = 1 (blue) / 2 (red)`. Zone-occupancy counts must go through `UTIL_GetTeam(pPlayer)`; never compare `fuser4` directly to bot-team values.
9. **`is_team_play` is on**: Cold Spot sets `is_team_play = TRUE`, so existing teamplay-aware code (friendly avoidance, team chat, teammate detection) is active automatically.

## Mutators Blocked
- TBD — defer to gamerules `MutatorAllowed` overrides if/when added. None currently enumerated in `coldspot_gamerules.cpp`.
