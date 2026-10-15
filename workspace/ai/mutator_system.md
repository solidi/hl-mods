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

## 0. Recent delta (2026-10-15)

- Added the `Remove func_*` **instant** mutator as `INSTANT_REMOVE_FUNC = 17` (roll is now `0..17`). It removes every entity of one random `func_*` class present on the map, announces `[Mutators] Remove func_*: <classname> was removed!`, and nothing comes back until the next map change (see §3.3.3). Server-only; no client, registry or asset change.
- Hardened runtime removal of brush entities for it (also fixes `killtarget`): `CFuncTank`, `CFuncTankLaser`, `CFuncTrackTrain` and `CFuncTrackChange` gained `UpdateOnRemove` teardown, and `CFuncTankControls` / `CPlatTrigger` hold `EHANDLE`s instead of raw pointers.
- Added the `bsod` **instant** mutator as `INSTANT_BSOD = 16` (roll was then `RANDOM_LONG(0, INSTANT_MUTATOR_COUNT - 1)` = `0..16`). Instant mutators have no `MUTATOR_*` ID, so no registry, `settings.scr`, `hud.txt` or vote-panel change was needed.
- New user message `gmsgBSOD` (`"BSOD"`, 0 bytes) opens a full-screen deep-blue fake crash screen (`CBSODPanel`, `MENU_BSOD`) on every alive, active, non-bot player, plays `sound/bsod.wav` and is dismissed with the bottom-right `Failed Successfully` button. All strings come from `titles.txt` (see §3.3.2).

## 0.1 Earlier delta (2026-10-14)

- Added the `Accept All Cookies` **instant** mutator as `AddInstantMutator()` case 15 (roll is now `RANDOM_LONG(0, 15)`). Instant mutators have no `MUTATOR_*` ID, so no registry, `settings.scr`, `hud.txt` or vote-panel change was needed; it is only ever picked at random on the instant cadence.
- New user message `gmsgCookies` (`"Cookies"`, 1 byte) opens a client-side VGUI cookie consent wall (`CCookiesPanel`, `MENU_COOKIES`) on every alive, active, non-bot player: scrollable fake agreement, `Accept All Cookies` (dismiss) on the left, `Reject All Cookies` (client runs `disconnect`) on the right. All strings come from `titles.txt` (see §3.3.1).

## 0.2 Earlier delta (2026-10-13)

- Added `blur` (`MUTATOR_BLUR = 11`) in alphabetical ID order after `bighead` (all downstream mutator IDs shifted by +1; `busters` is now 12, `linemode` is now 48, `three` is now 103).
- Canonical shared mutator range is now `MUTATOR_CHAOS`..`MUTATOR_WATERHURT` = `1..114`, with `MAX_MUTATORS_CL = 115` including trailing `RANDOM`. `hud.txt` declaration count is now 362 (`blur` reuses the `drunk` icon rect).
- While active, every client renders frame-feedback motion blur (ported from GSChaos `CFeatureBlur`): the previous blurred frame is blended over the finished 3D view at a frame-time based opacity and copied back as history, so anything moving on screen leaves a decaying trail. The HUD stays sharp. Client-only; no server logic or mode filters (see §3.28).

## 0.3 Earlier delta (2026-10-12)

- Added `linemode` (`MUTATOR_LINEMODE = 47`) in alphabetical ID order after `lightsout` (all downstream mutator IDs shifted by +1; `longjump` became 48, `three` was then 102).
- Canonical shared mutator range was then `MUTATOR_CHAOS`..`MUTATOR_WATERHURT` = `1..113`, with `MAX_MUTATORS_CL = 114` including trailing `RANDOM`. `hud.txt` declaration count was then 361 (`linemode` reuses the `oldtime` icon rect).
- While active, every client renders GoldenEye 007's hidden Line Mode: the 3D view washes out to white and only silhouettes and geometric creases of the world, brush entities and models are traced in black, in real time via a depth-buffer GLSL pass. The HUD draws normally on top. Client-only; no server logic or mode filters (see §3.27).

## 0.4 Earlier delta (2026-10-11)

- Added `goldeneye` (`MUTATOR_GOLDENEYE = 32`) in alphabetical ID order after `godmode` (all downstream mutator IDs shifted by +1; `goldenguns` became 33, `three` was then 101).
- Canonical shared mutator range was then `MUTATOR_CHAOS`..`MUTATOR_WATERHURT` = `1..112`, with `MAX_MUTATORS_CL = 113` including trailing `RANDOM`. `hud.txt` declaration count was then 360 (`goldeneye` reuses the `goldenguns` icon rect).
- While active, the local HUD drops the health/armor numbers, cross and suit icons and the separator bar; GoldenEye 007 styled curved, segmented health (left, yellow -> red) and armor (right, light blue -> blue) bars flash up for a few seconds whenever the local player is hurt. Client-only; no server logic or mode filters (see §3.26).

## 0.5 Earlier delta (2026-10-10)

- Added `myfavtexture` (`MUTATOR_MYFAVTEXTURE = 54`) in alphabetical ID order after `mirror` (all downstream mutator IDs shifted by +1; `three` was then 100).
- Canonical shared mutator range was then `MUTATOR_CHAOS`..`MUTATOR_WATERHURT` = `1..111`, with `MAX_MUTATORS_CL = 112` including trailing `RANDOM`.
- While active, every world and brush-entity surface on every client renders one replacement texture (default `AAATRIGGER` from `halflife.wad`, procedural black/magenta checker fallback). Client-only; no server logic or mode filters (see §3.25).

## 0.6 Earlier delta (2026-10-09)

- `MutatorsThink` now logs `Mutator "<name>" is unknown and cannot be applied.` to the server console when `sv_addmutator` does not resolve to a known token (for example, typoing `snackbar`).
- `sv_addmutator` resolves its first token to a `g_szMutators[]` index (case-insensitive name or numeric id) *before* calling `MutatorAllowed`, and passes the canonical lowercase name to the filter. Every mode filter uses case-sensitive `strstr` against canonical names, so validating raw input let `SLOWMO` bypass the multiplayer `slowmo` block. The enable loop and the `three` special pass key off the same resolved index, so `sv_addmutator 99` now expands `three` like the name does.
- Added `snarkbar` (`MUTATOR_SNARKBAR`) in the shared mutator ID space.
- While active, `GiveMutators` ensures alive players own a crowbar (`weapon_crowbar`) if they do not already have one.
- `flying_crowbar` impact handling now spawns five `monster_snark` entities that are attributed to the original thrower.
- Snark spawn points are resolved through repeated hull probes and surface-offset retries so impacts against walls/entities still emit usable, unstuck snarks near the contact location.
- No mode-specific `MutatorAllowed` filters were added, so `snarkbar` remains eligible anywhere mutators are enabled.
- Added `fadetoblack` (`MUTATOR_FADETOBLACK`) in alphabetical ID order after `explosiveai` (all downstream mutator IDs shifted by +1).
- While active, `fadetoblack` applies a local HP-based blackout overlay for alive active players and boosts outgoing damage for alive active non-observer attackers as HP drops.
- No mode-specific `MutatorAllowed` filters were added, so `fadetoblack` remains eligible anywhere mutators are enabled.
- Added `nelliaschoice` (`MUTATOR_NELLIASCHOICE`) in alphabetical ID order after `negativepi` (all downstream mutator IDs shifted by +1).
- While active, one non-movement, non-primary button is randomly selected as the danger key (`use`, `secondary attack`, `reload`, `alt1`, `ironsight`, or `score`) and center-printed as `<KEY> is the danger key!`.
- Pressing the selected danger key by an alive, active, non-observer player detonates and kills that player.
- Deactivating `nelliaschoice` clears the selected key; reactivation rolls a fresh key.
- `Nellia's Choice` was proposed by the alias `Nellia`.
- Added `nohud` (`MUTATOR_NOHUD`) in alphabetical ID order after `noclip` (all downstream mutator IDs shifted by +1).
- Canonical shared mutator range was then `MUTATOR_CHAOS`..`MUTATOR_WATERHURT` = `1..110`, with `MAX_MUTATORS_CL = 111` including trailing `RANDOM`.
- While active, `nohud` suppresses all client HUD elements and crosshairs; only the left-side `nohud` status icon is rendered.

---

## 1. Where the code lives

### Shared / IDs
- [workspace/src/common/const.h](workspace/src/common/const.h#L805-L920) —
  `MUTATOR_CHAOS`..`MUTATOR_WATERHURT` IDs (1..114) and
  `MAX_MUTATORS_CL` (client cap = `MUTATOR_WATERHURT + 1`).
- [workspace/src/pm_shared/pm_shared.c](workspace/src/pm_shared/pm_shared.c#L308) —
  reads movement/audio/control physinfo keys the server writes: `topsy`,
  `haste`, `prop`, `slj`, `jumpheight`, and `negpi`.
- [workspace/src/pm_shared/pm_math.c](workspace/src/pm_shared/pm_math.c) —
  mutator-aware PI in shared math: when `physinfo["negpi"] == "1"`, `M_PI`
  resolves to `-1.0` for prediction/server PM math.

### Server (dlls/)
- [workspace/src/dlls/gamerules.h](workspace/src/dlls/gamerules.h#L65-L272) —
  `struct mutators_t` (linked list node), `CGameRules` interface, protected /
  private state (`m_Mutators`, `m_SavedMutators`, timers, pool, flags),
  `MAX_MUTATORS = MUTATOR_WATERHURT`, `extern const char *g_szMutators[]`.
- [workspace/src/dlls/gamerules.cpp](workspace/src/dlls/gamerules.cpp#L66-L153) —
  `g_szMutators[]` name table (index = `MUTATOR_* - 1`).
- [workspace/src/dlls/gamerules.cpp](workspace/src/dlls/gamerules.cpp#L164-L172) —
  destructor + `FreeMutatorChain` (fixes former map-to-map leak).
- [workspace/src/dlls/gamerules.cpp](workspace/src/dlls/gamerules.cpp#L597-L2372) —
  All the `CGameRules::*Mutators*` methods described in §3.
- [workspace/src/dlls/combat.cpp](workspace/src/dlls/combat.cpp#L1038-L1245) —
  shared damage pipeline (`CBaseMonster::TakeDamage`) including
  `fadetoblack` low-health outgoing damage scaling.
- [workspace/src/dlls/util.h](workspace/src/dlls/util.h) — centralized
  mutator-aware `M_PI` (`negativepi` forces PI to `-1.0`).
- [workspace/src/dlls/player.cpp](workspace/src/dlls/player.cpp#L4258) —
  per-player mutator/rune checks that depend on runtime player state (e.g.
  `skyhook`, `floorislava`, `waterhurt`, and shared regen/ammoregen/vampire/rune pulses).
- [workspace/src/dlls/weapons.cpp](workspace/src/dlls/weapons.cpp) —
  `CWeaponBox` victor magnet logic (`MOVETYPE_NOCLIP` glide, 10 s timeout,
  victor-only touch lock while active).
- [workspace/src/dlls/func_tank.cpp](workspace/src/dlls/func_tank.cpp),
  [plats.cpp](workspace/src/dlls/plats.cpp),
  [trains.h](workspace/src/dlls/trains.h) — `UpdateOnRemove` teardown and
  `EHANDLE` links that let the `Remove func_*` instant mutator delete tanks,
  plats, track trains and track changers without dangling pointers (§3.3.3).
- [workspace/src/dlls/game.cpp](workspace/src/dlls/game.cpp#L89-L101) — cvar
  definitions (`sv_chaosfilter`, `sv_addmutator`, `sv_instantmutators`,
  `sv_mutatorlist`, `sv_mutatorcount`, `sv_mutatortime`) and registration.
- [workspace/redist/server_commands.txt](workspace/redist/server_commands.txt)
  — admin-facing mutator list and descriptions under `sv_addmutator`; keep
  entries alphabetically ordered.
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
  timer/icon fields, `m_Mutators` list on `CHud`, and centralized
  mutator-aware `M_PI` (`negativepi` forces PI to `-1.0`).
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
- [workspace/src/cl_dll/vgui_CookiesWindow.cpp](workspace/src/cl_dll/vgui_CookiesWindow.cpp) —
  `CCookiesPanel` cookie consent wall for the `Accept All Cookies` instant
  mutator, opened by `TeamFortressViewport::MsgFunc_Cookies` (§3.3.1).
- [workspace/src/cl_dll/vgui_BSODWindow.cpp](workspace/src/cl_dll/vgui_BSODWindow.cpp) —
  `CBSODPanel` fake crash screen for the `bsod` instant mutator, opened by
  `TeamFortressViewport::MsgFunc_BSOD` (§3.3.2).
- [workspace/src/cl_dll/mutator_tinnitus.cpp](workspace/src/cl_dll/mutator_tinnitus.cpp) —
  `Tinnitus_Hook` intercepts `pEventAPI->EV_PlaySound` when the tinnitus buzz
  is active and ducks all other sounds to 5%. Enabled/disabled via server
  `CLIENT_COMMAND("tinnitus_start"|"tinnitus_stop")`.
- [workspace/src/cl_dll/mutator_myfavtexture.cpp](workspace/src/cl_dll/mutator_myfavtexture.cpp) —
  `MyFavTexture_Frame` (called from `tri.cpp::HUD_DrawNormalTriangles`)
  swaps/restores world `texture_t` GL ids for `myfavtexture` (§3.25).
- [workspace/src/cl_dll/mutator_goldeneye.cpp](workspace/src/cl_dll/mutator_goldeneye.cpp) —
  `GoldenEye_Active` / `GoldenEye_OnDamage` / `GoldenEye_Reset` /
  `GoldenEye_Draw` (declared in `hud.h`), driven from `health.cpp` and
  gated in `battery.cpp` for `goldeneye` (§3.26).
- [workspace/src/cl_dll/mutator_linemode.cpp](workspace/src/cl_dll/mutator_linemode.cpp) —
  `LineMode_CaptureScene` (called from `tri.cpp::HUD_DrawNormalTriangles`)
  and `LineMode_Draw` (called at the top of `cdll_int.cpp::HUD_Redraw`,
  before `gHUD.Redraw`), both declared in `hud.h`; depth-edge GLSL
  post-process for `linemode` (§3.27).
- [workspace/src/cl_dll/mutator_blur.cpp](workspace/src/cl_dll/mutator_blur.cpp) —
  `Blur_Draw` (called at the top of `cdll_int.cpp::HUD_Redraw` right after
  `LineMode_Draw`, before `gHUD.Redraw`), declared in `hud.h`; frame-feedback
  motion blur for `blur` (§3.28).
- Client render/input consumers (mutator effects, non-exhaustive):
  `StudioModelRenderer.cpp` (BIGHEAD/MINIME/PAPER/SANIC/CRATE bones and
  proxies), `view.cpp` (MCCLANE/UPSIDEDOWN/AMIDEAD/TOPSYTURVY roll),
  `input.cpp` + `inputw32.cpp` (MIRROR/UPSIDEDOWN input inversion,
  NOMOUSE suppression),
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
- Server: `g_szMutators[MAX_MUTATORS]` where
  `MAX_MUTATORS = MUTATOR_WATERHURT` (114 entries). Indexing is always
  `g_szMutators[id - 1]`.
- Client display: `sMutators[MAX_MUTATORS_CL]` (name + description, 115 entries
  including a trailing `RANDOM`). Also `g_szMutators` is *not* defined
  client-side — the client uses `sMutators[i].name` for labelling only, and
  numeric IDs (`MUTATOR_*`) for behavioural checks.
- Real mutators are maintained in **alphabetical order** in all three aligned
  tables (`const.h` IDs, `g_szMutators[]`, `sMutators[]`), so new mutators
  must be inserted alphabetically and downstream IDs renumbered in lockstep.
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
- `m_iNelliaChoiceDangerButton`, `m_szNelliaChoiceDangerKey` — selected
  danger-key state for `nelliaschoice` while active.
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
    - If the added mutator is `nelliaschoice`, rolls and announces the danger key.
     - Bumps `m_flDetectedMutatorChange = gpGlobals->time + 1.0`.
    - If no table entry matches, prints an explicit unknown-mutator warning to the server console and applies nothing.
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
Rolls `RANDOM_LONG(0, INSTANT_MUTATOR_COUNT - 1)` over the file-local
`instant_mutator_e` enum in `gamerules.cpp` and applies a one-shot effect to
every live, non-observer, non-disconnected player. Each `case` uses the enum
name; the numeric value is what the server log prints
(`Instant mutator "<n>" enabled`). To add one, append an `INSTANT_*` entry
with the next explicit value just before `INSTANT_MUTATOR_COUNT` (the roll
range follows automatically) and add its `case`:
- 0 `INSTANT_NOTHING`: no-op announcement.
- 1 `INSTANT_PLUS_1_HEALTH`: `+1` HP (clamped to max_health).
- 2 `INSTANT_SWAP_HEALTH_ARMOR`: swap HP ↔ armour (skips god-mode players).
- 3 `INSTANT_PLUS_100_HEALTH`: `+100` HP.
- 4 `INSTANT_PLUS_100_ARMOR`: `+100` armour.
- 5 `INSTANT_1_HEALTH`: HP → 1 (skips god-mode).
- 6 `INSTANT_NICE`: HP=armour=69 ("Nice!").
- 7 `INSTANT_SIX_SEVEN`: HP=armour=67 ("Six, seeeeven!").
- 8 `INSTANT_HOT_POTATO`: spawns a live timed `CGrenade` in front of each player.
- 9 `INSTANT_RANDOM_DAMAGE`: `TakeDamage(RANDOM_FLOAT(10,20), DMG_SLASH)` (skips god-mode).
- 10 `INSTANT_TRIPMINE`: places a `monster_tripmine` if a valid surface is in front of the player.
- 11 `INSTANT_PET_SNARK`: spawns a friendly `monster_snark` in front of each player.
- 12 `INSTANT_PET_CHUMTOAD`: spawns a `monster_chumtoad` — but only if the current mode allows
  `MUTATOR_CHUMXPLODE` (this gate is checked once at the top of the case; if it
  fails, the entire case is skipped).
- 13 `INSTANT_HUMAN_ASSASSIN`: spawns a `monster_human_assassin` in front of the player.
- 14 `INSTANT_EXTRA_AMMO`: grants a current-weapon ammo bonus to each eligible player
  when the equipped weapon has a valid primary ammo type.
- 15 `INSTANT_ACCEPT_ALL_COOKIES`: opens the cookie consent wall on each eligible
  human player (see §3.3.1).
- 16 `INSTANT_BSOD`: opens the blue screen of death on each eligible human
  player (see §3.3.2).
- 17 `INSTANT_REMOVE_FUNC`: removes every entity of one random `func_*` class
  present on the map until the next map change (see §3.3.3).

Every path finishes by broadcasting `CLIENT_SOUND_CHICKEN` (unless the case
cleared `broadcastChicken`; `INSTANT_ACCEPT_ALL_COOKIES` and `INSTANT_BSOD`
do, see §3.3.1 / §3.3.2) and a
`gmsgChaos(mutatorTime)` refresh (so the chaos-bar animates even in "instant
only" configurations).

### 3.3.1 `Accept All Cookies` cookie wall
A gag instant mutator that interrupts play with a fake cookie consent dialog.
It is not a `MUTATOR_*` entry: it cannot be added with `sv_addmutator`, voted,
or filtered per mode, and is only reached through the random roll above (or
through the `INSTANT MUTATORS` vote winner, which calls `AddInstantMutator()`).

- **Server (`gamerules.cpp`, `INSTANT_ACCEPT_ALL_COOKIES`).** For each player that is alive, not
  `IsSpectator()`, not `IsObserver()`, not `HasDisconnected` and not
  `FL_FAKECLIENT`, sends `MSG_ONE gmsgCookies` with `BYTE allowDisconnect`.
  The byte is `0` for the listen-server host (`!IS_DEDICATED_SERVER() &&
  index == 1`), because a host `disconnect` would shut the match down for
  everyone. Then prints `[Mutators] Accept All Cookies!` to chat.
- **Client message.** `TeamFortressViewport::MsgFunc_Cookies` stores the flag
  on the panel and calls `ShowVGUIMenu(MENU_COOKIES)`. HLTV spectators
  (`IsSpectateOnly`) ignore it. The normal `ShowVGUIMenu` rules apply: no
  menu during intermission or demo playback, and no duplicate if a wall is
  already open. `ShowCookiesMenu` also refuses to open (the wall is skipped,
  not queued) while any other menu is up.
- **Panel (`cl_dll/vgui_CookiesWindow.cpp`, `CCookiesPanel`).** Created once
  in the viewport constructor and reused. A darkened full-screen layer holds
  a centred window with a title, a `CTFScrollPanel` of agreement text and two
  buttons at the bottom: `Accept All Cookies` (left) and the slightly
  fainter `Reject All Cookies` (right). Mouse wheel scrolling uses the shared
  `HandleScrollPanelMouseWheel` path with wheel forwarding on the text. The
  window border picks up `HudColor()` and the scroll position resets to the
  top on every `Open()`. The game keeps running underneath, and while a VGUI
  menu is up the cursor replaces mouselook, which is the point.
- **Sound.** `Open()` plays `acceptall.wav` (`sound/acceptall.wav`, listed in
  `workspace/manifest`, asset supplied separately). As with the BSOD, the
  case clears `broadcastChicken` and sends the chicken `MSG_ONE_UNRELIABLE`
  only to connected human players who did not get the wall, so it cannot
  cut the wall's sound off.
- **Choices.** Clicks within 0.5 s of opening are ignored (stale fire-button
  state, same rule as `CMenuHandler_StringCommandClassSelect`). Accept closes
  the wall with `HideTopMenu()`. Reject closes it and runs `disconnect` on
  the client; with `allowDisconnect == 0` (listen host) Reject only closes it.
- **Votes take priority.** If a vote panel (`MENU_VOTE*`) opens while the
  wall is the top menu, `ShowVGUIMenu` closes the wall first so the vote is
  never stuck behind it. `TeamFortressViewport::Initialize` (level change)
  closes it through `HideVGUIMenu()`.
- **Localization (`redist/titles.txt`).** `Cookies_Title`, `Cookies_Accept`,
  `Cookies_Reject` and `Cookies_Agreement`. The agreement is read with
  `CHudTextMessage::LookupString` (no 1024-byte buffer limit), carriage
  returns are stripped and the text is wrapped by VGUI; each paragraph is one
  line in `titles.txt` (keep lines under the engine's 512-character line
  buffer) separated by blank lines.

### 3.3.2 `bsod` blue screen of death
A gag instant mutator that throws a fake system crash over the player's view.
Like §3.3.1 it has no `MUTATOR_*` entry and is only reached through the random
instant roll (or the `INSTANT MUTATORS` vote winner).

- **Server (`gamerules.cpp`, `INSTANT_BSOD`).** Same eligibility as the cookie
  wall (alive, not `IsSpectator()`, not `IsObserver()`, not
  `HasDisconnected`, not `FL_FAKECLIENT`). Sends an empty `MSG_ONE gmsgBSOD`
  and prints `[Mutators] Blue Screen of Death!` to chat. Nothing is
  destructive, so the listen-server host gets the same screen.
- **Client message.** `TeamFortressViewport::MsgFunc_BSOD` calls
  `ShowVGUIMenu(MENU_BSOD)`; HLTV spectators ignore it. `ShowBSODMenu` skips
  (does not queue) while any other menu is up, and the usual intermission /
  demo / duplicate rules apply.
- **Panel (`cl_dll/vgui_BSODWindow.cpp`, `CBSODPanel`).** Created once in the
  viewport constructor and reused. `paintBackground` fills the whole screen
  with opaque classic BSOD blue `(0, 0, 170)`, covering the world and HUD. A
  gray title block with blue text (`Title Font`, sized to the localized text
  plus padding) is centred near the top; white `Briefing Text` body text fills
  the screen below it (plain `TextPanel`, wrapped, no scrolling, so keep the
  body short enough for 640x480). The `Failed Successfully` `ColorButton`
  sits bottom-right: white text and border, inverting to blue text on white
  when hovered.
- **Sound.** `Open()` plays `bsod.wav` (`sound/bsod.wav`) through the
  client `PlaySound`, so it fires when the screen actually becomes visible.
  The usual instant-mutator chicken shares that local sound channel and would
  cut it off, so `INSTANT_BSOD` skips the `MSG_BROADCAST` chicken
  (`broadcastChicken = FALSE`) and sends it `MSG_ONE_UNRELIABLE` only to
  connected human players who did not get the screen (dead, spectating).
  The file is listed in `workspace/manifest`; the source asset and its
  `Build-Sound.ps1` `Compile-Sound` line are supplied separately.
- **Dismiss.** Clicks within 0.5 s of opening are ignored (same stale
  fire-button rule as the cookie wall); the button then closes the screen
  with `HideTopMenu()`. Keys do nothing, despite what the text claims.
- **Votes take priority.** `ShowVGUIMenu` closes the screen when a
  `MENU_VOTE*` panel arrives, and `TeamFortressViewport::Initialize` closes
  it on level change.
- **Localization (`redist/titles.txt`).** `BSOD_Title`, `BSOD_Button` and
  `BSOD_Body`. The body is read with `LookupString`, CRs are stripped, and
  each paragraph or register line is one line in `titles.txt`.

### 3.3.3 `Remove func_*` map brush purge
A server-only instant mutator that deletes one kind of map brush entity for
the rest of the map. Like §3.3.1 it has no `MUTATOR_*` entry and is only
reached through the random instant roll (or the `INSTANT MUTATORS` vote
winner).

- **Keyed list.** `g_RemovableFuncClasses[]` in `gamerules.cpp` lists every
  `func_*` classname the server DLL links (34, alphabetical), taken from the
  `LINK_ENTITY_TO_CLASS` lines in `bmodels.cpp`, `buttons.cpp`, `doors.cpp`,
  `func_break.cpp`, `func_tank.cpp`, `h_battery.cpp`, `healthkit.cpp`,
  `mortar.cpp`, `plats.cpp`, `triggers.cpp` and `vehicle.cpp`. Each key has an
  optional `loopSound`. Add new `func_*` classes here when they are linked.
  `func_rain` / `func_snow` are only looked up by `player.cpp` weather code and
  are not linked, so they are not in the list.
- **Roll.** `RemoveRandomFuncClass()` collects the keys that have at least one
  live entity (not `FL_KILLME`) on the current map and picks one at random,
  so every roll removes something. `func_traincontrols` and
  `func_vehiclecontrols` remove themselves once they link to their train, so
  they only come up when that link failed. With no key present it prints
  `[Mutators] Remove func_*: nothing left to remove!`.
- **Removal.** Every live entity of the chosen class goes through
  `UTIL_Remove`, so `UpdateOnRemove` runs and `targetname` is cleared in the
  same frame (triggers firing at it find nothing). Chat gets
  `[Mutators] Remove func_*: <classname> was removed!` and the log gets
  `Instant mutator "Remove func_*" removed <n> "<classname>"`. The usual
  chicken broadcast and chaos-bar refresh follow.
- **No restore.** Nothing is saved or respawned; the next map change spawns
  everything again from the BSP. Round restarts do not bring removed
  entities back. In single player a level restored from a save on a return
  trip keeps the removal, and removing a progression entity (`func_button`,
  `func_door`, `func_tracktrain`, ...) can soft-lock the level.
- **Sounds.** Looping `CHAN_STATIC` sounds keep playing on clients after
  their entity is freed, so each entity gets `STOP_SOUND` on `CHAN_STATIC`
  before removal for: the key's `loopSound` (charger loops
  `items/medcharge4.wav` / `items/suitcharge1.wav`), and, only while it is
  moving (`velocity` or `avelocity` non-zero), every `pev->noise`..`noise3`
  sample ending in `.wav` (door/plat/train move loops, `func_rotating` fans,
  tank rotate sound, track train and vehicle engines). Stops are reliable
  broadcasts, so the moving-only filter keeps their number small.
- **Removal hardening** (also applies to `killtarget` and any other
  `UTIL_Remove`):
  - `CFuncTank::UpdateOnRemove` calls `StopControl()`, so a player manning
    the tank gets the weapon and weapon HUD back and `m_pTank` cleared.
  - `CFuncTankLaser::UpdateOnRemove` turns its `env_laser` off; only the
    tank's `Think` does that, so a beam fired that frame would stay lit.
  - `CFuncTankControls` stores its tank as `EHANDLE m_hTank` (was raw
    `CFuncTank *m_pTank`, `FIELD_CLASSPTR`), so using the controls after the
    tank is gone does nothing. The save field was renamed, so an older SP
    save loses the controls-to-tank link.
  - `CPlatTrigger` (the unnamed trigger a `func_plat` / `func_platrot`
    spawns) stores `EHANDLE m_hPlatform`; once the platform is gone the
    trigger removes itself on its next touch.
  - `CFuncTrackTrain::UpdateOnRemove` clears `m_train` and resets `m_code`
    to `TRAIN_SAFE` on every `func_trackchange` / `func_trackautochange` that
    pointed at it, so they keep working as plain elevators.
    `CFuncTrackAuto::Use` now tolerates `m_train == NULL`.
  - `CFuncTrackChange::UpdateOnRemove` zeroes the velocity of a train it is
    carrying mid-move; the train would otherwise drift on the platform's
    velocity forever. The train is left stopped with no path.
- **Already safe without changes.** Riders/drivers (`PFLAG_ONTRAIN`) leave
  train mode on the next `PreThink` once `groundentity` no longer resolves;
  `CFuncVehicle::m_pDriver` dies with the vehicle;
  `CBaseEntity::UpdateOnRemove` clears node-graph door links (`FL_GRAPHED`);
  the gravity gun holds an `EHANDLE`; bots check `pBotPickupItem->free`
  before using chargers.
- **Mode filters.** None. Instant mutators have no `MutatorAllowed` path, so
  it can roll in every mode, including single player.

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
   - `SLIDE` on → force-start Selaco slide on active players;
     off → force-end Selaco slide immediately (`EndSelacoSlide(TRUE)`).
     The off path keys on `m_fSelacoForced`, which `StartSelacoSlide(TRUE)`
     sets; keep those two in sync or the teardown becomes dead code.
   - Call `GiveMutators(pl)` to hand out mutator-granted weapons.
   - `INVISIBLE` on/off → `MakeInvisible` / `MakeVisible`.
   - `STOMPONHEAD` on → force live active players to `pev->gravity = 0.70`;
     off → restore players at exactly that value to `1.0` (except Shidden
     dealters, which own `0.70` natively).
   - `999` on → force HP/armour/max to 999; off → clamp back to 100 unless the
     player is `IsArmoredMan` or virus-flagged.
   - `JEEPATHON` / `TOILET` → force body/bodygroup indices.
   - `NOCLIP` on → `MOVETYPE_NOCLIP`; off → snap back to spawn (kills
     bystanders inside a 64-unit sphere, kills the player if hull traces solid).
   - `GODMODE` on → set `FL_GODMODE`; off → clear (but not on `FL_NOTARGET`
     snowmen — they keep god-mode).
  - `HALFLIFE` toggles `HIDEHUD_ICE` and sends `gmsgHideWeapon`.
    Client-side visual resolvers treat `HIDEHUD_ICE` as a hard override:
    weapon model index is forced to normal and HEV sleeves are forced to orange.
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
- Per player: `STOMPONHEAD` applies Shidden-style low gravity (`0.70`) to
  live non-spectators while active (with Shidden-dealter-safe restore on
  disable), `TINNITUS` writes physinfo `prop=2` (footstep silencer), and
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
- `MUTATOR_STOMPONHEAD` → per-life low-gravity baseline (`pev->gravity = 0.70`).
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
| `MUTATOR_EXPCROWBAR` | `weapon_crowbar` (no `SelectItem` — see §3.21) |
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

### 3.9.1 `triplebang` central burst dispatch (`weapons.cpp::ItemPostFrame`)
`MUTATOR_TRIPLEBANG` is implemented in the shared attack dispatch path instead
of weapon-by-weapon custom code:
- For bullet-style and projectile-launcher weapons, one eligible
  primary/secondary trigger starts a queued burst: first shot fires
  immediately, then follow-up shots fire every `0.15s` (scaled by weapon speed
  multiplier) until three shots are fired.
- While the queue is active, manual attack input is masked so the next trigger
  cannot start until the burst finishes.
- Ammo accounting stays at **one trigger's cost** by snapshotting clip + reserve
  ammo before the first shot, replaying follow-up shots from the pre-shot state,
  then restoring the post-first-shot ammo state.
- Exemptions are handled centrally for high-risk classes (placeables,
  utility/melee, and complex charge/beam weapons) to avoid breaking arm/disarm,
  charge-up, or toggle-style behavior. Current exemptions include
  chainsaw, gravitygun/ashpod,
  egon, and placeables/throwables
  (handgrenade/satchel/tripmine/snark/chumtoad/snowball/vest/nuke).
- Burst queue state is mirrored in `cl_dll/hl/hl_weapons.cpp` for prediction and
  synchronized through `weapon_data_t` side channels:
  `m_iWeaponState` (signed pending count / attack mode), `m_flPumpTime`
  (pre-shot clip), `m_fNextAimBonus` (pre-shot primary reserve), and
  `m_flNextReload` (pre-shot secondary reserve).
- Non-timed eligible weapons retain the immediate multi-dispatch fallback in
  the same central path so generic mutator behavior remains intact.

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

### 3.12 `floorislava` floor detection and burn timing
`MUTATOR_FLOORISLAVA` lives in `player.cpp` because floor contact is a
per-player runtime condition, not a global world-cvar toggle.

Detection strategy is intentionally **map-agnostic** (no per-map texture lists):
- Requires `FL_ONGROUND` so the engine's movement system decides whether the
  player is standing on something.
- Rejects ladder and deep-water states (`IsOnLadder`, `waterlevel >= 2`) so
  climbing/swimming does not trigger lava burns.
- Accepts world/brush supports (`worldspawn`, `SOLID_BSP`, or
  `FL_WORLDBRUSH`) from `pev->groundentity`.
- Falls back to a short downward trace when `groundentity` is absent or
  ambiguous; requires an upward-facing plane normal (`normal.z >= 0.35`) and
  the same world/brush test.

When contact is valid, a per-player cooldown (`m_flFloorIsLavaTime`) reapplies
burn at fixed cadence (0.75 s). Each pulse extends `m_fBurnTime` by a small
amount, which feeds the existing `PlayerBurn()` timed-fire pipeline.

### 3.12.1 shared rune + `regen`/`ammoregen`/`vampire` tick in player post-think
`CBasePlayer::PostThink` calls `HandleSharedRuneAndRegenThink`, so periodic
rune behavior and mutator regen/ammoregen/vampire now run in every mode (including
single-player), not only multiplayer gamerules.

- Scope guard: alive, connected, non-spectator players with `deadflag == DEAD_NO`.
- Rune paths moved from multiplayer gamerules: `RUNE_VAMPIRE`, `RUNE_REGEN`,
  and `RUNE_AMMO`.
- `MUTATOR_REGEN`: every eligible player gets rune-style +1 pulses (health
  first, then armor), on a 1-second cadence.
- `MUTATOR_AMMOREGEN`: every eligible player gets rune-ammo-style +1 active
  weapon ammo pulses (primary first, then secondary), excluding `weapon_nuke`,
  on a 1-second cadence.
- `MUTATOR_VAMPIRE`: player damage applies rune-vampire-style lifesteal pulses
  (half the health the victim actually lost, clamped by max health on apply).
  It works against both players and monsters.
- If a player already has `RUNE_REGEN` or `RUNE_AMMO`, the matching mutator
  branch skips that player to avoid double-stacking.
- `MUTATOR_VAMPIRE` and `RUNE_VAMPIRE` share the same pending-heal channel
  (`m_fVampireHealth`), so damage events do not double-award lifesteal.
- Credit is accrued in exactly one place, `combat.cpp::AccrueVampireHealth`,
  called from `CBaseMonster::TakeDamage` right after `pev->health -= flTake`.
  It credits `healthBefore - max(healthAfter, 0)`, so rejected friendly fire
  (`FPlayerCanTakeDamage`), armor absorption, godmode / spawn protection, the
  headshot clamp and overkill never heal. It accumulates (`+=`), so every
  pellet and every victim in a frame counts; `Spawn()` clears it. Do not
  re-add credit in `TraceAttack`: that runs before all of those checks and
  used to overwrite per pellet. Because the hook is on `TakeDamage`, blast,
  burn and other non-trace damage drains too, for the rune as well.

### 3.13 `stomponhead` head-hit instagib + low gravity
`MUTATOR_STOMPONHEAD` reuses the proven Shidden stomp envelope in
`player.cpp::CheckHeadStomp` but removes team-role restrictions:

- Any alive, non-spectator player with sufficient downward landing speed can
  trigger the stomp.
- Any alive, non-spectator target player within the stomp sphere can be
  stomped (no team checks).
- Uses the same spatial checks as Shidden (`48u` search radius and
  `victim_z <= stomper_z + 36`) so head-contact feel remains familiar.
- Kill path is direct `Killed(..., GIB_ALWAYS)` for deterministic gibbing.

Gravity tuning mirrors Shidden's low-gravity feel so stomps are easier to
land: while active, players are held at `pev->gravity = 0.70` (applied on
spawn and re-applied in think/update paths).

### 3.14 `victor` fragger-owned weaponbox pull
`MUTATOR_VICTOR` is implemented in the server weaponbox path
(`player.cpp::PackDeadPlayerItems`, `weapons.cpp::CWeaponBox`) and affects only
death-dropped `weaponbox` entities.

- On player death, if the killer is a live player, the victim's death-drop
  weaponbox is tagged with that killer as the *victor target*.
- While tagged, the box switches to `MOVETYPE_NOCLIP` and glides toward the
  victor (same smooth velocity-lerp style as coldskulls magnetism, but always
  aimed at the killer).
- During this glide window, touch is locked to that victor only; all other
  players are ignored.
- The pull automatically stops and the box drops (`MOVETYPE_TOSS`) when:
  - the victor dies/disconnects,
  - the mutator is disabled,
  - or 10 seconds elapse without a successful pickup.
- World drops that are not `weaponbox` (runes, item entities, etc.) are not
  part of this mutator.

### 3.15 `pacifist` kill-credit inversion
`MUTATOR_PACIFIST` is implemented in `multiplay_gamerules.cpp::PlayerKilled`
and applies to player-vs-player kills (including vehicle-driver kills after
driver resolution).

- The victim gets `+1` frag.
- The victim's death count is not incremented.
- The killer does not gain or lose frag credit from that kill path.
- Suicide and world-kill paths keep their normal behavior.
- LMS and Chilldemic keep their mode flow logic, but skip their victim-frag
  reset/penalty when `pacifist` is active so the victim reward is preserved.

### 3.15.1 `fragswap` frag-score exchange
`MUTATOR_FRAGSWAP` is implemented in the shared scoring path
`multiplay_gamerules.cpp::PlayerKilled` and applies to eligible
player-vs-player kills.

- Eligibility matches frag-credit kills: post vehicle-driver resolution,
  non-suicide, revive not pending, and headshot gate passed when
  `MUTATOR_HEADSHOT` is active.
- The scorer captures pre-kill frag values for attacker and victim.
- Normal killer frag reward is still computed (base reward + assist bonus +
  first-blood bonus), then redirected:
  - victim frag becomes `attackerPreFrags + killerFragDelta`
  - attacker frag becomes `victimPreFrags`
- If both `pacifist` and `fragswap` are enabled, fragswap takes precedence for
  that kill path.
- Mode compatibility guards preserve the swap in modes that normally clear or
  penalize victim frags around death handling (LMS, Chilldemic, Horde,
  PropHunt, Shidden).

### 3.16 `revive` one-life instant rebirth
`MUTATOR_REVIVE` is implemented across `player.cpp::TakeDamage`,
`player.cpp::PlayerDeathThink`, and
`multiplay_gamerules.cpp::PlayerKilled`.

- On a lethal player-vs-player hit, `TakeDamage` marks a pending revive and
  stores the victim's death origin/angles if that player has not used revive
  during the current spawn.
- While pending, `PlayerKilled` suppresses score impact for that kill path:
  killer gains no frag credit and victim death count does not increment.
- On the next `PlayerDeathThink` tick, the victim's inventory is dropped/packed
  using normal death rules, then `Spawn()` is called with in-place respawn
  (`m_bSkipSpawnPointSelect = TRUE`) and position restored to the death point.
- After in-place respawn, linear/base/angular velocity are zeroed so the revived
  player regains footing instead of carrying pre-death momentum.
- Rebirth visuals are emitted via `TE_TELEPORT` at death/reappear locations,
  plus a short blue screen-fade pulse.
- `m_bMutatorReviveUsed` is set after the respawn so subsequent lethal hits in
  that same life behave as normal deaths.
- `Spawn()` resets revive usage state, so each new spawn gets exactly one
  revive again.
- Mode-specific `PlayerKilled` overrides that apply elimination/conversion
  side-effects (LMS, Chilldemic, Horde, Shidden, etc.) short-circuit when
  revive is pending so the first lethal kill does not advance mode end-state.
- `m_bMutatorPendingRevive` is armed in `TakeDamage` *before* the damage is
  actually applied, so both `TakeDamage` (post-apply) and the headshot veto in
  `Killed` disarm it again when the victim survives the "lethal" blow.
  Otherwise an unrelated later death would consume the revive.
- `PlayerDeathThink` re-checks `MutatorEnabled(MUTATOR_REVIVE)` so disabling
  the mutator between the arming hit and the death falls through to the normal
  death sequence, matching every gamerules callsite.

### 3.17 `headshot` kill gate
`MUTATOR_HEADSHOT` is implemented in the shared PvP scoring path in
`multiplay_gamerules.cpp::PlayerKilled`, with hit validation metadata sourced
from `player.cpp::TraceAttack`.

- Shared player damage (`player.cpp::TakeDamage`) clamps non-headshot lethal
  PvP damage to leave the victim at 1 HP, so ordinary PvP kills cannot finish
  unless the validating hitgroup is head.
- PvP kill scoring requires a validated headshot final blow from the killer.
- Non-headshot PvP deaths still follow normal death flow, but frag credit is
  blocked for that kill event.
- Direct-kill paths that bypass regular damage aggregation (for example some
  weapon/entity `Killed()` calls) are guarded in `player.cpp::Killed` with the
  same validator so mutator behavior remains consistent. That guard keeps the
  victim alive, so scripted instant-kill mechanics must re-check `IsAlive()`
  after calling `Killed()` before announcing a kill (see `CheckHeadStomp`).
- The veto path also clears `m_bMutatorPendingRevive` and
  `m_bChilldemicPendingConvert`, because the victim is not dying after all.
- Pacifist/revive integration is preserved: pacifist victim-frag inversion
  applies only when the kill also satisfies the headshot requirement; revive
  still suppresses scoring as before.
- Applies uniformly across game modes because almost all mode-specific
  `PlayerKilled` overrides delegate to `CHalfLifeMultiplay::PlayerKilled`.

### 3.18 `drunk` continuous camera disorientation
`MUTATOR_DRUNK` is implemented client-side in `cl_dll/view.cpp` so core
gameplay logic (movement speed, weapon behavior, scoring, collision) remains
unchanged.

- Active only for alive, first-person, non-spectator players.
- Applies continuous sinusoidal offsets to pitch/yaw/roll each frame so the
  view never settles.
- Adds periodic punch-angle bursts when the current punch magnitude decays below
  a threshold (`< 15`) to keep the motion erratic and disorienting.
- Uses the existing punch-angle decay pipeline (`V_DropPunchAngle`), mirroring
  the legacy "keep spinning while punch is low" style without server-side
  state mutation.

### 3.19 `sleepy` periodic blackout pulse
`MUTATOR_SLEEPY` is implemented server-side in `dlls/player.cpp::CBasePlayer::PostThink`
and applies a periodic HUD fade to simulate nodding off.

- Runs only while the mutator is active.
- Applies only to active human players: non-bot (`!FL_FAKECLIENT`),
  non-spectator, alive, and `deadflag == DEAD_NO`.
- Uses a per-player timer (`m_flSleepyTime`) so each player gets a fade every
  `SLEEPY_TIME` seconds (3.0 s): `UTIL_ScreenFade(this, Vector(0,0,0), 1.75f,
  0.1f, 255, FFADE_IN)`.
- Works across game modes because it sits in the shared player post-think path;
  round-based pause/restore still applies normally via the existing mutator
  list lifecycle.

### 3.20 `rocketjump` low-self-damage rocket mobility
`MUTATOR_ROCKETJUMP` is implemented in the shared damage path
`dlls/combat.cpp::CBaseMonster::TakeDamage`, so it applies uniformly across
all game modes.

- Applies only to **self-inflicted** blast damage (`DMG_BLAST`) where the
  attacker and victim are the same player.
- Applies only when the blast inflictor classname is a rocket projectile
  (`rpg_rocket` or `rocketcrowbar`).
- Caps self-damage health loss to 12.
- Keeps blast impulse and adds extra lift when the rocket detonates below the
  player (vertical offset scaled boost), making intentional downward shots jump
  higher.
- Removes `DMG_BURN` for the qualifying self-rocket blast so rocket-jumping
  does not ignite the shooter or apply post-jump burn ticks.

### 3.21 `expcrowbar` explosive crowbar
`MUTATOR_EXPCROWBAR` lives almost entirely inside `dlls/crowbar.cpp`; only the
weapon grant and the redeploy hook sit in `dlls/gamerules.cpp`. It applies in
every game mode (no `MutatorAllowed` filter) and affects no weapon other than
`weapon_crowbar`.

- **Grant.** `GiveMutators` hands out `weapon_crowbar` to every alive player
  that does not already own one. Unlike the other weapon-granting mutators it
  deliberately does **not** call `SelectItem`, so the player's current weapon
  is untouched.
- **Visual identity.** `CCrowbar::Deploy` / `DeployLowKey` delegate to
  `CCrowbar::DeployExplosive`, which deploys `models/v_rocketcrowbar.mdl` and
  then sets `m_pPlayer->pev->team = WEAPON_ROCKETCROWBAR - 1` — the p_weapons
  bodygroup selector that `DefaultDeploy` normally fills with `m_iId - 1`, so
  the override has to happen after the base call.
  `CCrowbar::Precache` precaches the rocket-crowbar view model
  unconditionally; without it a mid-round toggle leaves the player with no
  viewmodel because `MODEL_INDEX` returns 0 for an unprecached model.
- **Model-slot arbitration with `snarkbar`.** The swap is gated on
  `ExplosiveCrowbarModelActive()` = `expcrowbar && !snarkbar`. `snarkbar`
  needs the throw, and the rocket-crowbar model has no throw sequence, so when
  both mutators run the stock `models/v_crowbar.mdl` is kept and the throw and
  charged smash stay live. The blast still fires in both cases. The toggle
  fix-up loop in `MutatorsThink` evaluates the same condition, otherwise it
  would redeploy every tick chasing a model `Deploy()` will never pick.
- **Toggle handling.** The per-player fix-up loop in the
  `m_flDetectedMutatorChange` apply block re-`Deploy()`s the active item when
  it is `weapon_crowbar` and `pev->viewmodel` does not match the model the
  current mutator state wants. The string comparison keeps it idempotent, so
  unrelated mutator churn does not cause redeploy spam, and mutator expiry
  restores `models/v_crowbar.mdl` plus the crowbar p_weapons index.
- **Blast.** `ExplosiveCrowbarBlast()` (server-only) fires from
  `CCrowbar::Swing()` on any connecting swing and from
  `CFlyingCrowbar::SpinTouch()` on any thrown-crowbar impact: `100` damage in
  a `250u` radius, `DMG_BLAST | DMG_BURN`, standard `TE_EXPLOSION` visuals
  with the usual `icesprites` fireball split and scorch/paintball decal.
  `RadiusDamage` is called with `ignoreAttacker = TRUE`, so the swinger or
  thrower never takes damage or impulse from their own blast. Teammates are
  not exempt.
- **Throw / smash fallback (temporary).** `CCrowbar::SecondaryAttack()` (throw)
  and `CCrowbar::Reload()` (charged smash) redirect into `PrimaryAttack()`
  while the model swap is active, so every button just swings:
  `v_rocketcrowbar.mdl` ships only sequences `0..11` and has no `pull_back` /
  `throw` animation, so the real modes would play a clamped, wrong pose. Each
  redirect mirrors the cooldown `Swing()` set into the field the base
  `ItemPostFrame` branch re-syncs from, keeping the swing cadence normal. The
  gates sit after the GunGame redirect so GunGame behaviour is unchanged.
  Adding the two sequences to the rocket-crowbar QCs is the only thing needed
  to restore the real modes — the `flying_crowbar` blast path is already wired.
- Full mechanics reference:
  [weapons.md → Explosive Crowbar](weapons.md#explosive-crowbar-expcrowbar-mutator).

### 3.22 `exploder` random player detonation
`MUTATOR_EXPLODER` lives entirely in
`dlls/gamerules.cpp::CGameRules::ExploderMutatorThink()`, called once per second
from the `m_flAddMutatorTime` block of `MutatorsThink()`. It is server-only,
allowed in every game mode, and grants nothing.

- **Per-player fuse.** Each eligible player carries `CBasePlayer::m_flExploderTime`,
  a `gpGlobals->time` deadline seeded with `RANDOM_FLOAT(EXPLODER_MIN_FUSE,
  EXPLODER_MAX_FUSE)` (4–45 s), so detonations can be sudden or take a long
  while. `0` means unscheduled.
- **Eligibility.** Only players that are alive, not observers
  (`pev->iuser1 == 0`), `deadflag == DEAD_NO`, and not `FL_GODMODE` are armed.
  Anyone failing the test has their fuse reset to `0`, so respawning re-rolls a
  fresh fuse instead of inheriting a stale deadline. Nothing tracks the field
  across map changes — `m_flExploderTime` is a plain member defaulted to `0`.
- **Percentage roll.** When the fuse expires the player gets a
  `EXPLODER_CHANCE` (35 %) roll. Win or lose, the fuse is immediately
  re-randomised, so a survivor keeps ticking.
- **Blast.** A winning roll calls
  `CGrenade::Vest(pPlayer->pev, pPlayer->pev->origin, EXPLODER_BLAST_DAMAGE)`
  — the same helper the explosive vest and the `volatile` mutator use. The
  grenade's owner is the exploding player, so `RadiusDamage` hits the player
  themself plus everyone inside the derived `damage * 2.5` radius (140 damage /
  350 units). Death notices resolve the inflictor classname to `vest`.
- **Pausing.** `MutatorsThink()` returns early while `m_bMutatorsPaused`, so
  round intermissions stop the fuses without any extra wiring; the next tick
  after the round resumes reschedules them.

### 3.23 `fadetoblack` low-health risk/reward
`MUTATOR_FADETOBLACK` is implemented across shared server damage flow and
client HUD draw code so it behaves consistently in every mode.

- **Server damage scaling (`dlls/combat.cpp::CBaseMonster::TakeDamage`).**
  Damage gets scaled when the attacker is a player who is alive, active, and
  not observing (`IsAlive`, `deadflag == DEAD_NO`, `iuser1 == 0`, not
  `IsObserver()`), and attacker/victim are different entities.
- **Damage curve.** Multiplier is `1.0 + (missingHealth^2 * 2.0)`, so output
  stays 1x at full health and ramps toward 3x at near-zero health.
- **Client blackout (`cl_dll/hud_redraw.cpp`).** The local player receives a
  fullscreen black alpha-blended GL quad overlay whose alpha uses a blended linear+
  quadratic missing-health ramp and caps at `235/255` so near-death is almost black but still
  faintly visible.
- **Mode filters.** No mode-specific `MutatorAllowed` blacklist entries were
  added, so `fadetoblack` remains eligible in all mutator-enabled modes.

### 3.24 `nelliaschoice` danger-key roulette
`MUTATOR_NELLIASCHOICE` is implemented server-side in `dlls/gamerules.cpp` with
per-frame trigger checks in `dlls/player.cpp::CBasePlayer::PreThink`, so the
effect is authoritative and applies in every mode.

- **Activation roll.** On mutator enable (or restore without existing state),
  the server picks one key from a fixed non-movement set:
  `IN_USE`, `IN_ATTACK2`, `IN_RELOAD`, `IN_ALT1`, `IN_IRONSIGHT`, `IN_SCORE`.
  `g_NelliaChoiceButtons[]` uses those macros directly — do not re-declare the
  bit values, because this mod moves `IN_ALT1` to `1 << 16` and defines
  `IN_IRONSIGHT` as `1 << 14`, which is not the stock HLSDK layout.
- **Announcement.** The selected key is center-printed to all clients as
  `<KEY> is the danger key!` and logged server-side.
- **Persistence.** The chosen key remains fixed for the full active lifetime of
  the mutator.
- **Trigger path.** If an alive, active, non-observer player presses the chosen
  key edge (`m_afButtonPressed`), the server detonates them (`CGrenade::Vest`)
  and force-kills any survivor state to guarantee the effect resolves.
- **Reroll policy.** Deactivating `nelliaschoice` clears the stored key; a later
  reactivation rolls a fresh danger key.

`Nellia's Choice` was proposed by the alias `Nellia`.

### 3.25 `myfavtexture` world texture swap
`MUTATOR_MYFAVTEXTURE` is client-only and lives in
`cl_dll/mutator_myfavtexture.cpp`. The server only carries the name-table
entry; no `MutatorAllowed` filter, so it is allowed in every mode and in the
Chaos pool.

- **Mechanism.** The world model (`GetEntityByIndex(0)->model`) owns the
  `textures[]` list that brush submodels share, so one pass covers world and
  `func_*` entities. The SDK `com_model.h::texture_t` is the *software*
  layout; the hardware renderer stores `int gl_texturenum` right after
  `width`/`height` (offset 24). The file mirrors only those leading fields in
  `hw_texture_t` (static-asserted) and overwrites `gl_texturenum`. `sky` is
  skipped; masked `{` and water `!` textures are swapped too.
- **Texture source.** Const holders `kMyFavTextureWad` (`halflife.wad`) and
  `kMyFavTextureName` (`AAATRIGGER`). The WAD is loaded once via
  `COM_LoadFile`, parsed with full bounds checks (WAD3 magic, lump type
  `0x43`, no compression, mip0 + palette inside the lump) and cached as RGBA.
  On any failure, or when the name is `*checker`, a 32x32 black/magenta
  checker (16-texel cells) is generated instead — the engine's own
  "missing texture" is not a WAD lump. The chosen source is logged once.
- **Uniform density.** World UVs are normalized to each original texture's
  size, so the replacement is uploaded as variants holding a whole number of
  source repetitions per original span (`round(orig / src)`, min 1, capped at
  1024 texels). Wrap stays seamless and density is ~1:1 texel; originals
  smaller than the source show a shrunk pattern. Variants are cached by
  repetition count (max 64), mipmapped by box filter, `GL_REPEAT`, and the
  previous `GL_TEXTURE_BINDING_2D` / `GL_UNPACK_ALIGNMENT` are restored.
- **Safety gate.** Before writing, at least 90% of non-sky textures must hold a
  unique id that `glIsTexture` accepts; otherwise the map is logged and
  skipped (no writes). No-op on Xash (`g_fXashEngine`, where the field is an
  index), on non-OpenGL renderers (`IEngineStudio.IsHardware() != 1`), and on
  macOS.
- **Lifecycle.** `MyFavTexture_Frame` reconciles every rendered frame against
  `MutatorEnabled(MUTATOR_MYFAVTEXTURE)`, so add, expiry, `clear` (254),
  round pause/restore and late join need no `MsgFunc_AddMut` / expiry /
  `InitHUD` kickoffs. Restore only writes originals back while the swap is
  still *live* (same world, same `textures` array/count, same entries, each
  still holding our id); otherwise the map was reloaded and the state is
  discarded without writing.
- **Known side effects.** Detail textures likely drop off swapped surfaces (the
  engine appears to key them by GL id), fences/grates render solid, and the
  upload skips the engine's `texgamma`, so brightness can differ slightly
  from stock textures.
- **Extending.** Per-texture randomization would pick a source per
  `texture_t` inside `ApplySwap` and key variants by source as well.

### 3.26 `goldeneye` 007 health / armor bars
`MUTATOR_GOLDENEYE` is client-only and lives in
`cl_dll/mutator_goldeneye.cpp`. The server only carries the name-table entry;
no `MutatorAllowed` filter, so it is allowed in every mode and in the Chaos
pool. The HUD icon alias reuses the `goldenguns` rect.

- **HUD removal.** While `GoldenEye_Active()`, `CHudHealth::Draw` skips the
  cross icon, health number and the thin separator bar, and
  `CHudBattery::Draw` returns before the suit icon and armor number.
  `DrawDamage` (damage-type tiles) and `DrawPain` (direction arrows) still run.
- **Bars.** Two arcs centred on the screen: health bends on the left (`(`),
  armor on the right (`)`). Each arc is 8 segments, five short ticks under
  three long blocks, spanning -50°..51° from the horizontal (angles measured
  off the N64 reference HUD). Radii are `0.42`..`0.52` of
  `min(ScreenHeight, ScreenWidth * 0.75)`, centre dropped `0.03` of that, so
  the arcs stay round on any aspect ratio and scale with resolution. HUD sway
  (`g_xP`/`g_yP`) is applied to the centre.
- **Fill.** Fill follows arc length (gaps excluded), bottom to top, so the top
  segment can be partially lit. Bright part (alpha 235) = current value, dim
  part (alpha 70) = remaining capacity. Max is 100 (999 while `999` is
  active); values above max clamp to full. Per-vertex gradients sampled from
  the reference: health `(255,224,60)` -> `(235,40,20)`, armor
  `(172,226,255)` -> `(21,22,255)`.
- **Real-time animation.** Geometry is tessellated every frame (≤ 2° quad
  strips). The shown fill eases toward the live value
  (`1 - exp(-dt * 6)`), so a hit visibly drains the bar. On pop-in the arcs
  sweep in bottom-to-top over 0.2 s, hold 2.5 s after the last hit, then fade
  out over 0.5 s. While hidden the shown fill snaps to the live value, so
  the next hit drains from the pre-hit amount.
- **Triggers.** `CHudHealth::MsgFunc_Damage` (when `dmg_take` or
  `dmg_save` > 0) and any health decrease in `MsgFunc_Health` (covers direct
  sets such as the instant "1 health"). Pickups, regen and respawn do not
  show the bars. The server sends no `Damage` message for `FL_GODMODE`.
- **Lifecycle.** `CHudHealth::Reset` (ResetHUD on every spawn) hides the
  bars; a show timer that sits in the future after a client-clock restart is
  dropped. Expiry, `clear` (254), pause/restore and late join need no
  kickoffs because `GoldenEye_Active()` reads `MutatorEnabled` every frame.
  `nohud`, `HIDEHUD_HEALTH`, spectate-only and suit-less players follow the
  normal `CHudHealth` gating.
- **Rendering.** Raw GL inside `CHudHealth::Draw`, wrapped in
  `glPushAttrib(ENABLE|COLOR_BUFFER|CURRENT|LIGHTING|TRANSFORM)` plus pushed
  projection/modelview matrices, so no state leaks into later HUD passes.
  `GoldenEye_Active()` is false on macOS and when
  `IEngineStudio.IsHardware() != 1`, so those clients keep the classic
  numbers instead of losing the health display.
- **negativepi.** Degree-to-radian conversion uses the mutator-aware `M_PI`,
  so with `negativepi` the arcs shrink to roughly ±16° and flip top/bottom,
  same as the other HUD consumers that route through `M_PI`.

### 3.27 `linemode` GoldenEye 007 Line Mode
`MUTATOR_LINEMODE` is client-only and lives in
`cl_dll/mutator_linemode.cpp`. The server only carries the name-table entry;
no `MutatorAllowed` filter, so it is allowed in every mode and in the Chaos
pool. The HUD icon alias reuses the `oldtime` rect.

- **Look.** Recreates the N64 hidden Line Mode: the whole 3D view is painted
  white and only geometric edges are inked black — silhouettes of players,
  monsters, items, projectiles and the viewmodel against what is behind them,
  plus creases of the world and brush entities (wall corners, floor/wall
  seams, steps, door frames, crate edges, pipe facets). Textures, lighting,
  decals and anything that does not write depth (sprites, particles, beams,
  most additive/blended surfaces) wash out to white. The HUD is untouched.
- **Two hooks.** `LineMode_CaptureScene` runs from
  `tri.cpp::HUD_DrawNormalTriangles`, the only client callback where the
  world projection is current. It records `GL_VIEWPORT`, `GL_DEPTH_RANGE`,
  `far/(far-near) = (1 - P[10]) / 2` and the view-space tangent per pixel
  `2 / (|P[0]| * viewportWidth)` from `GL_PROJECTION_MATRIX`. Non-perspective
  passes (`P[11] > -0.5`, spectator overview) are ignored; when several passes
  render in a frame (spectator inset) the largest viewport wins.
  `LineMode_Draw` runs at the top of `cdll_int.cpp::HUD_Redraw` (after
  `gPortalRenderer.DrawPortal`, before `gHUD.Redraw`), when the finished 3D
  frame, including the viewmodel, is still in the back buffer with its depth.
  The capture flag is consumed every `HUD_Redraw`, so a frame without a
  perspective 3D pass draws nothing.
- **Edge test.** The depth buffer is copied with `glCopyTexSubImage2D` into a
  `GL_DEPTH_COMPONENT24` `GL_TEXTURE_2D` (nearest, clamp, resized with the
  viewport) and a full-screen GLSL 1.10 quad samples it. Window depth is
  affine in `1/z`, so it is exactly linear across any plane in screen space.
  For each pixel the shader takes the absolute second difference of depth
  along the horizontal, vertical and both diagonals at `step` pixels and keeps
  the largest. Dividing by `far/(far-near) - depth` (proportional to `1/z`)
  turns it into a change of screen-space surface slope, so planar surfaces at
  any distance or grazing angle stay white while creases and depth jumps
  light up. `smoothstep(T, 2T)` with
  `T = LINEMODE_CREASE_SLOPE (0.5) * step * tanPerPixel` grades the ink:
  bends of about 27° head-on start to show and 45°+ creases and every
  silhouette are solid black. Samples past the viewport border report no bend,
  so the screen frame does not get an outline.
- **Line weight and noise.** `step = max(1, round(viewportHeight / 720))`, so
  lines are about 2 px at 720p, 4 px at 1080p/1440p and 6 px at 4K. A noise
  floor of `LINEMODE_DEPTH_ULPS (6)` depth-buffer quantization steps (from
  `GL_DEPTH_BITS`, clamped 16..24, scaled by the captured depth range) is
  subtracted first, which also fades weak creases out naturally with
  distance. Depth is normalized by the captured `glDepthRange`, so
  `gl_ztrick`'s alternating reversed half-ranges map back to `0..1`.
- **Viewmodel.** GoldSrc squeezes the viewmodel into the first 30 % of the
  depth range, which is still affine, so its planes stay white; its
  silhouette inks strongly but interior creases read about an order of
  magnitude weaker than world creases, leaving mostly an outline of hands
  and gun.
- **GL plumbing.** GL 2.0 entry points (`glCreateShader`..`glUniform2f`,
  `glActiveTexture`) are resolved once through `SDL_GL_GetProcAddress`
  into a file-local table with explicit `__stdcall` on Windows; constants are
  `#ifndef`-guarded because Windows `GL/gl.h` is 1.1 while Linux headers
  already carry them. The program is built lazily on first active frame and
  re-validated with `glIsProgram`; the texture with `glIsTexture`. Each draw
  saves `GL_CURRENT_PROGRAM` / `GL_ACTIVE_TEXTURE` and wraps everything in
  `glPushAttrib(ENABLE|COLOR_BUFFER|DEPTH_BUFFER|TEXTURE|VIEWPORT|POLYGON|SCISSOR)`
  so the engine's cached texture binding and the later HUD/VGUI passes see
  unchanged state. Fixed-function fog and texture enables are irrelevant
  under the fragment shader.
- **Failure handling.** Missing entry points, compile/link errors (info log is
  printed) or a rejected depth copy (checked with `glGetError` after clearing
  stale errors, once per texture allocation; e.g. a multisampled read buffer)
  print `linemode: <reason>, effect disabled` and switch the effect off for
  the rest of the session, leaving normal rendering. No-op on Xash
  (`g_fXashEngine`), on non-OpenGL renderers
  (`IEngineStudio.IsHardware() != 1`) and on macOS (stubs).
- **Lifecycle.** Both hooks read `MutatorEnabled(MUTATOR_LINEMODE)` every
  frame, so add, expiry, `clear` (254), pause/restore and late join need no
  `MsgFunc_AddMut` / expiry / `InitHUD` kickoffs. GL objects persist across
  maps; nothing is restored when the mutator ends because nothing in the
  engine was modified.
- **Interactions.** Effects drawn later in `HUD_Redraw` apply on top of the
  line image: `blur` smears it (§3.28), `mirror` flips it, `fadetoblack` darkens it, and with
  `cl_screeneffects 1` the colour corrector inverts it for `inverse` (white
  lines on black) and tints it for `sildenafil`; `oldtime` has no visible
  effect on a black/white image. Screen fades or tints the engine composites
  before `HUD_Redraw` are likely washed out.
- **Tuning.** `LINEMODE_CREASE_SLOPE` (lower = more interior lines),
  `LINEMODE_LINE_SCALE` (lower = thicker lines) and `LINEMODE_DEPTH_ULPS`
  (higher = fewer far-distance lines) at the top of the file.

### 3.28 `blur` motion blur
`MUTATOR_BLUR` is client-only and lives in `cl_dll/mutator_blur.cpp`, a port
of GSChaos' `CFeatureBlur` onto the mod's mutator pattern. The server only
carries the name-table entry; no `MutatorAllowed` filter, so it is allowed in
every mode and in the Chaos pool. The HUD icon alias reuses the `drunk` rect.

- **Look.** Classic frame-feedback (accumulation) motion blur: anything that
  moves on screen, including the view itself when turning, leaves a trail
  that fades over roughly a tenth of a second. A still view stays sharp.
  The HUD is untouched.
- **One hook.** `Blur_Draw` runs at the top of `cdll_int.cpp::HUD_Redraw`
  right after `LineMode_Draw` and before `gHUD.Redraw`, when the finished 3D
  frame (including the viewmodel and any Line Mode image) is in the back
  buffer and the HUD is not. GSChaos hooks `SwapBuffers` instead, which also
  smears the HUD.
- **Per frame.** With the `GL_VIEWPORT` current at `HUD_Redraw` (the 2D
  full-window viewport): (1) draw the history texture as a full-viewport quad
  over the new frame with `glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)`
  and `glColor4f(1,1,1,decay)` under `GL_MODULATE`, so the frame becomes
  `decay * history + (1 - decay) * current`; (2) `glCopyTexSubImage2D` the
  result back into the history texture.
- **Decay.** GSChaos curve,
  `decay = 0.9^(frameTime * 100) * 0.66667 + 0.3`: 0.9 at 100 fps, ~0.86 at
  60 fps, ~0.93 at 200 fps (ceiling ~0.97). GSChaos derives frame time from `fps_max`; the
  port measures it with `gEngfuncs.GetAbsoluteTime()` because `fps_max` is
  only a cap (and can be 0). Tunables are `BLUR_*` at the top of the file.
- **History texture.** One `glGenTextures` name on
  `GL_TEXTURE_RECTANGLE_NV` (pixel texcoords, same target as `colorcor.cpp`
  and the portal renderer), `GL_RGB8`, nearest, clamp-to-edge, reallocated
  when the viewport size changes and re-validated with `glIsTexture`. RGB on
  purpose: GoldSrc's frame buffer alpha is not meaningful and an RGBA copy
  (as in GSChaos) would skew the blend. Nearest filtering keeps the feedback
  loop from drifting or softening a static image.
- **Reseeding.** The first active frame, a new allocation, a viewport change,
  a negative frame time or a gap above `BLUR_MAX_FRAME_GAP` (0.25 s: loading,
  alt-tab, hitches) skip the blend and only copy the current frame, like
  GSChaos' `ActivateFeature`. Every inactive frame clears the primed flag, so
  re-enabling never shows a stale image.
- **GL state.** The whole pass is wrapped in
  `glPushAttrib(ENABLE|COLOR_BUFFER|CURRENT|DEPTH_BUFFER|TEXTURE|POLYGON|TRANSFORM)`
  plus pushed projection/modelview matrices (identity, NDC quad), so the
  engine's cached texture binding, colour, blend and matrix mode are
  unchanged for the HUD/VGUI passes. Fixed-function only: no shader or
  extension entry points, assumes texture unit 0 like `colorcor.cpp` and
  `CHud::Mirror`.
- **Failure handling.** The copy is checked with `glGetError` once per texture
  allocation (after draining stale errors); a rejection (multisampled read
  buffer, no rectangle texture support) prints
  `blur: frame buffer could not be copied, effect disabled` and switches the
  effect off for the session. No-op on Xash (`g_fXashEngine`), on non-OpenGL
  renderers (`IEngineStudio.IsHardware() != 1`) and on macOS (stub).
- **Lifecycle.** Reads `MutatorEnabled(MUTATOR_BLUR)` every frame, so add,
  expiry, `clear` (254), pause/restore and late join need no
  `MsgFunc_AddMut` / expiry / `InitHUD` kickoffs. Nothing in the engine is
  modified, so nothing is restored when it ends.
- **Interactions.** `linemode` runs first, so its line image is blurred.
  Effects drawn later in `HUD_Redraw` act on the blurred image (`mirror`
  flips it, `fadetoblack` darkens it, `cl_screeneffects` colour correction
  tints/inverts it) and are not themselves smeared. `drunk`/`upsidedown`
  camera motion smears heavily, by design.
- **Known limit.** Blending into an 8-bit back buffer quantizes the feedback:
  a difference of under about `0.5 / (1 - decay)` levels (~5 at 100 fps,
  ~15 at very high frame rates) can stop decaying, leaving a faint ghost
  until that area of the screen changes. Same behaviour as GSChaos.

---

## 4. Wire protocol

The server drives the client over five user messages. All names are ≤ 8
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

### `gmsgCookies` — cookie wall (instant mutator)
`MSG_ONE`, single `BYTE allowDisconnect` (`0` for the listen-server host).
Handled in `TeamFortressViewport::MsgFunc_Cookies`, opens `CCookiesPanel`
(`MENU_COOKIES`). See §3.3.1.

### `gmsgBSOD` — blue screen of death (instant mutator)
`MSG_ONE`, no payload (registered with size `0`). Handled in
`TeamFortressViewport::MsgFunc_BSOD`, opens `CBSODPanel` (`MENU_BSOD`).
See §3.3.2.

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
  `UPSIDEDOWN` (roll +180), `AMIDEAD` (roll +80), `DRUNK` (continuous sway +
  periodic punch kicks), `TOPSYTURVY` in singleplayer (roll 180 while alive).
  `MINIME` also adjusts view height.
- **Input inversion (inputw32.cpp + input.cpp):** `MIRROR`, `TOPSYTURVY`,
  `UPSIDEDOWN` flip mouse axes appropriately so the world stays controllable.
  `NOMOUSE` suppresses mouse look and mouse buttons for alive, active,
  non-spectator players only.
- **Post-process (colorcor.cpp):** `OLDTIME` and `INVERSE` (colour negation /
  black-and-white), `ASTRONAUT` (blue tint), `SILDENAFIL` (blue boost).
- **HP blackout (hud_redraw.cpp):** `FADETOBLACK` draws a fullscreen black
  overlay using missing-health percentage for alive active non-observer local
  players, capped just below fully black. `DrawFadeToBlackOverlay` restores
  `GL_TEXTURE_2D`, `GL_DEPTH_TEST` and `glColor4f(1,1,1,1)` before returning —
  the raw-GL HUD passes and VGUI that run after it inherit this state.
- **World textures (mutator_myfavtexture.cpp):** `MYFAVTEXTURE` swaps every
  world/brush `texture_t` GL id to a tiled replacement texture and restores
  the originals when the mutator ends (§3.25).
- **Health/armor HUD (mutator_goldeneye.cpp, health.cpp, battery.cpp):**
  `GOLDENEYE` hides the health/armor numbers and icons and draws GoldenEye
  007 curved segmented bars for a few seconds after each hit (§3.26).
- **Line Mode (mutator_linemode.cpp, tri.cpp, cdll_int.cpp):** `LINEMODE`
  copies the depth buffer after the 3D view and redraws it as black edge
  lines on white with a GLSL pass before the HUD (§3.27).
- **Motion blur (mutator_blur.cpp, cdll_int.cpp):** `BLUR` blends the
  previous blurred frame over the finished 3D view and copies the result back
  as history, before the HUD (§3.28).
- **Cookie wall (vgui_CookiesWindow.cpp):** instant mutator 15 opens the
  `CCookiesPanel` VGUI menu from `gmsgCookies` (§3.3.1).
- **Blue screen (vgui_BSODWindow.cpp):** instant mutator 16 opens the
  `CBSODPanel` VGUI menu from `gmsgBSOD` and plays `bsod.wav` (§3.3.2).
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

Newly added mutators:
- `fadetoblack` (`MUTATOR_FADETOBLACK`) is a global risk/reward mutator with
  HP-based client blackout and low-health outgoing damage scaling (documented
  in §3.23).
- `nelliaschoice` (`MUTATOR_NELLIASCHOICE`) assigns a random non-movement danger
  key that detonates the pressing player (documented in §3.24).
- `nohud` (`MUTATOR_NOHUD`) suppresses all client HUD/crosshair rendering except
  the mutator's own status icon.
- `myfavtexture` (`MUTATOR_MYFAVTEXTURE`) renders one replacement texture on
  every world/brush surface (documented in §3.25).
- `goldeneye` (`MUTATOR_GOLDENEYE`) replaces the health/armor numbers with
  GoldenEye 007 styled curved bars shown briefly when hurt (documented in
  §3.26).
- `linemode` (`MUTATOR_LINEMODE`) renders GoldenEye 007's hidden Line Mode,
  black traced edges on a white world (documented in §3.27).
- `blur` (`MUTATOR_BLUR`) renders frame-feedback motion blur on the 3D view
  (documented in §3.28).

### Chaos / meta
| ID | Name | Scope | Effect | Filtered by |
|---:|---|---|---|---|
| 1 | `chaos` | S | Not a real mutator — enabling it starts the periodic chaos cadence (`m_flChaosMutatorTime`). Cleared with `unchaos`. | — |
| 103 | `three` | S | Not a mutator — special token in `sv_addmutator` that fires `AddRandomMutator` three times. | — |

### Movement / physics (world cvars or physinfo)
| ID | Name | Scope | Effect |
|---:|---|---|---|
| 5 | `astronaut` | SC | `sv_gravity = 199`; client colour-cor slight blue tint. |
| 9 | `bigfoot` | S | `sv_stepsize = 192`. |
| 38 | `ice` | S | Per-spawn `friction = 0.3`; slippery movement. |
| 47 | `lightsout` | S | Lightstyle 0 blackout, force flashlight on, sky→(1,1,1). |
| 49 | `longjump` | S | Grants `item_longjump`. |
| 54 | `megarun` (physinfo `haste=1`) | SC | Player haste; pm_shared reads `canHaste`. |
| 61 | `noclip` | S | `MOVETYPE_NOCLIP` for players; kills bystanders on off-toggle. |
| 63 | `nomouse` | C | Disables mouse look and mouse buttons for alive, active, non-spectator players; dead/spectator and UI flows are unaffected. |
| 76 | `pushy` | S | `WeaponMutators` gives -recoil impulse on every shot. |
| 87 | `sanic` | C | Replaces player model with sanic sprite. |
| 90 | `skyhook` | S | Grappling-hook-style gameplay tweak (`AllowGrapplingHook`). |
| 92 | `slide` | S | Forces alive active players into continuous Selaco slide loops; each cycle restarts immediately while active, and removal force-breaks active slides. |
| 93 | `slowbullets` | S | `sv_slowbullets = 2`. |
| 94 | `slowmo` | S | `sys_timescale = 0.49`. **Blocked in `MutatorAllowed` — treat as disabled.** |
| 98 | `speedup` | S | `sys_timescale = 1.49`. **Blocked in `MutatorAllowed`.** |
| 100 | `stomponhead` | S | Any active player who lands on another player's head instantly gibs the victim; players use Shidden-like low gravity (`pev->gravity = 0.70`) while active. |
| 101 | `superjump` | S | `sv_jumpheight = 299`. |
| 106 | `topsyturvy` (physinfo `topsy=1`) | SC | Player upside-down. **Blocked in `MutatorAllowed` for MP.** |
| 109 | `upsidedown` | C | View roll 180 + mouse inversion. |
| 114 | `waterhurt` | S | Any active non-spectator player touching water is instantly gibbed; checks `waterlevel > 0` and accepts `CONTENT_WATER` plus current-water contents (texture-independent water detection). |

### Combat modifiers
| ID | Name | Scope | Effect |
|---:|---|---|---|
| 2 | `999` | S | Force HP/armour/max_health to 999. Filtered by CtC, Instagib, Loot. |
| 3 | `amidead` | C | View roll 80° (drunken lean). |
| 6 | `autoaim` | S | Client-driven aim assist; off-toggle calls `ResetAutoaim`. |
| 7 | `barrels` | S/Weapon | Grants `weapon_gravitygun`; barrels become props. |
| 8 | `berserker` | S/Weapon | Grants `weapon_chainsaw`. |
| 12 | `busters` | S/Weapon | Grants `weapon_egon`. |
| 13 | `chumxplode` | S | Chumtoads explode; gated by CtC/Loot filters. |
| 14 | `closeup` | C | Force iron-sight FOV. |
| 16 | `cowboy` | S/Weapon | Grants `weapon_dual_sawedoff`. |
| 19 | `dealter` | S | Per-frame damage to non-suit players (rot effect). |
| 20 | `dontshoot` | S/Weapon | Grants `weapon_fingergun`; every trigger pull damages the shooter (see `WeaponMutators`). |
| 24 | `explosiveai` | S | Sets `g_ExplosiveAI`. **Blocked in `MutatorAllowed`.** |
| 26 | `fastweapons` | S | Weapon time-scaling. |
| 27 | `firebullets` | S | Ignites victims on hit. |
| 28 | `firestarter` | S/Weapon | Grants `weapon_flamethrower`. |
| 29 | `floorislava` | S | Standing on map floors/brushes ignites the player on a short cadence (timed burn via `PlayerBurn`). |
| 32 | `godmode` | S/Weapon | Sets `FL_GODMODE`; grants `weapon_vice` (special melee). |
| 34 | `goldenguns` | S | One-hit-kill damage bonus. Client also forces first-person weapon finish to gold (sleeve color remains independently resolved). |
| 35 | `grenades` | S | 1/11 fire chance to also throw a grenade. |
| 37 | `headshot` | S | Only a headshot final blow can kill another player; other lethal PvP hits are clamped to leave the victim at 1 HP and award no frag. |
| 39 | `infiniteammo` | S | `sv_infiniteammo = 2`. |
| 40 | `instagib` | S/Weapon | Grants `weapon_zapgun`. |
| 43 | `itemsexplode` | S | Weapons/items become destructible; iterates `entityList[]`. **Blocked in `MutatorAllowed`.** |
| 58 | `napkinstory` | S | (napkin_story reference — melee/scoring tweak.) |
| 60 | `nelliaschoice` | S | One non-movement key (`use`, `secondary attack`, `reload`, `alt1`, `ironsight`, `score`) is randomly selected while active; pressing that key detonates and kills the active non-observer player. |
| 59 | `negativepi` | SC | Central math override mutator: all shared PI references resolve to `-1.0` while active (server `dlls/util.h::M_PI`, client `cl_dll/hud.h::M_PI`, and PM shared math via `pm_shared/pm_math.c`). Server replicates state through player physinfo key `negpi` so prediction and server movement agree. Direct `2π`/`π/180` callsites route through `M_PI` (e.g. `napalm_pool.cpp`, `lifebar.cpp`, `radar.cpp`). |
| 65 | `noreload` | S | No reload cycles. |
| 67 | `notthebees` | S | Sets `m_iNotTheBees`; hornetgun swarms exit players on damage. |
| 69 | `pacifist` | S | Player-vs-player kills award +1 frag to the victim, do not increment victim deaths, and award no killer frag credit. |
| 70 | `paintball` | SC | Paintball-style hit FX. |
| 73 | `plumber` | S/Weapon | Grants `weapon_dual_wrench`. |
| 74 | `portal` | S/Weapon | Grants `weapon_ashpod`. |
| 77 | `railguns` | S/Weapon | Grants `weapon_dual_railgun` + full uranium. |
| 78 | `randomweapon` | S | `mp_randomweapon = 2`; per-spawn random loadout. |
| 81 | `revive` | S | First lethal player-vs-player frag per spawn immediately revives the victim in-place with default spawn loadout; killer gains no frag and victim gains no death increment. |
| 82 | `ricochet` | S | Bullets bounce (up to N ricochets). |
| 83 | `rocketbees` | S/Weapon | Grants `weapon_hornetgun`; bee projectiles explode. |
| 84 | `rocketcrowbar` | S/Weapon | Grants `weapon_rocketcrowbar`. |
| 85 | `rocketjump` | S | Self-fired rockets cap self-damage, get stronger lift when detonated below the player, and do not apply self-burn DOT from the blast. |
| 86 | `rockets` | S | 1/11 fire chance to also throw a rocket (via `ThrowRocket`). |
| 95 | `slowweapons` | S | Weapon time-scaling. |
| 97 | `snowballs` | S | 1/11 fire chance to also throw a snowball. |
| 99 | `stahp` | S | `UTIL_IsMovementBlocked` returns TRUE (see util.h) — freezes movement. |
| 96 | `snarkbar` | S/Weapon | Ensures players have `weapon_crowbar`; thrown `flying_crowbar` impacts spawn five owner-attributed `monster_snark` entities with collision-safe spawn retries near the contact point. |
| 107 | `triplebang` | S/SC | Central `ItemPostFrame` burst mutator: bullet-style, projectile-launcher, requested sci-fi projectile families (crossbow/freezegun/rpg, gauss, hornetgun, railgun including dual variants where applicable), fists, and melee (crowbar, rocketcrowbar, knife, wrench, dual wrench) fire three shots in queued succession (`~0.15s` between shots) with one-trigger ammo cost; other eligible weapons use immediate central fallback. |
| 108 | `turrets` | S | Auto-turrets fire at everyone. |
| 111 | `vested` | S/Weapon | Grants `weapon_vest` (explosive vest). |
| 112 | `victor` | S | Fragged player's dropped `weaponbox` glides to the fragger with victor-only pickup while active; pull ends on victor death/disconnect, mutator disable, or 10 s timeout. |
| 113 | `volatile` | S | Sets `m_iVolatile`; damage cascades. |

### Visual / HUD
| ID | Name | Scope | Effect |
|---:|---|---|---|
| 10 | `bighead` | C | Head/arm bones scaled 3× in `StudioModelRenderer`. |
| 11 | `blur` | C | Frame-feedback motion blur (GSChaos `CFeatureBlur` port): the previous blurred frame is blended over the finished 3D view and copied back as history before the HUD, so movement leaves fading trails. OpenGL only; other renderers draw normally (§3.28). |
| 15 | `coolflesh` | SC | Frostbite / freeze cosmetic. |
| 17 | `crate` | C | Player model becomes `models/box.mdl`. |
| 18 | `credits` | S | Enters "credits" mode on players (`m_iCreditMode = 1`). |
| 21 | `drunk` | C | Continuously sways/spins first-person view and injects periodic punch bursts for disorientation. |
| 30 | `fog` | S | Broadcasts `gmsgFog(50,200,125,125,125,0)`. |
| 33 | `goldeneye` | C | Removes health/armor numbers, icons and separator; GoldenEye 007 curved segmented health (left, yellow->red) and armor (right, light blue->blue) bars flash up for ~3 s when hurt, bright = current, dim = capacity. OpenGL only; other renderers keep the classic HUD (§3.26). |
| 36 | `halflife` | S | `HIDEHUD_ICE` hides Cold Ice HUD elements and forces vanilla first-person visual style (normal weapon + orange sleeves). |
| 41 | `inverse` | C | Colour-corrector negates output. |
| 42 | `invisible` | S | `MakeInvisible` / `MakeVisible` on players. |
| 44 | `jack` | C | Jack-in-the-box head cosmetic (blocked in PropHunt). |
| 45 | `jeepathon` | S | Every player becomes a jeep bodygroup. |
| 46 | `jope` | S | Player names swapped to "Jope"; original saved in info-key `j`. |
| 48 | `linemode` | C | GoldenEye 007 hidden Line Mode: the 3D view washes out to white and silhouettes/creases of the world, brush entities and models are traced in black via a real-time depth-buffer GLSL pass before the HUD. OpenGL 2.0 only; other renderers draw normally (§3.27). |
| 50 | `loopback` | S | Damage returns to the attacker (wormhole). |
| 51 | `marshmellow` | C | Marshmallow head (blocked in PropHunt). |
| 52 | `maxpack` | S | Max ammo pickups. |
| 53 | `mcclane` | C | View roll -180 permanently. |
| 55 | `minime` | C | Player model scaled to 0.5×, view offset. |
| 56 | `mirror` | C | Mouse X inverted; view mirrored. |
| 57 | `myfavtexture` | C | Every world/brush surface renders one replacement texture (`AAATRIGGER` from `halflife.wad`, checker fallback); OpenGL only (§3.25). |
| 62 | `nohud` | C | Hides all client HUD elements and crosshairs while still drawing only the left-side `nohud` status icon. |
| 64 | `noradar` | C | Hides radar HUD. |
| 66 | `notify` | S | Notification/phone effect. |
| 68 | `oldtime` | C | Black-and-white colour correction. |
| 71 | `paper` | C | Player bones flattened to 10 % Y-axis. |
| 72 | `piratehat` | C | Pirate cosmetic (blocked in PropHunt). |
| 75 | `pumpkin` | C | Pumpkin cosmetic (blocked in PropHunt). |
| 79 | `rats` | S | Spawns `monster_rat` entities with `iuser1 = MUTATOR_RATS`. |
| 88 | `santahat` | S/C | Santa cosmetic + periodic `next_santa_sound` (blocked in PropHunt). |
| 89 | `sildenafil` | C | Colour-corrector blue boost. |
| 91 | `sleepy` | S | Every 3 seconds, applies a black HUD fade pulse (`UTIL_ScreenFade`) to active human players (non-bot, non-spectator, `deadflag == DEAD_NO`). |
| 102 | `thirdperson` | C | `CAM_ToThirdPerson` on add; reverts on remove/clear (blocked in most round modes). |
| 104 | `tinnitus` | SC | Physinfo `prop=2` (footstep silencer) + client audio ducking + buzz loop. |
| 105 | `toilet` | S | Player becomes toilet or camera bodygroup (blocked in PropHunt). |

**Note:** Certain names in `g_szMutators[]` do not match their `MUTATOR_*`
identifier stem — e.g. `MUTATOR_MEGASPEED` uses the string `"megarun"`,
`MUTATOR_MARSHMELLO` uses `"marshmellow"`, `MUTATOR_NAPKIN` uses
`"napkinstory"`. When adding new mutators keep the mapping consistent between
`common/const.h`, `dlls/gamerules.cpp::g_szMutators[]`, and
`cl_dll/vgui_TeamFortressViewport.cpp::sMutators[]` — the three arrays are
addressed by `MUTATOR_* - 1` and must remain 1:1.

---

## 9. Adding a new mutator (checklist)

1. **ID (shared).** Insert the new mutator in alphabetical order in
   `common/const.h` (matching `g_szMutators[]` token order) and renumber every
   following `MUTATOR_*` define so IDs remain contiguous. Apply the same
   insert + renumber to the bot's copy in
   `workspace/grave-bot-src/common/const.h` (separate project, not picked up
   by the mod build, so drift is silent).
2. **Server name table.** Insert the internal string into the alphabetically
   correct position in
   `dlls/gamerules.cpp::g_szMutators[]`. Must be lowercase, unique, and match
   the substring compare used by `sv_addmutator` / `sv_chaosfilter` /
   `MutatorAllowed`.
3. **Client display table.** Insert `{ "name", "short description" }` at the
   same alphabetical/index position in
   `cl_dll/vgui_TeamFortressViewport.cpp::sMutators[]`. Do
   not reorder existing entries.
4. **Settings + command docs.** Update `workspace/redist/settings.scr` mutator
  list to insert the same mutator at the matching alphabetical position, and
  renumber every following numeric value.
  Also update `workspace/redist/server_commands.txt` under `sv_addmutator`
  with the same mutator name and a brief description, kept in alphabetical
  order with the surrounding mutators.
5. **Max sentinels.** Ensure sentinel macros point to the final mutator after
   renumbering (`MAX_MUTATORS` in `gamerules.h` and `MAX_MUTATORS_CL` in
   `common/const.h`).
6. **Filters.** Decide whether the mutator should be allowed in every mode.
   If not, add `strstr(mutator, g_szMutators[MUTATOR_FOOBAR - 1]) ||
   atoi(mutator) == MUTATOR_FOOBAR` return-`FALSE` blocks in the relevant
   `MutatorAllowed` overrides (and `CHalfLifeMultiplay::MutatorAllowed` if
   universally disabled). Add to `sv_chaosfilter` default if it should be
   opt-in only.
7. **Effect wiring.**
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
   - New source file (e.g. client `cl_dll/mutator_<name>.cpp` or
     `cl_dll/vgui_<Name>Window.cpp`): register it in all three build lists in
     the same change. Client: `src/projects/vs2019/hl_cdll.vcxproj`
     (`ClCompile`), `hl_cdll.vcxproj.filters` (`ClCompile` with
     `<Filter>Source Files\cl_dll</Filter>`), and `src/linux/Makefile.hl_cdll`
     (`$(HL1_OBJ_DIR)/<name>.o`). Server: `hldll.vcxproj`,
     `hldll.vcxproj.filters` (`Source Files\dlls`) and `src/linux/Makefile.hldll`.
     A file missing from `.filters` still builds, so the gap is silent; the
     `mutator_tinnitus`, `mutator_myfavtexture`, `mutator_goldeneye`,
     `mutator_linemode` and `mutator_blur` adds all missed it until 2026-10-14.
8. **VGUI vote panel.** No code change needed unless the mutator should be
   *hidden* from the vote grid; if so add a `strstr(sMutators[i].name, ...)`
   skip in `CVoteMutatorPanel` constructor (matching the existing
   slowmo/speedup/topsyturvy/itemsexplode/explosiveai list).
9. **Pause/restore.** Nothing to change — the pause system operates on IDs
   and TTLs, not on effects.
10. **Documentation.** Add a row to the catalogue in §8 and update any relevant
  spoke doc (`workspace/ai/voting_system.md`,
  `workspace/ai/gamerules.md`, mode-specific docs when the mutator is
  permanently associated with a mode). Also add/update the mutator entry in
  `workspace/redist/readme.txt` under the current version's New Mutators list
  with name + short description.
11. **Build.** Windows: `workspace/Build-Windows.ps1`. Linux:
   `workspace/build-linux.sh`. Both DLLs must rebuild (`ice.dll` and
   `client.dll`) so the shared const.h change is picked up on both sides.
   If the change added a source file, confirm the `.vcxproj` and
   `.vcxproj.filters` item lists still match (see the project audit snippet in
   [cir.md](cir.md#adding-a-source-file)).

---

## 10. Known pitfalls & invariants

- **Symmetric IDs and ordering.** `MUTATOR_*` values are on the wire. Keep
  `common/const.h`, `grave-bot-src/common/const.h`,
  `dlls/gamerules.cpp::g_szMutators[]`,
  `cl_dll/vgui_TeamFortressViewport.cpp::sMutators[]`, and
  `workspace/redist/settings.scr` mutator IDs synchronized. Canonical order is
  alphabetical; inserting a new mutator requires renumbering all later IDs in
  every one of those lists in the same change. Keep
  `workspace/redist/server_commands.txt` mutator bullets alphabetized too, with
  matching mutator names and descriptions, and update
  `workspace/redist/readme.txt` New Mutators release notes with the new mutator
  name/description.
- **HUD sprite declaration count.** The first line of
  `workspace/sprites/hud.txt` is the sprite declaration total. Any add/remove
  of a sprite alias (including mutator icons like `pacifist`) must update that
  number, or trailing entries can fail to load.
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
- **Removing map entities at runtime.** Stock brush classes keep raw pointers
  to each other (`CFuncTrackChange::m_train`, and before 2026-10-15
  `CFuncTankControls::m_pTank` and `CPlatTrigger::m_pPlatform`). Before a
  mutator deletes a class of map entity, check who points at it and give the
  target an `UpdateOnRemove` cleanup or the holder an `EHANDLE`. Stop looping
  `CHAN_STATIC` sounds first too; clients keep playing them after the entity
  is freed (§3.3.3).

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
