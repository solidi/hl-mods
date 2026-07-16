# LifeBar and Floating Damage Numbers

Everything related to player life bar sprites and floating damage numbers in the client HUD lives in `workspace/src/cl_dll/lifebar.cpp` and `workspace/src/cl_dll/lifebar.h`.

Use this page when working on:
- player overhead life bar icons
- floating damage numbers
- attacker attribution and ownership emphasis
- horde monster damage-number display

Parent hub: [client.md](client.md)

## Runtime Ownership

- Client owner: `CHudLifeBar` (`g_LifeBar` singleton)
- Message hooks: `LifeBar`, `MLifeBar`
- Render path:
  - `CHudLifeBar::UpdateSprites()` for overhead lifebar sprites
  - `CHudLifeBar::Draw()` -> `RenderDamageNumbers()` for floating numbers

## Core Data Structures

Defined in `workspace/src/cl_dll/lifebar.h`:

- `s_LifeBarData`
  - per-player lifebar sprite state (`health`, `armor`, `refreshTime`)
- `s_DamageNumber`
  - floating number instance state (`damage`, `attackerIndex`, `spawnTime`, `lifetime`, `worldPosition`, drift, active flags)
- `s_MonsterEntry`
  - slot state for horde monsters (`entityIndex`, `previousHealth`, `refreshTime`, `damageNumbers[]`)

Capacity constants:
- `MAX_DAMAGE_NUMBERS = 5` per entity bucket
- `MAX_HORDE_MONSTERS = 48` tracked monster slots

## Message Flow

### Player path: `LifeBar`

Server registration:
- `gmsgLifeBar = REG_USER_MSG("LifeBar", 3)` in `workspace/src/dlls/player.cpp`

Payload (3 bytes):
1. armor (`BYTE`)
2. player index to render (`BYTE`)
3. attacker index (`BYTE`)

Client handling:
- `CHudLifeBar::MsgFunc_LifeBar`
  - updates lifebar refresh and armor cache
  - compares previous health to current entity health
  - spawns floating damage number when health drops
  - threads attacker index into `AddDamageNumber`
  - drives bell sound (`cl_playpoint`) when local player is attacker

### Monster path: `MLifeBar`

Server registration:
- `gmsgMonsterLifeBar = REG_USER_MSG("MLifeBar", 8)` in `workspace/src/dlls/player.cpp`

Payload (8 bytes):
1. monster entity index (`SHORT`)
2. current health (`SHORT`)
3. max health (`SHORT`)
4. attacker index (`SHORT`, player-only, `0` if unknown/non-player)

Server sender:
- `CBaseMonster::TakeDamage` in `workspace/src/dlls/combat.cpp`
- sends only in horde flow for entities marked `RADAR_HORDE`

Client handling:
- `CHudLifeBar::MsgFunc_MLifeBar`
  - validates minimum payload size
  - reads attacker index when present (`iSize >= 8`), else fallback `0`
  - manages per-monster slot allocation/refresh
  - creates damage number instances on health deltas

## Damage Number Lifecycle

1. Spawn
- Player path: `AddDamageNumber(playerIndex, damage, attackerIndex)`
- Monster path: direct slot write in `MsgFunc_MLifeBar`
- World position is seeded from target origin with random offset
- Arc motion is initialized from random horizontal velocity

2. Simulate
- `RenderDamageNumbers()` computes elapsed lifetime
- Expired entries are deactivated
- Active entries use ballistic vertical motion plus horizontal drift

3. Render
- `RenderDamageDigits(...)`
- Converts world position to screen position
- Applies distance-based size clamp
- Draws minus bar (when `cl_lifemeter == 2`) and digit quads

## Ownership Visual Rules (Current Baseline)

Primary separation:
- Local-player-owned hits:
  - warm tint (`255, 186, 64`)
  - leading marker glyph (small square)
- Non-local hits:
  - neutral tint (`220, 220, 220`)
  - no marker glyph

Secondary separation:
- Keep same fade curve for all hits
- Apply alpha weighting:
  - local-owned hit: `1.0x`
  - non-local hit: `0.6x`

Local-owned is determined by:
- `dmg.attackerIndex == localPlayer->index`

## Cvars and Controls

- `cl_lifemeter`
  - `0`: disabled
  - `>= 1`: lifebar sprites active
  - `> 1`: floating numbers enabled
  - `> 2`: floating number value shows current health instead of delta
- `cl_playpoint`
  - plays bell sound when local player is identified as attacker in `LifeBar`

## Known Caveats

1. Message compatibility
- `MLifeBar` changed from 6 bytes to 8 bytes.
- Mixed old/new client-server binaries may disagree on payload shape.
- Recommended policy: use matched client/server build pairs.

2. Attribution scope
- Monster attacker index only tracks player attackers.
- Non-player/world damage defaults to `attackerIndex = 0` and renders as non-local style.

3. On-screen clutter
- In heavy fights, many overlapping hits can still stack visually.
- Next optional upgrade is motion-language split (local tighter rise, non-local lateral drift).

## Edit Checklist

When changing this system, verify all of the following:

1. Message contract
- `REG_USER_MSG` size matches sender/receiver payload
- client parser handles fallback safely for missing fields

2. Attribution threading
- attacker index is stored in `s_DamageNumber` for both player and monster paths
- all spawn sites set `attackerIndex` explicitly

3. Rendering
- ownership tint/marker rules apply identically in player and monster loops
- alpha weighting applies after fade calculation
- no crashes when local player/entity is unavailable

4. Behavior regressions
- lifebar sprites still draw normally
- bell sound behavior unchanged
- no stale monster-slot artifacts after expiration/map change

## Validation Scenarios

PvP:
1. Local player damages another player -> warm tint + marker + full alpha fade
2. Other player damages target -> neutral tint + no marker + dimmed fade
3. Local player in first person does not get self clutter unless intended by existing rules

Horde:
1. Local player damages horde monster -> local-owned style
2. Teammate damages same monster -> non-local style
3. Monster/world-only damage -> non-local style fallback

Stability:
1. Reconnect/map transition does not leave stale active numbers
2. Spectator and observer paths do not crash and still remain readable

## Related Files

- `workspace/src/cl_dll/lifebar.h`
- `workspace/src/cl_dll/lifebar.cpp`
- `workspace/src/dlls/player.cpp`
- `workspace/src/dlls/combat.cpp`
- `workspace/ai/client.md`
