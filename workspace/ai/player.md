# Player Abilities — Cold Ice Remastered Reference

Cold Ice extends vanilla Half-Life deathmatch with an acrobatic, melee-rich
moveset. Each non-vanilla ability is dispatched through an **impulse** in
`CBasePlayer::CheatImpulseCommands` ([player.cpp](../src/dlls/player.cpp#L5325-L5410)),
runs on the server, and is mirrored to the client via an `m_EFlags` bit so the
view model can swap (e.g. `models/v_forcegrab.mdl`).

This doc is the source of truth for every player-side ability. For the bot
side, see [gravebot_combat.md](gravebot_combat.md) and the memory note
`/memories/repo/gravebot_combat_mechanics.md`. For the rune effects that
modulate damage, fire rate, and gravity, see [runes.md](runes.md).

---

## 1. State surface on `CBasePlayer`

| Member                  | Purpose                                                     | Declared |
|-------------------------|-------------------------------------------------------------|----------|
| `m_iJumpCount`          | Cycles 0 → 1 (jump) → 2 (double-jump sound) → 3 (triple-jump flip) | [player.h](../src/dlls/player.h) |
| `m_fOffhandTime`        | Shared cooldown gate for off-hand actions (punch/kick/forcegrab/grenade) | [player.h](../src/dlls/player.h) |
| `m_fForceGrabTime`      | End-of-window timestamp for the current force grab          | [player.h](../src/dlls/player.h#L327) |
| `m_Banana`              | `EHANDLE` to the active `monster_grabweapon` projectile or grabbed snowball | [player.h](../src/dlls/player.h#L328) |
| `m_fFlipTime`           | Per-direction flip animation gate                           | [player.h](../src/dlls/player.h) |
| `m_iHoldingItem`        | Which alt-fire hand is currently busy (passed to `StartKick`/`StartPunch`) | [player.h](../src/dlls/player.h) |
| `pGrapplingHook`        | Active `CHook` entity (currently disabled build)            | [player.h](../src/dlls/player.h) |
| `m_flNextHook`          | Re-fire gate for the grapple                                | [player.h](../src/dlls/player.h) |
| `m_fSelacoButtonTime`   | First-tap timestamp for slide auto-detect                   | [player.h](../src/dlls/player.h) |
| `m_fSelacoCount`        | Forward-tap counter for slide auto-detect                   | [player.h](../src/dlls/player.h) |
| `m_fHasRune`            | Active rune (see [runes.md](runes.md))                      | [player.h](../src/dlls/player.h#L227) |

### `m_EFlags` bits

Defined in [src/common/const.h](../src/common/const.h). Each bit doubles as a
client-side gate that drives view-model swaps in
[cl_dll/entity.cpp `HUD_StudioEvent`/view-model selection](../src/cl_dll/entity.cpp#L622-L661).

| Bit                  | Meaning                                |
|----------------------|----------------------------------------|
| `EFLAG_FORCEGRAB`    | Tractor beam active — view model = `v_forcegrab.mdl` |
| `EFLAG_PLAYERKICK`   | Off-hand kick in flight                |
| `EFLAG_PUNCH`        | Off-hand punch in flight               |
| `EFLAG_HURRICANE`    | Hurricane kick spin                    |
| `EFLAG_SLIDE`        | Selaco slide active                    |
| `EFLAG_THROW`        | Weapon-throw windup                    |
| `EFLAG_GRENADE`      | Off-hand grenade armed                 |
| `EFLAG_PROTECT`      | Damage gate (rune protect / shield)    |
| `EFLAG_CANCEL`       | Cancel-current-action latch            |

---

## 2. Animation roster

Selected by `CBasePlayer::SetAnimation` (search `PLAYER_` in `player.cpp`):

- `PLAYER_PUNCH`, `PLAYER_KICK`, `PLAYER_HURRICANE_KICK`
- `PLAYER_SLIDE`
- `PLAYER_RIGHT_FLIP`, `PLAYER_LEFT_FLIP`, `PLAYER_BACK_FLIP`, `PLAYER_FRONT_FLIP`
- `PLAYER_JUMP`, `PLAYER_SUPERJUMP`
- `PLAYER_CELEBRATE`, `PLAYER_PULL_UP`, `PLAYER_FROZEN`

---

## 3. Impulse map

The dispatch switch in [CheatImpulseCommands L5325-5410](../src/dlls/player.cpp#L5325-L5410):

| Impulse | Action            | Entry                                                          |
|---------|-------------------|----------------------------------------------------------------|
| 206     | Off-hand Kick     | [CBasePlayerWeapon::StartKick](../src/dlls/weapons.cpp)        |
| 207     | Off-hand Punch    | [CBasePlayerWeapon::StartPunch](../src/dlls/weapons.cpp)       |
| 208     | Slide             | [CBasePlayer::StartSelacoSlide](../src/dlls/player.cpp#L5446)  |
| 209     | Off-hand Grenade  | [CBasePlayerWeapon::ThrowGrenade](../src/dlls/weapons.cpp)     |
| 210     | Right Flip        | `CBasePlayer::StartRightFlip`                                  |
| 211     | Left Flip         | `CBasePlayer::StartLeftFlip`                                   |
| 212     | Back Flip         | `CBasePlayer::StartBackFlip`                                   |
| 213     | Front Flip        | `CBasePlayer::StartFrontFlip`                                  |
| 214     | Hurricane Kick    | [CBasePlayer::StartHurricaneKick](../src/dlls/player.cpp#L5837)|
| 215     | Force Grab        | [CBasePlayer::StartForceGrab](../src/dlls/player.cpp#L6325)    |
| 216     | Throw Weapon      | [CBasePlayerWeapon::ThrowWeapon](../src/dlls/weapons.cpp)      |
| 217/218 | Grapple Fire/Kill | Disabled (commented out in [player.cpp L5392-5410](../src/dlls/player.cpp#L5392-L5410)) — gated under `#if defined( GRAPPLING_HOOK )` elsewhere. |

---

## 4. Per-ability detail

### 4.1 Off-hand Punch (impulse 207)

- Entry: `CBasePlayerWeapon::StartPunch` — performs a short forward melee trace.
- State: sets `EFLAG_PUNCH`; calls `ReleaseHeldItem(300-500 ms)` to free the hand.
- Cooldown: `m_fOffhandTime`.
- Animation: `PLAYER_PUNCH`.
- Networking: client reads `EFLAG_PUNCH` to play arm anim on the view model.

### 4.2 Off-hand Kick (impulse 206)

- Entry: `CBasePlayerWeapon::StartKick`.
- State: sets `EFLAG_PLAYERKICK`; `ReleaseHeldItem(700-900 ms)`.
- Damage: medium-club hit on first solid contact.
- Mode interaction: with `mp_meleedrop` enabled, kicks force the target to drop
  their active weapon as a `weaponbox`.

### 4.3 Hurricane Kick (impulse 214)

- Entry: [`CBasePlayer::StartHurricaneKick`](../src/dlls/player.cpp#L5837).
- Mechanics: sets `EFLAG_HURRICANE`, plays `PLAYER_HURRICANE_KICK`, schedules
  [`EndHurricaneKick`](../src/dlls/player.cpp#L5865) as `SetThink` after the
  spin duration; deals club damage in a radial sweep during the spin.
- Cooldown: `m_fOffhandTime` (shared off-hand gate).

### 4.4 Flips — Right / Left / Back / Front (impulses 210-213)

- Each calls `StartRightFlip` / `StartLeftFlip` / `StartBackFlip` /
  `StartFrontFlip`. Gate: `m_fFlipTime`.
- Triple-jump on `CBasePlayer::Jump` ([player.cpp L2747-2839](../src/dlls/player.cpp#L2747-L2839))
  auto-dispatches a flip when `m_iJumpCount == 3` — direction picked from
  current view yaw + movement keys.
- Animation: one of `PLAYER_*_FLIP`.

### 4.5 Double / Triple Jump

- `CBasePlayer::Jump` ([player.cpp L2747-2839](../src/dlls/player.cpp#L2747-L2839))
  manages `m_iJumpCount`:
  - `1` → ordinary jump impulse.
  - `2` → adds a second vertical kick + double-jump sound.
  - `3` → triggers a flip + `PLAYER_SUPERJUMP` for long-jump module.
- Reset on touching ground.

### 4.6 Force Grab (impulse 215)

- Entry: [`CBasePlayer::StartForceGrab`](../src/dlls/player.cpp#L6325).
- Retry tick: [`CBasePlayer::TryGrabAgain`](../src/dlls/player.cpp#L6500) at 0.25 s.
- End: [`CBasePlayer::EndForceGrab`](../src/dlls/player.cpp#L6580).
- Proxy entity: [`CGrabWeapon`](../src/dlls/player.cpp#L6085-L6206)
  (`monster_grabweapon`) — attract @ 400 u/s, repel @ 1900 u/s with `100 DMG_CLUB`.
- State: `EFLAG_FORCEGRAB`; `m_Banana` holds the projectile; window
  `m_fForceGrabTime = now + 2.5 s`.
- Sound: `heaven.wav` while pulling, `odetojoy.wav` once locked, `gunpickup2.wav`
  on catch.
- View model: client swap to `models/v_forcegrab.mdl`
  ([cl_dll/entity.cpp L622-661](../src/cl_dll/entity.cpp#L622-L661)).
- Mode gates:
  - Refused if `pev->waterlevel == 3`.
  - Refused if `g_pGameRules->MutatorEnabled(MUTATOR_RICOCHET)`.
  - Refused if `!g_pGameRules->IsAllowedToDropWeapon(this)`.
  - World-item sweep skipped if `!g_pGameRules->IsMultiplayer()`.

#### Target acquisition

The function tries three kinds of targets, in order:

1. **Enemy player holding a non-fists weapon** — original trace hit.
   The victim's active weapon is removed and a `monster_grabweapon` is spawned
   at the trace endpoint with `pev->body = weapon.m_iId - 1` and
   `pev->message = classname`.
2. **Slow `kts_snowball`** (`|velocity| <= 75`, no owner) — picked up and
   re-thrown when the player taps impulse 215 again. `pev->owner` becomes the
   grabber and `pev->iuser1` flips to `1` (repel).
3. **World pickup** — bounded sphere sweep along the aim ray.
   Helper: [`CBasePlayer::FindForceGrabWorldItem`](../src/dlls/player.cpp#L6213).
   Walks 0..1024u in 64u steps with a 32u sphere radius; accepts the first hit
   whose classname starts with `weapon_`, `item_`, `rune_`, or `ammo_`, or
   equals `weaponbox`. Skips entities with `EF_NODRAW`, player-owned items,
   and self.

#### `CGrabWeapon::pev->iuser2` — dispatch tag

| Value | Source                        | Touch behavior                                     |
|-------|-------------------------------|----------------------------------------------------|
| 0     | Stolen from enemy player      | `GiveNamedItem` + `SelectItem` (existing path)     |
| 1     | World `weapon_*` pickup       | Resurrect-and-dispatch (see below); fallback `CBasePlayerItem::AttemptToMaterialize` at `FlWeaponRespawnTime` |
| 2     | World `item_*` pickup         | Resurrect-and-dispatch; fallback `CItem::Materialize` at `FlItemRespawnTime` |
| 3     | World `rune_*` pickup         | Resurrect-and-dispatch; fallback `SUB_Remove` +0.1 s |
| 4     | World `weaponbox`             | `UTIL_SetOrigin` box onto grabber + bare `DispatchTouch` (the box keeps its own `pfnTouch`; `CWeaponBox::Touch` is private and cannot be referenced externally) |
| 5     | World `ammo_*` pickup         | Resurrect-and-dispatch; fallback `CBasePlayerAmmo::Materialize` at `FlAmmoRespawnTime` |

The original world entity is hidden **immediately on projectile spawn**
(`EF_NODRAW`, `SOLID_NOT`, `SetTouch(NULL)`, `nextthink` scheduled for the
standard respawn). After Create, `AcquireForceGrabWorldItem` copies the
source's `pev->model`, `pev->body`, and `pev->skin` onto the proxy so the
flying projectile renders as the correct world item (otherwise every grab
shows `w_weapons.mdl`). The proxy itself is spawned at
`pWorld->pev->origin + (0,0,64)` for every type so it floats at roughly
chest height — easier to track and control than dragging along the floor.

#### Per-entity scratch fields used by the force-grab system

| Field        | Stored on        | Purpose                                                     |
|--------------|------------------|-------------------------------------------------------------|
| `iuser1`     | `CGrabWeapon`    | Mode: `ATTRACT (0)` = fly to grabber, `REPEL (1)` = bounce out |
| `iuser2`     | `CGrabWeapon`    | Dispatch tag (table above)                                  |
| `vuser2`     | `CGrabWeapon`    | REPEL direction locked at trigger time (player aim, set in `StartForceGrab`'s "already got a hook" branch via `UTIL_MakeVectors(pev->v_angle); gpGlobals->v_forward`). `GrabWeaponThink` uses it for velocity when in REPEL mode; falls back to homing on `pev->enemy` if the vector is near-zero (snowball path). |
| `pev->enemy` | `CGrabWeapon`    | Edict of the hidden original world entity (target of resurrect-and-dispatch on catch, fallback target for REPEL homing). |
| `vuser1`     | **Hidden world** | Original spawn origin, stashed in `AcquireForceGrabWorldItem`. Defense-in-depth restore in the failure-cleanup path; not normally needed since the resurrect-and-dispatch keeps `pev->origin` untouched. |

**Resurrect-and-dispatch** (iType 1/2/3/5): on catch the hidden original is
briefly resurrected — `SetThink(NULL)`, per-class touch restored
(`CBasePlayerItem::DefaultTouch`, `CItem::ItemTouch`, `CRune::RuneTouch`,
`CBasePlayerAmmo::DefaultTouch`), `EF_NODRAW` cleared, `SOLID_TRIGGER`,
`FL_ONGROUND` set — then `DispatchTouch(orig, plr)` fires the entity's own
pickup path. The entity is **not** moved onto the grabber: `DispatchTouch`
calls the touch handler directly without a position/trace check, and the
engine's respawn pipeline (`VecWeaponRespawnSpot`, `CItem::Materialize`,
`CBasePlayerAmmo::Materialize`) reads `pev->origin` to choose the respawn
spot. Keeping the entity in place guarantees it respawns where it started.

The resurrect approach sidesteps the failure modes of `GiveNamedItem`:
`CRune::RuneTouch` early-outs on missing `FL_ONGROUND`, and
`CItem::Spawn`'s `DROP_TO_FLOOR` can `UTIL_Remove` an item that spawns
overlapping the player. If post-dispatch detection sees the entity still
alive (not `FL_KILLME`, `movetype != MOVETYPE_FOLLOW`, no `EF_NODRAW`), the
proxy re-hides it (with `UTIL_SetOrigin(..., vuser1)` as a defensive
restore) and queues the per-type respawn pipeline.

**Holstered-weapon redeploy on catch**: when `iType != 0` and the grabber's
active weapon is not single-hand (`!FBitSet(m_pActiveItem->iFlags(),
ITEM_FLAG_SINGLE_HAND)`), `DeployLowKey()` is called after dispatch so the
weapon view model re-emerges (the player-steal path 0 reaches this naturally
through `SelectItem`).

#### Repel tap (re-fire while attracting)

While the projectile is in `ATTRACT` mode, tapping impulse 215 again:

1. Calls `UTIL_MakeVectors(pev->v_angle)` and stashes `gpGlobals->v_forward`
   in `m_Banana->pev->vuser2` — locking in the direction the player is aiming
   **at the moment of the tap** (not continuously updated).
2. Sets `m_Banana->pev->iuser1 = 1` (REPEL).

`CGrabWeapon::GrabWeaponThink` then drives velocity along `vuser2` at
1900 u/s. `GrabWeaponTouch` removes the banana on any non-owner contact:
players take 100 `DMG_CLUB`, world brushes / non-players just `UTIL_Remove`
it so the banana never ricochets indefinitely. (Earlier behavior used
`MOVETYPE_BOUNCEMISSILE` to home on `pev->enemy` and would loop forever on
walls — both fixed.)

### 4.7 Grapple Hook (impulses 217/218 — disabled build)

- Files: `src/dlls/grapplinghook.cpp`, `CHook` class.
- Player state: `pGrapplingHook`, `m_flNextHook`.
- CVars: `mp_grapplinghook`, `mp_grapplinghookdeploytime`, `mp_grabsky`.
- Currently commented out in `CheatImpulseCommands`
  ([player.cpp L5392-5410](../src/dlls/player.cpp#L5392-L5410)) — the
  rest of the support code is built under `#if defined( GRAPPLING_HOOK )`.

### 4.8 Throw Weapon (impulse 216)

- Entry: `CBasePlayerWeapon::ThrowWeapon(TRUE)`.
- Spawns a `monster_throwweapon` entity carrying the active weapon model + id.
- Gate: `g_pGameRules->IsAllowedToDropWeapon(this)`. Sets `EFLAG_THROW`.

### 4.9 Off-hand Grenade (impulse 209)

- Entry: `CBasePlayerWeapon::ThrowGrenade(TRUE)`.
- Sets `EFLAG_GRENADE`; baseline cooldown `0.55 s * g_pGameRules->WeaponMultipler()`.

### 4.10 Slide — Selaco style (impulse 208 + auto-detect)

- Manual entry: impulse 208 → [`StartSelacoSlide`](../src/dlls/player.cpp#L5446).
- Auto entry: [`CalculateToSelacoSlide`](../src/dlls/player.cpp#L5419) detects
  **three forward taps within 0.65 s** while pitch < 22° using
  `m_fSelacoButtonTime` and `m_fSelacoCount`.
- End: [`EndSelacoSlide`](../src/dlls/player.cpp#L5681) (also called from
  player think when stand-up clearance returns).
- State: `EFLAG_SLIDE`; animation `PLAYER_SLIDE`.
- Master gate cvar: `acrobatics` (`acrobatics.value`).

### 4.11 Taunt

- Activity `PLAYER_CELEBRATE`. Triggered from `chat`/`taunt` console paths
  and automatically by `CBasePlayer::Killed`'s celebrate branch.
- No EFLAG bit — anim only.

### 4.12 Iron Sights

- Input bit `IN_IRONSIGHT` (see `kb_act.lst` bind `+ironsight`).
- Each opted-in weapon checks the bit in its `ItemPostFrame` / fire path and
  applies its own accuracy / fire-rate modifier. Opted-in weapons:
  mp5, mag60, python, rpg, railgun, sawedoff, shotgun, smg, snowball, usas,
  zapgun, glock (see `wpn_shared/`).
- Pure server-side state — no EFLAG.

---

## 5. Cross-cutting gates

- `acrobatics` cvar — master gate for flips, slide, hurricane kick.
- `g_pGameRules->IsAllowedToDropWeapon(pPlayer)` — required by force grab and
  throw weapon (gamemodes like Coldskull disable both).
- `g_pGameRules->WeaponMultipler()` — global fire-rate / cooldown multiplier.
- `MUTATOR_RICOCHET` — disables force grab (target gets too far).
- `m_fOffhandTime` — shared cooldown across punch / kick / grenade /
  hurricane kick / forcegrab error paths.
- `pev->waterlevel == 3` — most acrobatics refuse while fully submerged.
- `g_pGameRules->IsMultiplayer()` — force-grab world-item sweep is MP-only.

---

## 6. Client touchpoints

- View-model selection: [cl_dll/entity.cpp L622-661](../src/cl_dll/entity.cpp#L622-L661)
  consults `m_EFlags` and swaps to `models/v_forcegrab.mdl`,
  `models/v_kick.mdl`, `models/v_punch.mdl`, etc.
- Pro-tips: `FORCEGRAB_TIP` and related IDs in [hud.h](../src/cl_dll/hud.h)
  drive the first-time-use hint banners.
- Default binds and IN_* bits: [cl_dll/input.cpp](../src/cl_dll/input.cpp) +
  `kb_act.lst`. The `+ironsight` bind toggles `IN_IRONSIGHT`.

---

## 7. Bot integration

The Grave Bot reuses every ability via its impulse layer
(see [gravebot_combat.md](gravebot_combat.md)). Notable hooks:

- Bot calls `StartForceGrab` indirectly through `BotFireGun` when its target is
  beyond melee range and holds an upgrade.
- Bot reads `m_iJumpCount` / `m_fSelacoButtonTime` to chain double/triple jumps
  and slides; see `/memories/repo/gravebot_combat_mechanics.md`.

---

## 8. Pitfalls

- **`globalvars_t` stomp** — the engine zeroes parts of `pev` on transition;
  any `m_f*Time` member you treat as authoritative must be re-asserted in
  `Spawn` / `ResetForRound`.
- **EFLAG reset on respawn** — `CBasePlayer::Spawn` clears `m_EFlags`. Don't
  assume an EFLAG persists across a death.
- **View-model selection is server-driven** — the client cannot independently
  decide to show `v_forcegrab.mdl`; the server must set the EFLAG bit, the
  client mirrors it.
- **Force grab world-item path skips SP** — `FindForceGrabWorldItem` returns
  `NULL` outside multiplayer. The classic enemy-steal path still works in SP
  bots-only mode because that path doesn't go through the sweep.
- **`monster_grabweapon::pev->iuser2`** — `0` is reserved for the enemy-steal
  case so a freshly-constructed projectile (`iuser2 == 0` by default) keeps
  the existing behavior.
- **Snowball forcegrab requires `kts` mode** — the velocity gate (`<= 75 u/s`)
  is only meaningful for grenade-launched snowballs in kts_gamerules.
