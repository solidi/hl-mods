# Observer and Spectator Context (Server + Client)

This document covers both sides of the observer/spectator pipeline:
- Server: entity state, mode changes, target switching, and spawn/start transitions.
- Client: controls, HUD panel, mode UI, and networked observer fields.

It also explains how this codebase treats "observer" versus "spectator".

## 1. Server-side observer flow (player entity)

Primary implementation lives in `src/dlls/observer.cpp` on `CBasePlayer`.

### `Observer_FindNextPlayer(bool bReverse)`
- Cycles through clients in either direction.
- Skips:
  - self,
  - disconnected players,
  - players already in observer mode,
  - hidden/no-draw players (`EF_NODRAW`).
- Sets `m_hObserverTarget` when it finds a valid target.
- Updates network target (`pev->iuser2`) when not in roaming mode.

#### Current switch behavior (new change)
When a new target is selected, server now:
- Moves observer origin to target origin with eye-height offset: `z + 32`.
- Snaps observer angles to target view direction:
  - `pev->angles = pev->v_angle = target->pev->v_angle`.
- Forces one immediate angle apply with `pev->fixangle = TRUE`.

This is implemented in `Observer_FindNextPlayer` and applies across gamemodes, including chilldemic, because all normal follow-next/follow-prev switching routes through this function.

### `Observer_HandleButtons()`
- Server-side button handling in non-HLTV player observer flow.
- `IN_JUMP`: cycles observer mode.
- `IN_ATTACK`: next target.
- `IN_ATTACK2`: previous target.
- Input is rate-limited by `m_flNextObserverInput`.

### `Observer_CheckTarget()`
- Ensures non-roaming observers always have a valid target.
- Falls back to roaming if no target is available.
- Retargets if tracked player is invalid or has remained dead long enough.

### `Observer_CheckProperties()`
- In `OBS_IN_EYE`, copies FOV and current weapon from target.
- Sends `gmsgSetFOV` and `gmsgCurWeapon` to observer client so HUD/crosshair align with tracked target.

### `Observer_SetMode(int iMode)`
- Validates mode bounds.
- Verifies current target validity.
- Ensures non-roaming modes have a target; otherwise falls back to roaming.
- Writes mode/target to `pev->iuser1` and `pev->iuser2`.
- Persists last observer mode in `m_iObserverLastMode`.

## 2. Server-side observer entry points

In `src/dlls/player.cpp`:

### `StartDeathCam()`
- Sends dead player into observer-like camera state after death timeout.
- Uses intermission spot if present; otherwise traces upward and looks down.
- Sets observer physics flags and disables normal player body rendering.

### `StartObserver(Vector vecPosition, Vector vecViewAngle)`
- Full transition into spectator/observer state for a player.
- Clears gameplay state (weapons/FOV/actions/status), sets `PFLAG_OBSERVER`, `EF_NODRAW`, no-clip-like spectator state.
- Moves player to provided observer position.
- Calls `Observer_SetMode(m_iObserverLastMode)`, which then establishes follow target if needed.

In `src/dlls/client.cpp` command handling:
- `specmode <mode>` routes to `CBasePlayer::Observer_SetMode` when player is observer.
- `follownext <0|1>` routes to `CBasePlayer::Observer_FindNextPlayer` when player is observer.

## 3. Legacy server spectator entity (`CBaseSpectator`)

In `src/dlls/spectator.cpp`, `CBaseSpectator` is a separate spectator class:
- `FL_SPECTATOR`, `SOLID_NOT`, `MOVETYPE_NOCLIP`.
- Supports impulse teleport among deathmatch spawn points.

This is a distinct path from `CBasePlayer` observer mode. In practical multiplayer gameplay here, observer camera behavior is primarily driven by `CBasePlayer` + `observer.cpp`.

## 4. Client-side spectator/observer controls and rendering

### Input routing
In `src/cl_dll/input.cpp`:
- Attack/attack2/jump/use/duck input is forwarded into `gHUD.m_Spectator.HandleButtonsDown(...)`.

### Core client observer logic
In `src/cl_dll/hud_spectator.cpp`, `CHudSpectator` handles:
- Button logic (`HandleButtonsDown`, `HandleButtonsUp`).
- Mode transitions (`SetModes`).
- Next/prev selection (`FindNextPlayer`).
- Overview/inset camera handling and camera math (`V_GetInEyePos`, `V_GetChasePos`).

Behavior split:
- Non-HLTV (`!IsSpectateOnly()`): mode/target commands are forwarded to server (`specmode`, `follownext`).
- HLTV/spectate-only: client can locally choose targets/modes and drives `g_iUser*` state.

### Networked observer state fields
In `src/cl_dll/entity.cpp`:
- Client receives server `iuser1`, `iuser2`, `iuser3` into `g_iUser1`, `g_iUser2`, `g_iUser3` for local player.
- These fields control observer mode, tracked target, and menu mode.

### VGUI spectator panel
In `src/cl_dll/vgui_SpectatorPanel.cpp`:
- UI buttons map to spectator actions:
  - next/prev player,
  - mode/camera menus,
  - inset toggle,
  - option menus (join/spectate flows).
- Uses `gHUD.m_Spectator` APIs and global observer fields (`g_iUser1`, `g_iUser3`) for labels and visibility.

## 5. Observer vs Spectator in this codebase

There are two related concepts:

1. Player observer mode (`CBasePlayer`):
- Main in-game dead/spectate flow.
- Uses observer modes (`OBS_*`), target entity index (`iuser2`), and player-owned state (`m_hObserverTarget`).
- Works with game rules, player death transitions, and HUD updates.

2. Spectator entity (`CBaseSpectator`):
- Separate legacy spectator class with simple no-clip + impulse teleport behavior.
- Not the same pipeline as `CBasePlayer` observer tracking.

So they overlap conceptually, but implementation is not identical. For gameplay follow-camera switching, treat `observer.cpp` + `player.cpp` + `hud_spectator.cpp` as the authoritative path.
