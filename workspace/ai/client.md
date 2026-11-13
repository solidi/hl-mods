# Client DLL — AI Context Hub

Everything that ships in `client.dll`. Source: `workspace/src/cl_dll/`. Built by `src/projects/vs2019/hl_cdll.sln`.

> Parent: [cir.md](cir.md). Use this as the launch point when the work is **client-side**: HUD components, VGUI menus, view models, prediction, message handlers.

## Architecture in One Picture

```
engine ──▶ HUD_Frame / HUD_Redraw / HUD_VidInit / HUD_PostRunCmd
              │
              ├──▶ gHUD (CHud)            — singleton in hud.{h,cpp}
              │     ├── m_pHudList         — linked list of CHudBase components
              │     │     (Health, Battery, Ammo, Radar, Banner, …)
              │     └── MsgFunc_<X>        — receives engine user messages
              │
              ├──▶ gViewPort (TeamFortressViewport*)
              │     ├── CMenuPanel*        — currently visible vgui menu
              │     │     (CClassMenuPanel, CTeamMenuPanel,
              │     │      CVoteGameplayPanel, CVoteMutatorPanel,
              │     │      CVoteMapPanel, …)
              │     └── MsgFunc_<X>        — UI-relevant user messages
              │
              └──▶ ev_hldm.cpp             — client-side weapon prediction events
```

## File Map (high-traffic)

- `hud.{h,cpp}` — `CHud`, the singleton HUD; `HOOK_MESSAGE` registry; engine callback wiring.
- `hud_msg.cpp` — message handlers that live on `CHud` itself (e.g. `MsgFunc_InitHUD`).
- `workspace/src/pm_shared/pm_shared.c` — shared movement/prediction runtime used by both client and server. See [pm_shared_system.md](pm_shared_system.md).
- `vgui_TeamFortressViewport.{h,cpp}` — the client viewport, all VGUI menus, all VGUI message handlers. See [vgui_system.md](vgui_system.md).
- `vgui_VoteMapWindow.cpp`, `vgui_VoteGameplayWindow.cpp`, `vgui_VoteMutatorWindow.cpp` — the gameplay/mutator/map vote panels.
- `vgui_VoteGameOptionsWindow.cpp`, `vgui_VoteServerOptionsWindow.cpp`, `vgui_VoteBotOptionsWindow.cpp` — per-row option vote panels (game/server options at intermission or RTV; bot options RTV only, see [bot_options_system.md](bot_options_system.md)).
- `lifebar.{h,cpp}` — player overhead lifebar sprites and floating damage numbers (attacker ownership emphasis). See [lifebar.md](lifebar.md).
- `ev_hldm.cpp` — client-side weapon firing/prediction events. New server weapons that fire visibly need an entry here, otherwise the local player sees lag.
- `hl/hl_events.cpp` — binds `events/*.sc` scripts to `EV_Fire*` callbacks.
- `parsemsg.{h,cpp}` — `BEGIN_READ` / `READ_BYTE` / `READ_STRING` helpers used by every `MsgFunc_*`.
- `particlemgr.cpp`, `particlesys.cpp`, `FlameSystem.cpp`, `particlemsg.cpp` — client particle/flame ownership, lifecycle, and toggles. See [particle_system.md](particle_system.md).
- `weapon_glow.cpp` — glow on world pickup weapons (`cl_weaponglow`). See [Pickup Weapon Glow](#pickup-weapon-glow).

## Weapon/Sleeve Visual Resolution

Client visuals now resolve weapon skin and HEV sleeve skin separately:

- User cvars:
    - `cl_weaponmodel` (`0..5`) controls the weapon finish.
    - `cl_sleevemodel` (`0..4`) controls the sleeve color.
- Runtime HUD fields in `CHud`:
    - `m_WeaponModelIndex`
    - `m_SleeveModelIndex`

Resolution helpers live in `util.cpp` / `cl_util.h`:

- `GetEffectiveWeaponModelIndex(modelName, forViewModel)`
- `GetEffectiveSleeveModelIndex()`
- `GetCombinedViewModelSkinIndex(modelName)`
- `UseIceVisualStyle()`

Effective precedence is:

1. `HALFLIFE` mutator (`HIDEHUD_ICE`) forces vanilla visuals:
     - weapon `SKIN_NORMAL`
     - sleeve `SLEEVE_ORANGE`
2. Team/game-mode sleeve forcing (red/blue/yellow/green contexts) overrides user sleeve cvar.
3. `GOLDENGUNS` (and GunGame knife special-case) force the **viewmodel weapon** to gold.
4. Otherwise user cvars apply directly.

Viewmodels use a combined skin row index:

- `combined = weaponIndex * 5 + sleeveIndex`
- This yields 30 texturegroup rows per `v_*.mdl` (6 weapon finishes x 5 sleeves).
- Compatibility fallback: if a viewmodel has fewer skin families than `combined`, client code falls back to weapon-only skin index until that model's QC is upgraded.

Non-viewmodel entities continue using weapon-only skin selection.

`UseIceVisualStyle()` is the central guard for ice-blue client effects (particles, muzzle flash variants, beam tint), so FX now respect mutator overrides without mutating user cvars.

## Iron Sight Attachment Contract

`V_IronSight` in `view.cpp` now requires the viewmodel studio header to declare both of these attachment slots:

- attachment `1`: iron-sight position (`aim_punch`)
- attachment `2`: iron-sight angle offsets (`aim_angles`)

If either slot is missing (for example, models that reuse attachment 1 for an alternate muzzle like sawedoff), client code skips iron-sight close-up/angle transforms and restores normal FOV behavior.

## Sleeve Texture Authoring Notes

Recent sleeve texture work introduced an authoring pattern for shared HD sleeve atlases:

- Base shared files like `models/hd/iceSleeve_*.bmp` and `models/hd/iceSleeveExt_*.bmp` are consumed by many HD viewmodels (and by some SD QCs through `..\\hd\\...` references).
- To keep neutral gray suit details consistent across colors, treat `iceSleeve_blue.bmp` / `iceSleeveExt_blue.bmp` as structure templates.
- Workflow for red/yellow/green variants:
    1. Keep each target texture's color regions.
    2. Copy only gray-like pixels from the blue template into the target.
    3. Save back as 8bpp indexed BMP.
- Keep source and target dimensions identical before merge; model compilers expect texture dimensions to stay stable.
- Build caveat: `Compile-Model` timestamp checks are model-folder local, so shared texture edits alone may be skipped. Touch affected QCs (or clean rebuild) before compiling to force MDL refresh.

## Hooking a New User Message

Three places to touch (see the existing `MapList` plumbing for the full pattern):

1. **`hud.cpp`** — declare `int __MsgFunc_<Name>(...)` (forwarder) and add `HOOK_MESSAGE(<Name>);` inside `CHud::Init`.
2. **`vgui_TeamFortressViewport.{h,cpp}`** — declare and implement `int TeamFortressViewport::MsgFunc_<Name>(...)`. Use `BEGIN_READ`, `READ_BYTE`, `READ_STRING`, etc.
3. **`player.cpp` (server side)** — register the `gmsg<Name>` slot inside `LinkUserMessages()`. **Name ≤10 chars**, ideally ≤8 (see [server.md → User-Message Registry](server.md#user-message-registry)).

If the message is large, chunk it (see the MOTD / MapList senders described in [server.md](server.md)).

## VGUI vs HUD: Which One Owns It?

- **HUD components** (`CHudBase` subclasses): drawn every frame by `CHud::Redraw`, immediate-mode, no input. Used for ammo, health, radar, banner, on-screen messages.
- **VGUI panels**: retained-mode widgets owned by `TeamFortressViewport`. Used for menus, scoreboard, vote panels. Anything that needs buttons, scrollbars, or focus belongs here.

Don't try to put a button in a HUD component, and don't draw the radar with VGUI. The schemes (fonts, colors, borders) are also separate — see the lesson in [cir.md](cir.md#cross-cutting-lessons).

## Localized Strings

Strings starting with `#` (e.g. `#Title_VoteMap`) are looked up in `resource/valve_english.txt` (and per-language siblings). At runtime use `gHUD.m_TextMessage.BufferedLocaliseTextString("#Foo")` to get the resolved text. If you ship a new `#`-prefixed key, update the `.txt` files.

## Third Person Body Fade

When the third person camera gets close to the controlled player, the player's own model turns see-through so it does not cover the fight. It turns solid again as the camera moves back. This happens when walls push the camera in, or when the camera distance is set short (`cam_idealdist`, `+camin`, `+camdistance`). Only this client sees it. Nothing is networked, and other players see the model as the server sends it.

- **Distance.** `V_CalcNormalRefdef` (`view.cpp`) measures the eye to the final camera origin, after the `CAM_Think` wall pull-in and the shoulder offset trace. It calls `CAM_UpdateBodyFade`. First person, intermission and spectating call `CAM_ResetBodyFade` (solid).
- **Curve** (`in_camera.cpp`). Solid at `CAM_FADE_SOLID_DIST` (56) and above. Down to `CAM_FADE_MIN_ALPHA` (0.3) at `CAM_FADE_CLEAR_DIST` (20) and below. The value moves toward its target at `CAM_FADE_SPEED` (4 alpha per second), using client time. Extra views in the same frame (`nextView`, portals) do not advance it. The default `cam_idealdist` of 60 stays solid, and the shortest distance (30) stays at about 0.55.
- **Translucent pass.** `HUD_AddEntity` calls `CAM_ApplyBodyFade`. If the local player is `kRenderNormal`, its client-side `curstate` becomes `kRenderTransTexture` / 255 so the engine sorts it into the translucent list. A blended body drawn in the opaque pass would hide everything drawn after it. The server values are stored, and `HUD_Redraw` puts them back with `CAM_RestoreBodyFade` once every 3D pass of the frame is done. A restore only happens if the values still match the override, so a network refresh in between wins. Bodies that are already translucent from the server (invisibility, death fade) are not touched. Dead players (`curstate.health <= 0`) are skipped.
- **Draw.** `CStudioModelRenderer::StudioRenderModel` asks `CAM_GetBodyFade` and sets the body pass with `IEngineStudio.StudioSetRenderamt(serverBlend * alpha)`. `serverBlend` is 255 for a solid body, otherwise the server `renderamt`. This covers the player model, the p_ weapon and hats (crate and Prop Hunt models too). The glow shell pass goes back to its normal blend, and its thickness goes back into `renderamt`. Server transparency is scaled, never replaced. On exit the entry `renderamt` is restored.

## Pickup Weapon Glow

Weapons lying in the world glow so they are easier to spot in a fight (after the Boltgun pickups). This covers map spawned weapons and dropped weapon boxes. It is client only and nothing is networked. `cl_weaponglow` (default `1`, archived) turns it on or off. Code: `weapon_glow.cpp`.

- **What counts as a pickup.** `WeaponGlow_IsPickup` checks for a non-player entity with one of these models: `w_weapons.mdl`, `w_satchel.mdl`, `v_tripmine.mdl`, `w_grenade.mdl` or `w_portalgun.mdl`. It must also be `MOVETYPE_TOSS` + `SOLID_TRIGGER`, which is a landed `CBasePlayerItem` (`Materialize`) or a `CWeaponBox`. Thrown, grabbed and projectile uses of the same models are `BOUNCE` / `BOUNCEMISSILE` / `SOLID_BBOX`, so they do not glow. A weapon that is still falling (`FallInit` sets `SOLID_BBOX`) starts glowing once it lands. A victor magnet box (`NOCLIP`) does not glow.
- **Prop Hunt is excluded.** Props disguise as `w_weapons.mdl` / `w_ammo.mdl` items, so a glow on the real pickups would give every prop away. Props are drawn through `StudioDrawPlayer` and would never glow.
- **Model lighting** (`StudioDrawModel`). After `StudioDynamicLight`, `WeaponGlow_Lighting` raises the floor to at least 112 ambient and 96 shade. The model still keeps the map's light colour and direction.
- **Environment light.** `WeaponGlow_Add` (called after `StudioRenderModel`) gives a pickup within 512 units a small dlight in the HUD colour (see Colour below). The radius is about 72 and pulses slowly. The dlight is keyed `0x5747 + entindex`, so the same slot is reused every frame. At most 8 are added per view, which leaves slots for muzzle flashes. None are added in the xray second view.
- **Colour.** `WeaponGlow_Colors` looks up `HudColor()` (`util.cpp`) in `kPalettes[]`. Each entry pairs an `RGB_*` HUD colour with a starburst tint and a dlight colour:

  | HUD colour | Starburst (additive) | Dlight |
  |---|---|---|
  | `RGB_YELLOWISH` (orange or yellow sleeves, Half-Life override, yellow team) | gold 1.00 0.78 0.35 | 160 125 55 |
  | `RGB_REDISH` (red sleeves, red team, buster, virus) | 1.00 0.32 0.22 | 170 45 30 |
  | `RGB_GREENISH` (green sleeves, green team, chumtoad holder) | 0.40 1.00 0.35 | 60 150 50 |
  | `RGB_BLUEISH` (blue sleeves, the `cl_sleevemodel 1` default) | 0.35 0.72 1.00 | 55 115 180 |
  | `RGB_ORANGEISH` (loot carrier) | 1.00 0.55 0.18 | 170 85 30 |
  | `RGB_PURPLEISH` / `RGB_MAGENTAISH` / `RGB_WHITEISH` | 0.70 0.38 1.00 / 1.00 0.38 1.00 / 0.92 0.95 1.00 | 110 50 160 / 150 55 150 / 130 130 135 |

  The last row covers the colours `HudColor()` does not return today; status icons use them. The starburst tints are lifted toward white, because a fully saturated additive tint looks muddy. The dlights are toned down to about the same brightness. A HUD colour without an entry falls back to `0.3 + 0.7 * hud` for the starburst and `0.6 * hud` for the light. If you add a new HUD colour, add a palette row. The starburst looks up the colour once per view and the dlight once per light, so a team or sleeve change shows up on the next frame. `HudColor()` only sends `con_color` and tracer commands when the colour changes, so calling it here costs nothing extra.
- **Starburst** (`WeaponGlow_TransparentTriangles`, from `HUD_DrawTransparentTriangles` just before `XRay_TransparentTriangles`). The world space bounds of the drawn submodel come from the bone transforms (`StudioDrawnBounds`) and set the centre and size (radius 10..36). The pickup is queued once per entity, and the queue is drawn and cleared once per view. The pass uses raw GL: `#ifndef __APPLE__`, hardware only, `glPushAttrib` / `glPopAttrib`. It draws additive, depth tested and without depth writes, with no texture and with `GL_FOG` off, because additive glow under fog would add the fog colour. The camera axes come from the current modelview, so xray, portal and mirror views line up. There are three camera facing triangle fans: a soft core and two counter-rotating serrated rings. Each ring has hashed tip lengths, and the tips fade out while the valleys stay dim. The burst sits 0.4 radii behind the model centre, so the opaque weapon covers it. It fades in between 32 and 96 units from the eye and fades out between 1024 and 1536 units.
- **Pi.** `M_PI` in this client follows the `negativepi` mutator (`hud.h`). Geometry that must stay round uses its own constant (`WEAPONGLOW_PI`).

## Where Things Render

| What | Where to look |
|------|--------------|
| Menus (vote, class, team, …) | [vgui_system.md](vgui_system.md) |
| Cookie consent wall (`Accept All Cookies` instant mutator) | `vgui_CookiesWindow.cpp`, [vgui_system.md](vgui_system.md), [mutator_system.md §3.3.1](mutator_system.md) |
| Blue screen of death (`bsod` instant mutator) | `vgui_BSODWindow.cpp`, [vgui_system.md](vgui_system.md), [mutator_system.md §3.3.2](mutator_system.md) |
| Vote panels (gameplay/mutator/map sequence) | [voting_system.md](voting_system.md) |
| Bot-options RTV panel | `vgui_VoteBotOptionsWindow.cpp`, [bot_options_system.md](bot_options_system.md) |
| Radar overlay | [radar_system.md](radar_system.md) |
| Banner / pickup overlays | [banner_system.md](banner_system.md) |
| Life bars + floating damage numbers | [lifebar.md](lifebar.md) |
| Particle and flame effects (message -> manager -> render lifecycle) | [particle_system.md](particle_system.md) |
| World/brush texture swap (`myfavtexture` mutator, hardware `texture_t::gl_texturenum`) | `mutator_myfavtexture.cpp`, [mutator_system.md §3.25](mutator_system.md) |
| Second view per frame + see-through blend (`xray` mutator, `nextView`, user clip plane) | `mutator_xray.cpp`, `view.cpp::V_CalcRefdef`, `GameStudioModelRenderer.cpp`, [mutator_system.md §3.31](mutator_system.md) |
| Red LED display + red HUD (`virtualboy` mutator, last screen-space pass before the HUD and one pass after it) | `mutator_virtualboy.cpp`, `cdll_int.cpp::HUD_Redraw`, `tri.cpp`, [mutator_system.md §3.32](mutator_system.md) |
| Thermal vision (`predator` mutator, per-body-part heat mask pass into a private FBO from `StudioRenderFinal_Hardware`, false colour display pass before `blur`) | `mutator_predator.cpp`, `StudioModelRenderer.cpp`, `view.cpp::V_CalcRefdef`, `tri.cpp`, `cdll_int.cpp::HUD_Redraw`, [mutator_system.md §3.36](mutator_system.md) |
| World hidden, objects kept (`nobackgrounds` mutator, reject-all user clip plane, opaque brush entities and sprites moved to the transparent pass, fog-coloured backdrop) | `mutator_nobackgrounds.cpp`, `view.cpp::V_CalcRefdef`, `entity.cpp::HUD_AddEntity`, `GameStudioModelRenderer.cpp`, `fog.cpp`, [mutator_system.md §3.33](mutator_system.md) |
| MOTD / scoreboard | `vgui_TeamFortressViewport.cpp` (`MsgFunc_MOTD`, `ScorePanel`) |
| Scoreboard awards row (weapon of choice + two awards; third header row of the old scoreboard, second of the VGUI one) | `scoreboard.cpp` (`MsgFunc_Awards`, `GetAwardsText`), `vgui_ScorePanel.cpp` (`m_AwardsLabel`), [award_system.md](award_system.md) |
| Weapon firing prediction | `ev_hldm.cpp` |
| Third person body fade (own model see-through while the camera is close; local only) | `in_camera.cpp`, `view.cpp::V_CalcNormalRefdef`, `entity.cpp::HUD_AddEntity`, `StudioModelRenderer.cpp::StudioRenderModel`, `cdll_int.cpp::HUD_Redraw`, [Third Person Body Fade](#third-person-body-fade) |
| Pickup weapon glow (lit model, small dlight, serrated starburst behind world weapons; `cl_weaponglow`) | `weapon_glow.cpp`, `StudioModelRenderer.cpp::StudioDrawModel`, `tri.cpp::HUD_DrawTransparentTriangles`, [Pickup Weapon Glow](#pickup-weapon-glow) |
| Weapons (full inventory + mechanics) | [weapons.md](weapons.md) |

## Lessons Worth Repeating

- **Construct furniture in the panel ctor; build dynamic content in `Open()`.** Anything sourced from a server user message (vote rosters, dynamic map list, MOTD) may not have arrived when the panel is constructed at level load. `CVoteMapPanel` is the reference pattern: empty arrays in the ctor, `BuildButtons()` from `Open()`, teardown of any prior buttons before rebuild. If the data can still arrive after `Open()` (manifests are streamed and paced, bot options ~5s after connect), also rebuild from `Update()` once it lands, as `CVoteBotOptionsPanel` does.
- **Reset chunked accumulators on `seq == 0`, commit on `isLast`.** Don't trust intermediate state — a reconnect or restart can interleave a fresh stream with a partial one.
- **HUD vs VGUI is a hard line.** Buttons / focus / scrollbars belong in VGUI panels; per-frame immediate-mode draws (radar, banner, ammo) belong in `CHudBase` subclasses. The schemes (fonts/colors) are independent.
- **Weapon effect responsiveness comes from event callbacks, not server temp entities.** Pattern: server `PLAYBACK_EVENT_FULL` in weapon fire code, client `EV_FireXxx` in `ev_hldm.cpp`, hook in `hl_events.cpp`, plus an `events/<name>.sc` stub in `workspace/redist/events/`. See the railgun/dual-railgun implementation for a complete example.
- **Decide translucency in `HUD_AddEntity`, blend at draw time.** The engine sorts entities into the opaque and translucent lists by `curstate.rendermode` after `HUD_AddEntity`. Switching the mode inside the studio renderer is too late. Any client-side `curstate` override must be put back after the frame, because the engine may only refresh it when a packet arrives. For a glow shell entity, `renderamt` is the shell thickness, not its opacity. Use `IEngineStudio.StudioSetRenderamt` for the body pass and restore it before the shell pass (see [Third Person Body Fade](#third-person-body-fade)).
