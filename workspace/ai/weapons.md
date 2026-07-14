# Weapons — AI Context Spoke

Cross-cutting reference for everything that registers a `weapon_*` classname. Most weapons have a server-side authority half (in `workspace/src/dlls/`) and a client-side prediction half (in `workspace/src/cl_dll/`, primarily `ev_hldm.cpp` + `wpn_shared/` mirrors). This file documents the **mechanics** they share and inventories every `weapon_*` entity.

> Parents: [server.md](server.md), [client.md](client.md). Sister docs: [player.md](player.md) (impulse abilities), [gravebot_combat.md](gravebot_combat.md) (bot weapon use), [runes.md](runes.md) (rune-modified fire behaviour).

## File Map

- `workspace/src/dlls/weapons.{h,cpp}` — `CBasePlayerItem`, `CBasePlayerWeapon`, the `ItemPostFrame` dispatcher, weapon registry (`ItemInfoArray`), `CGrenade` base, and shared helpers (`ApplyMultiDamage`, `EjectBrass`, `W_Precache`, throw helpers).
- `workspace/src/dlls/<weapon>.cpp` — one file per weapon (a few share, e.g. `mp5.cpp` covers `weapon_mp5` and `weapon_9mmAR`).
- `workspace/src/dlls/ggrenade.cpp` — core grenade entity logic (`CGrenade`) plus specialized throwable entities such as `freezegrenade`.
- `workspace/src/dlls/wpn_shared/hl_wpn_glock.cpp` — the only HLSDK-shared weapon kept under `wpn_shared/`.
- `workspace/src/dlls/dual_*.cpp` — akimbo variants spawned by the Dualizer mutator (one per base weapon).
- `workspace/src/cl_dll/ev_hldm.cpp` — client prediction events (`EV_FireXxx`). A new server weapon that fires while held by the local player must register a matching event here or it will feel laggy.
- `workspace/src/cl_dll/hl/hl_events.cpp` — event-script hook table (`gEngfuncs.pfnHookEvent("events/<name>.sc", EV_FireXxx)`).
- `workspace/redist/events/*.sc` — event script stubs loaded by both server `PRECACHE_EVENT` and client `HookEvent`.
- `workspace/src/cl_dll/wpn_shared/` — client mirrors of select weapons (used by Half-Life predicted weapons).

## CBasePlayerWeapon Mechanics

All player weapons derive from `CBasePlayerWeapon` (in `weapons.h`). The base provides:

- **`ItemInfo`** — registered through `GetItemInfo(ItemInfo *p)`. Fields: `pszName`, `iMaxAmmo1/2`, `pszAmmo1/2`, `iMaxClip` (or `WEAPON_NOCLIP`), `iSlot`/`iPosition` (HUD), `iId` (must match a `WEAPON_*` enum in `weapons.h`), `iFlags` (`ITEM_FLAG_*`), `iWeight`, `pszDisplayName`.
- **Lifecycle hooks** — `Spawn`, `Precache`, `FallInit`, `Materialize`, `Respawn`, `AddToPlayer`, `Deploy`/`DeployLowKey`, `Holster`, `RetireWeapon`, `DestroyItem`.
- **Per-frame dispatch** — `ItemPostFrame()` (in `weapons.cpp`) reads `m_pPlayer->pev->button` and calls into the per-weapon virtuals.

### Virtual entry points (in firing-priority order inside `ItemPostFrame`)

| Virtual | Button | Notes |
|---------|--------|-------|
| `PrimaryAttack()` | `IN_ATTACK` | Gate `m_flNextPrimaryAttack`. Multiply final delay by `g_pGameRules->WeaponMultipler()`. |
| `SecondaryAttack()` | `IN_ATTACK2` | Gate `m_flNextSecondaryAttack`. |
| `Reload()` | `IN_RELOAD` | Only fires when `iMaxClip() != WEAPON_NOCLIP` **or** the weapon overrides `AcceptReload()` to `TRUE` (see below). |
| `WeaponIdle()` | none | Called when no fire buttons; gate `m_flTimeWeaponIdle`. |
| `SemiAuto()` | — | Return `TRUE` if the weapon should require button release between shots; default `FALSE`. |
| `UseDecrement()` | — | Return `TRUE` when client predicts the weapon. Standard pattern: `#if defined( CLIENT_WEAPONS ) return TRUE; #else return FALSE; #endif`. |
| `AcceptReload()` | — | New (see Proximity Mines / Freeze Grenades, below). Default `FALSE`. Return `TRUE` to force `IN_RELOAD` to invoke `Reload()` even on `WEAPON_NOCLIP` weapons. Used by `CKnife` (zoom), `CSatchel` (prox mine), `CTripmine` (prox mine), `CHandGrenade` (freeze throw). |

### Ammo accounting

- `iMaxClip = WEAPON_NOCLIP` (-1) means the weapon has no clip; ammo is consumed directly out of `m_pPlayer->m_rgAmmo[m_iPrimaryAmmoType]`.
- `iMaxClip > 0` enables `m_iClip` and the engine reload machinery (`m_fInReload`, `DefaultReload`).
- `pszAmmo1 = NULL` + `iMaxAmmo1 = -1` means the weapon never consumes ammo (knife, fists, wrench).
- `ITEM_FLAG_EXHAUSTIBLE` removes the weapon from inventory when ammo is exhausted (satchel, tripmine, snark, handgrenade).
- `ITEM_FLAG_LIMITINWORLD` caps how many copies can exist as world entities at once.

### Helpers used everywhere

- `DefaultDeploy(viewmdl, weaponmdl, anim, animExt, skiplocal=0, body=0)` — view/weapon model swap + anim, sets `m_pPlayer->m_szAnimExtention`. Pair with `DefaultHolster(anim, body)`.
- `DefaultReload(clipSize, anim, delay, body)` — sets `m_fInReload`, animates, and `ItemPostFrame()` finishes the swap after `m_flNextAttack`.
- `SendWeaponAnim(anim, skiplocal=1, body=0)` — client-predicted when `CLIENT_WEAPONS` is defined.
- `GetNextAttackDelay(delay)` — accurate timer that rolls over float precision near match boundaries.
- `EjectBrassLate()` / `EjectShotShellLate()` — schedule shell-eject TEs via `m_flEjectBrass` / `m_flEjectShotShell`.
- `ThrowGrenade()`, `ThrowSnowball()`, `ThrowRocket()` — used by the “off-hand grenade” (impulse 209) and several gamerules; see [player.md](player.md).

### Prediction (`CLIENT_WEAPONS`)

When `CLIENT_WEAPONS` is defined, predicted weapons save `m_flNextPrimaryAttack`, `m_flNextSecondaryAttack`, `m_flTimeWeaponIdle` as `FIELD_FLOAT` (raw, not time-relative) — see `CBasePlayerWeapon::m_SaveData` in `weapons.cpp`. Always rebuild **both DLLs** when toggling this define; mismatched builds fail silently.

### Railgun Event Pattern (authoritative damage, client-rendered trail)

`weapon_railgun` and `weapon_dual_railgun` are now wired like Gauss for responsiveness:

1. Server weapon code (`railgun.cpp`, `dual_railgun.cpp`) precaches an event (`events/railgun.sc`, `events/dual_railgun.sc`) and stores the index (`m_usRailgunFire`).
2. `PrimaryAttack`/`SecondaryAttack` call `StartFire` in both builds (no `#ifndef CLIENT_DLL` gate around the first shot), so local prediction can emit effects immediately.
3. `Fire()` always calls `PLAYBACK_EVENT_FULL(FEV_NOTHOST, ...)` and carries only compact metadata (damage/side). This keeps local effects instant while preventing duplicate owner playback from server.
4. Server stays authoritative for gameplay: hit traces, reflection math, damage, decals, and recoil velocity remain under `#ifndef CLIENT_DLL`.
5. Client visuals live in `ev_hldm.cpp` (`EV_FireRailgun`, `EV_FireDualRailgun`): the callback rebuilds the spiral beam trail, impact glow, and impact sprite trail from predicted traces.
6. Client event registration is mandatory in `hl_events.cpp`, and both `events/*.sc` files must exist in `workspace/redist/events/`.

Dual secondary note: the first barrel is predicted immediately; the delayed off-hand barrel still fires server-authoritatively for damage, and a client-side delayed playback event keeps the second visual responsive.

### FreezeGun Shock-Combo Pattern (authoritative combo, client-rendered laser)

`weapon_freezegun` now has a primary plasma orb and a secondary hitscan ice laser with UT99-style combo behavior.

1. Server weapon code (`freezegun.cpp`) precaches and uses two events: `events/freezegun.sc` (primary plasma shot) and `events/freezegun_laser.sc` (secondary laser beam).
2. Primary attack remains projectile-authoritative: it spawns `plasma` via `CPlasma::CreatePlasmaRocket` and broadcasts the primary event for local responsiveness.
3. Secondary attack is server-authoritative hitscan with 1 ammo per shot. It traces forward, then falls back to a proximity-to-beam plasma search (`FindPlasmaTargetAlongBeam`) so fast-moving plasma still registers reliably.
4. On plasma hit, `CPlasma::DetonateByLaser(pAttacker)` reassigns plasma ownership to the laser shooter before explosion, so kill/attacker credit goes to the combo shooter (including when detonating another player's plasma).
5. Immediate secondary after primary requires a base-dispatch exception in `weapons.cpp::ItemPostFrame()`. The default path syncs secondary cooldown to primary after `PrimaryAttack`; Freezegun resets `m_flNextSecondaryAttack` back to `0.0f` in that branch.
6. Secondary beam alignment intentionally uses level view angles (`v_angle`) and does not include `punchangle`, preventing rapid follow-up shots from drifting off the plasma path.
7. Client visuals are driven by `EV_FireFreezeGunLaser` (`cl_dll/ev_hldm.cpp`) and event hook registration in `cl_dll/hl/hl_events.cpp`; shipping requires `workspace/redist/events/freezegun_laser.sc`.

### CGrenade

`weapons.h` declares `CGrenade : public CBaseMonster` as the projectile base for thrown/timed explosives. Key entry points:

- `ShootTimed`, `ShootContact`, `ShootSatchelCharge`, `ShootTimedCluster` — factories.
- `Explode(Vector, Vector)` / `Explode(TraceResult*, int)` — TE_EXPLOSION + `RadiusDamage`.
- `BounceTouch`, `SlideTouch`, `ExplodeTouch`, `DangerSoundThink`, `Detonate`, `DetonateUse`, `TumbleThink`.
- `UseSatchelCharges(pevOwner, SATCHELCODE)` — detonate / release all `monster_satchel` belonging to a player.

## User-Message Registry (weapon-relevant)

User messages registered in `player.cpp::LinkUserMessages()` that weapons depend on: `CurWeapon`, `AmmoX`, `AmmoPickup`, `WeapPickup`, `WeaponList`, `HideWeapon`, plus per-feature ones (e.g. `Brass`, `EjectBr`, `Crosshair`). Remember the **≤10-char name limit** (≤8 safe). Long payloads must be chunked — see [server.md → User-Message Registry](server.md#user-message-registry).

## Weapon Inventory (every `LINK_ENTITY_TO_CLASS( weapon_*, … )`)

Numbers in parentheses are `iSlot.iPosition` from each `GetItemInfo`. “Dual_*” weapons are spawned by the Dualizer mutator; you normally don’t put them in maps.

### Slot 1 — Melee
- `weapon_crowbar` → `CCrowbar` (`crowbar.cpp`)
- `weapon_knife` → `CKnife` (`knife.cpp`) — `+reload` toggles 30° sniper-style zoom; `+attack2` charges a thrown knife; `iMaxClip = 1` is a deliberate hack to force server-side reload routing.
- `weapon_wrench` → `CWrench` (`wrench.cpp`), `weapon_dual_wrench` → `CDualWrench` (`dual_wrench.cpp`)
- `weapon_chainsaw` → `CChainsaw` (`chainsaw.cpp`)
- `weapon_rocketcrowbar` → `CRocketCrowbar` (`rocket_crowbar.cpp`)
- `weapon_fists` → `CFists` (`fists.cpp`)
- `weapon_fingergun` → `CFingerGun` (`fingergun.cpp`) — joke gun used by some mutators.

### Slot 2 — Pistols / sidearms
- `weapon_glock`, `weapon_9mmhandgun` → `CGlock` (`wpn_shared/hl_wpn_glock.cpp`), `weapon_dual_glock` → `CDualGlock`
- `weapon_python`, `weapon_357` → `CPython` (`python.cpp`)
- `weapon_deagle` → `CDeagle` (`deagle.cpp`), `weapon_dual_deagle` → `CDualDeagle`
- `weapon_mag60` → `CMag60` (`mag60.cpp`), `weapon_dual_mag60` → `CDualMag60`
- `weapon_freezegun` → `CFreezeGun` (`freezegun.cpp`) — primary fires a plasma orb; secondary fires a blue ice laser (1 ammo) that can detonate flying plasma for a shock-combo style mid-air freeze blast.
- `weapon_zapgun` → `CZapgun` (`zapgun.cpp`)

### Slot 3 — SMG / chain / shotguns
- `weapon_mp5`, `weapon_9mmAR` → `CMP5` (`mp5.cpp`) — primary `9mm`, secondary `ARgrenades` (M203).
- `weapon_smg` → `CSMG` (`smg.cpp`), `weapon_dual_smg` → `CDualSMG`
- `weapon_chaingun` → `CChaingun` (`chaingun.cpp`), `weapon_dual_chaingun` → `CDualChaingun`
- `weapon_shotgun` → `CShotgun` (`shotgun.cpp`)
- `weapon_sawedoff` → `CSawedOff` (`sawedoff.cpp`), `weapon_dual_sawedoff` → `CDualSawedOff`
- `weapon_12gauge` → `C12Gauge` (`gauge_shotgun.cpp`)
- `weapon_usas` → `CUsas` (`usas.cpp`), `weapon_dual_usas` → `CDualUsas` — full-auto shotgun.

### Slot 4 — Heavy / energy / explosive
- `weapon_crossbow` → `CCrossbow` (`crossbow.cpp`)
- `weapon_sniperrifle` → `CSniperRifle` (`sniper_rifle.cpp`)
- `weapon_railgun` → `CRailgun` (`railgun.cpp`), `weapon_dual_railgun` → `CDualRailgun` — beam/trail/glow are client event-driven (`EV_FireRailgun`, `EV_FireDualRailgun`) while hit/damage remains server-authoritative.
- `weapon_gauss` → `CGauss` (`gauss.cpp`) — charge-up secondary.
- `weapon_egon` → `CEgon` (`egon.cpp`)
- `weapon_hornetgun` → `CHgun` (`hornetgun.cpp`), `weapon_dual_hornetgun` → `CDualHgun`
- `weapon_flamethrower` → `CFlameThrower` (`flamethrower.cpp`), `weapon_dual_flamethrower` → `CDualFlameThrower`
- `weapon_rpg` → `CRpg` (`rpg.cpp`), `weapon_dual_rpg` → `CDualRpg`
- `weapon_glauncher` → `CGrenadeLauncher` (`glauncher.cpp`)
- `weapon_cannon` → `CCannon` (`cannon.cpp`)
- `weapon_nuke` → `CNuke` (`nuke.cpp`) — single-use map-wide kaboom.

### Slot 5 — Throwables / placeables
- `weapon_handgrenade` → `CHandGrenade` (`handgrenade.cpp`) — `+attack` throws a cluster grenade, `+attack2` throws a timed grenade, **`+reload` throws `freezegrenade`**. These timed throwables now detonate immediately when they touch a living player/monster; they still bounce/roll on non-living collision.
- `weapon_satchel` → `CSatchel` (`satchel.cpp`) — radio-detonated; **+reload deploys a proximity mine** (see below). Cold Ice variant: when a thrown satchel comes to rest it morphs into a `monster_human_assassin` decoy.
- `weapon_tripmine` → `CTripmine` (`tripmine.cpp`, slot 5/pos 3) — laser-beam mine; **+reload deploys a proximity mine** (see below).
- `weapon_snark` → `CSqueak` (`squeakgrenade.cpp`)
- `weapon_chumtoad` → `CChumtoad` (`chumtoad.cpp`) — variant snark.
- `weapon_snowball` → `CSnowball` (`snowball.cpp`)
- `weapon_vest` → `CVest` (`vest.cpp`) — wearable suicide explosive (the female-assassin “vest” charge).

### Special / utility
- `weapon_gravitygun` → `CGravityGun` (`gravitygun.cpp`)
- `weapon_ashpod`, `weapon_portalgun` → `CAshpod` (`ashpod.cpp`)
- `weapon_vice` → `CVice` (`vice.cpp`)

## Freeze Grenade (`freezegrenade`, thrown by `weapon_handgrenade` reload)

`freezegrenade` is a grenade-physics projectile entity defined in `ggrenade.cpp` (`CFreezeGrenade`) and launched from `CHandGrenade::Reload()`.

### Wiring

1. `CHandGrenade` overrides `AcceptReload()` to `TRUE`, so no-clip grenade weapons can consume `IN_RELOAD`.
2. `CHandGrenade::Reload()` arms throw state `m_fireState == 2` and reuses pin-pull timing.
3. `CHandGrenade::WeaponIdle()` resolves throw mode:
	- `m_fireState == 0` → `CGrenade::ShootTimedCluster`
	- `m_fireState == 1` → `CGrenade::ShootTimed`
	- `m_fireState == 2` → `CFreezeGrenade::ShootTimed`
4. Thrown timed/cluster/freeze projectiles are tagged with spawnflags so `CGrenade::BounceTouch` can branch payload behavior. On collision with an alive client/monster they detonate immediately; on world/static collisions they keep normal bounce/roll behavior until timer detonation.
5. `CFreezeGrenade::FreezeDetonate()` emits a white ring (`TE_BEAMCYLINDER`), white flash sprite (`TE_SPRITE`), and cool-tint dlight, then applies `RadiusDamage(..., DMG_BLAST | DMG_FREEZE | DMG_NEVERGIB)` with low base damage.

### Gameplay effect

- **Health damage:** intentionally low (chip damage only).
- **Contact behavior:** direct hits on living targets trigger immediate freeze explosion; non-living impacts keep grenade physics and timed fuse behavior.
- **Control effect:** players hit by the blast get freeze stacks via `DMG_FREEZE` and enter the shared `FL_FROZEN` path (`m_iFreezeCounter`), temporarily preventing attacks/mobility until thaw ticks expire.
- **Cleanup:** classname `freezegrenade` is removed by `CHalfLifeMultiplay::RemoveAndFillItems` on round reset.

## Proximity Mines (`+reload` on satchel & tripmine)

Both `weapon_satchel` and `weapon_tripmine` deploy a **proximity mine** when the player hits `IN_RELOAD`. The mine is the `monster_proxmine` entity (`CProxMine`, defined in `tripmine.cpp`).

### Wiring

1. `CBasePlayerWeapon::AcceptReload()` defaults to `FALSE`. `CSatchel` and `CTripmine` override it to return `TRUE`.
2. `ItemPostFrame()`'s reload branch was changed from `iMaxClip() != WEAPON_NOCLIP` to `(iMaxClip() != WEAPON_NOCLIP || AcceptReload())`, so the dispatcher will call `Reload()` on these no-clip weapons.
3. `CSatchel::Reload()` and `CTripmine::Reload()` trace 128 units forward from the gun position. On a valid static surface (`MOVETYPE_NONE` / `MOVETYPE_PUSH`, non-conveyor) they create `monster_proxmine` at the impact, decrement ammo, play the place animation, and gate `m_flNextAttack` for 1 s.
4. `CSatchel` refuses to place a mine while the radio detonator is out (`m_chargeReady != 0`).

### `CProxMine` lifecycle

- `Spawn` — mounts to the model already in place (`models/v_tripmine.mdl`, `body=3`, `TRIPMINE_WORLD` sequence), starts `mine_deploy.wav` + `mine_charge.wav`, schedules `PowerupThink` with a 2.5 s power-up timer.
- `PowerupThink` — traces back to find the host surface, then on arm time it goes `SOLID_BBOX`, plays `mine_activate.wav`, calls `MakeIndicator()` to attach a `sprites/glow01.spr` glow sprite (red, `kRenderGlow`, `kRenderFxNoDissipation`, scale 0.2), and hands off to `ProxThink`.
- `ProxThink` — every 50 ms blinks the indicator (220 → 32 alpha at 0.5 s rate) and every 150 ms scans `UTIL_FindEntityInSphere` for any living `IsPlayer()`/`FL_MONSTER` target inside `PROXMINE_DETECT_RADIUS` (200 u). The owner and same-team players (via `g_pGameRules->PlayerRelationship`) are skipped; a line-of-sight trace must clear before detonation.
- `Killed` / `DelayDeathThink` — short random delay, then `CGrenade::Explode` with `DMG_BLAST` and `gSkillData.plrDmgTripmine`.
- `TakeDamage` — quietly disarms (no explosion) if shot while still powering up.

### Tuning knobs

All in `tripmine.cpp`:

| Constant | Value | Meaning |
|----------|-------|--------|
| `PROXMINE_ARM_TIME` | `2.5f` s | Time from placement until the mine becomes solid + active. |
| `PROXMINE_SCAN_RATE` | `0.15f` s | Period between proximity scans. |
| `PROXMINE_DETECT_RADIUS` | `200.0f` u | Sphere radius for target search. |
| `PROXMINE_BLINK_RATE` | `0.5f` s | Indicator blink period. |

### Caveats

- The indicator sprite is attached via `SetAttachment(edict(), 0)`; the underlying `models/v_tripmine.mdl` has no real attachment 0, so the glow rides on the model origin. That’s fine for a small glow but if you want to perch it on a panel of the model add an attachment in the QC.
- The trip-mine model has the world `body=3` selected for the placed look; `CProxMine` keeps that body.
- `monster_proxmine` is precached by both `CSatchel::Precache` and `CTripmine::Precache` via `UTIL_PrecacheOther("monster_proxmine")`. If you script-spawn a proxmine from a context where neither weapon was precached (custom map logic, third-party deployer), call `UTIL_PrecacheOther("monster_proxmine")` first.
- There is no client prediction event for the proxmine deploy. The 1-second post-place gate hides the latency.

## Conventions / Lessons

- **Add a `weapon_*` class:** new `.cpp`, declare in `weapons.h`, append a `WEAPON_*` enum if needed, add to `W_Precache`, implement `GetItemInfo` with a fresh slot/position, and add a client mirror in `wpn_shared` only if it’s a Half-Life predicted weapon. Don't forget the `monster_*` projectile, if any.
- **For non-hitscan visual effects, prefer event callbacks over server temp-entity spam.** Keep gameplay traces/damage on server, then mirror visuals in `ev_hldm.cpp` through `PLAYBACK_EVENT_FULL` + `hl_events.cpp` hook (railguns are the reference implementation).
- **If a weapon needs asymmetric fire cadence (e.g., instant secondary after slower primary), audit `ItemPostFrame()` as well as weapon-local timers.** The base dispatcher may overwrite one attack timer with the other after `PrimaryAttack()`/`SecondaryAttack()`.
- **Reload semantics on no-clip weapons:** override `AcceptReload()` to `TRUE` and implement `Reload()` — that’s the entire contract.
- **Don't mutate state inside `Holster()` without also clearing `m_pPlayer->m_iWeapons*` for `ITEM_FLAG_EXHAUSTIBLE` weapons.** See `CSatchel::Holster` and `CTripmine::Holster` for the canonical pattern.
- **Floating weapons:** `floatingweapons` cvar selects an alternate world-sequence (see `CSatchel::Spawn`, `CTripmine::Spawn`).
- **Test with bots.** The Grave bot has hand-tuned weapon-use logic — see [gravebot_combat.md](gravebot_combat.md) and `/memories/repo/gravebot_combat_mechanics.md`. New weapons that don't appear in its preference tables fall through to the default melee logic.

## Checklist: adding a new `monster_*` projectile/placeable

When you add a server-side entity that players can place or that lingers in the world (mines, satchels, sentries, etc.), touch **every** site below or you'll get latent bugs (no precache crash, bots ignoring it, ghosts surviving round restart, gungame leaving live mines after rotation):

1. **`LINK_ENTITY_TO_CLASS`** in the entity's `.cpp` (server) — _and_ **`LINK_ENTITY_TO_FUNC`** in [grave-bot-src/dlls/linkfunc.cpp](../grave-bot-src/dlls/linkfunc.cpp). The bot DLL has its own LINK table; missing entries cause `CreateNamedEntity` to fail when the bot loads.
2. **Precache.** Add `UTIL_PrecacheOther("monster_xxx")` to the `Precache()` of every weapon/spawner that creates it. See `CTripmine::Precache`, `CSatchel::Precache`.
3. **`CHalfLifeMultiplay::RemoveAndFillItems`** (multiplay_gamerules.cpp ~line 1063) — append the classname to `pRemoveThese[]` so map restarts sweep player-placed instances. Add a tripmine-style special case if the entity has a beam/sprite/sound that needs explicit teardown.
4. **Bot threat scanning** — [grave-bot-src/dlls/bot_combat.cpp](../grave-bot-src/dlls/bot_combat.cpp) `BotAssessGrenades` keeps an allowlist of classnames bots are willing to shoot at. Both branches (`CRABBED_DLL` and default) need the new classname or bots will walk into mines.
5. **Gungame rotation** — [src/dlls/gungame_gamerules.cpp](../src/dlls/gungame_gamerules.cpp) `IPointsForKill` calls `DeactivateItems(pAttacker, "monster_xxx")` / `DeactivateSatchels(pAttacker)` when the player advances past the parent weapon. If your projectile descends from `weapon_satchel` or `weapon_tripmine`, hook the cleanup there too. See [gungame_gamerules.md](gungame_gamerules.md).
6. **Save/Restore** — `IMPLEMENT_SAVERESTORE` + `TYPEDESCRIPTION m_SaveData[]` for any persisted fields. Single-player isn't the only case; round restarts on dedicated servers also serialise.
7. **FGD** (if level designers can place it directly) — `cir/maps/cir.fgd` and any per-mod FGDs.
