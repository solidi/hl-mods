# Grappling Hook — Cold Ice Remastered Reference

A swing/zip-line projectile gated behind the `GRAPPLING_HOOK` preprocessor
define. Build wiring in this repository:
- Windows: `workspace/powershell/Compile-DLL.psm1` always passes
  `/p:GrapplingHook=GRAPPLING_HOOK` to MSBuild (used by `hldll.vcxproj` and
  `hl_cdll.vcxproj`).
- Linux: `workspace/src/linux/Makefile.hldll` and `Makefile.hl_cdll` set
  `-DGRAPPLING_HOOK`.

For the player-side ability surface, see
[player.md §4.7](player.md#47-grapple-hook-impulses-217218--disabled-build).
For bot integration, see §7 below.

---

## 1. Files & symbols

| File | Purpose |
|------|---------|
| [src/dlls/grapplinghook.h](../src/dlls/grapplinghook.h)   | `class CHook : public CBaseEntity` declaration. |
| [src/dlls/grapplinghook.cpp](../src/dlls/grapplinghook.cpp) | All server logic for `CHook` / `grapple_hook` entity. |
| [src/dlls/player.h](../src/dlls/player.h) (`pGrapplingHook`, `m_flNextHook`) | Per-player handle and re-fire gate. |
| [src/dlls/client.cpp](../src/dlls/client.cpp) (`+hook` / `-hook`) | Console binds that drive Fire/Kill from the client. |
| [src/dlls/player.cpp](../src/dlls/player.cpp) L4661-4663, L5492-5519 | Player-side cleanup on respawn and the impulse 217/218 dispatch (gated by `#if defined(GRAPPLING_HOOK)`). |
| [src/dlls/weapons.cpp](../src/dlls/weapons.cpp) L387 | `UTIL_PrecacheOther("grapple_hook")` — registers sounds/model at server activation. |
| [src/dlls/game.cpp](../src/dlls/game.cpp) L44, L47 | `mp_grapplinghookdeploytime`, `mp_grabsky` cvars. |
| [src/dlls/skill.h](../src/dlls/skill.h), `gamerules.cpp` L461 | `gSkillData.plrSpeedHook` / `sk_plr_hookspeed`, `plrDmgHook` / `sk_plr_dmg_hook`. |

The entity is registered with `LINK_ENTITY_TO_CLASS( grapple_hook, CHook )`.

---

## 2. CVars and skill data

| CVar / Skill                  | Default | Effect |
|-------------------------------|---------|--------|
| `mp_grapplinghook`            | (gate) | Mode-level enable: tested via `g_pGameRules->AllowGrapplingHook(plr)`. Per-mode overrides live in `singleplay_gamerules.cpp`, `multiplay_gamerules.cpp`, `ctc_gamerules.cpp`. |
| `mp_grapplinghookdeploytime`  | `1.0`   | Cooldown between consecutive `+hook` deployments — written to `m_flNextHook`. |
| `mp_grabsky`                  | `1`     | When `1`, sky-grappling is allowed (the texture trace is skipped). When `0`, `FireHook` traces forward and refuses if the surface texture is `"sky"`. |
| `sk_plr_hookspeed`            | skill   | `gSkillData.plrSpeedHook` — projectile launch speed. |
| `sk_plr_dmg_hook`             | skill   | `gSkillData.plrDmgHook` — damage on a takedamage entity hit. |

Per-mode `AllowGrapplingHook` (returns `BOOL`):
- Singleplayer: always allows.
- Multiplay base: gated by `mp_grapplinghook`.
- CTC: mode-specific override (see `ctc_gamerules.cpp`).
- Default base class: `= FALSE` (must be opted into).

---

## 3. Entity lifecycle

The hook follows the standard GoldSrc projectile lifecycle. Below is the full
state machine; every transition is wired up in `grapplinghook.cpp`.

```
                    +hook bind
                        |
                        v
client.cpp / impulse 217: CHook::HookCreate( player )
                        |   GetClassPtr → DispatchSpawn skipped at create time
                        |   sets pevOwner = player, classname = "hook"
                        v
   ┌────────────────────────────────────────────────────────────┐
   │ FireHook()                                                 │
   │   guard: m_fActiveHook, !pevOwner, !IsAlive(), iuser1      │
   │   sky check (mp_grabsky=0): traceline + TRACE_TEXTURE      │
   │   Spawn() → MOVETYPE_FLY, SOLID_BBOX, w_items.mdl body=7   │
   │   muzzle traceline 20→64u from view to seed origin         │
   │   pev->velocity = dir * sk_plr_hookspeed                   │
   │   SetTouch(HookTouch); nextthink = +0.2                    │
   └────────────────────────────────────────────────────────────┘
                        |
            ┌───────────┴───────────┐
            v                       v
     touches owner             touches anything else
     (re-arm 0.2s think)       SetTouch(NULL); SetThink(NULL)
                                       |
                  ┌────────────────────┼─────────────────────┐
                  v                                          v
       pOther->takedamage                              !takedamage (wall)
       TraceAttack(plrDmgHook, DMG_NEVERGIB)           SOLID_NOT, vel=0
       restore player movetype/gravity                 SetThink(Think)
       m_fActiveHook = FALSE                           m_fHookInWall = TRUE
       SP: Killed(); MP: pev->effects |= EF_NODRAW     player->movetype = FLY
       pev->nextthink = -1     <-- hibernating         (null-guarded)
                  |
                  v
                 -hook bind  → KillHook() → SUB_Remove() → UpdateOnRemove()
                  ^
                  |
   ┌──────────────┴──────────────────────────────────┐
   │ Think() — runs every 0.1s while in wall         │
   │   if !pevOwner || !IsAlive(): SetTouch(NULL),   │
   │     SetThink(SUB_Remove), bail.                 │
   │   draws TE_BEAMPOINTS rope each tick.           │
   │   pulls owner along (pev->origin - owner.origin)│
   │     * 3.0 + m_vVecDirHookMove until <50u.       │
   │   when within 50u: latch m_vPlayerHangOrigin,   │
   │     pin player at that origin, gravity = -.001. │
   └─────────────────────────────────────────────────┘
```

### State surface

`CHook` private members:

| Field | Type | Purpose |
|-------|------|---------|
| `pevOwner`              | `EHANDLE` | Owning `CBasePlayer`. EHANDLE so it self-nulls if the edict is freed. |
| `m_fActiveHook`         | `BOOL`    | "I currently own player.movetype." Cleared by KillHook / takedamage hit / UpdateOnRemove. |
| `m_fHookInWall`         | `BOOL`    | Hook latched into geometry — Think pulls player. |
| `m_fPlayerAtEnd`        | `BOOL`    | Player has reached the hang point — pin in place. |
| `m_vPlayerHangOrigin`   | `Vector`  | Origin to pin player at once `m_fPlayerAtEnd`. |
| `m_vVecDirHookMove`     | `Vector`  | Forward vector at fire time, baked into the pull velocity. |
| `ropesprite`            | `short`   | Sprite index for the beam (currently borrows `g_sModelIndexSmoke2`). |

`CBasePlayer` members (under `#if defined( GRAPPLING_HOOK )`):

| Field            | Type             | Purpose |
|------------------|------------------|---------|
| `pGrapplingHook` | `CHook *`        | Active hook for this player (NULL when none). |
| `m_flNextHook`   | `float`          | Re-deploy timestamp gate (`gpGlobals->time + grapplinghookdeploytime`). |

---

## 4. Hardening notes (post-scan patches)

A logic / NPE sweep was performed on this entity. Five defects were patched
in-place; record them here so future regressions are obvious.

1. **NULL `TRACE_TEXTURE` in `FireHook` sky guard.** `TRACE_TEXTURE` may
   return `NULL` when the trace doesn't hit a textured surface. The previous
   code passed it directly into `stricmp`. Now null-checked before compare.
2. **NPE in `HookTouch` wall branch.** `pevOwner->pev->movetype = MOVETYPE_FLY`
   was unconditional. If the owner disconnected mid-flight, the EHANDLE is
   NULL → crash. Now guarded; if owner is gone we `SetThink(SUB_Remove)` and
   bail. (The takedamage branch already guarded.)
3. **NPE in `Think`.** The death-check only triggered if `pevOwner` was
   non-NULL **and** dead — the NULL case fell through to
   `WRITE_COORD( pevOwner->pev->origin.x )`. Fixed to `!pevOwner ||
   !pevOwner->IsAlive()`. Death path also calls `SetTouch(NULL)` to avoid a
   stale callback firing in the 0.1s window before `SUB_Remove` runs.
4. **Dangling `CBasePlayer::pGrapplingHook` after self-removal.** When `Think`
   self-removed via `SUB_Remove`, the player still held the freed `CHook *`.
   Subsequent `KillHook` (e.g. from `CBasePlayer::Spawn`'s respawn cleanup or
   a `-hook` press) would dereference freed memory. Fixed by overriding
   `CHook::UpdateOnRemove()`, which clears `pPlayer->pGrapplingHook` and
   restores `MOVETYPE_WALK` / `gravity = 1` if the hook was still actively
   controlling the player. Because `UpdateOnRemove` is called on every removal
   path (including engine-side cleanup at level transition or `FCAP_PORTAL`
   churn), this also covers cases that don't go through `KillHook`.
5. **Hibernating-hook re-fire.** After hitting a takedamage entity, the
   projectile sets `EF_NODRAW` and `nextthink = -1`, but the player still
   holds a non-NULL `pGrapplingHook`. The client guard
   `if (plr->pGrapplingHook == NULL && plr->m_flNextHook < gpGlobals->time)`
   then prevents re-fire until the player explicitly releases `-hook`. This
   is the existing behavior — *not* changed — but called out so future edits
   don't "fix" it accidentally.

### Lifecycle invariants to preserve

- `m_fActiveHook == TRUE` ⇔ "I currently own the player's movetype." Always
  pair a `pevOwner->pev->movetype = MOVETYPE_FLY` with a corresponding
  restore (KillHook / takedamage branch / UpdateOnRemove).
- Never deref `pevOwner` without an EHANDLE truthiness check. The handle can
  null between any two ticks.
- Do not rebuild `pGrapplingHook` ownership outside of the `+hook` bind path
  in `client.cpp` and the impulse 217 case in `player.cpp`.
  `UpdateOnRemove` only clears the pointer when it still equals `this`, so
  ownership can't be silently reassigned.

---

## 5. Pitfalls

- **`pev->gravity = -1` in `Spawn`** — leftover for a previous movetype, but
  `MOVETYPE_FLY` ignores gravity, so it's a no-op visible only after
  `m_fPlayerAtEnd` re-purposes the player's `pev->gravity`.
- **`ropesprite = g_sModelIndexSmoke2`** — the rope is drawn with the smoke
  sprite index because no dedicated rope sprite is precached. Replacing it
  needs both a `PRECACHE_MODEL` call in `Precache()` and a stable global
  index reset in `ServerActivate`.
- **`UTIL_PrecacheOther("grapple_hook")` is required.** Removing it means
  `EMIT_SOUND` / `SET_MODEL` calls in `Spawn`/`FireHook` would precache mid-
  game and host_error if the asset wasn't already in the precache table.
- **No client-side prediction.** This is purely server-driven. The pull will
  feel laggy on high ping until prediction events are added (the existing
  `weapons/xbow_*` SFX assets are reused so client can hear them, but motion
  is server authoritative).
- **`Killed( pev, GIB_NEVER )` in SP only.** In MP the projectile is hidden
  with `EF_NODRAW` and idled (`nextthink = -1`); it must be torn down by
  `KillHook`/`UpdateOnRemove`, not by an inflicted death.
- **`mp_grabsky` polarity is inverted from the cvar name.** `1` = sky-grapple
  permitted (texture trace skipped), `0` = sky-grapple refused. The default
  is `1`, matching the original Cold Ice behaviour.

---

## 6. Build wiring (already live)

The grapple now ships enabled by default:

1. **Windows** — `workspace/powershell/Compile-DLL.psm1` line ~22 declares
   `[string]$grapplinghook = "GRAPPLING_HOOK"` and passes
   `/p:GrapplingHook=$grapplinghook` to MSBuild for both `hldll.vcxproj`
   (server, `ice.dll`) and `hl_cdll.vcxproj` (client, `client.dll`).
2. **Linux** — `workspace/src/linux/Makefile.hldll` and
   `Makefile.hl_cdll` set `-DGRAPPLING_HOOK` in `CFLAGS`.
3. **Server console** — `mp_grapplinghook 1` (default) plus the active
   gamerules' `AllowGrapplingHook` override must both be TRUE.
4. **Player input** — bind a key to `+hook` (handled by `client.cpp`) or
   issue impulse 217 / 218 (handled by `CBasePlayer::CheatImpulseCommands`
   in [player.cpp](../src/dlls/player.cpp#L5492-L5519)).

`pGrapplingHook` and `m_flNextHook` are gated on the same define in
`player.h`, so a mismatched build will silently produce bad layouts. See
[cir.md → Cross-cutting Lessons](cir.md#cross-cutting-lessons).

---

## 7. Bot usage (grave_bot)

Bots fire the hook through the same impulse 217 / 218 path human players use.
See also [gravebot_combat.md §6](gravebot_combat.md) and
`/memories/repo/gravebot_hook_usage.md`.

### 7.1 Intent enum

Defined in [grave-bot-src/dlls/bot.h](../grave-bot-src/dlls/bot.h):

| Constant | When fired |
|----------|-----------|
| `HOOK_INTENT_NONE`    | Idle / not currently hooked. |
| `HOOK_INTENT_ITEM`    | No enemy; chosen pickup is well above the bot with a hookable ceiling. |
| `HOOK_INTENT_DAMAGE`  | Enemy visible recently, but combat options exhausted — close the gap. |
| `HOOK_INTENT_ESCAPE`  | Active enemy + HP at or below `BOT_HOOK_ESCAPE_HP` (25). |
| `HOOK_INTENT_PURSUIT` | Enemy ≥ 600u away, moving away ≥ 200u/s, HP ≥ 35. |

Intent priority (highest first): **ESCAPE > PURSUIT > DAMAGE > ITEM**.
Only one intent is ever active per hook.

### 7.2 State on `bot_t`

| Field | Purpose |
|-------|---------|
| `b_hook_active`               | TRUE between impulse 217 fire and impulse 218 release. While TRUE the bot skips the kick/punch/grab impulse block in `BotFireWeapon`. |
| `i_hook_intent`               | `HOOK_INTENT_*` value. |
| `pHookItem`                   | ITEM intent: the world item we're swinging toward. Cleared on pickup. |
| `v_hook_target_point`         | Anchor world point we aimed at. |
| `f_hook_release_at`           | Hard timeout — forced impulse 218 if not released sooner (`BOT_HOOK_MAX_DURATION = 2.0s`). |
| `f_hook_release_retry_until`  | Short post-release retry window that re-sends impulse 218 (`BOT_HOOK_RELEASE_RETRY = 0.35s`) to survive one-frame command loss. |
| `f_hook_cooldown_until`       | Next time the bot may refire. Base `BOT_HOOK_COOLDOWN = 3.0s` × per-skill mult `{1.0, 1.2, 1.5, 2.0, 3.0}` (index = `bot_skill`, 0=hardest). |
| `f_hook_velocity_check_time`  | Next time to sample horizontal speed for anti-stuck. |
| `i_hook_low_velocity_samples` | Consecutive low-velocity (<32 u/s) samples; release at 2. |

All eight fields are zero-initialized in `BotSpawnInit`.

### 7.3 Helper functions

All defined in
[grave-bot-src/dlls/bot_combat.cpp](../grave-bot-src/dlls/bot_combat.cpp)
(below the rune helpers):

| Function | Role |
|----------|------|
| `BotFireHook(pBot, intent, pItem, vAimPoint)` | Sets impulse 217, populates the eight fields, applies water/observer guards, clears stale release-retry state. |
| `BotReleaseHook(pBot)`                        | Sets impulse 218 unconditionally, opens release-retry window, clears active hook state. |
| `BotMaybeReleaseHook(pBot)`                   | Per-tick safety: timeout, target-invalid, pursuit-close-enough, anti-stuck, water/observer, CtC holder-transition release, and zombie-hook desync recovery. |
| `BotComputeHookAimForItem`                    | Returns anchor + LOS check for an item-detour hook. |
| `BotConsiderHookForItem(pBot, pItem)`         | Item-detour gate + aim + fire. |
| `BotComputeEscapeAnchor`                      | Best-of-three traces (back-up / straight-up / lateral-up); scored. |
| `BotConsiderHookForEscape(pBot)`              | Escape gate + aim + fire. |
| `BotComputePursuitAnchor`                     | Anchor past the enemy along bot→enemy line. |
| `BotConsiderHookForPursuit(pBot)`             | Pursuit gate + aim + fire. |
| `BotConsiderHookForDamage(pBot)`              | Damage-fallback gate + aim + fire. |

### 7.4 Call sites

| Site | Wire-in |
|------|---------|
| [bot.cpp](../grave-bot-src/dlls/bot.cpp) `BotThink` (after `BotMaybeDropRuneForSwap`) | Per-tick `BotMaybeReleaseHook`. |
| [bot.cpp](../grave-bot-src/dlls/bot.cpp) engagement branch (after `BotFindEnemy`, before `BotShootAtEnemy`) | `BotConsiderHookForEscape`. |
| [bot.cpp](../grave-bot-src/dlls/bot.cpp) `BotFindItem` (end of function, after `pBotPickupItem` assignment) | `BotConsiderHookForItem`. |
| [bot_combat.cpp](../grave-bot-src/dlls/bot_combat.cpp) `BotFireWeapon` melee block | `BotConsiderHookForPursuit` → `BotConsiderHookForDamage` → existing impulses. Whole melee block is suppressed while `b_hook_active`. |
| [bot_client.cpp](../grave-bot-src/dlls/bot_client.cpp) `BotClient_Valve_ItemPickup` | Calls `BotReleaseHook` when the bot picks anything up mid-ITEM-hook. |

### 7.5 Tuning constants (hardcoded in bot_combat.cpp)

| Constant | Value | Effect |
|----------|-------|--------|
| `BOT_HOOK_COOLDOWN`         | `3.0f`  | Base cooldown between refires. |
| `BOT_HOOK_MAX_DURATION`     | `2.0f`  | Hard timeout (forced release). |
| `BOT_HOOK_RELEASE_RETRY`    | `0.35f` | Brief release resend window after 218 to ensure hook teardown is observed. |
| `BOT_HOOK_ITEM_Z_THRESHOLD` | `96.0f` | Min item-above-bot height to detour-hook. |
| `BOT_HOOK_ITEM_MAX_RANGE`   | `1024.0f` | Max hook range for any intent. |
| `BOT_HOOK_ESCAPE_HP`        | `25`    | HP ≤ this triggers escape consideration. |
| `BOT_HOOK_PURSUIT_MIN_DIST` | `600.0f` | Min enemy distance for pursuit. |
| `BOT_HOOK_PURSUIT_MIN_VEL`  | `200.0f` | Min enemy speed for pursuit. |
| `BOT_HOOK_PURSUIT_AWAY_DOT` | `0.3f`  | dot(enemy_vel_dir, away_from_bot) gate. |
| `BOT_HOOK_PURSUIT_MIN_HP`   | `35`    | HP < this disables pursuit. |
| `hook_cooldown_mult[5]`     | `{1.0, 1.2, 1.5, 2.0, 3.0}` | Per-`bot_skill` cooldown multiplier (0=hardest). |

### 7.6 CVar

| CVar | Default | Effect |
|------|---------|--------|
| `sv_bots_hook` | `1` | Master switch for bot hook usage. `0` disables all four intents. Registered in [dll.cpp](../grave-bot-src/dlls/dll.cpp) alongside `sv_botsmelee`. |

The bot still respects `mp_grapplinghook` — `BotHookEnabled` returns false
if either cvar is zero.

### 7.7 CtC-specific hook hardening (session update)

- **Holder transition guard**: in CtC, if a bot becomes a chumtoad holder while a hook is active, `BotMaybeReleaseHook` force-releases immediately.
- **Release reliability**: hook release now re-sends impulse 218 for a short burst (`f_hook_release_retry_until`) to avoid one-frame command loss leaving a latched hook.
- **Desync failsafe**: if local bot state says hook is inactive but player movement still looks hook-latched (`MOVETYPE_FLY` + negative gravity), the bot reissues 218 and refreshes the retry window.
- **Net effect**: prevents "forgotten deployed hook" stalls, including the CtC pickup-in-flight case.
