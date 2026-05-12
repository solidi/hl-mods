# Runes — Cold Ice Remastered Reference

Runes are persistent power-ups: a player carries at most one at a time, and the
effect stays active until they die or run `drop_rune`. There are 9 primary rune
types, defined as `RUNE_*` integers in [src/dlls/items.h](../src/dlls/items.h#L30-L42).

This doc is the source of truth for everything rune-related. For how the bot
picks them up, see [gravebot.md → Rune handling](gravebot.md#rune-handling).

---

## 1. Rune types

| ID | Enum            | Classname       | Effect (one-line)                                  | Effect site |
|----|-----------------|-----------------|----------------------------------------------------|-------------|
| 1  | `RUNE_FRAG`     | `rune_frag`     | +1 frag per kill (kill counts as 2)                | [multiplay_gamerules.cpp `IPointsForKill`](../src/dlls/multiplay_gamerules.cpp#L2060-L2063) |
| 2  | `RUNE_VAMPIRE`  | `rune_vampire`  | Heal attacker by `damage/2` on damage dealt        | [multiplay_gamerules.cpp](../src/dlls/multiplay_gamerules.cpp#L1713-L1727), [player.cpp](../src/dlls/player.cpp#L508-L511) |
| 3  | `RUNE_PROTECT`  | `rune_protect`  | Halve incoming damage                              | [player.cpp](../src/dlls/player.cpp#L519-L520) |
| 4  | `RUNE_REGEN`    | `rune_regen`    | +1 HP/s, then armor when full                      | [multiplay_gamerules.cpp](../src/dlls/multiplay_gamerules.cpp#L1728-L1742), [player.cpp](../src/dlls/player.cpp#L2312-L2320) |
| 5  | `RUNE_HASTE`    | `rune_haste`    | Faster fire / shorter reload                       | [weap_smg.cpp](../src/dlls/weap_smg.cpp#L276) and other `if (m_pPlayer->m_fHasRune == RUNE_HASTE)` sites |
| 6  | `RUNE_GRAVITY`  | `rune_gravity`  | `pev->gravity = 0.2`                               | [player.cpp](../src/dlls/player.cpp#L2307-L2310) |
| 7  | `RUNE_STRENGTH` | `rune_strength` | `flDamage *= 1.5` for outgoing damage              | [player.cpp](../src/dlls/player.cpp#L513-L515) |
| 8  | `RUNE_CLOAK`    | `rune_cloak`    | Render alpha invisibility                          | [items.cpp](../src/dlls/items.cpp#L1055-L1060) |
| 9  | `RUNE_AMMO`     | `rune_ammo`     | Refilling magazine (+ instagib hornetgun /         | [multiplay_gamerules.cpp](../src/dlls/multiplay_gamerules.cpp#L1743-L1800), [items.cpp](../src/dlls/items.cpp#L1073-L1086) |
|    |                 |                 | snowball glauncher in those modes)                 | |

`RUNE_FLAKE`, `RUNE_SKULL`, `RUNE_HORNET`, `RUNE_SNOWBALL` (10–13) are
gamemode-specific variants and are NOT spawned by `CWorldRunes`.

Player-side state lives on `CBasePlayer`:

- `m_fHasRune` — current rune ID, 0 if none ([player.h](../src/dlls/player.h#L227)).
- `m_flRuneHealTime` — regen / ammo tick gate.
- `m_fVampireHealth` — vampire drain accumulator.

---

## 2. Entity model — `CRune` and the per-rune subclasses

All rune entities share a base class `CRune` ([items.cpp `CRune::Spawn`](../src/dlls/items.cpp#L467-L485),
[`CRune::RuneTouch`](../src/dlls/items.cpp#L487-L525)).

- `MOVETYPE_TOSS`, `SOLID_TRIGGER`, random spawn velocity (±300 XY, 0–300 Z),
  25 s entity lifetime.
- Touch handler is `CRune::RuneTouch` — validates the toucher is a player,
  defers to subclass `MyTouch(pPlayer)`, plays `rune_pickup.wav`, sends a HUD
  message, removes the entity.
- Visual: `models/w_runes.mdl` with `pev->body = RUNE_* − 1` (mesh variant 0–8)
  + per-rune glow shell (`renderfx = kRenderFxGlowShell`, `renderamt = 5`,
  custom RGB).

Each subclass (`CFragRune`, `CVampireRune`, `CProtectRune`, `CRegenRune`,
`CHasteRune`, `CGravityRune`, `CStrengthRune`, `CCloakRune`, `CAmmoRune`) lives
in [items.cpp 546–1089](../src/dlls/items.cpp#L546-L1089). Subclass `MyTouch`:

1. Bails out if `pPlayer->m_fHasRune` is already set.
2. Writes the rune ID to `m_fHasRune`.
3. Applies one-shot effects (e.g. CLOAK sets the player's render mode; AMMO
   may give a weapon).
4. Returns `TRUE` so `RuneTouch` removes the entity.

Linkage: `LINK_ENTITY_TO_CLASS(rune_frag, CFragRune)` etc. through
[items.cpp 1089](../src/dlls/items.cpp#L1089).

Runes do **not** use `pev->fuser4` for radar — that field is reserved for
gamemode role tags (Busters / CTC / Arena / CTF / Loot).

---

## 3. World controller — `CWorldRunes`

[items.cpp 1113–1358](../src/dlls/items.cpp#L1113-L1358).

| Method | Purpose |
|---|---|
| `Spawn()` | Precaches all 9 rune classes, schedules `SpawnRunes` at +5 s. |
| `Precache()` | `UTIL_PrecacheOther` for each `rune_*` class. |
| `SpawnRunes()` | Spawn cycle — runs every 30 s. Spawn count = `min(ceil(playerCount/2) + 1, 9)`. |
| `CreateRune(class)` | Picks a random `info_player_deathmatch` via `SelectSpawnPoint`, creates the entity with random velocity, applies mutator side-effects (turrets / barrels / rats may also spawn). |
| `SelectSpawnPoint(spot)` | Random `info_player_deathmatch`. |
| `static DropRune(pPlayer)` | Drops the player's current rune at their position. |

Spawn cadence: first batch +5 s after map load, rebuild every 30 s. Up to
nine runes can be alive at once.

---

## 4. Drop mechanic

The only drop entry point is the `drop_rune` client command
([client.cpp 925–933](../src/dlls/client.cpp#L925-L933)):

```cpp
else if ( FStrEq(pcmd, "drop_rune" ) )
{
    CBasePlayer *pPlayer = GetClassPtr((CBasePlayer *)pev);
    if ( pPlayer->m_fHasRune )
    {
        CWorldRunes::DropRune(pPlayer);
        ClientPrint(pPlayer->pev, HUD_PRINTCENTER, "Discarded Rune\n");
    }
}
```

`CWorldRunes::DropRune(pPlayer)` ([items.cpp 1142–1211](../src/dlls/items.cpp#L1142-L1211)):

1. Maps `m_fHasRune` → classname (`rune_frag`, `rune_vampire`, …).
2. Per-rune cleanup:
   - **GRAVITY** — restore `pev->gravity = 1.0`.
   - **AMMO** — strip the special weapon granted on pickup
     (`weapon_hornetgun` in instagib, `weapon_glauncher` in snowball mode).
   - **CLOAK** — restore render mode.
3. Spawns the rune entity at `pPlayer->GetGunPosition() + v_forward * 32`
   with velocity ≈ `v_forward * 400`.
4. Clears `m_fHasRune` and the matching status icon.

There is also a death-drop in [player.cpp 876–909](../src/dlls/player.cpp#L876-L909):
on death, if `m_fHasRune` is set and no other rune is within 256 u, it calls
`CWorldRunes::DropRune(this)`. Otherwise it just clears `m_fHasRune` (and
resets HASTE-affected weapon timers) — this prevents rune clusters when bots
or players die on top of an existing rune.

---

## 5. How bots interact

Short version: bots track their rune in a separate state mirror and may
**swap on contact** by issuing `drop_rune` just before touching a strictly
better rune. Full design + scoring table is in
[gravebot.md → Rune handling](gravebot.md#rune-handling). The bot does not
read `m_fHasRune` directly; it learns its rune type from the
`BotClient_Valve_ItemPickup` callback by parsing the `rune_*` classname.
