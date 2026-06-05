# Gungame Gamerules

`CHalfLifeGunGame` (src/dlls/gungame_gamerules.cpp) extends `CHalfLifeMultiplay`. Players progress through a fixed weapon ladder (`g_WeaponId[]`) one level at a time; first to clear the ladder (or reach `Winner`) wins the round.

Activated when `g_GameMode == GAME_GUNGAME` (set via `mp_gamemode` / `gamemode` cvar — see [gamerules.md](gamerules.md)).

---

## Ladder

`g_WeaponId[MAXLEVEL+1]` (gungame_gamerules.cpp:41) lists short weapon names without the `weapon_` prefix, grouped roughly by HUD slot:

| Group | Examples |
|-------|----------|
| Hand (pistols) | `9mmhandgun` → `dual_glock` → `deagle` → ... → `zapgun` |
| Long (rifles) | `9mmAR`, `12gauge`, `shotgun`, `crossbow`, `sniperrifle`, `chaingun` ... |
| Heavy | `rpg`, `dual_rpg`, `railgun`, ..., `gauss`, `egon`, `glauncher`, `gravitygun` |
| Loose | `snowball`, `handgrenade`, `satchel`, `tripmine`, `snark`, `chumtoad`, `vest` |
| Melee | `chainsaw`, `wrench`, `crowbar`, `rocketcrowbar`, `knife` |
| Sentinel | `Winner` |

The current player level is `m_iRoundWins`. `g_WeaponId[m_iRoundWins]` is the active weapon. Gating: `ggfrags` cvar — frags per level.

Weapon hand-out at respawn / level-up: `sprintf(weapon, "weapon_%s", g_WeaponId[...])` (line ~354) then `pPlayer->GiveNamedItem(weapon)`. Old weapons are stripped first.

---

## Rotation cleanup (IPointsForKill, line ~395)

When the attacker advances a level, any projectiles/placeables they spawned with the *old* weapon would otherwise persist and still kill people. The dispatcher in `IPointsForKill` clears them by classname before incrementing `m_iRoundWins`:

| Outgoing weapon | Cleanup |
|-----------------|---------|
| `snark` | `DeactivateItems("monster_snark")` |
| `chumtoad` | `DeactivateItems("monster_chumtoad")` |
| `crossbow` | `DeactivateItems("bolt")` |
| `gravitygun` | `DeactivateItems("monster_barrel")` |
| `freezegun` | `DeactivateItems("plasma")` |
| `handgrenade` / `9mmAR` / `glauncher` | `DeactivateItems("grenade")` |
| `rpg` / `dual_rpg` | `DeactivateItems("rpg_rocket")` |
| `hornetgun` / `dual_hornetgun` | `DeactivateItems("hornet")` |
| `flamethrower` / `dual_flamethrower` | `DeactivateItems("flameball")` |
| `cannon` | `DeactivateItems("flak")` + `DeactivateItems("flak_bomb")` |
| `tripmine` | `DeactivateItems("monster_tripmine")` + `DeactivateItems("monster_proxmine")` |
| `satchel` | `DeactivateSatchels(pAttacker)` + `DeactivateItems("monster_proxmine")` |

`DeactivateItems(pPlayer, classname)` walks all entities of that classname and removes those owned by `pPlayer` (mirrors `DeactivateSatchels` in satchel.cpp). Proximity mines are deployed via `+reload` on either `weapon_tripmine` or `weapon_satchel` (see [weapons.md](weapons.md)), so they need cleanup on **both** branches.

### Adding a new weapon to the ladder

1. Append the short name to `g_WeaponId[]` in the appropriate slot group.
2. Bump `MAXLEVEL` in `gungame_gamerules.h` if the array grew.
3. If the new weapon spawns persistent projectiles/placeables, add a `DeactivateItems(pAttacker, "monster_xxx")` branch in `IPointsForKill`. Skipping this lets the bot or player win-by-old-mine after they've already "lost" the weapon.
4. Make sure the projectile classname is also covered by `RemoveAndFillItems` (see [gamerules.md](gamerules.md)) so round restarts wipe it.

---

## Related files

- [gamerules.md](gamerules.md) — base gamerules, `RemoveAndFillItems`.
- [weapons.md](weapons.md) — weapon classes, AcceptReload / proxmine.
- [gravebot_combat.md](gravebot_combat.md) — bot weapon preferences; bots in gungame use `m_iRoundWins` to pick their active weapon.
