# Horde Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_HORDE = 10` (defined in `common/const.h`)
- **String ID**: `"horde"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Horde"` — survivors-vs-monsters wave-based co-op
- **Source**: `src/dlls/horde_gamerules.cpp`, `src/dlls/horde_gamerules.h`
- **Class**: `CHalfLifeHorde : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` — `BotHordePreUpdate`, `BotHordeThink`, `BotHordePickTarget`, `BotHordeFindEntities` (helpers static within the file).

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, the cross-DLL `fuser4` / `RADAR_*` conventions, the [`v_goal` Preservation Contract](gamerules.md#critical--v_goal-preservation-contract), and the bot integration checklist that every mode (including Horde) must satisfy.

## Concept
All connected players join a single team (`"survivors"`, `pev->fuser3 == 1`) and face waves of NPC monsters spawned by the gamerules. Each wave spawns `ENEMY_TOTAL` monsters at deathmatch spawn points; their `pev->message` is set to the literal string `"horde"` and `pev->fuser4` is set to `RADAR_HORDE` so they show on the radar and can be enumerated cheaply. Monster classes rotate through `szMonsters[]` (headcrab → zombie → houndeye → human_grunt → panther → human_assassin → gargantua) as the wave number rises, and per-wave `hardness` scales `pev->max_health` so late waves are dramatically tougher. A wave ends when every horde-tagged monster is dead. After a 3-second pause the next wave spawns; surviving players are **not** sent to spectator — they keep their position on the map and are restocked to `health = 100` when the next wave begins. Players who died sit in spectator until a wave boundary, then re-enter via `ExitObserver`. The game ends when `m_iSuccessfulRounds >= roundlimit`, when `survivors_left < 1`, or when `m_iRoundWins >= scorelimit`.

## Win Condition
- Survive `roundlimit` waves (`m_iSuccessfulRounds`) — co-op victory for the survivors team
- Or hit `scorelimit` `m_iRoundWins` (per-player frag-based) → `GoToIntermission()`
- Loss condition: `survivors_left < 1` mid-wave → game ends, `g_GameInProgress = FALSE`
- No team-vs-team scoring; this is PvE, not PvP

## Wave Lifecycle (`CHalfLifeHorde::Think`)
1. **Wait for players** (`m_fWaitForPlayersTime`) — countdown banner, then initial 5-second countdown.
2. **Wave spawn** (`m_fBeginWaveTime` reached):
   - Restock alive players: `pev->health = 100`.
   - Returning observers re-enter the arena (`ExitObserver`); a 3-second grace window prevents monster collisions.
   - Pick monster class index from `m_iWaveNumber`: `index = (m_iWaveNumber / ENEMY_TOTAL) % ARRAYSIZE(szMonsters)` plus a `+1` increment for the leftover spawns of that wave (so each wave introduces a new tier).
   - For each spawn: `CBaseEntity::Create(monster, spot.origin, spot.angles)`, then **immediately** `pev->message = MAKE_STRING("horde")` and `pev->fuser4 = RADAR_HORDE`.
   - Telefrag-clear: any entity within 64u of the spawn that isn't itself horde-tagged is killed.
   - Hardness scaling: `hardness = (m_iWaveNumber / (ARRAYSIZE(szMonsters) * ENEMY_TOTAL)) * 10`. When `hardness > 1`, `max_health *= hardness` and `health = max_health`.
   - Increment `m_iWaveNumber`.
3. **Wave active**: each tick (`flUpdateTime` cadence ~1.5s), enumerate every entity with `message == "horde"`, count survivors, prune `DEAD_DEAD`/`EF_NODRAW` corpses, and rebroadcast the objective HUD.
4. **Wave end** (`m_iEnemiesRemain <= 0`): play `CLIENT_SOUND_WAVE_ENDED`, increment `m_iSuccessfulRounds`, schedule the next wave (`m_fBeginWaveTime = gpGlobals->time + 3.0`).
5. **Round time limit**: if `HasGameTimerExpired()`, every horde-tagged entity is `UTIL_Remove`'d and the round resets.

## Teams & Damage
- Single survivor team, name `"survivors"`, `pev->fuser3 == 1` set on every player
- `m_szTeamName = "survivors"` is broadcast via `gmsgTeamNames` (one team in the list, plus the synthetic `"other"` slot)
- `IsTeamplay()` returns `TRUE`
- `FPlayerCanTakeDamage`: blocks all PvP damage between survivors (no FF, period — not even with `friendlyfire` non-zero)
- `PlayerRelationship`: `GR_TEAMMATE` for all player→player pairs
- `ShouldAutoAim`: disabled against teammates
- Monsters can damage and kill players normally; players score frags off monsters

## Horde Monster Tagging
| Field | Value | Meaning |
|-------|-------|---------|
| `pev->classname` | one of `szMonsters[]` | Standard HL monster class — uses stock `monster_*` AI |
| `pev->message` | `"horde"` (string table) | Wave-membership tag; the gamerules' authoritative list |
| `pev->fuser4` | `RADAR_HORDE = 8` | Radar identifier (red, 2x size) — see [radar_system.md](radar_system.md) |
| `pev->max_health` | base × `hardness` | Scales with wave number (capped only by float range) |
| `FL_MONSTER` | set | Standard monster flag — bots use this to distinguish from players |

The two tags (`pev->message == "horde"` and `pev->fuser4 == RADAR_HORDE`) are functionally redundant; bots use `pev->message` (string-key entity lookup is `O(monsters)`, no full sphere scan) and double-check `FL_MONSTER`. The radar uses `pev->fuser4` because clients don't see the message string.

## Per-Player State
| Field | Type | Purpose |
|-------|------|---------|
| `IsInArena` | BOOL | TRUE while the player is alive in the wave |
| `m_flForceToObserverTime` | float | Time at which a dead player is sucked to spectator |
| `m_iRoundWins` | int | Waves survived (broadcast via `gmsgScoreInfo`) |
| `m_iRoundPlays` | int | Waves attempted (incremented on every wave end) |
| `m_iAssists` | int | Reset to 0 on every wave end |
| `m_iShowGameModeMessage` | float | Time to show the "Find the monsters. Kill them!" banner |

## Spectator Behavior

> Foundation: see the [Spectator System](gamerules.md#spectator-system) section in the hub document. Horde is **round-based** (`IsRoundBased() == TRUE` at `horde_gamerules.cpp:1071`).

Horde uses the **canonical round-based pattern**: `InsertClientsIntoArena(0)` admits every connected player at wave start, `m_flForceToObserverTime` kicks dead players to spectator after a 3-second death-cam window, and `SuckAllToSpectator()` resets at game-end and countdown-abort edges.

### Connection
- New connects in any mode (round-based included) land in **Limbo**: `iuser3 = OBS_UNDECIDED_SIMPLE`, `m_bWantsToPlay = FALSE`. `PlayerSpawn` gate branch 3 returns and the player parks in `OBS_ROAMING` with the join menu rendered.
- After `auto_join`, `m_bWantsToPlay = TRUE`. The next wave's `InsertClientsIntoArena(0)` admits them (gated on `IsCommittedToPlay()`).
- After `spectate`, `m_bWantsToPlay` stays `FALSE` and they remain observers indefinitely. The `survivors_left` and round-eligibility loops never count them.
- Bots are auto-committed at connect (`m_bWantsToPlay = TRUE` for any `FL_FAKECLIENT`) and the auto-promotion fast path in `multiplay_gamerules.cpp ~1792` calls `ExitObserver()` next tick.

### Wave Start (`horde_gamerules.cpp:749`)
```cpp
g_GameInProgress = TRUE;
InsertClientsIntoArena(0);  // every committed-to-play player → IsInArena = TRUE, ExitObserver()
```
Limbo + Chose-Spectate players are skipped by the `IsCommittedToPlay()` gate. They remain observers across the wave boundary.

The wave-restart branch (`m_fBeginWaveTime` expired) also gates on `IsCommittedToPlay()` when picking observers up off the bench — a Limbo player will not be auto-admitted into a wave they didn't opt into.

### Mid-Wave Death
- `FPlayerCanRespawn` returns `FALSE` (no mid-wave respawn). Dying players get `m_flForceToObserverTime = gpGlobals->time + 3.0` for the death-cam.
- After 3s, `Think()` sucks them to spectator and clears the timer. They watch the rest of the wave.
- `survivors_left < 1` mid-wave → game ends, `g_GameInProgress = FALSE`, `SuckAllToSpectator()`.

### Wave End → Wave Start
- Wave end (all horde monsters dead): `g_GameInProgress` stays `TRUE`. After a 3-second pause, the next wave begins via the same `InsertClientsIntoArena` path. Dead players re-enter; alive players are *not* sent through `ExitObserver` (they were never in observer).
- The 3-second grace at wave start prevents monster-collision telefrags when respawning observers land on a deathmatch start that's near a fresh spawn.
- The score-reset / `m_iRoundPlays++` loop at wave end is gated on `IsCommittedToPlay()` — Limbo and Chose-Spectate players are not credited a wave they didn't play.

### Game End
- `m_iSuccessfulRounds >= roundlimit` or `m_iRoundWins >= scorelimit` → `GoToIntermission()`. `SuckAllToSpectator()` is called from the wave-end path at line 774.
- Countdown abort (player drops below minimum): `SuckAllToSpectator()` at line 707, full reset.

### Bot-Side Implications
Bots in spectator have `EF_NODRAW` and won't be acted on by horde monster AI (they aren't valid `m_hEnemy` targets). The `BotHordeThink` dispatch is gated on `IsAlive()` so observer-state bots don't try to run combat logic.

### Spectator-targeting filter (monsters.cpp / mpstubb.cpp)

Added 2026-05 after a report that horde monsters were tracking and attacking spectators:

- **`CBaseMonster::Look()`** ([mpstubb.cpp](../src/dlls/mpstubb.cpp)) — when scanning visible entities for potential enemies, clients with `EF_NODRAW`, `IsObserver()`, or `IsSpectator()` are skipped. A spectator never enters the candidate list and so cannot become `m_hEnemy`.
- **`CBaseMonster::CheckEnemy()`** ([monsters.cpp](../src/dlls/monsters.cpp)) — releases an already-locked `m_hEnemy` (sets `bits_COND_ENEMY_DEAD`) if it transitions to spectator state mid-engagement (e.g. the player issued `spectate` before the monster could finish them). Without this, a monster could keep firing at an invisible target.

Both files now `#include "player.h"` for the `CBasePlayer::IsObserver/IsSpectator` accessors. The filter is mode-agnostic but in practice only fires in horde (the only multiplayer mode with active monster AI vs. clients).

## Key Constants
```cpp
#define GAME_HORDE   10
#define RADAR_HORDE  8

// szMonsters[] in horde_gamerules.cpp
// {"monster_headcrab", "monster_zombie", "monster_houndeye",
//  "monster_human_grunt", "monster_panther", "monster_human_assassin",
//  "monster_gargantua"}

// Cvars
// roundlimit          — waves required to win
// scorelimit          — alternative per-player frag win condition
// roundwaittime       — pre-game wait window
// roundtimelimit      — per-round timer (HasGameTimerExpired)
```

## Bot Relevance
- **Wave detection is free**: the gamerules pre-tags every spawned monster, so bots never need to maintain their own monster list — a single `UTIL_FindEntityByString(NULL, "message", "horde")` walk is enough to enumerate the live wave.
- **No FF concern**: monster targeting can be aggressive; survivors cannot accidentally hit each other regardless of friendlyfire cvar.
- **Inter-wave breather is the resupply window**: there is no respawn-to-checkpoint reset. Surviving players keep whatever they're holding and have ~3 seconds (plus any time spent standing around between bot scan ticks) to walk the map collecting health/armor/ammo before the next wave spawns. The gamerules **does** auto-restock HP to 100 at wave start, but armor and ammo are **not** topped up.
- **Volatile monster set**: `pev->message == "horde"` entities are created and destroyed every wave. Bots must not cache pointers across wave boundaries.
- **Hardness scaling**: late-wave monsters can have absurd HP. Threat-by-class is more meaningful than threat-by-current-HP for target picking.
- **Radar already drawn for monsters**: human teammates already see horde monsters on the radar; bots reading `pev->message` get the same visibility.

## Bot AI Implementation (grave-bot-src)

### Current Status
**Fully implemented.** `BotHordePreUpdate` and `BotHordeThink` are live in `bot_combat.cpp`, dispatched from `bot.cpp` alongside the other teamplay gamemodes. Bots cache the live monster list per frame, evaluate a per-bot role every ~0.75s, and route to the picked monster's origin via the shared waypoint system with `v_goal` preservation. Role state is reset in `BotSpawnInit`.

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"horde"` via `strstr` or `atoi == GAME_HORDE`
- Sets `is_team_play = TRUE`
- Sets `is_gameplay = GAME_HORDE`
- **CRITICAL**: Without this entry, `is_gameplay` stays at 0 (default FFA), and all `GAME_HORDE` checks would be dead.

### Architecture (mirrors Cold Spot / Busters patterns)

#### State (`bot.h`)
```cpp
// Role enum (alongside CSPOT_ROLE_*, BUSTERS_ROLE_*)
enum {
    HORDE_ROLE_NONE = 0,
    HORDE_ROLE_HUNTER,    // wave active; pursue picked monster
    HORDE_ROLE_RESUPPLY,  // between waves; gather pickups
    HORDE_ROLE_RETREAT    // HP <= 25; fall back to pickups
};

// bot_t fields
int     i_horde_role;            // current role (HORDE_ROLE_*)
float   f_horde_role_eval_time;  // throttle for re-evaluating role (~0.75s)
edict_t *p_horde_target;         // sticky monster target (focus-fire bias)
float   f_horde_target_time;     // expiry for sticky target preference
Vector  v_horde_last_target_org; // last picked monster origin (for waypoint-snap detection)
```

All five are reset in `BotSpawnInit`.

#### Entity Caching (`bot_combat.cpp`)
```cpp
#define MAX_HORDE_CACHE 32
static float    s_horde_cache_time = -1.0f;
static int      s_horde_count = 0;
static edict_t *s_horde_monsters[MAX_HORDE_CACHE];

static void BotHordeFindEntities()
{
    if (s_horde_cache_time == gpGlobals->time) return;
    s_horde_cache_time = gpGlobals->time;
    s_horde_count = 0;

    edict_t *pEnt = NULL;
    while ((pEnt = UTIL_FindEntityByString(pEnt, "message", "horde")) != NULL
        && s_horde_count < MAX_HORDE_CACHE)
    {
        if (FNullEnt(pEnt) || pEnt->free) continue;
        if (!(pEnt->v.flags & FL_MONSTER)) continue;
        if (!IsAlive(pEnt))                continue;
        if (pEnt->v.effects & EF_NODRAW)   continue;
        s_horde_monsters[s_horde_count++] = pEnt;
    }
}
```

The cache is process-global (not per-bot), refreshed once per `gpGlobals->time` tick, and shared by every horde bot in the same frame.

#### Threat Scoring (`BotHordeMonsterScore`)
| Class | Score | Rationale |
|-------|-------|-----------|
| `monster_gargantua` | 100 | One-shot risk; highest priority always |
| `monster_human_assassin` | 60 | High DPS, evasive |
| `monster_panther` | 50 | Fast melee + bite damage |
| `monster_human_grunt` | 40 | Ranged; deals consistent damage |
| `monster_houndeye` | 25 | AoE shockwave |
| `monster_zombie` | 15 | Slow melee |
| `monster_headcrab` | 8 | Trivial |
| (any other) | 10 | Fallback for future monster classes |

Final pick score: `score = base_threat * 1000 / (distance + 200)`. This makes a gargantua at 1500u still outweigh a headcrab at 200u, but a headcrab at 100u beats a gargantua at 4000u — bots commit to whatever's an actual immediate problem.

#### Sticky Target (`BotHordePickTarget`)
- If `pBot->p_horde_target` is alive, still `FL_MONSTER`, and `f_horde_target_time > gpGlobals->time`, return it without re-scoring.
- Lock duration: `HORDE_STICKY_TIME = 4.0s` — refreshed every time a new target is picked.
- This is the **soft focus-fire** mechanism: combined with the threat-score formula it produces gradual, stable target convergence rather than per-frame thrashing between two equally-weighted threats. Hard focus-fire (every survivor on the same monster) was deliberately rejected — it leaves flank threats unaddressed.

#### Pre-Update (`BotHordePreUpdate`, called every frame before `BotFindEnemy`)
- Refresh the monster cache.
- Evaluate role every ~0.75s:
  - HP `<= HORDE_RETREAT_HP` (25) → `RETREAT`
  - No live horde monsters → `RESUPPLY`
  - Else → `HUNTER`
- If `HUNTER` with a valid pick:
  - Refresh sticky lock if the target identity changed.
  - **Target-relocation invalidation**: compare new origin to `v_horde_last_target_org`. On any delta > `HORDE_TARGET_SWITCH_DIST` (256u), wipe `waypoint_goal`, `old_waypoint_goal`, `f_waypoint_goal_time` so the next nav tick re-paths instead of walking to the previous monster's last known spot.
  - Set `v_goal = pTarget->v.origin`, `f_goal_proximity = 64.0f`.
  - Suppress generic item detours: `pBotPickupItem = NULL`, `item_waypoint = -1`.
- If `RESUPPLY` / `RETREAT` (or `HUNTER` with no target available):
  - Clear `v_goal = g_vecZero`, `f_goal_proximity = 0`, `p_horde_target = NULL`, `f_horde_target_time = 0`, `v_horde_last_target_org = g_vecZero`.
  - Letting `v_goal` revert to zero hands control to the default `BotFindItem` / `BotFindWaypointGoal` chain — which already weights health/armor/ammo by current need, naturally prioritizing healthkits during `RETREAT` and broadly exploring during `RESUPPLY`.

#### Think (`BotHordeThink`, else-if in the `BotThink` dispatch chain)
Inserted after the `GAME_BUSTERS` branch in `bot.cpp`:
```cpp
else if (is_gameplay == GAME_HORDE && BotHordeThink(pBot))
{
    // BotHordeThink sets v_goal + f_move_speed for hunting / resupply / retreat.
}
```
- `HUNTER` with a non-zero `v_goal`: `f_move_speed = f_max_speed`, face the target, return `true`.
- `RESUPPLY` / `RETREAT`: return `false` so the default nav/pickup logic runs — the existing `BotFindItem` heuristics already prefer healthkits when low and armor/ammo otherwise.

#### Enemy Acquisition (`BotFindEnemy`)
Horde now has **four** explicit protection layers in `BotFindEnemy`:
1. **Retreat short-circuit**: when `i_horde_role == HORDE_ROLE_RETREAT`, immediately return `NULL`. This prevents the bot from being yanked back into combat by the generic "monster within 2500u" scan while it's trying to grab a healthkit.
2. **Sticky-target promotion**: when `p_horde_target` is alive and within the sticky window, and the bot has line-of-sight + view-cone hit on it, return it directly as `pBotEnemy`. This bypasses the score-by-distance generic scan so the bot stays committed to the picked threat instead of flipping to whichever monster wandered closest.
3. **Player-target strip at entry/fallback**: if Horde sees a carried-over player enemy (`pBotEnemy`), remembered target (`pRemember`), or post-selection enemy (`pNewEnemy`) with `FL_CLIENT`/`FL_FAKECLIENT`, it is nulled immediately.
4. **Player-scan bypass**: the generic "search world for players" loop is skipped entirely in Horde.

Outside those guards, the generic monster scan in `BotFindEnemy` (which filters on `FL_MONSTER` + `IsAlive` + LoS + view-cone) remains the acquisition path for Horde targets.

#### Direct-Steer Condition (`bot.cpp` movement block)
- `hordeChase` joins the existing family. When `is_gameplay == GAME_HORDE` and `v_goal` is non-zero: direct-steer is enabled if the bot is within `128u` of `v_goal` unconditionally, or within `500u` with `FVisible(v_goal, pEdict)`. Final approach to a monster goes straight rather than bouncing off the last waypoint.

#### Waypoint Routing (`bot_navigate.cpp` — `BotFindWaypointGoal`)
- A `GAME_HORDE` branch treats `v_goal` (the picked monster's origin) as the destination and picks the nearest waypoint by pure Euclidean distance (no LOS, no team-flag mismatch). Mirrors the Cold Spot branch.
- **Do not assign `pBot->waypoint_goal = index` inside this branch.** Same caller contract as Cold Spot — the change-detection compare in `BotHeadTowardWaypoint` requires the previous value to remain intact until after the comparison.
- When `v_goal == g_vecZero` (RESUPPLY / RETREAT), the branch falls through so the default goal selection (health → armor → wander) runs.
- `GAME_HORDE` is added to the 0.5s recalc gate, the goal-change waypoint-snap block, and the `v_goal` preservation list so the generic "forget goal" reset in `bot.cpp` does not wipe the monster target.

### Team mapping (bot perspective)
- `UTIL_GetTeam(pEdict)` returns `1` for any survivor (`pev->fuser3 > 0`) and `2` for monsters/other.
- The bot DLL's two-team return values are inverted relative to other modes' "blue=1 / red=2" meaning here — the only thing that matters is that all survivors return the same value and all monsters return a different value.
- There is no second player team to worry about. Survivor-vs-survivor targeting is now blocked by **both** layers: (a) team checks in generic bot logic and (b) Horde-specific hard guard in `BotFindEnemy` that strips player targets and bypasses the player-scan loop entirely.

## Rapid Debug Playbook

Use this when Horde bots appear to target players or stop prioritizing monsters.

1. **Confirm mode detection first** (`BotCheckTeamplay`):
  - `is_gameplay` must resolve to `GAME_HORDE` and `is_team_play` must be true.
  - If mode detection is wrong, every Horde guard in `BotFindEnemy` is bypassed.

2. **Confirm monster cache is populated** (`BotHordeFindEntities`):
  - `s_horde_count` should be > 0 during active waves.
  - Empty cache with live monsters means the wave tags are wrong (`message != "horde"`, missing `FL_MONSTER`, or `EF_NODRAW`).

3. **Trace enemy acquisition in this order** (`BotFindEnemy`):
  - RETREAT short-circuit returns `NULL`.
  - Sticky target returns monster directly when visible.
  - Player enemy strip clears `pBotEnemy`/`pRemember`/`pNewEnemy` if any are clients.
  - Player scan loop is skipped in Horde.
  - Final enemy should be either `NULL` or `FL_MONSTER`.

4. **If bot still attacks players, inspect caller state transitions**:
  - Verify no non-Horde branch overwrites `is_gameplay` mid-session.
  - Verify no later logic in `BotThink` writes a player edict back to `pBotEnemy` after `BotFindEnemy`.

5. **Validate role + movement coupling**:
  - `HORDE_ROLE_HUNTER` + non-zero `v_goal` should produce chase behavior.
  - `HORDE_ROLE_RETREAT` should force `pBotEnemy = NULL` and allow item-nav fallback.

6. **Fast in-game reproduction recipe**:
  - Start Horde with many bots and at least one human observer.
  - Force repeated line-of-sight breaks (corners, platforms) and watch for target churn.
  - A correct build should never keep or reacquire a client as `pBotEnemy` in Horde.

### Tunables
| Constant | Value | Purpose |
|----------|-------|---------|
| `MAX_HORDE_CACHE` | 32 | Monster cache size; ENEMY_TOTAL is much smaller |
| `HORDE_STICKY_TIME` | 4.0s | Sticky-target lock duration |
| `HORDE_RETREAT_HP` | 25 HP | RETREAT role threshold (per user spec) |
| `HORDE_TARGET_SWITCH_DIST` | 256u | Target-relocation delta that wipes stale routing |
| Role eval interval | 0.75s | Throttle role transitions |
| Direct-steer near gate | 128u | Unconditional direct-steer to monster |
| Direct-steer visible gate | 500u | Direct-steer with FVisible LoS check |

### Key Differences from Cold Spot / CTF / Busters
- **PvE, not PvP**: Targets are NPC monsters, never players. No team-relative aiming, no friendly-fire concerns.
- **Volatile target set**: Monsters die every wave. Cached `p_horde_target` pointers must be re-validated against `IsAlive` and `FL_MONSTER` on every use — the sticky branch in `BotHordePickTarget` does this explicitly.
- **No "objective" entity**: Cold Spot has the spot, CTF has the flag, Busters has the egon weaponbox. Horde's "objective" is "the highest-threat live monster", which is computed every frame.
- **Inter-wave breather, not respawn**: Surviving bots **don't** lose their position on death — there is no spawn point reset. The `RESUPPLY` role exists to take advantage of this brief window: after the last monster dies, all surviving bots have ~3s to grab whatever's in walking distance before the next wave spawns. Falling back to default nav (rather than scripting an explicit pickup pattern) reuses the existing item-weight heuristics that already prefer healthkits when HP is low and armor/ammo otherwise.
- **Hardness scaling matters more than HP for prioritization**: A wave-30 zombie has 10× HP but is still a zombie — same DPS, same speed, same threat. Threat-by-class (the `BotHordeMonsterScore` table) gives stable, intuitive ordering across wave numbers.
- **No coordination between bots in code**: There is no shared "this monster is taken" registry. Soft focus-fire emerges from the threat-score formula: bots converge on whichever monster scores highest from each bot's individual position. When one teammate kills the picked target, the survivors naturally re-pick the next-highest threat on their next role tick.

## Lessons Learned (post-Phase 7 polish)

### Bug #3 — Horde player-target leakage through generic enemy paths
**Symptom**: In Horde, bots occasionally target/attack teammate players instead of monsters.

**Root cause**: The generic player-search and remember/fallback paths in `BotFindEnemy` were still reachable in Horde. Under stale/misordered state, a client target could survive into `pNewEnemy`.

**Fix** (`bot_combat.cpp`):
1. Clear `pBotEnemy` at Horde entry if it is `FL_CLIENT`/`FL_FAKECLIENT`.
2. Clear `pRemember` in Horde if it points to a client.
3. Skip the player-scan loop entirely in Horde.
4. Final safety guard: clear `pNewEnemy` if it is a client.
5. Exclude Horde from the generic `b_engaging_enemy` carry-forward branch.

**Lesson**: For PvE modes, do not rely only on team checks. Add **mode-local target-type invariants** ("enemy must be monster") at multiple choke points so fallback paths cannot reintroduce invalid target classes.

### Bug #1 — `BotShouldEngageEnemy` rejected non-player classnames
**Symptom**: Bot acquires a monster as enemy, aim-locks on it, but doesn't move toward it and doesn't fire. Retreats correctly at HP ≤ 25.

**Root cause** (`bot_combat.cpp` ~line 2811): The function early-returns `FALSE` when `strcmp(pEnemy->v.classname, "player") != 0`. Every horde monster (`monster_zombie`, `monster_gargantua`, etc.) failed this check, so:
- `b_last_engage = FALSE` every frame
- `bShouldEngage = FALSE` → the engage block at the call site never sets `b_engaging_enemy = TRUE`
- The combat-movement block (strafing, longjump, ignore-wpt, close-range commit) never runs
- Aim still tracks because aim updates don't gate on `b_engaging_enemy`
- Retreat works because `BotFindEnemy` short-circuits to `NULL` in `HORDE_ROLE_RETREAT`

**Fix**: Two layered patches in `bot_combat.cpp`:
1. Inside `BotShouldEngageEnemy`: add a `GAME_HORDE` early-return-TRUE for any live `FL_MONSTER` enemy.
2. At the engage-decision call site (after the existing Arena `is_gameplay == GAME_ARENA` immediate-engage bypass): add a parallel `GAME_HORDE` block that forces `b_engaging_enemy = TRUE` on monster targets, mirroring the Arena pattern.

**Lesson**: The bot DLL was originally PvP-only — many combat helpers hard-code `classname == "player"`. **Any future PvE-style mode** (or one where bots target monsters: CtC chumtoad-bearer is the only existing precedent) must audit these helpers, not just `BotFindEnemy`. When adding a mode that targets monsters, grep `STRING(.*classname).*"player"` across `bot_combat.cpp` first.

### Bug #2 — Bots ran past elevated monsters without engaging
**Symptom**: Two bots running waypoints under a platform with a headcrab 96–128u above. Both aim-locked on the headcrab but never fired and never broke off the waypoint to pursue.

**Root cause** (two-fold):
1. The fire gate (`bot_combat.cpp` ~line 3940) requires `FVisible(v_enemy_origin)`. Traces from the bot's eye to `BotBodyTarget` of the elevated monster clip the platform edge → fire gate fails. Aim still updates because `BotShootAtEnemy`'s aim path doesn't gate on visibility.
2. The existing combat stuck-jump only triggers after the bot has stopped closing horizontal distance for 1.0s. Bots running waypoints *past* an elevated mob never trip that detector — their horizontal distance keeps changing.

**Fix**: Added a Horde elevated-monster pursuit branch in `BotShootAtEnemy` immediately after the combat stuck-jump section (`bot_combat.cpp`).

Trigger conditions (all must hold):
- `is_gameplay == GAME_HORDE`
- Enemy is a live `FL_MONSTER`
- `heightDiff > 32u` (monster meaningfully above bot)
- `horzDist <= 600u` (engagement range)

When triggered:
- Sets `f_ignore_wpt_time = gpGlobals->time + 0.5f` to suspend waypoint following
- Re-asserts `f_move_speed = pBot->f_max_speed`
- Hands off to `BotGoalElevatedJump(pBot, pBot->pBotEnemy->v.origin, true /*force*/)` — the same multi-jump helper used by CTF flag-pursuit and Busters egon-grab. `bForceTrigger=true` bypasses the helper's "wait 0.5s + close horizontally" gate so the combo commits immediately.
- The helper runs ground → double → triple-jump (flip), re-asserting forward facing + max forward speed every frame so `velocity.Length2D() > 100` keeps the flip viable.

Once the bot reaches the platform's level, line-of-sight clears and the existing fire gate engages naturally.

**Lesson**: For PvE modes, **test elevation scenarios specifically** — most bot tests against players run on the same nav-mesh level. The combat stuck-jump as-shipped only catches *blocked* paths, not *parallel-but-unreachable* paths. The pattern (height delta + range threshold + force-triggered multi-jump) is reusable for any future "monster on a ledge" scenarios.

### Improvement #3 — Idle-monster teleporter (gameplay layer)
**Problem**: Some monster classes (especially headcrabs that miss a leap, or grunts that cover but never re-emerge) can park in unreachable corners and burn out the round timer with no chance for survivors to find them.

**Implementation**: `CHalfLifeHorde::Think` (`horde_gamerules.cpp`). Piggybacks on the existing per-tick `FIND_ENTITY_BY_STRING(NULL, "message", "horde")` pass — no separate timer field, no new entity scan.

Per-monster idle state stored on free pev fields. **Two parallel tracks** are needed because some monsters (patrolling grunts, hopping headcrabs) move enough to keep the tight stationary track perpetually reset but never actually leave a small region:

- **Stationary track** (24u / 30s tight window):
  - `pev->vuser1` — last-sampled origin
  - `pev->fuser1` — timestamp when monster was first observed stationary (0 = unobserved or just moved)
- **Wander track** (320u / 30s loose anchor — added 2026-05):
  - `pev->vuser2` — anchor origin (set when wander track is seeded or when monster strays beyond 320u from anchor)
  - `pev->fuser2` — anchor reset deadline

Each tick, for every horde monster:
- Stationary: `(vecCur - vuser1).Length() >= 24u` → moved meaningfully → reset `vuser1 = origin`, `fuser1 = now`
- Wander: `(vecCur - vuser2).Length() >= 320u` → wandered out of anchor radius → reset `vuser2 = origin`, `fuser2 = now + 30s`
- **Either** track at deadline AND **not in a fight** (`m_hEnemy` null or its target dead) → add to a stack-allocated `pTeleport[64]` batch
- Both tracks reset on combat (live `m_hEnemy`) so a monster actively fighting is never flagged

After the loop:
- For each flagged monster: try up to 8 candidate spawn points via `EntSelectSpawnPoint("info_player_deathmatch")`. For each candidate, scan a 64u sphere; reject if it contains a live player or another live horde monster (the monster being moved is ignored — the spawn picker may hand back the spot it currently occupies). The first clear candidate wins. If none of the 8 are clear, **skip this monster** for this tick — it gets re-flagged next tick and retried.
- **No telefrag on teleport.** The wave-spawn path gibs anything in the 64u sphere because the round hasn't started yet, but a stuck-monster shuffle is a quality-of-life action and must not punish a nearby survivor. Reject-and-retry is the correct behavior.
- For chosen monsters: `UTIL_SetOrigin` to the new position, **then `DROP_TO_FLOOR(pTeleport[i])`** so the monster doesn't float in mid-air (added 2026-05 — `info_player_deathmatch` spawns sit at player eye height, well above floor for short-bbox monsters like headcrabs). Copy spawn `angles`, zero `velocity`, re-seed both **`vuser1`/`fuser1` and `vuser2`/`fuser2`** using the **post-drop** `pTeleport[i]->v.origin` (not the spawn-spot origin) so neither track immediately re-flags.
- Single consolidated chat: `[Horde] Teleported N monster(s)` (singular/plural handled, count is `iMoved` — only successful relocations).
- One `CLIENT_SOUND_EBELL` broadcast for the whole batch (same chime CtC uses for chumtoad teleports).

**Lessons**:
- **Reuse spare pev fields for per-entity state on entities the gamerules controls.** No new class member, no map lookup, no edict-index array. `vuser1`/`fuser1` were already free for monsters in this mode.
- **"In a fight" test must be on the monster's AI**, not the player's enemy: check `MyMonsterPointer()->m_hEnemy` and verify the target is alive. Don't try to walk `gpGlobals->maxClients` looking for who's shooting at it — the monster already knows.
- **Batch player-facing notifications.** N teleports in one tick produce one chat line and one sound, not N. The 1.5s `flUpdateTime` cadence makes batch-per-tick natural.
- **Re-seed the idle samples after teleport.** The just-teleported origin would otherwise be ≠ the previous `vuser1`, causing an immediate re-sample-and-reset that's harmless but noisy in debug. Setting `vuser1 = new origin, fuser1 = now` (and `vuser2`/`fuser2` for the wander track) keeps the timeline clean. **Use the post-`DROP_TO_FLOOR` origin**, not the spawn-spot origin — they differ by the floor-drop distance.
- **A single tight stationary check is not enough.** Some monster classes (patrolling grunts, hopping headcrabs) move enough every second to keep a 24u/1.5s stationary check perpetually reset, but never actually leave a small region. A parallel loose **wander track** (320u radius / 30s window, anchored on first observation) catches them. The two tracks share the *not-in-fight* gate and the same teleport batch — either can flag.
- **`DROP_TO_FLOOR` after teleport.** `EntSelectSpawnPoint("info_player_deathmatch")` returns spots calibrated for player eye height, which is well above the floor for short-bbox monsters. Without `DROP_TO_FLOOR`, headcrabs / barnacles end up floating in mid-air and look broken. Always drop after `UTIL_SetOrigin` for entity moves that target a player spawn.
- **Don't telefrag on quality-of-life entity moves.** The wave-spawn path can gib whatever's at the spawn point because the round hasn't started — players are still in spectator. Mid-round teleports of existing monsters must validate the destination (64u sphere scan for live players + other horde monsters) and **skip-and-retry** rather than gib. Reusing the wave-spawn telefrag pattern blindly here would damage survivors and turn a QoL feature into a hostile mechanic.

## Conventions for Future Horde Work
- **Gamerules-side per-monster state**: prefer free pev fields (`vuser1`, `fuser1`, `iuser1-4`) over new class members. The horde monster set is volatile (re-spawned every wave), so fields scoped to the entity lifetime are correct by construction.
- **Cadence tag**: any new gameplay-layer monitoring (idle detection, position checks, ambient effects) should hook into the existing `flUpdateTime = gpGlobals->time + 1.5;` cadence in `Think`. Don't add a second world-entity scan; piggyback on the existing horde enumeration.
- **Player-facing chat / sound**: use `[Horde]` prefix for chat lines (matches existing `[Horde] %s has been defeated!` convention). Use `CLIENT_SOUND_EBELL` for non-combat positional-change events (matches CtC teleport).
- **Bot-side combat audit checklist**: when adding a new horde behavior, verify against
  1. `BotShouldEngageEnemy` (classname gate)
  2. `BotFireWeapon` (any internal weapon-selection paths that assume a player target)
  3. The fire gate at the bottom of `BotShootAtEnemy` (FVisible, FInViewCone, reaction time)
  4. `BotFindEnemy` (HORDE_ROLE_RETREAT short-circuit, sticky-target promotion)
  5. The combat stuck-jump branch in `BotShootAtEnemy` and the new horde elevated-monster pursuit branch immediately after it
- **Don't cache monster pointers across waves.** The wave-end `UTIL_Remove` of every horde-tagged entity invalidates pointers. The static `s_horde_monsters[]` cache is bounded to a single `gpGlobals->time` tick exactly because of this.
