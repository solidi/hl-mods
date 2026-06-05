# Chilldemic Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_CHILLDEMIC = 4` (defined in `src/common/const.h`)
- **String ID**: `"chilldemic"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Chilldemic"` — survivors-vs-infected elimination/infection round mode
- **Source** (Cold Ice Remastered code submodule under `workspace/src/`): `src/dlls/chilldemic_gamerules.cpp`, `src/dlls/chilldemic_gamerules.h`
- **Class**: `CHalfLifeChilldemic : public CHalfLifeMultiplay`
- **Bot Source** (bot submodule under `workspace/grave-bot-src/`): `grave-bot-src/dlls/bot_combat.cpp` (`BotCheckTeamplay` registration), `grave-bot-src/dlls/util.cpp` (`UTIL_GetTeam` chilldemic branch)

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, shared spectator/round APIs, cross-DLL conventions, and common pitfalls.

## Concept
Chilldemic is a round-based infection mode with two teams:
- **Survivors**: start armed, stay alive, and try to eliminate skeletons.
- **Skeletons (Virus)**: start as one randomly selected player each round and spread by fragging survivors.

Every round starts with one infected (`TEAM_SKELETONS` / `RADAR_VIRUS`) and the rest as survivors. The round ends when either side is fully eliminated:
- `survivors_left == 0` -> skeletons win the round
- `skeletons_left == 0` -> survivors win the round

## Win Condition
- Per-round: eliminate the other side
- Match-end: governed by shared round constraints (`roundlimit`, `roundtimelimit`, `scorelimit`) and intermission flow
- On timer expiration, `DetermineWinner()` resolves by highest frags among arena participants

## Scoring
- Base frag/death accounting uses `CHalfLifeMultiplay::PlayerKilled`
- `pev->frags`: per-life frag count (still used for round MVP tie-break in `DetermineWinner`)
- `m_iRoundWins`: persistent round/match score field (used for winner displays and scoreboards)
- On survivor infection, victim frags are reset to `0` in `PlayerKilled` to avoid stale MVP carryover

## Teams and Roles
- Team names:
  - `"survivors"`
  - `"skeletons"`
- Team semantics are driven by `pev->fuser4` in this mode:
  - `TEAM_SKELETONS` / `RADAR_VIRUS` -> infected/skeleton
  - otherwise -> survivor
- `IsTeamplay()` returns `TRUE`
- `PlayerRelationship` uses `GetTeamID`/team strings (`GR_TEAMMATE` for same side)
- Friendly fire uses standard teamplay rule via `FPlayerCanTakeDamage` + `friendlyfire`

## Round Flow (`CHalfLifeChilldemic::Think`)
1. **Wait state**:
- Calls `CheckClients()`
- Requires at least 2 committed players
- Uses `roundwaittime` + countdown (`m_iCountDown`) before round start
2. **Round start**:
- Calls `SetRoundLimits()`
- Picks one random committed arena player as skeleton (`pev->fuser4 = TEAM_SKELETONS`)
- Sets `g_GameInProgress = TRUE`
- `RestoreMutators()`
- Calls `InsertClientsIntoArena(0)`
3. **Round active loop**:
- Counts active survivors/skeletons each update
- Pushes objective text per role
- Handles delayed force-to-spectator (`m_flForceToObserverTime`) for dead players
4. **Round end**:
- If one side reaches 0: stops round timer, pauses mutators, prints winner messaging, increments `m_iSuccessfulRounds`, and schedules next cycle

## Infection Transition (Safe Immediate Conversion)
Chilldemic still converts lethal survivor hits into skeletons right away from the player’s perspective, but the actual respawn now happens from `PlayerDeathThink` after the current weapon frame has finished. That avoids invalidating the weapon owner while `PrimaryAttack()` is still on the stack.

Flow:
- On lethal damage to a survivor during active gameplay, `TakeDamage` records the victim origin/angles and marks a pending Chilldemic conversion.
- The normal death path still runs for scoring and death handling, and the victim remains in survivor model/team state during that dead frame window.
- On the next player death-think tick, the pending conversion is consumed:
  - infection role/model/team are applied at that deferred boundary
  - dead inventory is packed safely
  - the player respawns as a skeleton
  - the respawn point is restored to the original death location
  - a fixed 3-second spawn-style invulnerability window is applied

Implementation details:
- The lethal-hit marker is set in `CBasePlayer::TakeDamage` (`src/dlls/player.cpp`) behind the Chilldemic / arena / non-virus guard
- The infection model/team mutation and actual respawn happen in `CBasePlayer::PlayerDeathThink`
- `Spawn()` is still used to apply the mode-correct skeleton loadout and attributes, but only after the weapon frame is out of the call stack
- The corpse/bodyqueue theory was a red herring for this bug. The real fix was clearing `pev->nextthink` after the convert-time `Spawn()` so `PlayerDeathThink` does not fire again on the live skeleton and call `StartDeathCam()` / `CopyToBodyQue()` a second time.

## Spawn and Loadout Rules (`PlayerSpawn`)
### Skeleton spawn profile
- Weapons: `weapon_fists`, `weapon_vest`, `weapon_chainsaw`
- Health: `max_health = health = 50`
- Physics key: `haste = 1`
- Team/model:
  - `m_szTeamName = "skeletons"`
  - client model forced to `"skeleton"`

### Survivor spawn profile
- Restores preferred model via `pm` fallback (defaults to one of `iceman`, `commando`, `jesus`, `hhev`)
- Gives random non-nuke weapon via `GiveRandomWeapon("weapon_nuke")`
- Team/model:
  - `m_szTeamName = "survivors"`
  - model set to selected/default survivor model

## Respawn Rules (`FPlayerCanRespawn`)
- Round inactive -> no respawn
- Skeleton can respawn while at least one survivor remains
- Others are denied and routed to spectator by timer (`m_flForceToObserverTime`)

## HUD and Messaging
- Uses `gmsgObjective` for role/round/remaining-team updates
- Uses `gmsgTeamNames` + `gmsgTeamInfo` for team state
- Skeleton players receive:
  - `gmsgStatusIcon` (`"skeleton"`)
  - `gmsgBanner` guidance text
- Uses `gmsgPlayClientSound` for countdown/round-end/impact cues

## Item and Weapon Gating
- `weapon_nuke` is blocked for all players (`CanHavePlayerItem`, `CanHaveNamedItem`, `CanRandomizeWeapon`)
- Skeletons are restricted to melee/vest set:
  - allowed: `weapon_fists`, `weapon_chainsaw`, `weapon_knife`, `weapon_crowbar`, `weapon_wrench`, `weapon_dual_wrench`, `weapon_vest`
  - everything else denied
- Skeleton ammo pickups are blocked (`CanHavePlayerAmmo` when infected)

## Client Model Enforcement
`ClientUserInfoChanged` enforces role-safe model changes:
- Non-infected players cannot switch to `skeleton`
- Infected players cannot switch away from `skeleton`

## Mutator Constraints
- Explicitly disallows thirdperson mutator in this mode (`MutatorAllowed`)
- Inherits other mutator policy from `CHalfLifeMultiplay`

## Spectator Behavior
Chilldemic is **round-based** (`IsRoundBased() == TRUE`), so it follows shared round spectator APIs:
- joins start in limbo menu flow
- `InsertClientsIntoArena(0)` admits committed players at round start
- dead non-participants are moved through `SuckToSpectator` pipeline
- `m_flForceToObserverTime` drives delayed observer transitions

## Bot Notes
- Bot DLL recognizes chilldemic in `BotCheckTeamplay` and sets:
  - `is_team_play = TRUE`
  - `is_gameplay = GAME_CHILLDEMIC`
- Team resolution in bot util uses player model:
  - model `"skeleton"` -> team 2
  - otherwise -> team 1

No dedicated Chilldemic bot objective planner is currently wired (unlike CTF/CtC/KTS/Busters/Arena/Horde spokes); behavior is mostly generic teamplay combat with the mode/team registration and team mapping in place.

## Key Constants and Fields
```cpp
// Mode
#define GAME_CHILLDEMIC 4

// Team/role markers used by mode code
// TEAM_SKELETONS
// RADAR_VIRUS

// Core cvars used by flow
// roundlimit
// roundtimelimit
// roundwaittime
// friendlyfire
```

## Common Pitfalls (Mode-Specific)
1. Mixing team checks: this mode uses both team-name strings and `pev->fuser4` role markers.
2. Forgetting immediate infection semantics: survivor lethal hits are no longer a normal death->respawn cycle.
3. Forgetting to clear `pev->nextthink` after convert-time `Spawn()`: the old death think can re-fire and re-enter deathcam/corpse creation on the resurrected skeleton.
4. Basing winner logic on stale counters: `m_iSurvivorsRemain`/`m_iSkeletonsRemain` are recalculated in Think cadence; avoid one-off assumptions between ticks.
5. Treating skeletons as normal loadout players: weapon/ammo gates are intentionally strict.
