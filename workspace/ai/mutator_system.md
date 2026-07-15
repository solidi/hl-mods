# Mutator System

Cold Ice Remastered's *mutators* are gameplay modifiers that layer on top of the
active game mode. They can be enabled manually (`sv_addmutator`), rotated on a
timer (Chaos Mode), sprayed randomly as one-shot effects (Instant Mutators), or
selected democratically at intermission (Mutator Vote). Effects range from
purely visual (client-only HUD/render tweaks) to gameplay-critical (per-player
weapons, movement physics, respawn behaviour), so the system straddles the
server DLL (`ice.dll`) and the client DLL (`client.dll`).

This document is the single source of truth for the mutator subsystem. It
supersedes `mutator_pause_system.md` (round-based pause/restore is folded in
below).

---

## 1. Where the code lives

### Shared / IDs
- [workspace/src/common/const.h](workspace/src/common/const.h#L805-L892) —
  `MUTATOR_CHAOS`..`MUTATOR_VOLATILE` IDs (1..86) and `MAX_MUTATORS_CL` (client
  cap = `MUTATOR_VOLATILE + 1`).
- [workspace/src/pm_shared/pm_shared.c](workspace/src/pm_shared/pm_shared.c#L308) —
  reads three physinfo keys the server writes for movement/audio: `topsy`,
  `haste`, `prop`.

### Server (dlls/)
- [workspace/src/dlls/gamerules.h](workspace/src/dlls/gamerules.h#L65-L272) —
  `struct mutators_t` (linked list node), `CGameRules` interface, protected /
  private state (`m_Mutators`, `m_SavedMutators`, timers, pool, flags),
  `MAX_MUTATORS = MUTATOR_VOLATILE`, `extern const char *g_szMutators[]`.
- [workspace/src/dlls/gamerules.cpp](workspace/src/dlls/gamerules.cpp#L66-L153) —
  `g_szMutators[]` name table (index = `MUTATOR_* - 1`).
- [workspace/src/dlls/gamerules.cpp](workspace/src/dlls/gamerules.cpp#L164-L172) —
  destructor + `FreeMutatorChain` (fixes former map-to-map leak).
- [workspace/src/dlls/gamerules.cpp](workspace/src/dlls/gamerules.cpp#L597-L2372) —
  All the `CGameRules::*Mutators*` methods described in §3.
- [workspace/src/dlls/game.cpp](workspace/src/dlls/game.cpp#L89-L100) — cvar
  definitions (`sv_chaosfilter`, `sv_addmutator`, `sv_instantmutators`,
  `sv_mutatorlist`, `sv_mutatorcount`, `sv_mutatortime`) and registration.
- [workspace/src/dlls/multiplay_gamerules.cpp](workspace/src/dlls/multiplay_gamerules.cpp#L307-L1483) —
  `RandomizeMutator`, `VoteForMutator`, `CheckMutatorRTV`, mutator-vote arm of
  intermission voting state machine, `GoToIntermission()` pause call,
  `CHalfLifeMultiplay::MutatorAllowed` (base filter).
- Per-mode `MutatorAllowed` overrides: `arena_gamerules.cpp`,
  `busters_gamerules.cpp`, `chilldemic_gamerules.cpp`, `ctc_gamerules.cpp`,
  `ctf_gamerules.cpp`, `gungame_gamerules.cpp`, `instagib_gamerules.cpp`,
  `kts_gamerules.cpp`, `loot_gamerules.cpp`, `prophunt_gamerules.cpp`,
  `shidden_gamerules.cpp`. Round-based modes also invoke `PauseMutators()` /
  `RestoreMutators()` at lifecycle transitions (see §7).

### Client (cl_dll/)
- [workspace/src/cl_dll/hud.h](workspace/src/cl_dll/hud.h#L534-L898) — client
  `mutators_t`, `MutatorEnabled(int)`, `GetMutator(int)`, `CHudStatusIcons`
  timer/icon fields, `m_Mutators` list on `CHud`.
- [workspace/src/cl_dll/hud.cpp](workspace/src/cl_dll/hud.cpp#L571-L1234) —
  message shim registration (`HOOK_MESSAGE( AddMut )`,
  `HOOK_MESSAGE( Chaos )`), `MutatorEnabled` / `GetMutator` implementations.
- [workspace/src/cl_dll/hud_msg.cpp](workspace/src/cl_dll/hud_msg.cpp#L92-L484) —
  `MsgFunc_InitHUD` (frees the list on server reconnect), `MsgFunc_AddMut`
  (adds/updates/clears mutators, wires client-side kickoffs), `MsgFunc_Chaos`
  (starts/stops the chaos-timer HUD bar).
- [workspace/src/cl_dll/status_icons.cpp](workspace/src/cl_dll/status_icons.cpp#L52-L302) —
  chaos-bar rendering, mutator icon list, per-frame expiration cleanup,
  `DrawMutators` / `ToggleMutatorIcon`.
- [workspace/src/cl_dll/vgui_TeamFortressViewport.h](workspace/src/cl_dll/vgui_TeamFortressViewport.h#L77-L88) /
  [.cpp](workspace/src/cl_dll/vgui_TeamFortressViewport.cpp#L233-L322) — display
  strings via `MutatorInfo sMutators[]` (name + description, keyed to
  `MUTATOR_* - 1`).
- [workspace/src/cl_dll/vgui_VoteMutatorWindow.cpp](workspace/src/cl_dll/vgui_VoteMutatorWindow.cpp) —
  intermission vote panel and synthetic `INSTANT MUTATORS` button
  (`MUTATOR_VOTE_INSTANT = MAX_MUTATORS_CL + 1`).
- [workspace/src/cl_dll/mutator_tinnitus.cpp](workspace/src/cl_dll/mutator_tinnitus.cpp) —
  `Tinnitus_Hook` intercepts `pEventAPI->EV_PlaySound` when the tinnitus buzz
  is active and ducks all other sounds to 5%. Enabled/disabled via server
  `CLIENT_COMMAND("tinnitus_start"|"tinnitus_stop")`.
- Client render/input consumers (mutator effects, non-exhaustive):
  `StudioModelRenderer.cpp` (BIGHEAD/MINIME/PAPER/SANIC/CRATE bones and
  proxies), `view.cpp` (MCCLANE/UPSIDEDOWN/AMIDEAD/TOPSYTURVY roll),
  `input.cpp` + `inputw32.cpp` (MIRROR/UPSIDEDOWN input inversion),
  `colorcor.cpp` (OLDTIME/ASTRONAUT/INVERSE/SILDENAFIL post-process),
  `hud_redraw.cpp`, `radar.cpp`, `lifebar.cpp`, `ammo.cpp`, `entity.cpp`,
  `hl_weapons.cpp`, `com_weapons.cpp`.

---

## 2. Data model

### Server list (`CGameRules::m_Mutators`)
```c
struct mutators_t {
    int         mutatorId;   // MUTATOR_* (1-based)
    float       timeToLive;  // absolute gpGlobals->time when it expires, or -1 = permanent
    mutators_t *next;
};
```
Singly-linked list, head owned by `CGameRules`. Nodes are heap-allocated with
`new` and freed with `delete`; the destructor and `PauseMutators`/`clear` paths
call `FreeMutatorChain` to prevent leaks (see memory pitfalls in §10).

### Client list (`CHud::m_Mutators`)
Same shape, but `timeToLive` is client-time based (measured against
`gHUD.m_flTime`) and there is an added `startTime` used by the per-icon HUD
timer bar. `mutatorId == -1` sentinel is used only during message parsing to
break the read loop; `254` is a "clear all" signal (see §4).

### ID space and lookup tables
- Server: `g_szMutators[MAX_MUTATORS]` where `MAX_MUTATORS = MUTATOR_VOLATILE`
  (86 entries). Indexing is always `g_szMutators[id - 1]`.
- Client display: `sMutators[MAX_MUTATORS_CL]` (name + description, 87 entries
  including a trailing `RANDOM`). Also `g_szMutators` is *not* defined
  client-side — the client uses `sMutators[i].name` for labelling only, and
  numeric IDs (`MUTATOR_*`) for behavioural checks.
- Special sentinels on the `gmsgAddMutator` wire: `254` = clear all,
  `255` = end-of-batch, `-1` (as read byte) = short-read guard.
- Vote-only synthetic slots (only ever appear in vote payloads, never in the
  active list):
  - `MAX_MUTATORS` (vote id `MAX_MUTATORS + 1`) — RANDOM.
  - `MAX_MUTATORS + 1` (vote id `MAX_MUTATORS + 2`) — INSTANT MUTATORS toggle.

### Cvars (all `sv_*`, registered in `game.cpp`)
| Cvar | Default | Purpose |
|---|---|---|
| `sv_addmutator` | `""` | Set by admins / vote / round-transition to enqueue a mutator addition. Consumed by `MutatorsThink`. Supports names, numeric IDs, `chaos`, `unchaos`, `clear`, `three`, and an optional trailing duration (`"name 0"` = permanent). |
| `sv_instantmutators` | `"1"` | Enables one-shot Instant Mutators on the chaos cadence. |
| `sv_mutatorlist` | `""` | Semi-colon delimited "next up" list. Consumed by `MutatorsThink`: pops the first entry into `sv_addmutator` each tick until empty. Set by the vote tally and by admin. |
| `sv_mutatorcount` | `"3"` | Number of *simultaneously active* mutators Chaos Mode targets. Clamped `[0, 7]`. |
| `sv_mutatortime` | `"30"` | Base TTL in seconds for chaos-picked mutators and default `sv_addmutator` duration. Clamped `[10, 120]`. |
| `sv_chaosfilter` | `"itemsexplode;"` | Substring blacklist applied when Chaos Mode picks a random mutator (in addition to `MutatorAllowed`). |

### Per-`CGameRules` state (private, see `gamerules.h` bottom)
- `m_Mutators` — active linked list.
- `m_flChaosMutatorTime` — next chaos tick; `0` = chaos off.
- `m_flInstantMutatorTime` — next instant tick; `-1` = disabled.
- `m_flAddMutatorTime` — 1 Hz throttle for the `MutatorsThink` outer loop.
- `m_flDetectedMutatorChange` — deferred "apply effects" timestamp (see §3.5).
- `m_iMutatorPool[128]` + `m_iMutatorPoolSize` — LRU-style shuffle bag used by
  `AddRandomMutator` so chaos does not repeat until every allowed mutator has
  been chosen once.
- `m_JopeCheck` — `TRUE` while the `MUTATOR_JOPE` name-swap is applied.
- `m_iNotTheBees`, `m_iDontShoot`, `m_iVolatile` — mirrored flags used by
  hot-path checks in `WeaponMutators` / weapon code where a full list scan is
  wasteful.
- `szSkyColorRed/Green/Blue` — original sky colour saved at map start so
  `MUTATOR_LIGHTSOUT` can restore it.
- `m_bMutatorsPaused`, `m_SavedMutators`, `m_flSavedChaosMutatorTime`,
  `m_flPausedTimeDelta` — round-pause bookkeeping (§7).

---

## 3. Server pipeline

### 3.1 `MutatorsThink()` — the heartbeat
Called once per server frame from `CHalfLifeMultiplay::Think()`. Structure
(top-down):

1. **Pause guard.** Early-return if `m_bMutatorsPaused` (round-intermission).
2. **1 Hz outer gate** (`m_flAddMutatorTime`). Everything inside runs at ~1 Hz.
3. **Drain `sv_mutatorlist`.** Split on `;`, pop first token into
   `sv_addmutator`, write the remainder back into `sv_mutatorlist`.
4. **Process `sv_addmutator`.** After confirming
   `MutatorAllowed(sv_addmutator)`:
   - `chaos` or literal `"1"` → sets `m_flChaosMutatorTime` and sends
     `gmsgChaos` with the current increment.
   - `unchaos` → zeroes `m_flChaosMutatorTime`.
   - `clear` → sends `gmsgAddMutator(254, 0)` to clear the client HUD, zeroes
     chaos, expires every active mutator by setting `timeToLive = gpGlobals->time`.
   - `three` → three back-to-back `AddRandomMutator("sv_mutatorlist", …, TRUE)`.
   - Otherwise scans `g_szMutators[]` for a name-substring or numeric match:
     - Rejects duplicates (list scan).
     - Parses optional " N" suffix as duration; `N == 0` → permanent
       (`timeToLive = -1`); `N > 0` → custom seconds; missing → `sv_mutatortime`.
     - Sends `gmsgAddMutator(id + 1, sendDuration)` (permanent → send `0`).
     - Prepends a new `mutators_t` node to `m_Mutators`.
     - Bumps `m_flDetectedMutatorChange = gpGlobals->time + 1.0`.
   - Regardless of outcome, clears `sv_addmutator` at end.
5. **Expire old mutators.** Walks `m_Mutators`; nodes whose `timeToLive` has
   passed (and isn't `-1`) are unlinked, logged, and **`delete`d**. `count`
   tracks live nodes. `szMutators` is rebuilt as a `"id;id;id;"` string.
6. **Mirror to `gpGlobals->startspot`** (used by legacy checks). Only
   `ALLOC_STRING`s when the mirror value actually changed (fixes engine
   string-pool bloat).
7. **Chaos cadence.** If `m_flChaosMutatorTime > 0` and expired *and*
   `count < mutatorcount.value` (clamped), advances the timer and calls
   `AddRandomMutator("sv_addmutator", TRUE)` — the trailing `TRUE` also emits
   a `gmsgChaos` bar refresh.
8. **Instants cadence.** If `sv_instantmutators != 0`, tick
   `m_flInstantMutatorTime` and call `AddInstantMutator()` at each expiry.
9. **Apply detected change.** If `m_flDetectedMutatorChange > 0` and expired
   (see §3.5), reruns `EnvMutators()` and per-player fix-ups.

### 3.2 `AddRandomMutator(const char *cvarName, BOOL withBar, BOOL three)`
Refills `m_iMutatorPool` if empty by scanning `g_szMutators[]` and keeping
entries that pass both `MutatorAllowed` **and** the `sv_chaosfilter` substring
blacklist. Picks a random index, rejects it if the target cvar already contains
that name, otherwise appends `"name 0;"` (`three`/`withBar` path) or
`"name 0;<existing>"` (normal path) into the cvar via `CVAR_SET_STRING`. On
success the entry is removed from the pool by swap-with-last so the bag
empties before it can repeat.

When `withBar` is true it also fires `gmsgChaos(mutatorTime)` so the client bar
resets. That is the *only* place the chaos-bar increment is broadcast during
the periodic cadence.

### 3.3 `AddInstantMutator()`
Rolls `RANDOM_LONG(0, 13)` and applies a one-shot effect to every live,
non-observer, non-disconnected player:
- 0: no-op announcement.
- 1: `+1` HP (clamped to max_health).
- 2: swap HP ↔ armour (skips god-mode players).
- 3: `+100` HP.
- 4: `+100` armour.
- 5: HP → 1 (skips god-mode).
- 6: HP=armour=69 ("Nice!").
- 7: HP=armour=67 ("Six, seeeeven!").
- 8: spawns a live timed `CGrenade` in front of each player.
- 9: `TakeDamage(RANDOM_FLOAT(10,20), DMG_SLASH)` (skips god-mode).
- 10: places a `monster_tripmine` if a valid surface is in front of the player.
- 11: spawns a friendly `monster_snark` in front of each player.
- 12: spawns a `monster_chumtoad` — but only if the current mode allows
  `MUTATOR_CHUMXPLODE` (this gate is checked once at the top of case 12; if it
  fails, the entire case is skipped).
- 13: spawns a `monster_human_assassin` in front of the player.

Every path finishes by broadcasting `CLIENT_SOUND_CHICKEN` and a
`gmsgChaos(mutatorTime)` refresh (so the chaos-bar animates even in "instant
only" configurations).

### 3.4 `MutatorAllowed(const char *mutator)` filter chain
- `CGameRules::MutatorAllowed` is pure-virtual (`= FALSE`) so every rules
  class must implement it.
- `CHalfLifeMultiplay::MutatorAllowed` is the base implementation:
  - Blanket-rejects `slowmo`, `speedup`, `topsyturvy`, `explosiveai` (broken
    or hidden behind other systems).
  - In Snowball mode (`GAME_SNOWBALL`) rejects mutators that grant weapons or
    override the snowball loadout: `MAXPACK`, `BERSERKER`, `PLUMBER`,
    `COWBOY`, `BUSTERS`, `FIRESTARTER`, `PORTAL`, `RANDOMWEAPON`,
    `ROCKETCROWBAR`, `VESTED`, `FIREBULLETS`.
  - Everything else passes.
- Per-mode overrides all chain `return CHalfLifeMultiplay::MutatorAllowed(mutator);`
  after their local blacklists:
  - **Arena / Busters / Chilldemic / CtC / CtF / KtS / Prop Hunt / Shidden** —
    disable `THIRDPERSON` (breaks respective HUDs / silhouette rules); Busters
    also disables `RANDOMWEAPON`, `INVISIBLE`, `BUSTERS`; Shidden disables
    `INVISIBLE` and `DEALTER`; CtC disables `999`, `CHUMXPLODE`, `NOCLIP`,
    `DONTSHOOT`; PropHunt disables all "hat"-style cosmetic mutators
    (`SANTAHAT`, `PIRATEHAT`, `COWBOY`, `MARSHMELLO`, `JACK`, `PUMPKIN`,
    `TOILET`) because they would leak prop identity.
  - **Gun Game** — huge blacklist of weapon-granting mutators
    (`BARRELS`, `BERSERKER`, `DEALTER`, `DONTSHOOT`, `INSTAGIB`, `PLUMBER`,
    `COWBOY`, `BUSTERS`, `FIRESTARTER`, `PORTAL`, `RAILGUNS`, `RICOCHET`,
    `ROCKETBEES`, `ROCKETCROWBAR`, `VESTED`, `RANDOMWEAPON`) so weapon
    progression stays canonical.
  - **Instagib** — rejects nine weapon/pickup mutators plus `999`,
    `SLOWBULLETS`, and `NORELOAD` because they would defeat the one-shot rule.
  - **Loot** — rejects `999`, `CHUMXPLODE`, `NOCLIP`, `RANDOMWEAPON`,
    `DONTSHOOT`, `MAXPACK`, `THIRDPERSON` (weapon-count rules).
- The Chaos randomizer additionally applies `sv_chaosfilter` **on top of**
  `MutatorAllowed`, so servers can ban mutators without touching source.

### 3.5 `m_flDetectedMutatorChange` — deferred apply
Adding a mutator sets this timestamp to `gpGlobals->time + 1.0`. Removing an
expiring mutator does the same. Once the timestamp expires, `MutatorsThink`:
1. `RefreshSkillData()`.
2. `EnvMutators()` — see §3.6.
3. JOPE reconciliation — swaps or restores every player's `netname` via the
   `j` info key (backup slot for the original name).
4. Per-player fix-ups (looped over `maxClients`):
   - Force `m_iShowMutatorMessage = time + 2.0` so the HUD banner can fire.
   - Reapply physinfo keys (`topsy`, `haste`, `friction`) based on
     `TOPSYTURVY` / `MEGASPEED` / `ICE`.
   - `AUTOAIM` off → `ResetAutoaim`.
   - `SANTAHAT` on → schedule next santa sound; off → clear.
   - Call `GiveMutators(pl)` to hand out mutator-granted weapons.
   - `INVISIBLE` on/off → `MakeInvisible` / `MakeVisible`.
   - `999` on → force HP/armour/max to 999; off → clamp back to 100 unless the
     player is `IsArmoredMan` or virus-flagged.
   - `JEEPATHON` / `TOILET` → force body/bodygroup indices.
   - `NOCLIP` on → `MOVETYPE_NOCLIP`; off → snap back to spawn (kills
     bystanders inside a 64-unit sphere, kills the player if hull traces solid).
   - `GODMODE` on → set `FL_GODMODE`; off → clear (but not on `FL_NOTARGET`
     snowmen — they keep god-mode).
   - `HALFLIFE` toggles `HIDEHUD_ICE` and sends `gmsgHideWeapon`.
   - Cvar mirrors: `sv_infiniteammo` (2/0), `mp_randomweapon` (2/0),
     `sys_timescale` (1.49/1.0 for `SPEEDUP`; 0.49/1.0 for `SLOWMO` in
     `EnvMutators`), `sv_slowbullets` (2/0), `g_ExplosiveAI`,
     `g_ItemsExplode` (also iterates `entityList[]` to set
     `takedamage`/`health` on weapon/ammo entities so they can be shot to
     detonate), `m_iNotTheBees`, `m_iDontShoot`, `m_iVolatile`.
5. Zero `m_flDetectedMutatorChange`.

### 3.6 `EnvMutators()` — world-level effects
Runs directly from step 2 above (and can be re-invoked). Not per-player.
- Removes any lingering `monster_rat` entities tagged with `iuser1 = MUTATOR_RATS`
  when the mutator is off.
- Slam `sys_timescale` to 0.49 (SLOWMO) / 1.0 restore.
- `LIGHTSOUT` — switches lightstyle 0 to `"b"` (blackout), overrides
  `mp_flashlight` to `"2"`, forces sky RGB to `(1,1,1)`; disables → restores
  lightstyle `"m"`, `mp_flashlight = 0`, and the saved sky RGB.
- `SUPERJUMP` → `sv_jumpheight` 299/45.
- `ASTRONAUT` → `sv_gravity` 199/800.
- `BIGFOOT` → `sv_stepsize` 192/18.
- Per player: `TINNITUS` writes physinfo `prop=2` (footstep silencer);
  `FOG` sends per-client `gmsgFog(50, 200, 125,125,125, 0)` unless an
  `env_fog` entity exists; toggles the flashlight to match `LIGHTSOUT`.

Cvar mutations are guarded ("if not already X, set X"; "if X and mutator gone,
restore Y") so servers running with unusual defaults are respected outside
mutator scope.

### 3.7 `SpawnMutators(CBasePlayer*)`
Invoked from `CBasePlayer::Spawn` (via mode-specific spawn paths). Establishes
the per-life state:
- Physinfo `topsy` and `haste` refreshed.
- `MUTATOR_ICE` → `pev->friction = 0.3`.
- `LIGHTSOUT` → force flashlight on.
- `SANTAHAT` → schedule next santa sound.
- Random weapon (if the mode allows).
- `GiveMutators(pl)` — see §3.8.
- Invisibility toggle.
- `999` — force HP/max/armour to 999.
- `JEEPATHON` / `TOILET` bodygroups.
- `NOCLIP` / `GODMODE` flags.

### 3.8 `GiveMutators(CBasePlayer*)`
Called from `SpawnMutators` and the per-player fix-up loop. Idempotent — each
block first calls `HasNamedPlayerItem` before granting. Grants exactly one
weapon per active mutator (or a passive item):

| Mutator | Grants |
|---|---|
| `MUTATOR_ROCKETCROWBAR` | `weapon_rocketcrowbar` |
| `MUTATOR_INSTAGIB` | `weapon_zapgun` |
| `MUTATOR_RAILGUNS` | `weapon_dual_railgun` + full uranium |
| `MUTATOR_PLUMBER` | `weapon_dual_wrench` |
| `MUTATOR_COWBOY` | `weapon_dual_sawedoff` |
| `MUTATOR_BUSTERS` | `weapon_egon` |
| `MUTATOR_BARRELS` | `weapon_gravitygun` |
| `MUTATOR_PORTAL` | `weapon_ashpod` |
| `MUTATOR_BERSERKER` | `weapon_chainsaw` |
| `MUTATOR_VESTED` | `weapon_vest` |
| `MUTATOR_FIRESTARTER` | `weapon_flamethrower` |
| `MUTATOR_ROCKETBEES` | `weapon_hornetgun` |
| `MUTATOR_LONGJUMP` | `item_longjump` (only if suit present) |
| `MUTATOR_GODMODE` | `weapon_vice` (special melee) |
| `MUTATOR_DONTSHOOT` | `weapon_fingergun` |

### 3.9 `WeaponMutators(CBasePlayerWeapon*)`
Called from weapon PreFrame / Fire paths. Applies pre-fire mutator effects:
- **DONTSHOOT (`m_iDontShoot`).** For every weapon that consumes ammo,
  `WEAPON_ZAPGUN`, or `WEAPON_ROCKETCROWBAR`, when the wielder is not in
  god-mode: apply `TakeDamage(20-60, DMG_BLAST)`, red screen fade, centre-print
  the "Don't Shoot!!!" message, and throttle both attack timers. This is what
  gives the *dontshoot* mutator its "shoot yourself" behaviour.
- **ROCKETS / GRENADES / SNOWBALLS.** With 1/11 probability per fire, calls the
  weapon's `ThrowRocket` / `ThrowGrenade` / `ThrowSnowball` helpers so shooting
  spawns projectiles in addition to (or instead of) the normal shot.
- **PUSHY.** Applies a backwards velocity impulse (`-forward * rand(50..100) * 3`)
  on every shot, clearing `FL_ONGROUND` first. Turns firing into recoil-boost.

### 3.10 `MutatorEnabled(int mutatorId)`
List walk. Returns `TRUE` when a matching node exists and either
`timeToLive == -1` or `timeToLive > gpGlobals->time`. This is what the ~200+
consumer sites in the server / weapons / player / gamerules code call to gate
behaviour.

### 3.11 `UpdateMutatorMessage(CBasePlayer*)`
Currently a stub — the on-HUD "Mutators Active: …" banner is disabled but the
plumbing exists (`m_iShowMutatorMessage`, throttled by
`m_flDetectedMutatorChange` reapply cycles). If a future banner ever needs to
show live mutators, this is the entry point.

---

## 4. Wire protocol

The server drives the client over three user messages. All names are ≤ 8
chars to satisfy engine limits.

### `gmsgAddMutator` — mutator add / clear / restore
Payload framing (server → client):
- **Batch mode** (default): a sequence of `BYTE mutatorId, SHORT timeSeconds`
  pairs, terminated when `READ_OK()` returns false. `mutatorId == 255` slots
  are ignored (padding sentinel). `mutatorId == -1` is a defensive break.
- **Clear-all** (single frame): `BYTE 254, SHORT 0`. Client wipes its list and
  reverts special client-only kickoffs (third-person cam, tinnitus loop, iron
  sight forcing).
- `SHORT time == 0` means permanent (`timeToLive = -1` on the client).
- `SHORT time > 0` is the remaining seconds (`timeToLive = m_flTime + time`).

Consumer logic in `MsgFunc_AddMut`:
- Deduplicates by `mutatorId` — an existing node has its `startTime` /
  `timeToLive` updated in place (fixes former duplicate-alloc leak).
- Kicks off client-only side effects:
  - `MUTATOR_THIRDPERSON` → `CAM_ToThirdPerson()`.
  - `MUTATOR_TINNITUS` → `gEngfuncs.pfnClientCmd("tinnitus_start\n")`.
  - `MUTATOR_CLOSEUP` → `g_IronSight = TRUE` (forces iron-sight FOV).
- Plays `horse_neigh.wav`.
- Invalidates the status-icon list via `m_StatusIcons.DrawMutators()`.

`MsgFunc_StatusIcon` is a *separate* message used only for the timed icon
sprites — mutator icons are actually driven by `EnableIcon` calls issued from
`ToggleMutatorIcon` on the client's own `Draw` tick (see §5).

### `gmsgChaos` — chaos-bar control
Single `BYTE increment`. `0` clears the client's chaos bar. `> 0` restarts the
bar (`m_ChaosStartTime = m_flTime`, `m_ChaosIncrement = value`,
`m_ChaosTime = m_flTime + value`). The bar animates linearly across the left
edge of the screen for the entire increment.

### `gmsgVoteMutator` — mutator vote panel toggle
`BYTE timer` (`0` = close), optional `BYTE gameMode` for panel context.
Handled in `TeamFortressViewport::MsgFunc_VoteMutator`, opens
`CVoteMutatorPanel`.

Related: `gmsgVote` / `gmsgVoteFor` carry the per-player vote number
(1..`MAX_MUTATORS + 2`) so the tally labels stay live.

---

## 5. Client pipeline

### 5.1 Message intake
`CHud::MsgFunc_AddMut` and `MsgFunc_Chaos` (in `hud_msg.cpp`) mutate
`gHUD.m_Mutators` and the chaos-bar timers. `MsgFunc_InitHUD` frees the whole
list on level start (fixes prior null-without-free leak) and zeroes the chaos
timers.

### 5.2 Per-frame HUD upkeep — `CHudStatusIcons::Draw`
- Draws the left-edge chaos bar when `m_ChaosTime > m_flTime` and pipes seconds
  through the FVox timer callout.
- Draws up to `max` icons (2/3/4 depending on `ScreenHeight`) using
  `SPR_DrawAdditive` and a per-icon timer bar clipped from `startTime` and
  `timeToLive`.
- Every 1 s (`m_flCheckMutators`) it prunes expired nodes:
  - `MUTATOR_THIRDPERSON` → `CAM_ToFirstPerson`.
  - `MUTATOR_TINNITUS` → `tinnitus_stop`.
  - `MUTATOR_CLOSEUP` → `g_IronSight = FALSE`.
  - Node is `delete`d after unlink.
- Re-calls `DrawMutators()` which iterates every mutator id and calls
  `ToggleMutatorIcon(id, sMutators[id-1].name)`. That helper adds or removes
  the sprite via `EnableIcon`/`DisableIcon`, guarded by an `m_LastMutatorStatus`
  cache so we do not re-add every frame.
- `MUTATOR_LONGJUMP` is a special case: its icon is disabled only if the
  player is not currently wearing the long jump module (physinfo `slj != 1`),
  because it can be granted by a separate item pickup.

### 5.3 Client-only effect surfaces
Where each mutator lands on the client:

- **View/roll (view.cpp):** `MCCLANE` (view roll -180 permanently),
  `UPSIDEDOWN` (roll +180), `AMIDEAD` (roll +80), `TOPSYTURVY` in singleplayer
  (roll 180 while alive). `MINIME` also adjusts view height.
- **Input inversion (inputw32.cpp + input.cpp):** `MIRROR`, `TOPSYTURVY`,
  `UPSIDEDOWN` flip mouse axes appropriately so the world stays controllable.
- **Post-process (colorcor.cpp):** `OLDTIME` and `INVERSE` (colour negation /
  black-and-white), `ASTRONAUT` (blue tint), `SILDENAFIL` (blue boost).
- **StudioModelRenderer.cpp (per-bone):** `BIGHEAD` (scale head/arm bones 3x),
  `MINIME` (0.5x whole skeleton + -8 z), `PAPER` (Y-axis to 10 %), `CRATE`
  (swap model to `models/box.mdl`), `SANIC` (spawn a persistent
  `sprites/sanic.spr` temp entity in place of the player).
- **Radar (radar.cpp):** `NORADAR` hides the client radar.
- **Lifebar (lifebar.cpp):** `PAINTBALL` recolours the damage FX.
- **Ammo/hud_redraw:** `RICOCHET`, `INFINITEAMMO` UI hints.
- **Audio (mutator_tinnitus.cpp):** ducks all sounds to 5 % while
  `g_bTinnitusActive`, replays `tinnitus_buzz.wav` every 41 s on `CHAN_STATIC`.
  Uses `Tinnitus_Hook` / `Tinnitus_Unhook` to swap `pEventAPI->EV_PlaySound`.

### 5.4 Vote panel — `CVoteMutatorPanel`
Grid of buttons keyed to `MAX_MUTATORS_CL`:
- Skips button creation for the currently-disabled mutators
  (`slowmo`, `speedup`, `topsyturvy`, `itemsexplode`, `explosiveai`) so the
  panel matches `CHalfLifeMultiplay::MutatorAllowed`.
- `RANDOM` (vote id `MAX_MUTATORS + 1`) is pinned to grid slot 0.
- `INSTANT MUTATORS` is injected as a synthetic slot right after `CHAOS`
  (vote id `MUTATOR_VOTE_INSTANT = MAX_MUTATORS_CL + 1`, equivalently
  `MAX_MUTATORS + 2` on the server).
- Selecting a button executes `vote N` on the client, which the shared
  `client.cpp::Vote()` handler forwards back to the server as a
  `gmsgVoteFor(client, vote)`.

Server tally (`CheckMutatorRTV` and the intermission
`VOTE_MUTATORS_OPEN → VOTE_MAPS_TRANSITION` transition) picks the top three
votes:
- If any of them is the `RANDOM` sentinel it is replaced by
  `RandomizeMutator()` (which itself invokes `MutatorAllowed`).
- If any of them is `INSTANT` the server sets `sv_instantmutators 1`, else `0`.
- Real mutator winners are baked into `sv_mutatorlist` as
  `"name 0;name 0;name 0"` (permanent). The next-map `MutatorsThink` then
  drains them one at a time and turns each into a proper `mutators_t` node.

The intermission voting state machine keeps mutator voting at
`VOTE_MUTATORS_TRANSITION` (3) → `VOTE_MUTATORS_OPEN` (4). Timing is
proportional to `voting.value`.

---

## 6. Voting and RTV interactions

There are two distinct entry points into the mutator vote:

1. **Intermission auto-vote.** `CHalfLifeMultiplay::Think()` drives
   intermission phases; when it reaches `VOTE_MUTATORS_TRANSITION` it broadcasts
   `gmsgVoteMutator(voting.value, gameMode)`, sets `m_iVoteUnderway` to
   `VOTE_MUTATORS_OPEN`, and plays `CLIENT_SOUND_VOTEMUTATOR`. Timing budget:
   `(voting.value * 4) + 12` seconds from the start of intermission (the game-
   options phase now takes the earlier slot; see [game_options_system.md](game_options_system.md)).

2. **Rock-The-Vote.** `rtv mutator` (chat) or the RTV console command sets
   `m_fMutatorVoteTime = time + voting.value` and opens a client panel via
   `VoteForMutator()`. `CheckMutatorRTV()` polls each tick until the deadline
   expires, then runs the same tally logic.

Both paths:
- Wipe existing mutators (`sv_addmutator clear` in RTV; the map change wipes
  it naturally in intermission).
- Force `sv_instantmutators 0` before opening.
- Push results through `sv_mutatorlist` (permanent duration).
- Bots receive a synthesized `Vote()` call using `RandomizeMutator()` so an
  all-bot server still concludes the vote.

---

## 7. Round-based mutator pause / restore

Round-based modes have a lull between rounds — spectator cams, countdowns,
respawn queues. Left unmodified the mutator TTLs would tick down during that
lull, which is unfair (a "Low Gravity 30s" applied at round start would run
out before round 2 even begins). The pause/restore system freezes state
between rounds.

### 7.1 State
```
BOOL          m_bMutatorsPaused;         // guard against double-pause
mutators_t   *m_SavedMutators;           // deep copy of m_Mutators
float         m_flSavedChaosMutatorTime; // chaos remaining time when paused
float         m_flPausedTimeDelta;       // gpGlobals->time when pause began
```

### 7.2 `PauseMutators()`
Guarded by `m_bMutatorsPaused` (early-return if already paused).
1. Save chaos remaining = `m_flChaosMutatorTime - gpGlobals->time` (0 if off).
2. Deep-copy every `m_Mutators` node into `m_SavedMutators` (id + TTL).
3. Force every active mutator to expire immediately by writing
   `timeToLive = gpGlobals->time - 1.0f`. `MutatorsThink`'s normal expiration
   pass will now free them cleanly with `delete`.
4. Zero `m_flChaosMutatorTime` and broadcast `gmsgChaos(0)` to hide the bar.
5. Broadcast `gmsgAddMutator(254, 0)` so clients wipe their HUD list.
6. Log to console.

### 7.3 `RestoreMutators()`
Guarded by `!m_bMutatorsPaused` (early-return if not paused).
1. Compute `pauseDuration = gpGlobals->time - m_flPausedTimeDelta`.
2. Iterate `m_Mutators` and free any leftover expired nodes (defensive — the
   pass in `MutatorsThink` normally cleared them already).
3. Rebuild `m_Mutators` from `m_SavedMutators`:
   - Permanent (`timeToLive == -1`) → keep as `-1`.
   - Positive TTL → `timeToLive + pauseDuration` (shift forward by the pause
     length, preserving remaining time).
   - Zero / negative TTL → reset to `gpGlobals->time + sv_mutatortime`.
4. For each restored node broadcast `gmsgAddMutator(id, remaining)` where
   `remaining` is `0` for permanent or `max(1, timeToLive - now)` otherwise.
5. If `m_flSavedChaosMutatorTime > 0`, restart the chaos timer and broadcast
   `gmsgChaos((int)remaining)`.
6. `FreeMutatorChain` on the saved list, reset all pause-state fields.
7. `m_flDetectedMutatorChange = gpGlobals->time + 0.5` so `EnvMutators()` and
   per-player fix-ups run again shortly after unpause.

### 7.4 Where they are called
| Callsite | Mode |
|---|---|
| `multiplay_gamerules.cpp::GoToIntermission()` | Global catch-all (any mode ending the match) |
| `arena_gamerules.cpp` × 4 | Constructor, round-end, winner detection, mid-round abort |
| `chilldemic_gamerules.cpp` × 3 (+1 restore) | Constructor, round-end, respawn round begin |
| `horde_gamerules.cpp` × 3 (+1 restore) | Constructor, wave transitions |
| `jvs_gamerules.cpp` × 3 (+1 restore) | Constructor, round lifecycle |
| `lms_gamerules.cpp` × 3 (+1 restore) | Constructor, elimination transitions |
| `loot_gamerules.cpp` × 2 (+1 restore) | Constructor & round start; end via `GoToIntermission` |
| `prophunt_gamerules.cpp` × 3 (+1 restore) | Constructor, seek/hide phases |
| `shidden_gamerules.cpp` × 3 (+1 restore) | Constructor, hunter/prey transitions |

Pattern: pause in the constructor (mode boots into the countdown/warm-up
phase); pause again on round-end / winner detection; **restore** exactly once
at the `g_GameInProgress = TRUE` transition. `GoToIntermission()` provides the
final catch-all for map end.

### 7.5 What is *not* affected
Continuous modes (Deathmatch / TDM / CTF / Cold Skulls / Freeze Tag / Gun Game
/ Instagib / OITC / Sticks & Stones) never call the pause helpers — their
mutators tick normally throughout play.

---

## 8. Mutator catalogue

**Legend for scope:** S=server-only effect, C=client-only effect, SC=both.
**Weapon** means `GiveMutators` grants a weapon (see §3.8).
**World-cvar** means `EnvMutators` slams a cvar (§3.6).
**Filtered by:** modes that reject the mutator via `MutatorAllowed`.

### Chaos / meta
| ID | Name | Scope | Effect | Filtered by |
|---:|---|---|---|---|
| 1 | `chaos` | S | Not a real mutator — enabling it starts the periodic chaos cadence (`m_flChaosMutatorTime`). Cleared with `unchaos`. | — |
| 79 | `three` | S | Not a mutator — special token in `sv_addmutator` that fires `AddRandomMutator` three times. | — |

### Movement / physics (world cvars or physinfo)
| ID | Name | Scope | Effect |
|---:|---|---|---|
| 4 | `astronaut` | SC | `sv_gravity = 199`; client colour-cor slight blue tint. |
| 8 | `bigfoot` | S | `sv_stepsize = 192`. |
| 28 | `ice` | S | Per-spawn `friction = 0.3`; slippery movement. |
| 37 | `lightsout` | S | Lightstyle 0 blackout, force flashlight on, sky→(1,1,1). |
| 38 | `longjump` | S | Grants `item_longjump`. |
| 43 | `megarun` (physinfo `haste=1`) | SC | Player haste; pm_shared reads `canHaste`. |
| 47 | `noclip` | S | `MOVETYPE_NOCLIP` for players; kills bystanders on off-toggle. |
| 59 | `pushy` | S | `WeaponMutators` gives -recoil impulse on every shot. |
| 67 | `sanic` | C | Replaces player model with sanic sprite. |
| 70 | `skyhook` | S | Grappling-hook-style gameplay tweak (`AllowGrapplingHook`). |
| 71 | `slowbullets` | S | `sv_slowbullets = 2`. |
| 72 | `slowmo` | S | `sys_timescale = 0.49`. **Blocked in `MutatorAllowed` — treat as disabled.** |
| 75 | `speedup` | S | `sys_timescale = 1.49`. **Blocked in `MutatorAllowed`.** |
| 77 | `superjump` | S | `sv_jumpheight = 299`. |
| 82 | `topsyturvy` (physinfo `topsy=1`) | SC | Player upside-down. **Blocked in `MutatorAllowed` for MP.** |
| 84 | `upsidedown` | C | View roll 180 + mouse inversion. |

### Combat modifiers
| ID | Name | Scope | Effect |
|---:|---|---|---|
| 2 | `999` | S | Force HP/armour/max_health to 999. Filtered by CtC, Instagib, Loot. |
| 3 | `amidead` | C | View roll 80° (drunken lean). |
| 5 | `autoaim` | S | Client-driven aim assist; off-toggle calls `ResetAutoaim`. |
| 6 | `barrels` | S/Weapon | Grants `weapon_gravitygun`; barrels become props. |
| 7 | `berserker` | S/Weapon | Grants `weapon_chainsaw`. |
| 10 | `busters` | S/Weapon | Grants `weapon_egon`. |
| 11 | `chumxplode` | S | Chumtoads explode; gated by CtC/Loot filters. |
| 12 | `closeup` | C | Force iron-sight FOV. |
| 14 | `cowboy` | S/Weapon | Grants `weapon_dual_sawedoff`. |
| 17 | `dealter` | S | Per-frame damage to non-suit players (rot effect). |
| 18 | `dontshoot` | S/Weapon | Grants `weapon_fingergun`; every trigger pull damages the shooter (see `WeaponMutators`). |
| 19 | `explosiveai` | S | Sets `g_ExplosiveAI`. **Blocked in `MutatorAllowed`.** |
| 20 | `fastweapons` | S | Weapon time-scaling. |
| 21 | `firebullets` | S | Ignites victims on hit. |
| 22 | `firestarter` | S/Weapon | Grants `weapon_flamethrower`. |
| 24 | `godmode` | S/Weapon | Sets `FL_GODMODE`; grants `weapon_vice` (special melee). |
| 25 | `goldenguns` | S | One-hit-kill damage bonus. |
| 26 | `grenades` | S | 1/11 fire chance to also throw a grenade. |
| 29 | `infiniteammo` | S | `sv_infiniteammo = 2`. |
| 30 | `instagib` | S/Weapon | Grants `weapon_zapgun`. |
| 33 | `itemsexplode` | S | Weapons/items become destructible; iterates `entityList[]`. **Blocked in `MutatorAllowed`.** |
| 46 | `napkinstory` | S | (napkin_story reference — melee/scoring tweak.) |
| 49 | `noreload` | S | No reload cycles. |
| 51 | `notthebees` | S | Sets `m_iNotTheBees`; hornetgun swarms exit players on damage. |
| 53 | `paintball` | SC | Paintball-style hit FX. |
| 56 | `plumber` | S/Weapon | Grants `weapon_dual_wrench`. |
| 57 | `portal` | S/Weapon | Grants `weapon_ashpod`. |
| 60 | `railguns` | S/Weapon | Grants `weapon_dual_railgun` + full uranium. |
| 61 | `randomweapon` | S | `mp_randomweapon = 2`; per-spawn random loadout. |
| 63 | `ricochet` | S | Bullets bounce (up to N ricochets). |
| 64 | `rocketbees` | S/Weapon | Grants `weapon_hornetgun`; bee projectiles explode. |
| 65 | `rocketcrowbar` | S/Weapon | Grants `weapon_rocketcrowbar`. |
| 66 | `rockets` | S | 1/11 fire chance to also throw a rocket (via `ThrowRocket`). |
| 73 | `slowweapons` | S | Weapon time-scaling. |
| 74 | `snowballs` | S | 1/11 fire chance to also throw a snowball. |
| 76 | `stahp` | S | `UTIL_IsMovementBlocked` returns TRUE (see util.h) — freezes movement. |
| 83 | `turrets` | S | Auto-turrets fire at everyone. |
| 85 | `vested` | S/Weapon | Grants `weapon_vest` (explosive vest). |
| 86 | `volatile` | S | Sets `m_iVolatile`; damage cascades. |

### Visual / HUD
| ID | Name | Scope | Effect |
|---:|---|---|---|
| 9 | `bighead` | C | Head/arm bones scaled 3× in `StudioModelRenderer`. |
| 13 | `coolflesh` | SC | Frostbite / freeze cosmetic. |
| 15 | `crate` | C | Player model becomes `models/box.mdl`. |
| 16 | `credits` | S | Enters "credits" mode on players (`m_iCreditMode = 1`). |
| 23 | `fog` | S | Broadcasts `gmsgFog(50,200,125,125,125,0)`. |
| 27 | `halflife` | S | `HIDEHUD_ICE` hides Cold Ice HUD elements. |
| 31 | `inverse` | C | Colour-corrector negates output. |
| 32 | `invisible` | S | `MakeInvisible` / `MakeVisible` on players. |
| 34 | `jack` | C | Jack-in-the-box head cosmetic (blocked in PropHunt). |
| 35 | `jeepathon` | S | Every player becomes a jeep bodygroup. |
| 36 | `jope` | S | Player names swapped to "Jope"; original saved in info-key `j`. |
| 39 | `loopback` | S | Damage returns to the attacker (wormhole). |
| 40 | `marshmellow` | C | Marshmallow head (blocked in PropHunt). |
| 41 | `maxpack` | S | Max ammo pickups. |
| 42 | `mcclane` | C | View roll -180 permanently. |
| 44 | `minime` | C | Player model scaled to 0.5×, view offset. |
| 45 | `mirror` | C | Mouse X inverted; view mirrored. |
| 48 | `noradar` | C | Hides radar HUD. |
| 50 | `notify` | S | Notification/phone effect. |
| 52 | `oldtime` | C | Black-and-white colour correction. |
| 54 | `paper` | C | Player bones flattened to 10 % Y-axis. |
| 55 | `piratehat` | C | Pirate cosmetic (blocked in PropHunt). |
| 58 | `pumpkin` | C | Pumpkin cosmetic (blocked in PropHunt). |
| 62 | `rats` | S | Spawns `monster_rat` entities with `iuser1 = MUTATOR_RATS`. |
| 68 | `santahat` | S/C | Santa cosmetic + periodic `next_santa_sound` (blocked in PropHunt). |
| 69 | `sildenafil` | C | Colour-corrector blue boost. |
| 78 | `thirdperson` | C | `CAM_ToThirdPerson` on add; reverts on remove/clear (blocked in most round modes). |
| 80 | `tinnitus` | SC | Physinfo `prop=2` (footstep silencer) + client audio ducking + buzz loop. |
| 81 | `toilet` | S | Player becomes toilet or camera bodygroup (blocked in PropHunt). |

**Note:** Certain names in `g_szMutators[]` do not match their `MUTATOR_*`
identifier stem — e.g. `MUTATOR_MEGASPEED` uses the string `"megarun"`,
`MUTATOR_MARSHMELLO` uses `"marshmellow"`, `MUTATOR_NAPKIN` uses
`"napkinstory"`. When adding new mutators keep the mapping consistent between
`common/const.h`, `dlls/gamerules.cpp::g_szMutators[]`, and
`cl_dll/vgui_TeamFortressViewport.cpp::sMutators[]` — the three arrays are
addressed by `MUTATOR_* - 1` and must remain 1:1.

---

## 9. Adding a new mutator (checklist)

1. **ID (shared).** Append to `common/const.h` immediately before
   `MAX_MUTATORS_CL`, e.g. `#define MUTATOR_FOOBAR 87`. Bump the sentinel:
   `#define MAX_MUTATORS_CL MUTATOR_FOOBAR + 1`. The server-side
   `MAX_MUTATORS` macro (`gamerules.h`) auto-tracks because it is
   `MUTATOR_VOLATILE`, which means **adding at the end works, but inserting
   in the middle re-numbers every downstream ID and will desync clients** —
   always append.
2. **Server name table.** Append the internal string to
   `dlls/gamerules.cpp::g_szMutators[]`. Must be lowercase, unique, and match
   the substring compare used by `sv_addmutator` / `sv_chaosfilter` /
   `MutatorAllowed`.
3. **Client display table.** Append `{ "name", "short description" }` to
   `cl_dll/vgui_TeamFortressViewport.cpp::sMutators[]` at the same index. Do
   not reorder existing entries.
4. **Filters.** Decide whether the mutator should be allowed in every mode.
   If not, add `strstr(mutator, g_szMutators[MUTATOR_FOOBAR - 1]) ||
   atoi(mutator) == MUTATOR_FOOBAR` return-`FALSE` blocks in the relevant
   `MutatorAllowed` overrides (and `CHalfLifeMultiplay::MutatorAllowed` if
   universally disabled). Add to `sv_chaosfilter` default if it should be
   opt-in only.
5. **Effect wiring.**
   - Purely visual: `MutatorEnabled(MUTATOR_FOOBAR)` checks in the appropriate
     client file (`StudioModelRenderer.cpp`, `view.cpp`, `colorcor.cpp`, etc.).
   - Gameplay: `MutatorEnabled` checks in the server hot paths. If the check
     needs to be *very* hot (per-projectile), mirror it as a `BOOL`
     alongside `m_iNotTheBees` / `m_iDontShoot` / `m_iVolatile` and toggle it
     in the `m_flDetectedMutatorChange` apply block.
   - World cvar: extend `EnvMutators` with an on/off pair that also restores
     the pre-mutator default. Never rely on hard-coded default values —
     capture the pre-mutator value at map start.
   - Weapon grant: extend `GiveMutators`. Use `HasNamedPlayerItem` guards.
     Do not `SelectItem` inside a Give path if the mode may be spectator or
     paused.
   - Client-only kickoff: extend `MsgFunc_AddMut` (the `mutatorId == ...`
     ladder) and its mirror inside the `254` clear-all branch and the
     `CHudStatusIcons::Draw` expiry loop.
6. **VGUI vote panel.** No code change needed unless the mutator should be
   *hidden* from the vote grid; if so add a `strstr(sMutators[i].name, ...)`
   skip in `CVoteMutatorPanel` constructor (matching the existing
   slowmo/speedup/topsyturvy/itemsexplode/explosiveai list).
7. **Pause/restore.** Nothing to change — the pause system operates on IDs
   and TTLs, not on effects.
8. **Documentation.** Add a row to the catalogue in §8 and update any relevant
   spoke doc (`workspace/ai/voting_system.md`,
   `workspace/ai/gamerules.md`, mode-specific docs when the mutator is
   permanently associated with a mode).
9. **Build.** Windows: `workspace/Build-Windows.ps1`. Linux:
   `workspace/build-linux.sh`. Both DLLs must rebuild (`ice.dll` and
   `client.dll`) so the shared const.h change is picked up on both sides.

---

## 10. Known pitfalls & invariants

- **Symmetric IDs.** `MUTATOR_*` values are on the wire. Do not reorder or
  renumber. If a value is retired, keep the enum slot and just filter the
  string in `MutatorAllowed` everywhere.
- **List memory (server).** `MutatorsThink` used to `unlink` nodes without
  `delete` — resulting in a heap leak per expiration. The current code deletes
  cleanly; do not remove the `delete m;` calls in the expiration pass, the
  destructor's `FreeMutatorChain`, or the equivalent frees in
  `PauseMutators`/`RestoreMutators`. `CGameRules::~CGameRules()` also
  destroys both lists because `g_pGameRules` is `delete`d and reallocated on
  every map change.
- **List memory (client).** The same bug existed in
  `cl_dll/status_icons.cpp` (unlink without `delete`) and
  `hud_msg.cpp::MsgFunc_InitHUD` (nulling without freeing). Both are fixed.
  `MsgFunc_AddMut` also has a duplicate-alloc guard — a repeat mutator id in
  the payload updates the existing node instead of leaking a new one.
- **String-pool leak.** Do not go back to unconditional
  `gpGlobals->startspot = ALLOC_STRING(szMutators)`. The engine's string pool
  has no free path — you leak one string per tick otherwise. The current code
  only allocates when the value actually changes.
- **Runes and precache.** Even with `mp_allowrunes 0`, runtime rune creation
  (mutators, JvS, snowball path) can still occur; `CWorld::Precache` must
  always call `PrecacheRunes()` or `PF_precache_model_I` will fatal on
  `models/w_runes.mdl`. Applies to mutators that give runes as side effects.
- **Physinfo keys.** `topsy`, `haste`, and `prop` are read by
  `pm_shared/pm_shared.c` on both sides. Server writes them via
  `g_engfuncs.pfnSetPhysicsKeyValue`. Keep the key names in sync — a typo
  silently disables the effect.
- **Third-person / iron sight / tinnitus.** The three "kickoff" mutators
  need explicit *stop* paths in three places: the client's expiry pass in
  `CHudStatusIcons::Draw`, the `254` clear-all branch of `MsgFunc_AddMut`, and
  `MsgFunc_InitHUD` (level start). Missing one causes the effect to persist
  after the mutator ends.
- **Vote synthetic slots.** `RANDOM` is `MAX_MUTATORS + 1`; `INSTANT MUTATORS`
  is `MAX_MUTATORS + 2`. Do not confuse them for real IDs — they never end up
  in `g_szMutators[]` and must not be pushed through
  `sv_addmutator`/`sv_mutatorlist`.
- **JOPE cleanup.** `MUTATOR_JOPE` writes to the client info-key `j` as a
  backup slot for the original `netname`. If a player reconnects while JOPE is
  paused (round-based), the info-key persists — the restore path handles this
  by re-triggering `m_flDetectedMutatorChange`, which reruns the JOPE apply
  loop. Removing that scheduled reapply will strand players as "Jope".
- **`EnvMutators` cvar guards.** Every cvar override in `EnvMutators` is
  fenced with a "current value == mutator value" check. This is intentional:
  server admins may run with `sv_gravity != 800`, `sv_stepsize != 18`,
  `sys_timescale != 1`, etc., and the fence prevents mutator toggling from
  clobbering their custom defaults. Preserve that pattern when adding new
  world-cvar mutators.

---

## 11. Cross-links

- Round-based mode docs (each covers where they pause/restore):
  `workspace/ai/arena_gamerules.md`, `chilldemic_gamerules.md`,
  `horde_gamerules.md`, `jvs_gamerules.md` (JVS / Iceman),
  `lms_gamerules.md`, `loot_gamerules.md`, `prophunt_gamerules.md`,
  `shidden_gamerules.md`.
- Voting umbrella: `workspace/ai/voting_system.md`.
- Server side gamerules umbrella: `workspace/ai/gamerules.md`.
- Client umbrella: `workspace/ai/client.md`, `workspace/ai/vgui_system.md`.
- Runes: `workspace/ai/runes.md` (mutators that grant runes must precache).
- Particles: `workspace/ai/particle_system.md` (mutator FX often use aurora
  particle definitions).

## 12. Deprecated / superseded docs

- `workspace/ai/mutator_pause_system.md` (removed) — content merged into §7 of
  this file. Existing references in [cir.md](cir.md) and [server.md](server.md)
  have been redirected here.
