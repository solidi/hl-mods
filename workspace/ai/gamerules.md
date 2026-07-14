# Gamerules — AI Context Hub

This is the **root context document** for every gamemode in Cold Ice Remastered. Load this file first when working on any `*_gamerules.cpp` or its bot integration; it captures everything common across modes so the per-mode `*_gamerules.md` spokes can stay focused on what is actually unique.

> **How to load context for a mode**: read this file for the foundation, then open the relevant spoke below.

## Mode Roster

| ID | `GAME_*` | mp_gamemode | Class | Spoke |
|---:|----------|-------------|-------|-------|
| 0  | `GAME_FFA`        | `"ffa"` (default)  | `CHalfLifeMultiplay`              | — (base) |
| 1  | `GAME_ARENA`      | `"arena"`          | `CHalfLifeArena`                   | [arena_gamerules.md](arena_gamerules.md) |
| 2  | `GAME_LMS`        | `"lms"`            | `CHalfLifeLastManStanding`         | [lms_gamerules.md](lms_gamerules.md)  |
| 3  | `GAME_BUSTERS`    | `"busters"`        | `CMultiplayBusters`                | [busters_gamerules.md](busters_gamerules.md) |
| 4  | `GAME_CHILLDEMIC` | `"chilldemic"`     | `CHalfLifeChilldemic`              | [chilldemic_gamerules.md](chilldemic_gamerules.md) |
| 5  | `GAME_COLDSKULL`  | `"coldskull"`      | `CHalfLifeColdSkull`               | [coldskull_gamerules.md](coldskull_gamerules.md) |
| 6  | `GAME_COLDSPOT`   | `"coldspot"`       | `CHalfLifeColdSpot`                | [coldspot_gamerules.md](coldspot_gamerules.md) |
| 7  | `GAME_CTC`        | `"ctc"`            | `CHalfLifeCaptureTheChumtoad`      | [ctc_gamerules.md](ctc_gamerules.md) |
| 8  | `GAME_CTF`        | `"ctf"`            | `CHalfLifeCaptureTheFlag`          | [ctf_gamerules.md](ctf_gamerules.md) |
| 9  | `GAME_GUNGAME`    | `"gungame"`        | `CHalfLifeGunGame`                 | [gungame_gamerules.md](gungame_gamerules.md) |
| 10 | `GAME_HORDE`      | `"horde"`          | `CHalfLifeHorde`                   | [horde_gamerules.md](horde_gamerules.md) |
| 11 | `GAME_INSTAGIB`   | `"instagib"`       | `CHalfLifeInstagib`                | TBD |
| 12 | `GAME_ICEMAN`     | `"jvs"`            | `CHalfLifeJVS` (Jesus vs. Santa)   | TBD |
| 13 | `GAME_KTS`        | `"kts"`            | `CHalfLifeKickTheSnowball`         | [kts_gamerules.md](kts_gamerules.md) |
| 14 | `GAME_LOOT`       | `"loot"`           | `CHalfLifeLoot`                    | [loot_gamerules.md](loot_gamerules.md) |
| 15 | `GAME_PROPHUNT`   | `"prophunt"`       | `CHalfLifePropHunt`                | [prophunt_gamerules.md](prophunt_gamerules.md) |
| 16 | `GAME_SHIDDEN`    | `"shidden"`        | `CHalfLifeShidden`                 | [shidden_gamerules.md](shidden_gamerules.md) |
| 17 | `GAME_SNOWBALL`   | `"snowball"`       | `CHalfLifeSnowballFight`           | [snowballfight_gamerules.md](snowballfight_gamerules.md) |
| 18 | `GAME_TEAMPLAY`   | `"teamplay"`       | `CHalfLifeTeamplay`                | TBD |

Authoritative table: `gamePlayModes[]` in `src/dlls/multiplay_gamerules.cpp` (~line 240). Numeric IDs from `src/common/const.h`.

## Class Hierarchy

```
CGameRules                     (src/dlls/gamerules.h, .cpp)
└── CHalfLifeRules             (single-player; not used in multiplayer)
└── CHalfLifeMultiplay         (src/dlls/multiplay_gamerules.{h,cpp})  ← every multiplayer mode below
    ├── CHalfLifeArena
    ├── CMultiplayBusters
    ├── CHalfLifeColdSkull
    ├── CHalfLifeColdSpot
    ├── CHalfLifeCaptureTheChumtoad
    ├── CHalfLifeCaptureTheFlag
    ├── CHalfLifeKickTheSnowball
    ├── CHalfLifeJVS, CHalfLifeChilldemic, CHalfLifeGunGame,
    │   CHalfLifeHorde, CHalfLifeInstagib, CHalfLifePropHunt,
    │   CHalfLifeShidden, CHalfLifeLoot, CHalfLifeLastManStanding,
    │   CHalfLifeSnowballFight, CHalfLifeTeamplay …
    └── (per-mode subclass)
```

`InstallGameRules()` in `src/dlls/gamerules.cpp` (~line 510) is the dispatcher: it reads `g_GameMode` and `new`s the right subclass. Adding a mode means a new `case GAME_<MODE>:` entry there + a new `*_gamerules.{h,cpp}` pair + a `Is<Mode>()` query method on `CGameRules`.

## CGameRules — The Common Contract

Every mode inherits the virtual methods below. The default behavior lives in `CGameRules` / `CHalfLifeMultiplay`; a mode overrides only what it needs to change.

### Lifecycle / Think
- `Think()` — runs every server frame. Mutator updates, voice-mgr update, intermission timer, score / fraglimit / timelimit checks, `GoToIntermission()` trigger.
- `RefreshSkillData()` — populates `gSkillData.*` from `sk_*` cvars (weapon/monster damage, charger amounts, etc.).
- `CheckGameMode()` — polls `mp_gamemode` for changes; reinstantiates rules on change.

### Client lifecycle
- `ClientConnected` / `ClientDisconnected` — connect filtering, voice-mgr registration, scoreboard cleanup.
- `InitHUD` — broadcasts team list, scores, mutator state to a freshly-connected client.
- `PlayerSpawn` / `PlayerThink` — equipment, model, mutator effects, per-frame movement bookkeeping.
- `PlayerKilled` / `DeathNotice` — frag accounting, obituary message, mode-specific scoring.
- `IPointsForKill` — how many points the killer gets (negative for team-kill).

### Items & weapons
- `FShouldSwitchWeapon`, `GetNextBestWeapon`, `PlayerGotWeapon`, `PlayerGotItem`, `PlayerGotAmmo` — pickup-time hooks.
- `CanHavePlayerItem`, `CanHaveNamedItem`, `CanHavePlayerAmmo` — pickup gating.
- `WeaponShouldRespawn`, `FlWeaponRespawnTime`, `VecWeaponRespawnSpot` (and `Item*` / `Ammo*` siblings) — respawn policy.
- `DeadPlayerWeapons` / `DeadPlayerAmmo` — `GR_PLR_DROP_GUN_*` codes for what falls out of a corpse.

### Damage & teams
- `FPlayerCanTakeDamage` — friendly-fire / immunity gate. Modes use this to protect carriers, ghosts, downed players, etc.
    - In `CHalfLifeMultiplay`, spawn protection is enforced here via
        `pPlayer->m_fLastSpawnTime > gpGlobals->time` (driven by
        `mp_spawnprotectiontime`).
- `FlPlayerFallDamage` — fall-damage rule per `mp_falldamage`.
- `PlayerRelationship` — used by autoaim and friendly-AI; returns `GR_TEAMMATE` / `GR_ENEMY` / `GR_ALLY` / `GR_NEUTRAL`.
- `IsTeamplay`, `GetTeamID`, `GetTeamIndex`, `GetIndexedTeamName`, `IsValidTeam`, `ChangePlayerTeam`, `SetDefaultPlayerTeam` — team-rules surface used by HUD, voice mgr, and bot side.

### Mode-specific predicates
`CGameRules::IsCtC()` / `IsKickTheSnowball()` / `IsBusters()` / `IsCtF()` / `IsColdSpot()` / etc. — fast `g_GameMode == GAME_*` checks used by shared engine code that can't see per-mode classes.

### Mutators
- `MutatorAllowed(name)` — per-mode opt-out for any of the ~85 mutators in `g_szMutators[]`.
- `EnvMutators` / `SpawnMutators` / `WeaponMutators` / `GiveMutators` — entry points the mutator system calls every frame / on spawn / on weapon equip.
- `PauseMutators` / `RestoreMutators` — round-based modes pause mutator timers between rounds.

### Match flow helpers (`CHalfLifeMultiplay`)
- `CheckClients`, `InsertClientsIntoArena`, `HasGameTimerExpired`, `CheckRounds`, `SetRoundLimits`.
- `SuckToSpectator`, `SuckAllToSpectator` — force a player into the OBS pool (used between rounds, on disconnect, and when player count drops below the mode minimum).
- `RemoveAndFillItems` — wipe + respawn world items for a fresh round. Iterates `pRemoveThese[]` (classname list in multiplay_gamerules.cpp:1063) and `UTIL_Remove`s each match. Special-case for `monster_tripmine` calls `KillBeam()` then defers removal. **When adding a new player-placed `monster_*` projectile, add its classname here** or it survives round restarts.
- `GoToIntermission` — score finalisation, scoreboard freeze, map cycle / vote.
- `ChangeLevel` — applies the next map from `mapcycle.txt` / vote result.

## Common Constants

### Score / win condition
- `m_iRoundWins` (per-player int) — cumulative wins across the match. Most team modes sum this across teammates and compare against `mp_scorelimit`.
- `pev->frags` (per-player int) — per-life kill count. **Frags reset on round end in round-based modes**, `m_iRoundWins` does not.
- `mp_fraglimit`, `mp_scorelimit`, `mp_timelimit`, `mp_roundtimelimit`, `mp_roundlimit` — the four win-condition cvars used across modes.

### Spawn protection (`mp_spawnprotectiontime`)
- `mp_spawnprotectiontime` (declared in `game.cpp`) sets the initial protection window in seconds.
- `CBasePlayer::Spawn` sets `m_fLastSpawnTime = gpGlobals->time + mp_spawnprotectiontime` and applies spawn visuals/godmode setup through the multiplayer spawn pipeline.
- `CHalfLifeMultiplay::FPlayerCanTakeDamage` blocks all incoming damage while `m_fLastSpawnTime` is still in the future.
- The timer is force-expired early by offensive actions through `CBasePlayer::ExpireSpawnProtection`:
    - successful weapon fire from `CBasePlayerWeapon::ItemPostFrame` (`PrimaryAttack` / `SecondaryAttack` paths),
    - off-hand melee starts (`StartPunch`, `StartKick`, `StartHurricaneKick`),
    - successful grappling hook throw (`CHook::FireHook`, when the hook is actually launched).
- If no action force-expires it first, normal timeout cleanup still runs in `CHalfLifeMultiplay::PlayerThink` when the timer elapses.

### Cross-DLL signal flags (`pev->fuser*`)
The bot DLL is loaded in-process but **cannot read CBasePlayer members** directly. The convention across modes is to publish authoritative state on the entity's `pev` `fuser*` floats so the bot side can scan with `INDEXENT()` / `UTIL_FindEntityByClassname`.

| Field | Reserved by | Meaning |
|-------|-------------|---------|
| `pev->fuser1` | varied | mode-specific, see spoke |
| `pev->fuser2` | varied | mode-specific, see spoke |
| `pev->fuser3` | mutators / Prop Hunt | dual-purpose; varies by mode |
| `pev->fuser4` | **radar / team / role** | primary cross-DLL signal — see RADAR table below |
| `pev->euser1` | KTS | dribbler edict pointer (snowball entity) |

`pev->fuser4` is the single most important cross-DLL field. Every per-mode spoke documents what value it sets and on which entities.

### `RADAR_*` constants (`src/common/const.h`)
Used as `pev->fuser4` values so the radar HUD and the bot DLL can identify special entities without classname lookups.

| Value | Symbol | Used by |
|------:|--------|---------|
| 1 | `RADAR_CHUMTOAD` | CtC — set on the chumtoad-carrying player |
| 2 | `RADAR_BUSTER` | Busters — set on the player holding the egon |
| 5 | `RADAR_COLD_SPOT` | Cold Spot — set on the spot entity |
| 7 | `RADAR_SNOWBALL` | KTS — set on the loose snowball entity |
| 10 | `RADAR_FLAG_BLUE` | CTF — blue flag |
| 11 | `RADAR_FLAG_RED` | CTF — red flag |
| 12 | `RADAR_BASE_BLUE` | CTF — blue base |
| 13 | `RADAR_BASE_RED` | CTF — red base |
| 14 | `RADAR_ARENA_RED` | Arena — red player |
| 15 | `RADAR_ARENA_BLUE` | Arena — blue player |

> Always check `src/common/const.h` for the canonical numeric values. Treat the table above as a quick reference only.

### Team conventions
- Server-side: `TEAM_BLUE = 0`, `TEAM_RED = 1` (defined per-mode header). Some modes use `m_szTeamName` strings (`"blue"` / `"red"` / `"ghosts"` / `"busters"` / etc.).
- Bot side: `UTIL_GetTeam()` in `grave-bot-src/dlls/util.cpp` is **1-indexed**: `1 = blue`, `2 = red`, `0 = none`. The off-by-one is intentional so `0` can mean "no team".
- **Never compare server `fuser4` directly to bot `UTIL_GetTeam()` results** — translate through one of the helpers.

## CRITICAL — `v_goal` Preservation Contract

> This rule applies to **every** custom gamemode that pre-sets `pBot->v_goal`. Forgetting any single edit below silently breaks direct-steer / chase navigation — bots fall back to plain waypoint following with **no error or warning**. This is the most common trap when adding a new mode.
>
> Inside `bot.cpp` `BotThink`, an unconditional **"always forget goal"** line zeroes `v_goal` *between* the per-mode `*PreUpdate` / `*Think` (which sets it) and the direct-steer movement block (which reads it). Any mode that pre-sets `v_goal` MUST appear in the exclusion list:
>
> ```cpp
> // bot.cpp ~line 2777
> if (is_gameplay != GAME_COLDSKULL && is_gameplay != GAME_KTS &&
>     is_gameplay != GAME_CTC && is_gameplay != GAME_CTF &&
>     is_gameplay != GAME_ARENA && is_gameplay != GAME_COLDSPOT &&
>     is_gameplay != GAME_BUSTERS)
>     pBot->v_goal = g_vecZero;
> ```
>
> **Required edits when introducing a new gamemode (bot integration checklist):**
>
> 1. **`bot.cpp` ~line 2777** — add `&& is_gameplay != GAME_<MODE>` to the "always forget goal" exclusion list above.
> 2. **`bot.cpp` direct-steer block (~line 2920+)** — add a `<mode>Chase` bool to the OR chain that sets `bGoGoal = true`, otherwise the movement block uses `curr_waypoint_index` instead of `v_goal`.
> 3. **`bot_navigate.cpp` ~lines 566 & 577** — add `|| is_gameplay == GAME_<MODE>` to both the goal-recalc gate and the 0.5s `f_waypoint_goal_time` cadence.
> 4. **`bot_navigate.cpp` `BotHeadTowardWaypoint` (~line 660+)** — add a `GAME_<MODE>` waypoint-reset on goal change, otherwise stale waypoints persist when the goal moves.
> 5. **`bot_combat.cpp` `BotCheckTeamplay`** — register the `mp_gamemode` string lookup, otherwise `is_gameplay` stays at 0 (FFA) and every `GAME_<MODE>` branch is dead code.
> 6. **`bot.cpp` `BotSpawnInit`** — initialize all per-bot mode fields, otherwise stale state from a prior map/round leaks into the new one.
> 7. **`bot_func.h`** — declare `BotMyModeThink` / `BotMyModePreUpdate` extern.
> 8. **`bot.h`** — add per-bot fields and any role enums.
> 9. **`bot_navigate.cpp` `BotFindWaypointGoal`** — add a `GAME_<MODE>` block that picks the waypoint nearest to `v_goal` (mirroring the HORDE / LOOT blocks).  Without this, even though `*PreUpdate` sets `v_goal` correctly, the bot's `waypoint_goal` falls through to the generic tour/health picker and the bot routes to a waypoint unrelated to the objective — producing the classic "two bots pacing between two waypoints far from the action" stuck-game.

## Common Bot-Layer Patterns

These patterns recur in every mode's bot integration. Spokes describe how each mode applies them; the patterns themselves live here.

### Per-frame entity cache
Each mode defines a static `BotMyModeFindEntities()` that runs once per server frame (gated by `s_cache_time == gpGlobals->time`) and stashes the relevant target entity (flag / chumtoad / weaponbox / opponent / spot) in a file-scope static. `PreUpdate`, `Think`, and `BotFindEnemy` all call the cache lookup so they agree on the same target within a tick.

### Pre-Update + Think split
- **`BotMyModePreUpdate(pBot)`** runs in `bot.cpp` `BotThink` **before** `BotFindEnemy`. It refreshes role evaluation and pre-sets `v_goal` so the movement block has a target even on combat ticks where the per-mode Think function is skipped.
- **`BotMyModeThink(pBot)`** runs **after** `BotFindEnemy` in the no-enemy branch. Returns `bool` — `true` when it has set movement intent, `false` to fall through to default nav.

### Direct-steer (`<mode>Chase`)
A local `bool` in the movement block (`bot.cpp` ~line 2920+) that, when true, causes the bot to walk directly toward `v_goal` instead of the next waypoint. Two-tier rule:
- **< 300u**: unconditional (skip `FVisible` because floor-level entity origins clip eye-level traces).
- **300–500u**: gated by `FVisible` (otherwise walking through visible-but-impassable gaps).
- **> 500u**: never direct-steer; let waypoint routing handle it.

### `BotCheckTeamplay` registration
`bot_combat.cpp` matches the `mp_gamemode` string and sets `is_gameplay = GAME_<MODE>`. **Mandatory** — without it, every `is_gameplay == GAME_<MODE>` check is dead code and the mode runs as FFA from the bot's perspective.

### `MAKE_VECTORS` macro
The bot DLL must use the engine callback macro `MAKE_VECTORS(angles)` rather than the server-side `UTIL_MakeVectors`. Same pitfall recurs in every mode — the latter does not exist on the bot side.

### `BotGoalElevatedJump(pBot, vecTarget)` helper
Used by Cold Spot / Busters / KTS for objectives on pedestals or ledges. The helper cycles `i_goal_jump_phase` so the bot retries jumps until it lands on the platform. Idempotent — safe to call from both `*PreUpdate` and `*Think` on the same frame.

### Pace / juke variance
For modes where two bots can stalemate in a waypoint loop (Busters, Arena), each bot oscillates `f_<mode>_pace_scale` (0.65–1.0 multiplier on `f_move_speed`) every 1.5–4s plus probabilistic jukes (jump / duck / strafe burst). Single changes in isolation do not break the stalemate; all three (pace + juke + boosted random-waypoint frequency) are needed.

## Common Source-Side Patterns

### Score-vs-frag separation
Most modes use `m_iRoundWins` as the scoring currency and **never write to `pev->frags`** for objective progress. `frags` remains "kills this life" and resets each round. Busters is the textbook case: `pev->frags` is used to pick the next Buster (lowest count), while `m_iRoundWins` is the win condition. Mixing the two is a perennial bug source.

### `SOLID_NOT` initial state
Any entity that gets `pev->solid` set in `Spawn()` after a delay (flags, skulls, snowballs) starts as `SOLID_NOT` for ~0.25–0.5 s. Bot scans must include `SOLID_NOT` entities or they miss the entity for the first half-second of its life. Conversely, `UTIL_TraceLine` does **not** hit `SOLID_TRIGGER` entities — visibility checks against pickup triggers always return clear, regardless of geometry.

### Dual `fuser4` semantics on players vs entities
Several modes set `fuser4` on **both** the player (team / role indicator) and on a related entity (radar marker for that entity's class). Always disambiguate with a classname check before reading `fuser4`. Documented per-spoke.

### Cross-DLL detection
The bot DLL cannot include `cbase.h` or read `CBasePlayer` members. Authoritative cross-DLL signals are:
- `pev->fuser*` for state flags (radar / role / team / carrier).
- Classname scans (`UTIL_FindEntityByClassname`) for entity discovery.
- `pev->aiment` for "this entity is held by that player" relationships (CTF flags, KTS dribble).
- `IsAlive(pEdict)` (defined in bot util) for life state.

### Intermission + cleanup
`GoToIntermission()` does **not** automatically clear loose pickup entities (dropped flags, dropped weaponboxes, etc.). Bot logic must guard its think dispatch against `g_fGameOver` to avoid chasing stale objectives during the intermission display.

## Spectator System

The spectator pipeline is shared across all multiplayer modes. Every connecting human in any multiplayer mode lands in **Limbo** (observer + join menu) and only enters gameplay after committing via `auto_join` (or a team-pick command). Bots are auto-committed at connect.

### The Three Join States

All multiplayer modes (round-based and non-round-based) use the same 3-state model:

| State | `pev->iuser3` | `m_bWantsToPlay` | `IsCommittedToPlay()` | Counted by gameplay loops? |
|-------|---------------|------------------|------------------------|-----------------------------|
| **Limbo** (menu open, undecided) | `OBS_UNDECIDED_*` (≥7) | `FALSE` | `FALSE` | NO |
| **Chose-Spectate** (issued `spectate`) | `0` | `FALSE` | `FALSE` | NO |
| **Committed-to-Play** (issued `auto_join` / bot / round ingress) | `0` or `-1` (mode-dependent committed sentinel) | `TRUE` | `TRUE` | YES |

`IsCommittedToPlay()` is the **canonical predicate** for any iteration that decides round eligibility, score reset, ingress, or wave admission, and `m_bWantsToPlay` is the underlying committed-state flag. Do not treat `pev->iuser3 == 0` as the sole committed test; depending on mode, committed players may carry `0` or `-1`.

### Round-Based vs. Non-Round-Based

`CGameRules::IsRoundBased()` returns `FALSE` by default. A mode opts in by overriding it to `TRUE`:

| Round-based (returns TRUE) | Non-round-based (default FALSE) |
|----------------------------|----------------------------------|
| Arena, Chilldemic, Horde, JVS (Iceman), LMS, PropHunt, Shidden, Loot | FFA, Busters, Cold Skull, Cold Spot, CtC, CTF, GunGame, Instagib, KTS, Snowball, Teamplay |

The difference is **only**: when a Committed-to-Play player actually drops in.
- **Non-round-based**: `auto_join` calls `ExitObserver()` immediately — player spawns next tick.
- **Round-based**: `auto_join` sets `m_bWantsToPlay = TRUE` only; the next `CheckClients` / `InsertClientsIntoArena` round-boundary admits them via the standard ingress.

Limbo + Chose-Spectate are **always available** (even in round-based modes) and **ignore the `allow_spectators` cvar**. This is required so non-committed players don't artificially count toward round participation.

### Per-Player State Fields

| Field | Owner | Meaning |
|-------|-------|---------|
| `pev->iuser1` | engine | Active observer mode (`OBS_NONE` / `OBS_CHASE_LOCKED` / `OBS_CHASE_FREE` / `OBS_ROAMING` / `OBS_IN_EYE` / `OBS_MAP_FREE` / `OBS_MAP_CHASE`). Set by `StartObserver`; consulted by `pm_shared` and HUD. |
| `pev->iuser2` | engine | Currently-tracked target entity index for chase-cam modes. |
| `pev->iuser3` | gamerules | **Menu state.** `0` = either committed-to-play OR chose-spectate (disambiguate via `m_bWantsToPlay`). `OBS_UNDECIDED_SIMPLE` (7) = simple join menu open. `OBS_UNDECIDED_BLUE/RED/BOTH` (8/9/10) = team-aware join menu. `-1` = committed/chose-to-play sentinel used by non-round-based modes after the player commits; reset by `ExitObserver`. |
| `m_bWantsToPlay` | gamerules | `BOOL`. `TRUE` after the player issued `auto_join` (or for any `FL_FAKECLIENT`). `FALSE` for Limbo (menu open) and Chose-Spectate. Used together with `!HasDisconnected` via the `IsCommittedToPlay()` accessor. **Never reset by `StartObserver`** — must survive round transitions and suck-to-spectator. Initialized in `ClientPutInServer`. |
| `m_iObserverLastMode` | gamerules | Cached `iuser1` so we can restore the chase-cam style after a target dies. Defaults to `OBS_ROAMING`. |
| `m_iObserverWeapon` | gamerules | Dual-purpose: in observer-cam it stores the spectated player's weapon icon; **as a menu commit value** it stores the chosen `OBS_MENU_1..3` (0..2) before `ExitObserver` consumes it. Bots set `2` (auto-join) directly. |
| `m_flForceToObserverTime` | gamerules | Future `gpGlobals->time` at which a dead non-combatant gets `SuckToSpectator()`. Typically set to `gpGlobals->time + 3.0` in `FPlayerCanRespawn` for round-based modes. `0` = inactive. |
| `IsInArena` | gamerules | `BOOL`. `TRUE` = participating in the current round. `FALSE` = sitting out (spectator). Round-based modes gate `PlayerSpawn` and `FPlayerCanRespawn` on this. |

`OBS_*` mode constants and `OBS_UNDECIDED_*` / `OBS_MENU_*` codes live in `src/pm_shared/pm_shared.h`.

### The Universal `PlayerSpawn` Gate

Every multiplayer mode inherits this early-return at the top of `CHalfLifeMultiplay::PlayerSpawn` (`multiplay_gamerules.cpp` ~line 1885):

```cpp
// Place player in spectator mode if joining during a game
// Or if the game begins that requires spectators
if ((g_GameInProgress && !pPlayer->IsInArena) ||
    (!g_GameInProgress && IsRoundBased()) ||
    pPlayer->pev->iuser3 > 0)
{
    return;
}
```

Three branches, each with a distinct trigger:

1. **`g_GameInProgress && !IsInArena`** — round in flight, this player isn't in it. Fires for late connects to round-based modes and for losers in non-elimination round modes (Arena losers via `m_flForceToObserverTime`, etc.). Returns without spawning the player.
2. **`!g_GameInProgress && IsRoundBased()`** — between rounds. Returns without spawning so the next `Think` tick's `InsertClientsIntoArena()` can move every committed-to-play player in atomically (Limbo + Chose-Spectate are skipped by the `IsCommittedToPlay()` gate).
3. **`iuser3 > 0`** — Limbo (join menu open). Fires in **every** multiplayer mode now (round-based and non-round-based) because `ClientPutInServer` puts every connecting human into Limbo. Returns without spawning until `auto_join` / `join_blue` / `join_red` / `spectate` is issued.

If all three branches fall through, the player spawns normally.

### Connection-Time Setup (`ClientPutInServer` in `src/dlls/client.cpp` ~line 260)

```cpp
pPlayer->pev->iuser1 = 0;
pPlayer->pev->iuser2 = 0;
pPlayer->pev->iuser3 = 0;  // menu status

// Limbo: connecting humans see the join menu in ALL multiplayer modes.
if (g_pGameRules->IsMultiplayer())
    pPlayer->pev->iuser3 = OBS_UNDECIDED_SIMPLE;

pPlayer->m_bWantsToPlay = FALSE;
if (FBitSet(pPlayer->pev->flags, FL_FAKECLIENT))
    pPlayer->m_bWantsToPlay = TRUE;  // bots always commit
```

So every connecting human starts in **Limbo**: `iuser3 = OBS_UNDECIDED_SIMPLE`, `m_bWantsToPlay = FALSE`. `PlayerSpawn` fires branch 3 (`iuser3 > 0`) and parks them in `OBS_ROAMING` with the menu rendered. Bots additionally have `m_bWantsToPlay = TRUE` so they're auto-committed; the `FL_FAKECLIENT + iuser3 > 0` fast path in `multiplay_gamerules.cpp` (~line 1792) calls `ExitObserver()` for them next tick.

### Client Commands

Handled in `client.cpp` `ClientCommand`. **Available in all multiplayer modes**:

| Command | Effect |
|---------|--------|
| `menu` | Re-opens the join menu (only while spectating). Sets `iuser3 = OBS_UNDECIDED_SIMPLE` (FFA) or `OBS_UNDECIDED_BOTH` (CTF / KTS) and `m_bWantsToPlay = FALSE`. Blocked mid-round for active players. |
| `auto_join` | Sets `m_bWantsToPlay = TRUE`, `m_iObserverWeapon = OBS_MENU_3`. In **non-round-based** modes immediately calls `ExitObserver()`; in **round-based** modes the next round transition admits them via `InsertClientsIntoArena`. |
| `join_blue` | (CTF / Cold Spot / KTS) Sets `m_iObserverWeapon = OBS_MENU_1` then `ExitObserver()`. In FFA modes falls through to `model iceman`. |
| `join_red` | (CTF / Cold Spot / KTS) Sets `m_iObserverWeapon = OBS_MENU_2` then `ExitObserver()`. In FFA modes falls through to `model santa`. |
| `spectate` | Sets `iuser3 = 0`, `m_bWantsToPlay = FALSE`, calls `StartObserver` at a spawn point. In non-round-based modes requires `allow_spectators` cvar OR a Limbo->Spectate transition. **In round-based modes the command is BLOCKED for active in-arena combatants** (`!IsObserver() && IsInArena && iuser3 == 0`) — see [Mid-round spectate guard](#mid-round-spectate-guard) below. Limbo (menu open) and current observers may always issue it. Proxies (HLTV) always allowed. |

`ExitObserver` (`player.cpp`) clears `iuser1/iuser2/iuser3`, sets `m_iHideHUD = 0`, sets `m_iExitObserver = TRUE`, and calls `Spawn()`. The next `Spawn()` reaches the `PlayerSpawn` gate with `iuser3 == 0`, so all three branches fall through and the player actually spawns.

### Round-Based Transition APIs (`CHalfLifeMultiplay`)

Three functions form the contract every round-based mode uses. **Do not reimplement them per-mode** — call them.

#### `SuckToSpectator(CBasePlayer *pPlayer)` (~line 1135)
Forces a single player into spectator without telling them why:
- Clears `m_szTeamName`, broadcasts `gmsgTeamInfo` with empty team.
- Zeroes `pev->frags`, `m_iDeaths`; broadcasts `gmsgScoreInfo` so the scoreboard updates.
- Sets `IsInArena = FALSE`.
- Sets `m_iObserverLastMode = OBS_ROAMING` (chase-cams default to free roaming).
- Calls `StartObserver(spawnSpot.origin, spawnSpot.angles)` — picks a deathmatch spawn point, sets up the observer view, broadcasts kill-attachments TE.

#### `SuckAllToSpectator()` (~line 1164)
Loops every connected client and calls `SuckToSpectator`. Plays `CLIENT_SOUND_ROUND_OVER` to all players. Round-based modes call this on round end and on round-end edge cases (countdown abort, late join during countdown).

#### `InsertClientsIntoArena(float fragcount)` (~line 958)
The **canonical round-start ingress** for round-based modes. Iterates every connected player and gates on **`IsCommittedToPlay()`** (so Limbo + Chose-Spectate are skipped). For each committed player:
- `pPlayer->pev->frags = fragcount` (LMS uses `startwithlives`; everyone else passes `0`).
- `IsInArena = TRUE`.
- Broadcasts `gmsgScoreInfo`.
- Calls `pPlayer->ExitObserver()` — which clears `iuser*`, runs `Spawn()`, the `PlayerSpawn` gate falls through (because `IsInArena` is now `TRUE` and `g_GameInProgress` is `TRUE`), and the player spawns at a deathmatch start.
- Increments `m_iRoundPlays`.

`CheckClients()` (~line 932) similarly gates on `IsCommittedToPlay()` to count active participants and populate `m_iPlayersInArena[]`. **These two are the keystone admission/counting APIs** — changing the predicate here cascades to every round-based mode automatically.

Arena is the only outlier — it manually sets `IsInArena = TRUE` + `ExitObserver()` for the **two selected** combatants and `SuckToSpectator()` for everyone else committed-to-play, so that the rest of the pool stays in spectator. Every other round-based mode (Horde, Chilldemic, JVS, LMS, PropHunt, Shidden, Loot) calls `InsertClientsIntoArena(0)` to admit *all* committed-to-play players together. Mode-specific pool-builders and team-balance shuffles (Arena's `m_iOpponentPool[]`, JVS's `m_iJesusPool[]`, Shidden + PropHunt Fisher-Yates passes, Loot's pre-spawn `SOLID_NOT` set) all also gate on `IsCommittedToPlay()` so a Limbo player who joins between `CheckClients()` and the pool build cannot accidentally be assigned a role.

#### Cached pool draw-time prune

Arena (`m_iOpponentPool[]`) and JvS (`m_iJesusPool[]`) **cache** their player-index pool across rounds and refresh only on rare events (champion change, pool exhaustion, connect/disconnect). A player who was committed at pool-build time but issued `spectate` afterward will linger in the cache; if randomly drawn, `InsertClientsIntoArena` (or Arena's manual ingress) silently skips them and the round starts with a missing combatant or no Jesus.

**The fix is a stateless in-place compaction pass** that runs every wait-for-players `Think()` tick **before** any random draw from the pool:

```cpp
int iWrite = 0;
for (int iRead = 0; iRead < m_iPoolSize; iRead++) {
    int idx = m_iPool[iRead];
    CBasePlayer *plr = (CBasePlayer*)UTIL_PlayerByIndex(idx);
    if (plr && plr->IsPlayer() && !plr->HasDisconnected && plr->IsCommittedToPlay())
        m_iPool[iWrite++] = idx;
    else
        ALERT(at_console, "[<mode>] Pruning stale pool entry %d (not committed)\n", idx);
}
m_iPoolSize = iWrite;
```

Applied in [arena_gamerules.cpp](../src/dlls/arena_gamerules.cpp) (before "Build or refresh the opponent pool if needed") and [jvs_gamerules.cpp](../src/dlls/jvs_gamerules.cpp) (after `SetRoundLimits()`, before the `m_bJesusPoolNeedsRefresh` branch). **Any future round-based gamerules that caches a player-index pool across ticks must follow this pattern** — connect/disconnect-only refresh is insufficient because Limbo / Chose-Spectate transitions have no callback hook.

#### Late-joiner immediate-spectator suck

`CHalfLifeMultiplay::PlayerSpawn` (~line 1887 of [multiplay_gamerules.cpp](../src/dlls/multiplay_gamerules.cpp)) is the central late-joiner gate. The historical implementation merely `return`ed when `(g_GameInProgress && !pPlayer->IsInArena) || (!g_GameInProgress && IsRoundBased()) || iuser3 > 0` — but `CBasePlayer::Spawn` has already placed the edict in the world by that point, so the late-joiner was visible (and walkable) until the next gamerules `Think()` tick set `m_flForceToObserverTime` and the *following* tick called `SuckToSpectator`. That's up to ~3 s of "ghost spawning" — reported in PropHunt with connecting bots flashing into the playfield for half a second.

**Fix (in the base)**: inside the early-return branch, call `SuckToSpectator(pPlayer)` immediately when `IsRoundBased()` is true:

```cpp
if ((g_GameInProgress && !pPlayer->IsInArena) ||
    (!g_GameInProgress && IsRoundBased()) ||
    pPlayer->pev->iuser3 > 0)
{
    if (IsRoundBased() && !pPlayer->IsSpectator() && !pPlayer->HasDisconnected)
        SuckToSpectator(pPlayer);
    return;
}
```

This eliminates the visible spawn for every round-based mode (Arena, Horde, Chilldemic, JVS, LMS, PropHunt, Shidden, Loot) without changing behavior for FFA / Teamplay / Coldspot / etc. The `IsRoundBased()` gate is essential — non-round-based modes that use `iuser3 > 0` (snowball fight opt-in spectator) handle their own observer placement elsewhere and must not be double-sucked here.

#### Mid-round spectate guard

The `spectate` console command is handled in `client.cpp` `ClientCommand`. In round-based modes (Arena / Shidden / JvS / Horde / Chilldemic / LMS / PropHunt / Loot) an active in-arena combatant must NOT be able to issue `spectate` mid-round — that would let them dodge a kill, flip the win condition, or strand a 1v1 / Jesus role:

```cpp
if (g_pGameRules->IsRoundBased()
    && !(pev->flags & FL_PROXY)
    && pev->iuser3 == 0          // not in limbo menu
    && !pPlayer->IsObserver()    // not already observing
    && pPlayer->IsInArena)       // active combatant
{
    ClientPrint(pev, HUD_PRINTCENTER,
        "Cannot spectate mid-round.\nYou will be able to choose after this round.\n");
    return;
}
```

Limbo menu users (`iuser3 > 0`) and current observers can still use `spectate` — that's the correct path for new joiners and Limbo-decision flow. After the round ends, the natural death/round-flip path puts active players back into observer/limbo where they can use `spectate` to commit to Chose-Spectate.

### Dead-Player Force-To-Spectator

Round-based modes that allow respawn-while-round-active (or want to delay the kick by a death-cam window) use `m_flForceToObserverTime`:

```cpp
// FPlayerCanRespawn (Arena, Horde, etc.)
if ( !pPlayer->IsAlive() && !pPlayer->m_flForceToObserverTime )
    pPlayer->m_flForceToObserverTime = gpGlobals->time + 3.0;
```

The mode's `Think()` then polls every player and, for any that have crossed `m_flForceToObserverTime`, calls `SuckToSpectator(plr)` and clears the timer. The 3-second window lets the death animation play and the death-cam fade complete before the screen snaps to spectator.

### Reverse Path — `ExitObserver` (Player Wants Back In)

`CBasePlayer::ExitObserver()` (`player.cpp:7861`) is the **only** way a player can leave the observer state. It is called from:

- `client.cpp` — the `auto_join` / `join_blue` / `join_red` commands (non-round-based). After the player picks a team via the menu.
- `client.cpp` — `FL_FAKECLIENT + iuser3 > 0` auto-promotion path for bots (multiplay_gamerules.cpp ~1792).
- `multiplay_gamerules.cpp` — `InsertClientsIntoArena` (round-based round-start).
- `arena_gamerules.cpp` — manual call inside the arena round-start that promotes the two selected combatants (the rest get `SuckToSpectator`).

It clears `iuser1/iuser2/iuser3` to `0`, sets `m_iExitObserver = TRUE`, and calls `Spawn()`. The flag is consumed by `PlayerSpawn` to skip a couple of one-time spawn effects.

### Bot-Side Implications

Bots **never** open a join menu. `ClientPutInServer` sets `m_bWantsToPlay = TRUE` for any `FL_FAKECLIENT`, and the auto-promotion fast path (`multiplay_gamerules.cpp ~1792`) detects `FL_FAKECLIENT + iuser3 > 0`, sets `m_iObserverWeapon = 2`, and calls `ExitObserver()` next tick. While briefly mid-spectate (waiting for a round), bot AI must guard combat/movement on `IsAlive()` or `IsSpectator()` to avoid acting on observer-state bots.

### Common Pitfalls

1. **Adding a round-based mode and forgetting `IsRoundBased()` override** — players see the FFA join menu and `auto_join` "works" (because `iuser3 > 0` lets `PlayerSpawn` succeed branch 3), but the next `Think` immediately re-spectates them via the `g_GameInProgress + !IsInArena` branch. Symptom: connect, briefly spawn, snap back to spectator.
2. **Calling `ExitObserver()` without `IsInArena = TRUE` first in a round-based mode** — `PlayerSpawn` branch 1 returns immediately (because `g_GameInProgress` is `TRUE` and `IsInArena` is still `FALSE`). The player ends up in a half-state: not in observer (`iuser*` cleared) but not spawned either. Always go through `InsertClientsIntoArena` or set `IsInArena = TRUE` first.
3. **Forgetting the bot fast path** — if a new mode has its own `PlayerSpawn` that returns before the FL_FAKECLIENT branch at `multiplay_gamerules.cpp ~1792`, bots get stuck on the join menu and never enter the round. Either chain to the base `CHalfLifeMultiplay::PlayerSpawn` or replicate the FL_FAKECLIENT auto-join.
4. **`m_flForceToObserverTime` not cleared after `SuckToSpectator`** — the timer must be zeroed once consumed, otherwise the mode's `Think` repeatedly calls `SuckToSpectator` on an already-spectating player and the broadcast spam saturates the scoreboard.
5. **Using `!HasDisconnected` instead of `IsCommittedToPlay()` for round eligibility** — Limbo and Chose-Spectate players have `!HasDisconnected == TRUE` but should NOT be counted as round participants. New round-eligibility iterations must use `IsCommittedToPlay()`. The keystone APIs (`CheckClients`, `InsertClientsIntoArena`) already do this correctly.
6. **Resetting `m_bWantsToPlay` in `StartObserver`** — do not. The field must survive round transitions and suck-to-spectator events; otherwise a committed player who dies and gets sucked to spectator would silently revert to Limbo and not be re-admitted next round. Only `ClientPutInServer` (per-connect init), the `spectate` command, and the `menu` command should clear it.

## Common Pitfalls Across Modes

1. **`v_goal` wiped between `*PreUpdate` and direct-steer** — see the CRITICAL section above. The single most common bug when wiring a new mode.
2. **`is_gameplay` stuck at 0** — `BotCheckTeamplay` not registered → mode runs as FFA from the bot side. Symptom: every `GAME_<MODE>` branch silently skipped.
3. **Frag-vs-roundwins confusion** — using `pev->frags` where `m_iRoundWins` is meant (or vice-versa). Symptom: scoring resets every round, or per-life kill counts persist forever.
4. **`SOLID_TRIGGER` invisibility** — `UTIL_TraceLine` ignores triggers; can't use it to "see" flag pickups, snowball touches, etc. Use distance + classname instead.
5. **`m_szTeamName` lag** — string-name checks see stale values for up to one think tick after a team change. Use `pev->fuser4` for same-frame correctness.
6. **`UTIL_GetTeam` 1-indexing** — bot side returns 1 (blue) / 2 (red) / 0 (none). Server-side `TEAM_BLUE = 0` / `TEAM_RED = 1`. Translate, don't compare.
7. **Direct-steer through walls** — `FVisible` returns true through windows/gaps the bot can't traverse. Use the two-tier (<300u unconditional, 300–500u gated) rule.
8. **Stale `pBotPickupItem` blocking mode logic** — generic item-pickup pointer left non-null prevents the per-mode `*Think` else-if branch from firing. Each mode clears it explicitly in `*PreUpdate` (or in the early branch of `BotThink`) when the role demands it.
9. **`f_waypoint_goal_time` 1-second spawn delay** — an early implementation set this on spawn, suppressing goal selection for the first second. Now zeroed in `BotSpawnInit` so goal selection fires the first frame.
10. **`old_waypoint_goal` carryover** — if not cleared in `BotSpawnInit`, stale waypoint indices from a previous map can be restored after combat disengagement and send the bot to an invalid waypoint.

## Per-Mode Spokes

Each spoke contains: Overview · Win Condition · Scoring · Teams · State Machine · Class Members · Bot Behaviour · Mode-specific Pitfalls. Refer back to this hub for any concept that is not unique to that mode.

- [arena_gamerules.md](arena_gamerules.md) — 1v1 champion-defense duel
- [busters_gamerules.md](busters_gamerules.md) — Reverse-DM, lowest-fragger gets the egon
- [chilldemic_gamerules.md](chilldemic_gamerules.md) — round-based survivor-vs-infection mode
- [coldskull_gamerules.md](coldskull_gamerules.md) — FFA skull collection
- [coldspot_gamerules.md](coldspot_gamerules.md) — Team zone-hold with relocating spot
- [ctc_gamerules.md](ctc_gamerules.md) — FFA keep-away with the chumtoad
- [ctf_gamerules.md](ctf_gamerules.md) — Team capture-the-flag
- [horde_gamerules.md](horde_gamerules.md) — Survivors-vs-monsters wave-based co-op
- [kts_gamerules.md](kts_gamerules.md) — Team soccer with a snowball

Modes without a spoke yet (`GAME_INSTAGIB`, `GAME_ICEMAN`, `GAME_SNOWBALL`, `GAME_TEAMPLAY`) inherit `CHalfLifeMultiplay` defaults; spokes will be added as their bot integrations are built.

## Source File Map

- `src/dlls/gamerules.h` / `gamerules.cpp` — `CGameRules`, `CHalfLifeRules` (SP), `InstallGameRules()`, mutator system, `Is<Mode>()` predicates.
- `src/dlls/multiplay_gamerules.h` / `multiplay_gamerules.cpp` — `CHalfLifeMultiplay`, the multiplayer base. Frag/score/timelimit Think loop, intermission, map cycling, vote system, `gamePlayModes[]` registration table.
- `src/dlls/<mode>_gamerules.{h,cpp}` — one pair per mode, derives from `CHalfLifeMultiplay`.
- `src/common/const.h` — `GAME_*` IDs, `RADAR_*` flags, `MUTATOR_*` IDs.
- `grave-bot-src/dlls/bot.cpp` — `BotThink` orchestrator, `BotSpawnInit`, `BotFindItem`, direct-steer / `<mode>Chase` block.
- `grave-bot-src/dlls/bot_combat.cpp` — `BotCheckTeamplay`, per-mode `*PreUpdate` / `*Think`, `BotFindEnemy`.
- `grave-bot-src/dlls/bot_navigate.cpp` — `BotHeadTowardWaypoint`, `BotFindWaypointGoal`, per-mode goal-recalc gates.
- `grave-bot-src/dlls/bot.h` / `bot_func.h` — per-bot struct fields, function declarations.
