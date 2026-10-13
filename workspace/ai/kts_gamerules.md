# Kick the Snowball (KTS) Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_KTS = 13` (defined in `common/const.h`)
- **String ID**: `"kts"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Kick the Snowball"` — team-based soccer with a snowball
- **Source**: `src/dlls/kts_gamerules.cpp`, `src/dlls/kts_gamerules.h`
- **Weapon Integration**: `src/dlls/gravitygun.cpp` (hold/launch/return-to-foot, `+reload` force push)
- **Player Integration**: `src/dlls/player.cpp` (`StartForceGrab` / `TryGrabAgain` ball forcegrab, `AutoMelee` early-return in KTS), `src/dlls/weapons.cpp` (`StartKick` / `KickAttack` — impulse 206 kick, interactive-item nudge)
- **Commands**: `src/dlls/client.cpp` (`menu`, `auto_join`, `join_blue`, `join_red`, `spectate`)
- **Cvars** (`src/dlls/game.cpp`): `mp_ktsspawn1` / `mp_ktsspawn2` (goal spawn-point classnames, default `info_player_deathmatch`), `mp_interactiveitems` (default list includes `kts_snowball`, so kicks nudge the ball)
- **Class**: `CHalfLifeKickTheSnowball : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (BotKtsThink, BotFindEnemy KTS filters, BotAssessGrenades), `grave-bot-src/dlls/bot.cpp` (pre-update block, BotFindItem early-return, movement), `grave-bot-src/dlls/bot_navigate.cpp` (BotFindWaypointGoal KTS paths, re-eval snap, yaw override)

> **Foundation reading**: load [gamerules.md](gamerules.md) first — it covers the class hierarchy, the cross-DLL `fuser4` / `RADAR_*` conventions, the [`v_goal` Preservation Contract](gamerules.md#critical--v_goal-preservation-contract), and the bot integration checklist that every mode (including KTS) must satisfy.

## Win Condition
- First team to reach `scorelimit` combined `m_iRoundWins` wins
- Score tracked as sum of all team members' `m_iRoundWins`
- Calls `GoToIntermission()` via `UpdateHud()` when threshold is reached

## Teams
- **Blue (Iceman)**: `TEAM_BLUE = 0`, `pev->fuser4 = 0`, model = `iceman`
- **Red (Santa)**: `TEAM_RED = 1`, `pev->fuser4 = 1`, model = `santa`
- `UTIL_GetTeam` returns: `1 = blue`, `2 = red` (1-indexed; differs from `TEAM_BLUE/TEAM_RED`)
- `AutoJoin(pPlayer, team)`: `team > TEAM_RED` (the `auto_join` path) balances by counting other connected players' `fuser4`; explicit `join_blue` / `join_red` pass the requested team. Sets `m_szTeamName`, forces the model key, broadcasts `TeamInfo` / `ScoreInfo`, sends the objective.
- Team change while playing = `model iceman` / `model santa` → `ClientUserInfoChanged` kills the player with `GIB_ALWAYS` under `m_DisableDeathPenalty = TRUE` (no death penalty / `PlayerKilled` skipped), flips `fuser4` + team name, rebroadcasts.
- Only `iceman` and `santa` models allowed; any other model is reverted with a `[KtS] Can't change team` message. (Same-team model re-sends print a stale `[CtF]` prefix — cosmetic copy-paste.)

## Spectator Behavior

> Foundation: see the [Spectator System](gamerules.md#spectator-system) section in the hub document. KTS is **non-round-based** (`IsRoundBased()` not overridden → `FALSE`).

KTS is **team-based + non-round-based**, same pattern as CTF and Cold Spot.

### Connection
- `ClientPutInServer` sets `iuser3 = OBS_UNDECIDED_SIMPLE`.
- Player issues `menu` → `iuser3 = OBS_UNDECIDED_BOTH` (team-aware menu).
- `auto_join` / `join_blue` / `join_red` commit through `ExitObserver()` and the base `PlayerSpawn` assigns model + team.
- `spectate` parks in `OBS_ROAMING`. Because KTS is non-round-based, mid-match `spectate` from an active player is only honored when `allow_spectators` is set (or the player is still in the limbo menu, `iuser3 > 0`).
- `PlayerSpawn`: if `iuser3 > 0` it re-parks the player at `OBS_UNDECIDED_BOTH` and returns **before** granting the gravity gun; if `iuser3 == 0` (committing from spectator) it calls `AutoJoin(pPlayer, m_iObserverWeapon)`, sets `iuser3 = -1`, and schedules the team banner (`m_iShowGameModeMessage = time + 0.5`).
- Bots auto-promote via the `FL_FAKECLIENT + iuser3 > 0` fast path.

### Mid-Match — Dribbler Cleanup
The snowball entity caches its dribbler via `m_hDribbler` (an `EHANDLE`) and `pev->euser1` (raw edict pointer for cross-DLL bot reads). There is **no** `DropCharm` call in `PlayerKilled`, `ClientDisconnected`, the `spectate` handler, or `StartObserver`. Instead, `BallThink`'s dribble-maintain step (every 0.1s) releases the ball via `DropCharm` when the dribbler is invalid, `deadflag != DEAD_NO`, `IsSpectator()`, `HasDisconnected`, or when `pev->owner` (forcegrab) is set. That validity check runs **before** the goal-AABB check in the same tick, so a dribbler who dies/spectates cannot score on the way out.
- `ClientDisconnected` only clears `m_hLastToucher` if the leaver was the last toucher (prevents goal/kill credit to a freed player).
- `PackDeadPlayerItems`' `pFlag → DropCharm` path is never reached in KTS because both `DeadPlayerWeapons`/`DeadPlayerAmmo` return `NO` (early `RemoveAllItems` return).

### Pitfalls Specific to KTS
- **`pev->euser1` on the snowball must match `m_hDribbler`** — the dual storage is the cross-DLL bridge (bots read `euser1`, server reads `m_hDribbler`). Any new release path must go through `DropCharm` (or the gravity-held branch in `BallThink`, which clears both) or bots will read a stale "still dribbling" pointer.
- **Dribbler release is tick-latent** (≤0.1s). Do not add code that assumes `m_hDribbler` is cleared synchronously on death/spectate; if you need that, call `DropCharm` explicitly from the new path.
- **Gravity-gun hold is NOT released by holster/death.** See [Known Quirks](#known-quirks--open-issues).

## Snowball Entity (`CKtsSnowball`, classname `"kts_snowball"`)
- **Model**: `models/w_weapons.mdl` (body = `WEAPON_SNOWBALL - 1`), scale 4.0
- **Sounds**: `ball_bounce.wav` (wall/floor impact), `dribble.wav` (looped while dribbling)
- **Physics**: `MOVETYPE_BOUNCE`, `SOLID_BBOX`, `DAMAGE_YES` (hp 9999), friction 0.2, gravity unset (1.0). `Spawn` clears `FL_ONGROUND` (recycled edict slots can carry it and leave the ball floating).
- **Kick nudge side-effect**: `KickAttack`'s interactive-item nudge sets `pev->gravity = 0.5` and `pev->friction = 0.5` on the ball; nothing restores them (not even `ResetToMidpoint`) until a goal spawns a fresh ball.
- **Bbox**: `Vector(-12, -12, -12)` to `Vector(12, 12, 12)`
- **Radar**: `pev->fuser4 = RADAR_SNOWBALL` (`17`)
- **Precache**: done in the gamerules constructor via `UTIL_PrecacheOther("kts_snowball")` / `("kts_goal")`

### State Tracking
| Field | Type | Purpose |
|-------|------|---------|
| `m_hLastToucher` | EHANDLE | Last player who kicked/touched the ball (used for goal credit) |
| `m_hDribbler` | EHANDLE | Active dribbling player (NULL when loose) |
| `m_fDribbleSoundTime` | float | Next dribble sound emission time |
| `m_fLastThinkSpeed` | float | Ball speed cached at start of BallThink (pre-collision) |
| `m_fLastPlayerTouchTime` | float | Time of last player contact (idle reset clock) |
| `m_fStuckTime` | float | Time ball became motionless (-1 = not stuck) |
| `m_fBounceTime` | float | Debounce for bounce sound |
| `m_vLastContactVelocity` | Vector | Previous-tick velocity for ΔV bounce sound gating |
| `m_vLastThinkOrigin` | Vector | Origin at the previous `BallThink` |
| `m_fLastThinkMoveDist` | float | Distance moved since the previous `BallThink`; `< 1.0` = "effectively still" capture override in `BallTouch` |
| `m_fNoAutoCaptureUntil` | float | Global no-auto-capture window after strip/release |
| `m_iNoRecaptureEntIndex` | int | Controller entity index blocked from immediate recapture |
| `m_fNoRecaptureUntil` | float | Expiry time for same-controller recapture block |
| `m_bWasGravityHeld` | BOOL | Transition flag: gravity-held in previous think tick |
| `m_fScrumStartTime` | float | Start of the current scrum stall window (`-1` = no contested crowd) |
| `m_vScrumAnchor` | Vector | Ball origin when the stall window started; travel beyond 256u re-anchors |
| `pev->euser1` | edict_t* | Points to dribbler's edict (authoritative; used by bot code) |
| `pev->iuser1` | int | Forcegrab state: 0 = attract, 1 = repel |
| `pev->iuser2` | int | Gravity gun operator entity index; consumed (copied into `m_hLastToucher`, then zeroed) at the top of the next `BallThink` |
| `pev->iuser3` | int | Gravity gun hold latch on the ball (1 = held, 0 = released). Cleared by gravity-gun release paths, `DropCharm`, `ResetToMidpoint` |
| `pev->owner` | edict_t* | Forcegrab owner (engine collision semantics — NOT used for dribble) |

### Ball States
1. **Loose** (`MOVETYPE_BOUNCE`, `SOLID_BBOX`, `m_hDribbler = NULL`): Normal bouncing physics. Players walk into it to kick or auto-acquire dribble.
2. **Dribbling** (`MOVETYPE_NOCLIP`, `SOLID_NOT`, `m_hDribbler != NULL`): Ball tracks ahead of dribbler via spring-damper system. `pev->euser1` set to dribbler's edict. Untraceable (`SOLID_NOT`), so kicks/punches/gravity-gun traces hit the carrier, not the ball.
3. **Gravity-held** (`pev->iuser3 != 0`): Ball position driven by `CGravityGun::ItemPostFrame`. `BallThink` short-circuits (refreshes idle clock, clears stuck timer, force-clears any dribbler bridge fields) and `BallTouch` returns immediately.
4. **Forcegrabbed** (`pev->owner != NULL`): Started by `CBasePlayer::StartForceGrab` / `TryGrabAgain` (2.5s retry window) only if the traced ball is moving `<= 75 u/s` and has no owner. Sets `owner = grabber`, `iuser1 = 0`. `BallThink` pulls it at 350 u/s; at `< 60u` it calls `EndForceGrab()` and slams it along the grabber's view at 1500 u/s. A second tap sets `iuser1 = 1` → immediate 1500 u/s slam. Any other player touching the ball, any `TakeDamage`, or the owner dying cancels the grab.

### Gravity Gun Handoff (KTS-specific)
- Dribbler lookup is `FindPlayerDribbledKtsBall()` (server-only; scans `kts_snowball` for `euser1 == player`).
- If the player is dribbling and taps **primary** or **secondary** with `weapon_gravitygun` while not already holding an entity, the ball is auto-promoted into gravity-gun hold even if not in trace/range checks.
- The handoff path explicitly calls `DropCharm` first, then marks the ball held by gravity gun (`pev->iuser3 = 1`) and stamps `pev->iuser2` with the holder entity index (primary path stamps directly; secondary path stamps in the shared grab block).
- A loose ball can also be grabbed by **secondary** via the normal `GetEntity(256)` trace.
- While holding the KTS ball, **primary** launches it at `player velocity + autoaim forward * 1024`, stamps `iuser2`, clears `iuser3`.
- While holding the KTS ball, tapping **secondary** returns it to foot possession: clears `iuser3`, zeroes velocity, calls `CaptureCharm` for the same player.
- Primary with nothing held and no dribble: `GetEntity(256, true)` trace attack (`plrDmgGravityGun`, `DMG_ENERGYBEAM`) then overrides the target velocity to `forward * 256`. The world-barrel spawn is disabled in KTS.
- Hold tracking (`ItemPostFrame`): spring velocity toward `player origin + forward * 86`; if the ball drifts `> 128u` from the player, the hold drops (`iuser3 = 0`, zero velocity — no `iuser2` stamp).
- Primary/secondary cooldown: `0.4s`.
- While gravity-held (`pev->iuser3 != 0`), dribble/touch possession paths are suppressed entirely.
- On gravity-held -> loose transitions, `BallThink` applies the anti-huddle repossession gates (previous controller = `m_hLastToucher`) before any auto-acquire can run (same parity as dribble release).
- This gives a deterministic flow: dribble -> tap (primary/secondary) -> gun-hold -> secondary -> back to dribble.

### Gravity Gun `+reload` Force Push vs. KTS
- `CGravityGun::Reload()` (radius 180u, see [weapons.md](weapons.md#gravitygun-force-push-reload-on-weapon_gravitygun)) excludes `MOVETYPE_NOCLIP`, so a **dribbled** ball is never pushed; the carrier is.
- Each pushed target gets `TakeDamage(8, DMG_SONIC | DMG_NEVERGIB)` **after** its velocity is set:
  - Players: KTS refuses the damage, but `FPlayerCanTakeDamage` strips an enemy dribbler as a side effect; the knockback velocity survives.
  - Loose/held ball: `CKtsSnowball::TakeDamage` **overwrites** the 1150–1900 u/s launch with `pushDir * 8 * 3 = 24 u/s`. The force push effectively does not move the ball (see [Known Quirks](#known-quirks--open-issues)).

### Anti-Huddle Repossession Gates
- `KTS_STRIP_NEUTRAL_TIME` (0.35s): no player may auto-capture immediately after strip/release.
- `KTS_REACQUIRE_COOLDOWN_SAME_PLAYER` (0.60s): previous controller is blocked from instant recapture.
- Gates are enforced in both auto-acquire code paths (`BallThink` scan and `BallTouch` slow-ball capture).
- Gates are stamped by `DropCharm` and by gravity-held -> loose transitions to keep repossession parity.

### BallThink (runs every 0.1s) — exact order
1. Cache `m_fLastThinkSpeed` (pre-collision speed), `m_fLastThinkMoveDist`, `m_vLastThinkOrigin`.
2. Bail (no reschedule) if this entity is not the gamerules' active `pBall`.
3. Consume `pev->iuser2` → `m_hLastToucher`, then zero it.
4. **Scrum referee** (`UpdateScrum`, see below): if it pops the ball, reschedule and return. Runs before the gravity-held early-out so held balls are covered.
5. **Gravity-held branch** (`iuser3 != 0`): set `m_bWasGravityHeld`; if any dribbler bridge state exists, stop `dribble.wav`, clear `m_hDribbler`/`euser1`, restore `MOVETYPE_BOUNCE`/`SOLID_BBOX`; refresh `m_fLastPlayerTouchTime`, clear `m_fStuckTime`; return.
6. **Held → loose transition**: if `m_bWasGravityHeld` and the ball is neither dribbled nor forcegrabbed, `BeginAutoCaptureBlock(m_hLastToucher, 0.35, 0.60)`.
7. **Auto-acquire**: no dribbler, no forcegrab, live speed `< KTS_DRIBBLE_ACQUIRE_SPEED` (350) → nearest alive, non-spectator, connected player within `KTS_DRIBBLE_ACQUIRE_DIST` (72u, 3D distance, **either team**) that passes `CanPlayerAutoCapture` → `CaptureCharm`.
8. **Dribble maintain** (when `m_hDribbler`):
   - Validity release → `DropCharm` (see Dribbler Cleanup).
   - **Kick detection**: `m_fKickEndTime > time` (0.28s window set by `KickAttack`) or `m_fSelacoSliding` → plays `fists_hitbod.wav`, `DropCharm`, then velocity = view forward with pitch clamped (any downward pitch → `-5°`) × `KTS_FORCE_TOUCH` (600) or `KTS_FORCE_SLIDE` (900); `m_hLastToucher = dribbler`; return.
   - Target = dribbler origin + flattened view forward × 64u, Z from a trace-down (+48/−96) + 12u, else `origin.z − 20`.
   - **Distance break**: `tdist > 128u` → `DropCharm`; return.
   - **Spring-damper**: `springSpeed = tdist * 18` capped at 600 u/s, plus 50% of the dribbler's XY velocity; zero if `tdist <= 1`.
   - Re-emit `dribble.wav` every 5.8s; `m_hLastToucher = dribbler`; clear stuck timer.
   - **Goal AABB check** against red then blue goal `absmin/absmax` (NOCLIP skips trigger touches) → `OnGoalScored`; return.
   - Return (skips forcegrab + reset checks while dribbling).
8. **Forcegrab** (`pev->owner` set): see Ball States; skips reset checks while attracting.
9. **Reset checks** (loose only): `origin.z < -4096` → reset; no player contact for `> 20s` → reset; speed `< 20 u/s` for `> 3s` → reset.

### Scrum Referee (drop ball)
Breaks large-team lockups where a contested crowd keeps the ball penned in. `UpdateScrum()` runs every `BallThink` tick in every ball state (loose, dribbled, gravity-held, forcegrabbed).

**Detection**
1. Crowd = alive, non-spectator, connected players within `KTS_SCRUM_RADIUS` (160u, 3D) of the ball.
2. Armed only when crowd `>= KTS_SCRUM_MIN_PLAYERS` (4) **and** both teams are present (`fuser4`). Otherwise `m_fScrumStartTime = -1`.
3. On arming, anchor = ball origin. If the ball travels `> KTS_SCRUM_MAX_TRAVEL` (128u) from the anchor, the window restarts at the new position.
4. Ball stays within 128u of the anchor for `KTS_SCRUM_STALL_TIME` (2.5s) → `BreakScrum()`.

**`BreakScrum()`**
1. Drops any dribbler via `DropCharm(dribbler, origin)`.
2. `KtsReleaseGravityGunHolds()`: walks every player's inventory (not just the active item, because holstering does not release a hold) and nulls any `CGravityGun::m_pCurrentEntity` pointing at the ball + stops `pulsemachine.wav`. Then clears `iuser3` and `m_bWasGravityHeld`.
3. Cancels forcegrab (`EndForceGrab()` on the grabber, `owner = NULL`, `iuser1 = 0`).
4. Picks a heading from 8 yaw samples (random 0–45° base offset). Score = 256u wall-clearance trace fraction, `−0.25` per crowd player within 60° of the heading, `−2.0` if a goal within `KTS_SCRUM_GOAL_AVOID_DIST` (512u, XY) is within 60°. Highest score wins.
5. Velocity = heading × `KTS_SCRUM_POP_SPEED` (320) + `KTS_SCRUM_POP_LIFT` (420) up. ~528 u/s total, above the 350 u/s acquire speed.
6. `m_fNoAutoCaptureUntil = time + KTS_SCRUM_NO_CAPTURE_TIME` (1.0s). The same-player recapture block set by `DropCharm` is kept.
7. Feedback: `ball_bounce.wav` at pitch 120, and a `Scrum! Ball popped loose` center print to human crowd members.

**Notes**
- `m_hLastToucher` is untouched, so goal/kill credit stays with the last real toucher.
- Pop distance depends on the ball's current `pev->gravity` (a kick nudge halves it, roughly doubling flight time).
- `ResetToMidpoint` clears the scrum window.

### BallTouch (player contact)
- Gravity-held (`iuser3 != 0`) → return immediately (no bounce sound either).
- **Non-player**: ignored while dribbled; otherwise bounce sound if ΔV > 120 (debounced 0.2s).
- **Player** (alive only): refreshes `m_fLastPlayerTouchTime` first.
- **While dribbled**: return (no possession transfer by overlap).
- Touch by the forcegrab owner is ignored; touch by anyone else cancels the forcegrab and continues.
- **Capture**: `(m_fLastThinkSpeed < 350 || m_fLastThinkMoveDist < 1.0)` and `CanPlayerAutoCapture` → `CaptureCharm`, `m_hLastToucher = player`. The move-distance override exists because brush jitter can inflate cached speed on a visually still ball.
- **Otherwise kick**: direction = normalized(ball − player, XY) + 0.75 × player move dir (if XY speed > 50), normalized; Z tilt `0.55` sliding / `0.1` walking; force 900 sliding / 600 walking; `m_hLastToucher = player`.
- Ball-to-player impact damage is computed but the `TakeDamage` call is commented out — the ball never hurts players.

### TakeDamage (any damage applied to the ball)
- Breaks active dribble via `DropCharm(NULL, origin)` (previous controller resolved from `m_hDribbler`; no `m_fCameraDelay` stamp on the carrier). Rarely reached in practice because a dribbled ball is `SOLID_NOT`.
- **Overwrites** velocity: `pushDir * flDamage * mult`, `mult = 20` for `DMG_BULLET`, else `3`. Direction is away from the inflictor origin (fallback: inflictor forward).
- Typical KTS values: kick trace hit `20 * 3 = 60 u/s`, gravity-gun primary trace `60 u/s` (then overridden to 256), gravity-gun force push `8 * 3 = 24 u/s`.
- Cancels forcegrab (`owner = NULL`, `iuser1 = 0`). Does **not** clear `iuser3`.
- Sets `m_hLastToucher` to the attacker if it is a player. Always returns 1.

### ResetToMidpoint
- Clears `m_hLastToucher`, drops dribble (`DropCharm(NULL, g_vecZero)` — no lift), restarts idle clock, clears gates, `iuser1..3`, forcegrab owner, and `m_bWasGravityHeld`.
- Bails (state cleared, ball not moved) if gamerules isn't KTS or either goal is missing.
- Teleports to `FindSafeBallSpawn(midpoint)`: nearest `info_player_deathmatch`, `weapon_*`, or `ammo_*` origin + 36u. Note `IsAllowedToSpawn` replaces map `weapon_*`/`ammo_*` (except `SF_GIVEITEM`) with item drops, so in practice this is usually the nearest deathmatch spawn.
- Zeroes velocity/avelocity. Does **not** restore `gravity`/`friction` changed by kick nudges.
- If the ball moved `> 128u`: chat "Ball reset to mid field!" + `CLIENT_SOUND_AIRHORN`.

## Goal Entity (`CKtsGoal`, classname `"kts_goal"`)
- **Model**: `models/teleporter_orange_rings.mdl` (animated, `kRenderTransColor` amt 128)
- **Physics**: `MOVETYPE_NONE`, `SOLID_TRIGGER`
- **Trigger bbox**: `Vector(-32, -32, -72)` to `Vector(32, 32, 72)` — 64w × 64d × 144h (symmetric; the in-code comment saying "72h" is stale)
- **Team**: `pev->body` — `0 = TEAM_BLUE`, `1 = TEAM_RED`
- **Radar**: `RADAR_BASE_RED` or `RADAR_BASE_BLUE` via `pev->fuser4`; `SpecialEntity` is broadcast on creation and re-sent per player in `InitHUD`
- **Scoring**: Ball enters goal → OPPOSING team scores (blue bot scores in red goal, red bot in blue goal)

### GoalTouch
- Only fires for `kts_snowball` that matches the active `pBall` pointer
- Delegates to `OnGoalScored(opposingTeam, ball)`

### Dual scoring paths
1. **GoalTouch**: Engine trigger touch for `MOVETYPE_BOUNCE` ball (kicked/loose)
2. **BallThink AABB check**: Manual check every 0.1s for `MOVETYPE_NOCLIP` ball (dribbled)

## Gamerules Class (`CHalfLifeKickTheSnowball`)

### Key Members
| Field | Type | Purpose |
|-------|------|---------|
| `pRedGoal` | EHANDLE | Red goal entity |
| `pBlueGoal` | EHANDLE | Blue goal entity |
| `pBall` | EHANDLE | Active snowball (NULL between goal and respawn) |
| `m_fBallRespawnTime` | float | Scheduled ball respawn time (-1 = not pending) |
| `m_iBlueScore` / `m_iRedScore` | int | Cached team scores |
| `m_iBlueMode` / `m_iRedMode` | int | HUD mode flags for CtfInfo message |
| `m_fSpawnBlueGoal` / `m_fSpawnRedGoal` | float | Next goal-spawn attempt time (`-1` once spawned) |
| `m_DisableDeathPenalty` | BOOL | Suppresses PlayerKilled during team-change kill |

### CaptureCharm (begin dribble) — single entry point for every possession gain
Called from `BallThink` auto-acquire, `BallTouch` slow-ball capture, and gravity-gun secondary return-to-foot. No team check, no knowledge of the previous controller (callers set `m_hLastToucher`; at entry it still holds the *previous* toucher, except on the gravity-gun path where it already equals the capturer).
1. Show `cam_dribble` status icon; play `CLIENT_SOUND_LEVEL_UP` to the capturer; `m_fCameraDelay = 0`
2. `m_flNextAutoMelee = time + 300` (inert in KTS — `AutoMelee()` early-returns for KTS)
3. Set `m_hDribbler`, `pev->euser1 = ENT(pPlayer->pev)`, `m_fDribbleSoundTime = 0`, refresh `m_fLastPlayerTouchTime`
4. Switch ball to `MOVETYPE_NOCLIP`, `SOLID_NOT`, clear `FL_ONGROUND`
5. Snap ball to the dribble position (64u ahead, trace-down for slope), zero velocity

### DropCharm (end dribble)
`DropCharm(pPlayer, origin)`; `pPlayer` may be NULL (previous controller then resolved from `m_hDribbler`).
1. If `pPlayer`: `m_fCameraDelay = time + 2` (PlayerThink removes `cam_dribble` then), `m_flNextAutoMelee = time + 3`
2. Stop `dribble.wav`; clear `m_hDribbler`, `euser1`, `m_fDribbleSoundTime`
3. Restore `MOVETYPE_BOUNCE`, `SOLID_BBOX`; also clears `iuser3` and `m_bWasGravityHeld`
4. If `origin != g_vecZero`: relink at `origin + 20u Z` (pass `g_vecZero` from touch callbacks to skip relinking)
5. **Zero velocity** — callers must apply any push themselves afterwards
6. `BeginAutoCaptureBlock(prevController, 0.35, 0.60)`; clear `FL_ONGROUND`

### OnGoalScored
1. Play `CLIENT_SOUND_GOL`
2. Identify scorer (last toucher on scoring team) vs own-goal maker (own-goal frag penalty is commented out)
3. Drop active dribble (must happen before `pBall = NULL`)
4. `pBall = NULL`, `UTIL_Remove(ball)`
5. +1 `m_iRoundWins` to every scoring-team member, +1 bonus to the scorer; `ScoreInfo` broadcast
6. `Celebrate()` for scoring team
7. Banner: "GOAL! {Team} Team Scores!" / "{name} kicked it in!"
8. `UpdateHud` → scorelimit check → `GoToIntermission`
9. Schedule respawn (`KTS_BALL_RESPAWN_DELAY` = 6s) + "Ball incoming!" objective

### Think (per-frame)
- Spawn goals at `EntSelectSpawnPoint(mp_ktsspawn1/2)` with 2s retry; first attempt 2s after gamerules construction
- `EntSelectSpawnPoint` starts 1–5 entries into the classname list and skips spots failing `IsSpawnPointValid` (rejects `SF_GIVEITEM` spots and spots within 1024u of an existing `kts_goal`, which spaces the two goals apart)
- Goals replace the spawn point entity (set SOLID_NOT, EF_NODRAW)
- Initial ball spawn once both goals exist and no respawn is pending; scheduled respawn after a goal
- `SpawnBallAtMidpoint`: `CLIENT_SOUND_SOCCER`, ball at `FindSafeBallSpawn(midpoint)`, "Ball in play!" objective

### PlayerThink
- Removes `cam_dribble` once `m_fCameraDelay` elapses
- Shows the "You Are On Team …" banner when `m_iShowGameModeMessage` elapses

### PlayerKilled
- Skipped entirely while `m_DisableDeathPenalty` (team-change kill)
- If inflictor is `kts_snowball`: resolve kill credit from `m_hLastToucher` (enemy → their kill; same team/self → self-kill; none → original killer). Effectively dead code today because ball impact damage is commented out.
- Otherwise delegates to `CHalfLifeMultiplay::PlayerKilled`

### FPlayerCanTakeDamage
- Returns `TRUE` only for `trigger_hurt` attackers (void/pit/kill-brush map hazards)
- Returns `FALSE` for everything else, including when no ball exists
- Side effect: if the victim is the current dribbler and `KtsCanPlayerStripDribbler` allows it (non-player attacker, self, or enemy-team player), calls `DropCharm(victim, ballOrigin)` — ball pops 20u and is left at **zero velocity**
- Invoked from more than `TakeDamage`: `CBasePlayer::TraceAttack` (blood/decal `canBleed` check), `Freeze()` and `Confuse()` also call it, so the strip fires during the trace phase of kicks/punches

### FPlayerTookDamage
- Code: if victim is dribbling and strip allowed → `DropCharm` + push ball `180 u/s` away from attacker + `120 u/s` up
- **Unreachable for player attackers**: `CBasePlayer::TakeDamage` only calls it when damage was taken, and KTS refuses all non-`trigger_hurt` damage. In practice only `trigger_hurt` reaches it.

### Spawn/Weapons/Items
- Base `CHalfLifeMultiplay::PlayerSpawn` gives `weapon_fists`; KTS `PlayerSpawn` adds `weapon_gravitygun` (not for limbo players)
- `CanHaveNamedItem` restricts to these two weapons; `IsAllowedToDropWeapon` = FALSE
- `DeadPlayerWeapons` / `DeadPlayerAmmo` return `NO` (no drops)
- `IsAllowedToSpawn`: map `weapon_*` / `ammo_*` (without `SF_GIVEITEM`) are replaced by a random `item_healthkit`, `item_battery`, or `item_longjump`
- `AllowRuneSpawn`: only `rune_ammo` is blocked; all other runes spawn
- `MutatorAllowed`: third-person mutator blocked
- Spawn points within 1024u of a `kts_goal` (or flagged `SF_GIVEITEM`) are excluded

## Key Constants
```cpp
#define TEAM_BLUE 0
#define TEAM_RED  1

// Ball damage (computed in BallTouch, but the TakeDamage call is commented out — inert)
#define KTS_DAMAGE_MIN_SPEED  150.0f
#define KTS_DAMAGE_SCALE      (200.0f / 150.0f)

// Ball force
#define KTS_FORCE_TOUCH       600.0f    // walk kick
#define KTS_FORCE_SLIDE       900.0f    // slide kick
#define KTS_FORCE_DAMAGE_MULT 3.0f      // explosion/melee → force
#define KTS_FORCE_BULLET_MULT 20.0f     // bullet → force

// Ball reset
#define KTS_STUCK_TIMEOUT     3.0f      // motionless seconds before reset
#define KTS_IDLE_RESET_TIME   20.0f     // no-contact seconds before reset
#define KTS_FALLING_Z_LIMIT   -4096.0f  // z below which ball resets

// Ball respawn
#define KTS_BALL_RESPAWN_DELAY 6.0f     // seconds after goal before new ball

// Dribble system
#define KTS_DRIBBLE_ACQUIRE_SPEED  350.0f  // max ball speed to auto-acquire
#define KTS_DRIBBLE_ACQUIRE_DIST   72.0f   // proximity for auto-acquire (BallThink scan)
#define KTS_DRIBBLE_BALL_OFFSET    64.0f   // distance ahead of player
#define KTS_DRIBBLE_TRACK_SPEED    600.0f  // spring-damper velocity cap
#define KTS_DRIBBLE_LOSE_DV        200.0f  // UNUSED — defined but never referenced

// Anti-huddle repossession
#define KTS_STRIP_NEUTRAL_TIME             0.35f  // global no-auto-capture after strip/release
#define KTS_REACQUIRE_COOLDOWN_SAME_PLAYER 0.60f  // previous controller cannot instantly recapture

// Scrum referee
#define KTS_SCRUM_RADIUS          160.0f  // crowd radius around the ball
#define KTS_SCRUM_MIN_PLAYERS     4       // crowd size (both teams present) that arms the timer
#define KTS_SCRUM_STALL_TIME      2.5f    // penned seconds before the pop
#define KTS_SCRUM_MAX_TRAVEL      128.0f  // travel from anchor that counts as escaping
#define KTS_SCRUM_POP_SPEED       320.0f  // horizontal pop speed
#define KTS_SCRUM_POP_LIFT        420.0f  // vertical pop speed
#define KTS_SCRUM_NO_CAPTURE_TIME 1.0f    // global no-auto-capture after a pop
#define KTS_SCRUM_GOAL_AVOID_DIST 512.0f  // penalize pop headings toward goals closer than this
```

Related non-KTS constants that shape possession fights: kick trace range `96u` (`KickAttack`), kick interactive-nudge radius `96u` (the `192u` bot branch reads the weapon entity's `pev->flags`, never `FL_FAKECLIENT`, so it is dead), `sk_plr_kick = 20`, `sk_plr_gravitygun = 20`, gravity-gun force push radius `180u`, forcegrab capture speed `<= 75 u/s`, gravity-gun hold drop distance `128u`.

## Bot Behavior (grave-bot-src)

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"kts"` via `strstr` or `atoi == GAME_KTS`
- Sets `is_team_play = TRUE`
- Sets `is_gameplay = GAME_KTS`
- **CRITICAL**: Without this entry, `is_gameplay` stays at 0 (default FFA), and ALL `GAME_KTS` checks in bot code are dead. Every game mode MUST have a corresponding entry in `BotCheckTeamplay()` (`bot_combat.cpp`).

### Dribbler Identification
- `pev->euser1` on the snowball entity is the authoritative dribbler check
- `b_kts_has_ball` (per-bot bool) is set once per tick in the pre-update block (before `BotFindEnemy`): ball exists, `movetype == MOVETYPE_NOCLIP`, `euser1 == pEdict`. When true, the same block pre-sets `v_goal` to the enemy goal (`f_goal_proximity = 0`) and clears `pBotPickupItem` / `item_waypoint`; when false it zeroes `v_goal`.
- Replaces old `pev->owner` usage which had engine collision side-effects
- `BotKtsThink` runs in the no-enemy `else if` chain of the movement section; any tick with a `pBotEnemy` runs the shoot branch instead.

### BotKtsThink Priority (bot_combat.cpp)
| Case | Condition | Behavior |
|------|-----------|----------|
| 1 | `b_kts_has_ball` | Navigate to enemy goal; `v_goal = goal origin`; yaw override + direct-steer when close (< 300u) OR visible (`FVisible`); follow waypoints otherwise. Elevated-goal jump+kick and same-level stall+kick sequences when stuck near goal (see below) |
| 2 | Teammate dribbling | Escort/support instead of contesting ball: `v_goal` becomes a flank/lead support point around the carrier to reduce pile-ups and open the lane |
| 3 | Opponent dribbling | `v_goal = carrier` (`f_goal_proximity = 48`); if carrier is elevated and near in XY, try hook first then multi-jump recovery; when `< 96u` and facing (`dot > 0.65`), fire `impulse 206` (kick) with a 0.6s `f_kts_tackle_attempt_time` cooldown |
| 4 | Ball loose, `<= 120u` | `v_goal = ball`; yaw toward the **enemy goal** and run through the ball; elevated-ball hook/multi-jump recovery first |
| 5 | Ball loose, `> 120u` | `v_goal = ball`; face ball; waypoint routing via BotFindWaypointGoal; applies the same elevated-ball hook/multi-jump recovery |

Case 2 matches carriers with `FL_CLIENT | FL_FAKECLIENT`; Case 3 matches `FL_CLIENT`. If the ball is dribbled but neither case matches (e.g. the bot itself on a stale tick), execution falls through to the loose-ball cases.

### KTS Teammate Support (bot_combat.cpp)
- When `kts_snowball` is dribbled by an allied player (`movetype == MOVETYPE_NOCLIP`, `euser1` same team), non-carrier bots do not chase the ball.
- Support goal is computed from carrier-to-enemy-goal direction (fallback: carrier facing) with lane = `ENTINDEX(bot) % 3`:
  - lane 0 leads `96u` ahead,
  - lanes 1/2 flank `±96u` left/right, trailing `32u`.
- If a supporter is within `72u` (XY) of the carrier, the goal becomes `96u` directly away from the carrier, `24u` back, to break body-block pile-ups.
- If the carrier is elevated, supporters may still use vertical recovery (hook/jump) to maintain support.

### KTS Vertical Recovery (bot_combat.cpp)
- Trigger window: objective is above the bot (`zDelta >= 48`) and horizontally near (`xyDist <= 384`).
- Order of actions: hook first on tall ledges (`zDelta >= 96`, via `BotConsiderHookForItem`), then fallback to `BotGoalElevatedJump` (double/triple jump phases).
- Traversal safety: recovery is skipped while standing on traversal waypoints (`W_FL_LADDER`, `W_FL_LIFT`, `W_FL_JUMP`, `W_FL_DUCKJUMP`, `W_FL_DOUBLEJUMP`) so ladder/lift/jump routing is not disrupted.
- Applied to both elevated carrier chase and elevated loose-ball chase.

### Bot Strip Parity Field (bot.h)
- `f_kts_tackle_attempt_time` throttles deliberate strip attempts while chasing enemy carrier.

### BotFindWaypointGoal KTS Paths (bot_navigate.cpp)
The whole KTS branch only runs when bot `health > 25`; at `<= 25` the generic health-seeking logic runs instead.
- **Dribbling**: Pure-distance search (skips `W_FL_DELETED`, `W_FL_AIMING`, other-team waypoints) for nearest waypoint to the enemy goal (no LOS — goal entities often sit in recessed trigger volumes). Returns `-1` if none so the movement block drives via `v_goal`; never falls back to ball routing.
- **Teammate dribbling**: nearest waypoint to `BotComputeKtsSupportGoal` target around the allied carrier.
- **Ball-chasing**: nearest waypoint to the ball (no LOS, no range cap); also writes `v_goal = navTarget`.
- Returns `-1` if no ball exists — never falls through to tour waypoints.

### Movement Direction Block (bot.cpp)
- `ktsDirectSteer`: When dribbling and goal is close (< 300u) OR visible (`FVisible`) → bypass waypoints, steer directly at goal. The 300u distance fallback is needed because the `kts_goal` trigger origin often sits at floor level, causing eye-to-origin `FVisible` traces to clip geometry.
- `ktsBallChase`: When ball is loose and close (< 300u) OR visible → direct-steer toward ball. Same distance fallback rationale — ball at floor level clips `FVisible` traces.
- Both `ktsDirectSteer` and `ktsBallChase` set `bGoGoal = true`, which makes the movement direction block use `v_goal` instead of `curr_waypoint_index` for direction. This keeps `direction` aligned with `ideal_yaw` (set by BotKtsThink), preventing `cos(dgrad) ≈ 0` stalls.
- When neither condition: follow `curr_waypoint_index` via normal waypoint routing

### Waypoint Re-evaluation
- Runs every 0.5s in KTS (`f_waypoint_goal_time`)
- `curr_waypoint_index` reset via `WaypointFindReachable` only when ball-chasing AND `waypoint_goal` actually changes (prevents back-and-forth oscillation) AND `bSafeToSnap` (not on a ladder/`MOVETYPE_FLY` or `W_FL_LADDER|LIFT|JUMP|DUCKJUMP|DOUBLEJUMP` waypoint, and the current waypoint cannot already route to the new goal)
- Skipped entirely when dribbling (bot follows waypoint graph normally)

### Yaw Override (bot_navigate.cpp — BotHeadTowardWaypoint)
- When not dribbling (`!b_kts_has_ball`): skip waypoint-facing yaw — let BotKtsThink / movement block control yaw toward ball
- When dribbling: normal waypoint-facing yaw applies (BotKtsThink Case 1 overrides when close < 300u or goal is visible)

### Elevated-Goal Scoring (bot_combat.cpp — Case 1)
When the goal origin is > 36u above the bot and within 300u:
1. **Phase 1 — Jump attempts**: Bot jumps up to 3 times (0.6s cooldown) while running forward. If a jump carries the ball into the trigger volume, normal scoring fires.
2. **Phase 2 — Kick fallback**: After 3 failed jumps, bot backs up for 0.8s (reversed movement, aiming up at goal), then fires `impulse 206` (kick) to launch the ball upward.
3. **State reset**: Kick/jump state resets when the goal drops to the same level, when the kick fires, or when the bot loses the ball.

### Same-Level Stall Detection (bot_combat.cpp — Case 1)
When the goal is at the same level (< 36u height diff) and the bot stays within 100u for > 1.5s without scoring:
1. **Phase 1 — Walk in** (first 1.5s): Forces `f_move_speed = max` to push the bot through the trigger volume.
2. **Phase 2 — Kick fallback**: After 1.5s of lingering near the goal, bot enters the same back-up-and-kick sequence as the elevated-goal case.
Stall detection uses proximity duration (not instantaneous velocity) to handle oscillating/fidgeting bots that never reach 0 speed.

### Bot Fields for Goal Scoring (bot.h)
| Field | Type | Purpose |
|-------|------|---------|
| `b_kts_has_ball` | bool | Dribbler detection (set in pre-update block) |
| `f_kts_jump_time` | float | Next allowed jump attempt time |
| `i_kts_jump_count` | int | Consecutive jump attempts at current goal approach |
| `f_kts_kick_time` | float | Scheduled kick time (0.8s after entering kick sequence) |
| `b_kts_kick_pending` | bool | True while in the back-up-and-kick sequence |
| `f_kts_stall_time` | float | Time when the bot first entered the 100u stall zone |

### Team Mapping for Goals
- `UTIL_GetTeam` returns `1 = blue`, `2 = red`
- `kts_goal pev->body`: `0 = TEAM_BLUE`, `1 = TEAM_RED`
- Blue bot (team 1) scores in red goal (body == 1)
- Red bot (team 2) scores in blue goal (body == 0)
- Formula: `enemyGoalBody = (botTeam == 1) ? 1 : 0`

### Combat in KTS
- `BotFindEnemy`: When bot has ball → returns NULL (focus on scoring). Acquisition loop skips every player except the authoritative dribbler (`BotGetKtsSnowballCached()` + `MOVETYPE_NOCLIP` + `euser1`); the generic teamplay guard drops teammates. Retention drops the enemy as soon as they stop dribbling.
- `BotAssessGrenades` (every 0.2s) allowlists `kts_snowball`, so a visible ball within 1000u can be written into `pBotEnemy`. This runs after the shoot block in `BotThink`, and the next tick's `BotFindEnemy` KTS retention check clears it, so it is transient — but any code reading `pBotEnemy` between those points sees the ball.
- Engage/disengage: KTS resets `waypoint_goal = -1`, `old_waypoint_goal = -1` and `f_waypoint_goal_time = 0` instead of restoring `old_waypoint_goal`
- `BotFindItem`: Returns early in KTS — clears `pBotPickupItem` and `item_waypoint`

## Known Quirks / Open Issues
Verified against code (2026-10). Items 1 and 3 are mitigated (not fixed at the source) by the [Scrum Referee](#scrum-referee-drop-ball); the rest are unchanged.

1. **Strips leave a dead ball in the scrum.** Every player strip goes through `FPlayerCanTakeDamage` → `DropCharm`, which zeroes velocity and only lifts 20u. The 180 u/s push-away in `FPlayerTookDamage` never runs for player attackers. After the 0.35s neutral window the ball is still inside the 72u auto-acquire radius of the crowd, so possession churns in place. This drove large-team (6v6/8v8) scrum lockups; the scrum referee now pops the ball after 2.5s of contested stalling.
2. **Direct hits overwrite better velocities.** `CKtsSnowball::TakeDamage` replaces velocity with `damage * 3`. When a kick's line/hull trace hits the loose ball, `KickAttack` first applies the 600–800 u/s interactive nudge and then `TraceAttack` overwrites it to ~60 u/s — still below the 350 u/s acquire speed. Glancing kicks that only nudge keep the full velocity. Gravity-gun force push on the ball ends at ~24 u/s for the same reason.
3. **Gravity-gun hold latch can be orphaned.** `CGravityGun::Holster` (weapon switch, `StartObserver`, `RemoveAllItems` on death) does not clear `m_pCurrentEntity` or the ball's `iuser3`. An orphaned `iuser3 = 1` ball keeps hitting the gravity-held early-return in `BallThink` (idle/stuck reset frozen, no auto-acquire) and `BallTouch` (no touch capture/kick). It can still be punched, kicked by nudge, roll into a goal, or be re-grabbed and released with a gravity gun, which clears the latch. The scrum referee also clears it (and the holstered gun's pointer) when a contested crowd stalls around the ball; an orphaned ball with no contested crowd nearby stays latched.
4. **Kick nudge mutates ball physics** (`gravity 0.5`, `friction 0.5`) for the rest of the ball's life.
5. **Inert code**: `KTS_DRIBBLE_LOSE_DV`, ball impact damage, the snowball-inflictor branch of `PlayerKilled`, and `FPlayerTookDamage` (except `trigger_hurt`).
