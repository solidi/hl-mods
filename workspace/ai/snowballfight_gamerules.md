# Snowball Fight Game Mode — AI Context

## Overview
- Game mode: `GAME_SNOWBALL = 17` (`src/common/const.h`)
- `mp_gamemode` string: `"snowball"`
- Display class in roster: `CHalfLifeSnowballFight`
- Practical implementation: this mode is handled by **conditional branches inside `CHalfLifeMultiplay`** (`src/dlls/multiplay_gamerules.cpp`), not a dedicated `snowball_gamerules.cpp` subclass.

> Foundation reading: load [gamerules.md](gamerules.md) first for shared contracts (spectator model, match flow, mutator pipeline, scoring fields, and cross-DLL flags).

## Where Logic Lives
- `src/dlls/multiplay_gamerules.cpp`
- `src/dlls/glauncher.cpp` (snowball/snowbomb launcher behavior)
- `src/dlls/snowball.cpp` (weapon_snowball)
- `src/dlls/flying_snowball.cpp` (`flying_snowball` projectile)
- `src/dlls/snowbomb.cpp` (`snowbomb` bounce-then-freeze blast)

## Core Rules (CHalfLifeMultiplay conditionals)

### Damage tuning
- `RefreshSkillData` sets `gSkillData.plrDmgSnowball = 250` when `g_GameMode == GAME_SNOWBALL`.

### Objectives / HUD
- Mode objective text is changed from `Frag 'em` to `Snowball 'em` in both periodic objective refresh and late-join `InitHUD` paths.
- `PlayerThink` shows a one-shot banner to human clients:
  - title: `Snowball Fight`
  - subtitle: `Lots of balls, sometimes with launchers.`

### Spawn loadout
- Normal spawn flow still runs through `CHalfLifeMultiplay::PlayerSpawn`.
- In default-loadout branch (`addDefault`), Snowball mode gives:
  - `weapon_fists`
  - `weapon_vice`
  - `weapon_snowball`
- Bots still follow base auto-join behavior from shared multiplayer logic.

### Pickup gate
`CanHaveNamedItem` limits loadout to:
- `weapon_fists`
- `weapon_snowball`
- `weapon_vice`
- `weapon_glauncher`

Everything else is denied while `IsSnowballFight()` is true.

### World weapon replacement
`IsAllowedToSpawn` rewrites most world `weapon_*` / `ammo_*` spawns in Snowball mode:
- keeps `weapon_fists` and `weapon_vice`
- replaces other weapons/ammo with mostly `weapon_snowball`
- occasionally spawns `rune_ammo` (1 in 9 roll)

### Drops and inventory handling
- `DeadPlayerWeapons` returns `GR_PLR_DROP_GUN_NO`.
- `DeadPlayerAmmo` returns `GR_PLR_DROP_AMMO_NO`.
- `IsAllowedToDropWeapon` returns `FALSE`.

Result: players do not drop weapons/ammo and cannot manually drop weapons.

### Mutator restrictions
`MutatorAllowed` blocks several mutators specifically when `g_GameMode == GAME_SNOWBALL`, including:
- `MAXPACK`, `BERSERKER`, `PLUMBER`, `COWBOY`, `BUSTERS`, `FIRESTARTER`, `PORTAL`, `RANDOMWEAPON`, `ROCKETCROWBAR`, `VESTED`, `FIREBULLETS`.

## Snowbomb Tie-In (from Grenade Launcher)
In `src/dlls/glauncher.cpp`, `IsSnowballFight()` (or snowball mutator) changes launcher behavior:
- Primary attack fires `flying_snowball` rapidly.
- Secondary attack fires `snowbomb`.

`snowbomb` behavior (`src/dlls/snowbomb.cpp`):
- grenade-like bounce physics,
- short fuse,
- white blast visuals,
- radius damage with `DMG_FREEZE` so targets get frozen through shared freeze mechanics (`m_iFreezeCounter` / `FL_FROZEN`).

## Spectator / Round Model
- Inherits `CHalfLifeMultiplay` defaults.
- Not round-based (`IsRoundBased()` remains false in base).
- Uses fraglimit/timelimit style end conditions like FFA, with Snowball-specific objective strings.

## Practical Validation Checklist
1. Start server with `mp_gamemode snowball`.
2. Spawn and verify default weapons are fists + vice + snowball.
3. Attempt to pick up a non-snowball weapon and confirm denial.
4. Kill a player and verify no gun/ammo drop.
5. Use grenade launcher in mode:
   - primary fires flying snowballs,
   - secondary fires a snowbomb with freeze blast behavior.
6. Confirm objective HUD text reads `Snowball 'em`.
