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
- `vgui_TeamFortressViewport.{h,cpp}` — the client viewport, all VGUI menus, all VGUI message handlers. See [vgui_system.md](vgui_system.md).
- `vgui_VoteMapWindow.cpp`, `vgui_VoteGameplayWindow.cpp`, `vgui_VoteMutatorWindow.cpp` — the three vote panels.
- `ev_hldm.cpp` — client-side weapon firing/prediction events. New server weapons that fire visibly need an entry here, otherwise the local player sees lag.
- `hl/hl_events.cpp` — binds `events/*.sc` scripts to `EV_Fire*` callbacks.
- `parsemsg.{h,cpp}` — `BEGIN_READ` / `READ_BYTE` / `READ_STRING` helpers used by every `MsgFunc_*`.

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

## Where Things Render

| What | Where to look |
|------|--------------|
| Menus (vote, class, team, …) | [vgui_system.md](vgui_system.md) |
| Vote panels (gameplay/mutator/map sequence) | [voting_system.md](voting_system.md) |
| Radar overlay | [radar_system.md](radar_system.md) |
| Banner / pickup overlays | [banner_system.md](banner_system.md) |
| MOTD / scoreboard | `vgui_TeamFortressViewport.cpp` (`MsgFunc_MOTD`, `ScorePanel`) |
| Weapon firing prediction | `ev_hldm.cpp` |
| Weapons (full inventory + mechanics) | [weapons.md](weapons.md) |

## Lessons Worth Repeating

- **Construct furniture in the panel ctor; build dynamic content in `Open()`.** Anything sourced from a server user message (vote rosters, dynamic map list, MOTD) may not have arrived when the panel is constructed at level load. `CVoteMapPanel` is the reference pattern: empty arrays in the ctor, `BuildButtons()` from `Open()`, teardown of any prior buttons before rebuild.
- **Reset chunked accumulators on `seq == 0`, commit on `isLast`.** Don't trust intermediate state — a reconnect or restart can interleave a fresh stream with a partial one.
- **HUD vs VGUI is a hard line.** Buttons / focus / scrollbars belong in VGUI panels; per-frame immediate-mode draws (radar, banner, ammo) belong in `CHudBase` subclasses. The schemes (fonts/colors) are independent.
- **Weapon effect responsiveness comes from event callbacks, not server temp entities.** Pattern: server `PLAYBACK_EVENT_FULL` in weapon fire code, client `EV_FireXxx` in `ev_hldm.cpp`, hook in `hl_events.cpp`, plus an `events/<name>.sc` stub in `workspace/redist/events/`. See the railgun/dual-railgun implementation for a complete example.
