# Runes — Cold Ice Remastered Reference

Runes are persistent power-ups: a player carries at most one at a time, and the
effect stays active until they die or run `drop_rune`. There are 9 primary rune
types, defined as `RUNE_*` integers in [src/dlls/items.h](../src/dlls/items.h#L30-L42).

This doc is the source of truth for everything rune-related. For how the bot
picks them up, see [gravebot.md → Rune handling](gravebot.md#4-rune-handling).

---

## 1. Rune types

| ID | Enum            | Classname       | Effect (one-line)                                  | Effect site |
|----|-----------------|-----------------|----------------------------------------------------|-------------|
| 1  | `RUNE_FRAG`     | `rune_frag`     | +1 frag per kill (kill counts as 2)                | [multiplay_gamerules.cpp `IPointsForKill`](../src/dlls/multiplay_gamerules.cpp#L2693) |
| 2  | `RUNE_VAMPIRE`  | `rune_vampire`  | Heal attacker by `damage/2` on damage dealt        | [multiplay_gamerules.cpp](../src/dlls/multiplay_gamerules.cpp#L2283-L2294), [player.cpp](../src/dlls/player.cpp#L508-L511) |
| 3  | `RUNE_PROTECT`  | `rune_protect`  | Halve incoming damage                              | [player.cpp](../src/dlls/player.cpp#L519-L520) |
| 4  | `RUNE_REGEN`    | `rune_regen`    | +1 HP/s while health < max, then +1 armor/s while armor < max_health | [multiplay_gamerules.cpp](../src/dlls/multiplay_gamerules.cpp#L2298-L2309) |
| 5  | `RUNE_HASTE`    | `rune_haste`    | Faster fire / shorter reload + physics `haste=1`   | [items.cpp](../src/dlls/items.cpp#L802) and weapon `RUNE_HASTE` checks |
| 6  | `RUNE_GRAVITY`  | `rune_gravity`  | `pev->gravity = 0.6`                               | [items.cpp](../src/dlls/items.cpp#L885) |
| 7  | `RUNE_STRENGTH` | `rune_strength` | `flDamage *= 1.5` for outgoing damage              | [player.cpp](../src/dlls/player.cpp#L513-L515) |
| 8  | `RUNE_CLOAK`    | `rune_cloak`    | Render alpha invisibility                          | [items.cpp](../src/dlls/items.cpp#L1002-L1006) |
| 9  | `RUNE_AMMO`     | `rune_ammo`     | Refilling ammo (+ instagib hornetgun /             | [multiplay_gamerules.cpp](../src/dlls/multiplay_gamerules.cpp#L2312-L2325), [items.cpp](../src/dlls/items.cpp#L1068-L1086) |
|    |                 |                 | snowball glauncher in those modes)                 | |

`RUNE_FLAKE`, `RUNE_SKULL`, `RUNE_HORNET`, `RUNE_SNOWBALL` (10–13) are
gamemode-specific variants and are NOT spawned by `CWorldRunes`.

Player-side state lives on `CBasePlayer`:

- `m_fHasRune` — current rune ID, 0 if none ([player.h](../src/dlls/player.h#L227)).
- `m_flRuneHealTime` — regen / ammo tick gate ([player.h](../src/dlls/player.h#L228)).
- `m_fVampireHealth` — vampire drain accumulator ([player.h](../src/dlls/player.h#L533)).

---

## 2. Entity model — `CRune` and the per-rune subclasses

All rune entities share a base class `CRune` ([items.cpp `CRune::Spawn`](../src/dlls/items.cpp#L467-L485),
[`CRune::RuneTouch`](../src/dlls/items.cpp#L494-L531)).

- `CRune::Spawn` starts with `MOVETYPE_TOSS` + `SOLID_NOT`, then `MakeTrigger`
   flips to `SOLID_TRIGGER` after 0.25 s and schedules fadeout after 25 s.
- Touch handler is `CRune::RuneTouch` — validates the toucher is a player,
  defers to subclass `MyTouch(pPlayer)`, plays `rune_pickup.wav`, sends a HUD
  message, removes the entity.
- Pickup gate: runes only process pickup while on ground (`FL_ONGROUND`).
- Visual: `models/w_runes.mdl` with `pev->body = RUNE_* - 1` (mesh variant 0–8)
  + per-rune glow shell (`renderfx = kRenderFxGlowShell`, `renderamt = 5`,
  custom RGB).

`CAmmoRune` uses mode-specific mesh variants in `Spawn()`:

- Instagib: `pev->body = RUNE_HORNET - 1`.
- Snowball: `pev->body = RUNE_SNOWBALL - 1`.
- All other modes: `pev->body = RUNE_AMMO - 1`.

This is visual only; the carried rune ID is still `RUNE_AMMO`.

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

[items.cpp](../src/dlls/items.cpp#L1111).

| Method | Purpose |
|---|---|
| `Spawn()` | Calls `Precache()`, then schedules `SpawnRunes` at +5 s. |
| `Precache()` | Delegates to shared `PrecacheRunes()` (all 9 `rune_*` classes). |
| `SpawnRunes()` | Spawn cycle — runs every 30 s. Spawn count = `min(ceil(playerCount/2) + 1, 9)`. |
| `CreateRune(class)` | Picks a random `info_player_deathmatch` via `SelectSpawnPoint`, applies `AllowRuneSpawn` gamerule filtering, applies world-spawn uniqueness filter, then creates the entity with random velocity (plus mutator side-effects such as turrets / barrels / rats). |
| `SelectSpawnPoint(spot)` | Random `info_player_deathmatch`. |
| `static DropRune(pPlayer)` | Drops the player's current rune at their position. |

Spawn cadence: first batch +5 s after map load, rebuild every 30 s. Up to
nine spawn attempts happen per cycle (capped by player count), with no reroll
when an attempt is filtered.

### 3.1 World-spawn uniqueness (2026-07)

Periodic world rune spawning now enforces per-type uniqueness in `CreateRune`:

- If a rune of that classname already exists in the world, spawn is skipped.
- If any connected player currently holds that rune ID (`m_fHasRune`), spawn is skipped.
- Spawn slot is skipped (no reroll), preserving existing cadence and loop shape.

`mp_allowrunes` now controls world spawn mode:

- `mp_allowrunes = 0` -> no periodic world rune spawner.
- `mp_allowrunes = 1` -> 1:1 world-spawn mode enabled (the uniqueness checks above apply).
- `mp_allowrunes > 1` -> abundant world-spawn mode (legacy behavior; uniqueness checks are skipped).

Scope is intentionally limited to the periodic world spawner path only.

- Included: `CWorldRunes::SpawnRunes` -> `CWorldRunes::CreateRune`.
- Not included: direct/special rune creation paths such as
   `CWorldRunes::DropRune`, Snowball direct `Create("rune_ammo")`, and role grants
   like JvS `GiveNamedItem("rune_cloak")`.

### 3.2 Precache safety patch (2026-06)

This was patched after a map-cycle crash:

- Crash symptom: `Host_Error: PF_precache_model_I: 'models/w_runes.mdl' Precache can only be done in spawn functions`.
- Root cause: world rune spawning was gated by `mp_allowrunes` in
   [src/dlls/world.cpp](../src/dlls/world.cpp#L548-L549), but runes can still
   be created later by gameplay code (for example JvS grants `rune_cloak` in
   [src/dlls/jvs_gamerules.cpp](../src/dlls/jvs_gamerules.cpp#L626), and
   Snowball paths can create `rune_ammo` in
   [src/dlls/weapons.cpp](../src/dlls/weapons.cpp#L951) and
   [src/dlls/multiplay_gamerules.cpp](../src/dlls/multiplay_gamerules.cpp#L3470)).
- Fix: add a shared `PrecacheRunes()` declaration in
   [src/dlls/items.h](../src/dlls/items.h#L44), implement it in
   [src/dlls/items.cpp](../src/dlls/items.cpp#L1120), call it from
   `CWorldRunes::Precache`, and also call it unconditionally in
   `CWorld::Precache` at [src/dlls/world.cpp](../src/dlls/world.cpp#L602).

Resulting behavior:

- `mp_allowrunes` now controls only whether the periodic world rune spawner is
   created.
- Rune assets/classes are always precached during map spawn, so later
   `Create("rune_*")` / `GiveNamedItem("rune_*")` calls are safe.

---

## 4. Drop mechanic

The only drop entry point is the `drop_rune` client command
([client.cpp](../src/dlls/client.cpp#L1811-L1819)):

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

`CWorldRunes::DropRune(pPlayer)` ([items.cpp](../src/dlls/items.cpp#L1147-L1235)):

1. Maps `m_fHasRune` → classname (`rune_frag`, `rune_vampire`, …).
2. Per-rune cleanup:
   - **GRAVITY** — restore `pev->gravity = 1.0`.
   - **AMMO** — strip the special weapon granted on pickup
     (`weapon_hornetgun` in instagib, `weapon_glauncher` in snowball mode).
   - **CLOAK** — restore render mode.
   - **HASTE** — reset physics key `haste=0` unless ArmoredMan / MEGASPEED
     mutator / Shidden skeleton exceptions apply.
3. Spawns the rune entity at `pPlayer->GetGunPosition() + v_forward * 32`
   with velocity ≈ `v_forward * 400`.
4. Clears `m_fHasRune` and the matching status icon.

There is also a death-drop in [player.cpp](../src/dlls/player.cpp#L897-L924):
on death, if `m_fHasRune` is set and no other rune is within 256 u, it calls
`CWorldRunes::DropRune(this)`. Otherwise it just clears `m_fHasRune` and
resets rune-related local state (including haste/render reset path) — this
prevents rune clusters when bots or players die on top of an existing rune.

---

## 5. How bots interact

Short version: bots track their rune in a separate state mirror and may
**swap on contact** by issuing `drop_rune` just before touching a strictly
better rune. Full design + scoring table is in
[gravebot.md → Rune handling](gravebot.md#rune-handling). The bot does not
read `m_fHasRune` directly; it learns its rune type from the
`BotClient_Valve_ItemPickup` callback by parsing the `rune_*` classname.
