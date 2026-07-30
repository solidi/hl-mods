# PM Shared Movement System (Server + Client)

This document explains the shared movement and prediction layer implemented in `workspace/src/pm_shared/pm_shared.c`.

The same code is compiled into:
- Server DLL movement execution.
- Client DLL movement prediction.

Because both sides run this logic, movement changes can desync prediction if only one side is rebuilt or behavior diverges through preprocessor flags.

## 1. What this file owns

`pm_shared.c` is the core player-movement runtime:
- Ground, air, water, ladder, and noclip movement.
- Friction, acceleration, gravity integration, duck state transitions.
- Stuck-resolution attempts and collision response.
- Surface classification and movement sounds.
- Water transition sounds and drowning-adjacent movement state.

Primary entry points:
- `PM_Move(playermove_t* ppmove, int server)` initializes per-frame movement context.
- `PM_PlayerMove(qboolean server)` performs frame movement dispatch.

## 2. High-level frame flow

Typical `PM_PlayerMove` order:
1. `PM_CheckParamters()` clamps/normalizes command movement and view angles.
2. `PM_ReduceTimers()` advances timer fields (`flTimeStepSound`, `flDuckTime`, `flSwimTime`).
3. Observer/spectator fast-path check (`pmove->spectator || pmove->iuser1 > 0`).
4. Normal-player path:
   - unstick,
   - categorize water/ground,
   - ladder detection,
   - step sounds,
   - duck and movement dispatch by `movetype`.
5. `MOVETYPE_WALK` path ends with `PM_PlayWaterSounds()` transition audio.

Important split:
- `MOVETYPE_FLY` in this file usually means ladder-style movement handling for players.
- It does not always mean an entity that should emit movement audio.

## 3. Spectator and observer state model

Observer-related state comes in through `playermove_t`:
- `pmove->spectator`: classic spectator flag.
- `pmove->iuser1`: observer mode (`OBS_*` values). Non-zero means observer mode active.

In this repo, observer mode frequently uses `iuser1` to gate behavior. Relying only on `spectator` is not sufficient for all observer paths.

## 4. Sound-producing paths in pm_shared

Movement-related audio in `pm_shared.c` is produced by two functions:

- `PM_UpdateStepSound()`:
  - surface/ladder/wade step cadence,
  - calls `PM_PlayStepSound(...)`.

- `PM_PlayWaterSounds()`:
  - enter/exit water transition splash (`pl_wade*.wav`) using `oldwaterlevel` and `waterlevel` deltas.

### Spectator safety rule

Spectators/observers should never generate movement water/step sounds from pm_shared.

Current guard convention:
- Return early when either is true:
  - `pmove->spectator`
  - `pmove->iuser1 > 0`

This is now enforced in both `PM_UpdateStepSound()` and `PM_PlayWaterSounds()`.

## 5. 2026 fix: spectator water audio leak

Symptom:
- Spectator/observer movement outside world bounds could trigger water-like sounds (`pl_swim*` and/or splash/wade transitions).

Root causes:
1. Shared movement audio guards previously only checked `pmove->spectator`, not all observer-mode cases (`iuser1`).
2. Server `CBasePlayer::WaterMove()` runs before observer early-return in `PreThink`, so server-side water sounds could still fire for observers if not explicitly gated.

Fix applied:
- `pm_shared.c`:
  - `PM_UpdateStepSound()` now bails for `spectator || iuser1 > 0`.
  - `PM_PlayWaterSounds()` now bails for `spectator || iuser1 > 0`.
- `workspace/src/dlls/player.cpp`:
  - `CBasePlayer::WaterMove()` now exits immediately for observers/spectators and clears stale `FL_INWATER`.

## 6. Editing checklist for pm_shared changes

When changing `pm_shared.c`:
1. Rebuild both DLLs (`hldll` and `hl_cdll`), not only one side.
2. Validate on listen server and dedicated server paths if possible.
3. Test with:
   - ground movement,
   - ladder movement,
   - water entry/exit,
   - observer roaming and chase modes.
4. Confirm no prediction regressions (client feel and hit timing).

## 7. Quick navigation map

Useful functions in `pm_shared.c`:
- Water classification: `PM_CheckWater()`, `PM_InWater()`
- Ground/position: `PM_CatagorizePosition()`
- Movement core: `PM_WalkMove()`, `PM_AirMove()`, `PM_WaterMove()`, `PM_FlyMove()`
- Ladder handling: `PM_Ladder()`, `PM_LadderMove()`
- Audio: `PM_UpdateStepSound()`, `PM_PlayWaterSounds()`
- Entry: `PM_Move()`, `PM_PlayerMove()`

## 8. Related docs

- Root hub: `workspace/ai/cir.md`
- Client hub: `workspace/ai/client.md`
- Server hub: `workspace/ai/server.md`
- Observer details: `workspace/ai/observer.md`