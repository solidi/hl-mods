# Particle System — Ownership and Memory Context

Client particle effects in CIR are split between two systems:

- `ParticleSystemManager` in `workspace/src/cl_dll/particlemgr.{h,cpp}`
- `CFlameSystem` in `workspace/src/cl_dll/FlameSystem.{h,cpp}`

Message entry points are in `workspace/src/cl_dll/hud_msg.cpp` (`Particle`, `MParticle`, `DelPart`, `FlameMsg`, `FlameKill`), with server senders under `workspace/src/dlls/`.

## Runtime Topology

Server -> user message -> client message handler -> manager/flame state -> per-frame update/draw.

- `Particle` / `MParticle`: allocate one or more `ParticleSystem` objects with `new` and prepend to manager linked list.
- `DelPart`: remove `ParticleSystem` entries by entity index.
- `FlameMsg`: toggles flame-state entries by entity index.
- `FlameKill`: force extinguish/cleanup for an entity.

## Ownership Model

### 1) Manager-level ownership

`ParticleSystemManager` is the owner of all live `ParticleSystem` instances.

- Allocate: `AddSystem(new ParticleSystem(...))`
- Free paths:
  - `UpdateSystems`: deletes systems when `UpdateSystem(...)` returns false
  - `DeleteSystemWithEntity`: explicit delete by entity id
  - `ClearSystems`: deletes full linked list
  - manager destructor: calls `ClearSystems`

Patch note:
- `DeleteSystemWithEntity` now removes all matching systems, not only the first match.
- `UpdateSystems` now deletes orphaned entity-bound systems when `GetEntityByIndex(ent)` is null and `ent > 0`.

### 2) ParticleSystem-internal ownership

`ParticleSystem` owns:

- `m_pAllParticles`: allocated by `new[]` in `AllocateParticles`, freed by `delete[]` in destructor.
- `m_pFirstType` chain (`ParticleType`): each node freed in destructor.
- `.aur` file buffer from `COM_LoadFile` during constructor parse.

Patch note:
- Fixed `.aur` parse buffer lifetime: `COM_FreeFile` now frees the original loaded pointer, not the parser-advanced pointer.

### 3) Flame state ownership

`CFlameSystem` stores per-entity flame state in `std::map<int, FlameSys> Data`.

Patch note:
- Removed implicit map growth from passive reads.
- `Process(...)` now uses `find()` and exits unless an enabled entry exists.
- `SetState(...)` only creates/updates entries for active states.
- `Extinguish(...)` erases entries and stops loop sound.

This prevents map growth from non-burning entities being rendered each frame.

## Reference/De-reference Accounting

### ParticleSystemManager list

For each `AddSystem`:

- +1 system node in manager list.
- +1 `ParticleSystem` heap object.

De-reference/free conditions:

- `DeleteSystemWithEntity(ent)` removes all matching nodes and deletes each object.
- `ClearSystems()` removes entire list and deletes each object.
- `UpdateSystems()` removes dead systems (`UpdateSystem == false`) and now also removes orphaned entity-bound systems (`ent > 0 && entity missing`).

### ParticleSystem internals

Per `ParticleSystem` object:

- +1 file buffer from `COM_LoadFile` during construction.
- +N `ParticleType` nodes parsed from `.aur`.
- +1 particle array from `new particle[iParticles]`.

On destructor:

- -1 file buffer (constructor free after parse; no destructor free needed).
- -N `ParticleType` nodes.
- -1 particle array.

### FlameSystem map

Per active `FlameMsg(state>0)`:

- +1 map entry (or update existing).

On `FlameKill` or `FlameMsg(state<=0)`:

- -1 map entry via erase.

No entry is created from passive `Process()` calls anymore.

## High-risk Leak Patterns (Now Addressed)

1. Parsing-buffer free mismatch in `ParticleSystem` constructor.
2. Entity delete path only removing first matching system.
3. Orphaned entity-bound systems retained when entity pointer becomes null.
4. Flame-state map growth due implicit insertion on `Data[i]` reads.
5. Server sender gap: `flameball` now flags `m_burnParticleEnabled = 1`, ensuring remove paths emit `DelPart`.
6. Related server heap fix in particle-adjacent path: `CGib::SpawnRandomGibs` now frees temporary `gibsIndex` array.

## Practical Validation Checklist

1. Run a map with sustained fire effects for 10-20 minutes.
2. Verify `DelPart` and `FlameKill` traffic appears during entity cleanup.
3. Confirm client memory telemetry slope is flatter after repeated flameball/projectile churn.
4. Toggle `cl_particlesystem 0/1` during play; confirm no runaway growth while disabled.
5. Change map and verify no stale fire loops or lingering flame effects on non-burning entities.

## Related Context

- Parent overview: `workspace/ai/client.md`
- Message registration and server sends: `workspace/src/dlls/player.cpp` and effect emitters in `workspace/src/dlls/`.
