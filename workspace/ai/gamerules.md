# Gamerules — AI Context Hub

This is the **root context document** for every gamemode in Cold Ice Remastered. Load this file first when working on any `*_gamerules.cpp` or its bot integration; it captures everything common across modes so the per-mode `*_gamerules.md` spokes can stay focused on what is actually unique.

> **How to load context for a mode**: read this file for the foundation, then open the relevant spoke below.

## Mode Roster

| ID | `GAME_*` | mp_gamemode | Class | Spoke |
|---:|----------|-------------|-------|-------|
| 0  | `GAME_FFA`        | `"ffa"` (default)  | `CHalfLifeMultiplay`              | — (base) |
| 1  | `GAME_ARENA`      | `"arena"`          | `CHalfLifeArena`                   | [arena_gamerules.md](arena_gamerules.md) |
| 2  | `GAME_LMS`        | `"lms"`            | `CHalfLifeLastManStanding`         | TBD |
| 3  | `GAME_BUSTERS`    | `"busters"`        | `CMultiplayBusters`                | [busters_gamerules.md](busters_gamerules.md) |
| 4  | `GAME_CHILLDEMIC` | `"chilldemic"`     | `CHalfLifeChilldemic`              | TBD |
| 5  | `GAME_COLDSKULL`  | `"coldskull"`      | `CHalfLifeColdSkull`               | [coldskull_gamerules.md](coldskull_gamerules.md) |
| 6  | `GAME_COLDSPOT`   | `"coldspot"`       | `CHalfLifeColdSpot`                | [coldspot_gamerules.md](coldspot_gamerules.md) |
| 7  | `GAME_CTC`        | `"ctc"`            | `CHalfLifeCaptureTheChumtoad`      | [ctc_gamerules.md](ctc_gamerules.md) |
| 8  | `GAME_CTF`        | `"ctf"`            | `CHalfLifeCaptureTheFlag`          | [ctf_gamerules.md](ctf_gamerules.md) |
| 9  | `GAME_GUNGAME`    | `"gungame"`        | `CHalfLifeGunGame`                 | TBD |
| 10 | `GAME_HORDE`      | `"horde"`          | `CHalfLifeHorde`                   | TBD |
| 11 | `GAME_INSTAGIB`   | `"instagib"`       | `CHalfLifeInstagib`                | TBD |
| 12 | `GAME_ICEMAN`     | `"jvs"`            | `CHalfLifeJVS` (Jesus vs. Santa)   | TBD |
| 13 | `GAME_KTS`        | `"kts"`            | `CHalfLifeKickTheSnowball`         | [kts_gamerules.md](kts_gamerules.md) |
| 14 | `GAME_LOOT`       | `"loot"`           | `CHalfLifeLoot`                    | TBD |
| 15 | `GAME_PROPHUNT`   | `"prophunt"`       | `CHalfLifePropHunt`                | TBD |
| 16 | `GAME_SHIDDEN`    | `"shidden"`        | `CHalfLifeShidden`                 | TBD |
| 17 | `GAME_SNOWBALL`   | `"snowball"`       | `CHalfLifeSnowballFight`           | TBD |
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

Every mode inherits the virtual methods below. The default behaviour lives in `CGameRules` / `CHalfLifeMultiplay`; a mode overrides only what it needs to change.

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
- `RemoveAndFillItems` — wipe + respawn world items for a fresh round.
- `GoToIntermission` — score finalisation, scoreboard freeze, map cycle / vote.
- `ChangeLevel` — applies the next map from `mapcycle.txt` / vote result.

## Common Constants

### Score / win condition
- `m_iRoundWins` (per-player int) — cumulative wins across the match. Most team modes sum this across teammates and compare against `mp_scorelimit`.
- `pev->frags` (per-player int) — per-life kill count. **Frags reset on round end in round-based modes**, `m_iRoundWins` does not.
- `mp_fraglimit`, `mp_scorelimit`, `mp_timelimit`, `mp_roundtimelimit`, `mp_roundlimit` — the four win-condition cvars used across modes.

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
- [coldskull_gamerules.md](coldskull_gamerules.md) — FFA skull collection
- [coldspot_gamerules.md](coldspot_gamerules.md) — Team zone-hold with relocating spot
- [ctc_gamerules.md](ctc_gamerules.md) — FFA keep-away with the chumtoad
- [ctf_gamerules.md](ctf_gamerules.md) — Team capture-the-flag
- [kts_gamerules.md](kts_gamerules.md) — Team soccer with a snowball

Modes without a spoke yet (`GAME_LMS`, `GAME_CHILLDEMIC`, `GAME_GUNGAME`, `GAME_HORDE`, `GAME_INSTAGIB`, `GAME_ICEMAN`, `GAME_LOOT`, `GAME_PROPHUNT`, `GAME_SHIDDEN`, `GAME_SNOWBALL`, `GAME_TEAMPLAY`) inherit `CHalfLifeMultiplay` defaults; spokes will be added as their bot integrations are built.

## Source File Map

- `src/dlls/gamerules.h` / `gamerules.cpp` — `CGameRules`, `CHalfLifeRules` (SP), `InstallGameRules()`, mutator system, `Is<Mode>()` predicates.
- `src/dlls/multiplay_gamerules.h` / `multiplay_gamerules.cpp` — `CHalfLifeMultiplay`, the multiplayer base. Frag/score/timelimit Think loop, intermission, map cycling, vote system, `gamePlayModes[]` registration table.
- `src/dlls/<mode>_gamerules.{h,cpp}` — one pair per mode, derives from `CHalfLifeMultiplay`.
- `src/common/const.h` — `GAME_*` IDs, `RADAR_*` flags, `MUTATOR_*` IDs.
- `grave-bot-src/dlls/bot.cpp` — `BotThink` orchestrator, `BotSpawnInit`, `BotFindItem`, direct-steer / `<mode>Chase` block.
- `grave-bot-src/dlls/bot_combat.cpp` — `BotCheckTeamplay`, per-mode `*PreUpdate` / `*Think`, `BotFindEnemy`.
- `grave-bot-src/dlls/bot_navigate.cpp` — `BotHeadTowardWaypoint`, `BotFindWaypointGoal`, per-mode goal-recalc gates.
- `grave-bot-src/dlls/bot.h` / `bot_func.h` — per-bot struct fields, function declarations.
