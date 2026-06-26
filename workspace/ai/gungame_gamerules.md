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

Weapon hand-out at respawn / level-up: `sprintf(weapon, "weapon_%s", g_WeaponId[...])` then `pPlayer->GiveNamedItem(weapon)`. Old weapons are stripped first.

`m_iRoundWins` is incremented in `IPointsForKill` (after the rotation cleanup below). By the time `PlayerKilled` runs the level-up branch, `m_iRoundWins` is already the new value, and `roundsBefore` captured at the top tells whether to run a strip+regrant.

---

## Level-up is DEFERRED — never strip in PlayerKilled

`PlayerKilled` is reached from inside the firing weapon's damage callback:

```
CGauss::PrimaryAttack
  -> StartFire -> Fire -> TraceAttack -> ApplyMultiDamage
    -> CBaseEntity::Killed (victim)
      -> g_pGameRules->PlayerKilled
        -> CHalfLifeGunGame::PlayerKilled
```

Calling `plr->RemoveAllItems(FALSE)` on the **killer** here will reach `CBasePlayerItem::Drop()`, which sets `m_pNext = NULL; m_pPlayer = NULL;` (weapons.cpp ~1483) on every weapon the killer holds — *including the one currently executing `Fire()` further up the stack*. When `CGauss::PrimaryAttack` unwinds and hits its post-fire write:

```cpp
m_pPlayer->m_flNextAttack = UTIL_WeaponTimeBase() + 0.2;   // gauss.cpp:174
```

`m_pPlayer` is NULL → crash at `0x00000264` (NULL + `offsetof(CBasePlayer, m_flNextAttack)`). Reproduces reliably with bots, looks gauss-specific but applies to every weapon that touches `m_pPlayer` after firing (RPG, satchel, snarks, …). Reported as "ice.dll crash when bot kills another bot with tau_cannon near round start" — bots reach the gauss level fast on the ladder.

### The fix

The strip+regrant is queued and drained in `Think()`:

- `m_iPendingLevelUp[33]` — per-`ENTINDEX` flag on `CHalfLifeGunGame` (header `private:`).
- `PlayerKilled` level-up branch only sets `m_iPendingLevelUp[idx] = 1;` — it never touches the killer's weapons synchronously.
- `ProcessPendingLevelUps()` runs the actual `RemoveAllItems(FALSE)` + `GiveMutators` + `GiveNamedItem("weapon_fists")` (+ knife if `ggsteallevel > 0`) + the ladder weapon + level-up sound + center-print.
- `Think()` calls `ProcessPendingLevelUps()` at the very top. `Think` is invoked from `StartFrame()` (client.cpp ~2045), which runs *before* any player physics that frame — so no weapon `Fire()` is on the call stack.

Guards inside `ProcessPendingLevelUps` (re-check on the next-frame world): player exists via `UTIL_PlayerByIndex`, `IsPlayer`, `!HasDisconnected`, `IsAlive`, and `0 < m_iRoundWins < MAXLEVEL`.

### When editing the level-up code

- **Never** call `RemoveAllItems`, `GiveNamedItem`, or anything that drops/holsters the killer's weapons directly from `PlayerKilled`. Set the pending flag and let `ProcessPendingLevelUps` handle it.
- The same hazard applies anywhere else that mutates the killer's inventory during the kill callback (`AddPointsToPlayer`, `IPointsForKill`, mutator hooks). The non-inventory bookkeeping in `PlayerKilled` (frags, scoreboard messages, suicide/steal level adjustments on the **victim**) is still synchronous and fine — those don't run `Drop()` on a live weapon's `this`.
- If you add a new code path that needs to defer to the next frame, reuse `m_iPendingLevelUp` (it's a boolean per slot — re-queuing in the same frame is a no-op) or add a sibling per-slot queue alongside it. Don't bypass `Think()`.

---

## Rotation cleanup (IPointsForKill)

When the attacker advances a level, any projectiles/placeables they spawned with the *old* weapon would otherwise persist and still kill people. The dispatcher in `IPointsForKill` clears them by classname **before** incrementing `m_iRoundWins`:

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
- [weapons.md](weapons.md) — weapon classes, AcceptReload / proxmine. `CBasePlayerItem::Drop()`/`Kill()` NULL out `m_pPlayer` (the trigger for the level-up re-entrancy crash above).
- [gravebot_combat.md](gravebot_combat.md) — bot weapon preferences; bots in gungame use `m_iRoundWins` to pick their active weapon.
