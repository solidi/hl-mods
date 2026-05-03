# VGUI Menu System — Spoke

> Parent: [client.md](client.md) · Grandparent: [cir.md](cir.md) · Sibling: [voting_system.md](voting_system.md)

Covers the retained-mode VGUI viewport, every menu panel mounted under it, and the dynamic map list that drives the map vote. For the cross-cutting flow of the gameplay/mutator/map vote sequence (server timer, message contract, tally rules), see [voting_system.md](voting_system.md).

## Viewport (`TeamFortressViewport`)

- File: `src/cl_dll/vgui_TeamFortressViewport.{h,cpp}`.
- Singleton: `gViewPort` (created during `HUD_VidInit`).
- Owns: `CSchemeManager` (font/color schemes), `ScorePanel`, the active `CMenuPanel*`, all VGUI message handlers.
- Display switching: `ShowVGUIMenu(MENU_*, timer)` sets the active panel; `HideVGUIMenu()` clears it.

`MENU_*` IDs are defined as enum entries near the top of `vgui_TeamFortressViewport.h`. The vote panels are `MENU_VOTEGAMEPLAY`, `MENU_VOTEMUTATOR`, `MENU_VOTEMAP`.

## Menu Panel Family

```
CMenuPanel (base; src/cl_dll/vgui_MenuPanel.cpp)
├── CClassMenuPanel
├── CTeamMenuPanel
├── CVoteGameplayPanel    — vote on next game mode
├── CVoteMutatorPanel     — vote on next mutator
├── CVoteMapPanel         — vote on next map (dynamic; see below)
├── CMOTDPanel
└── …
```

All of them implement at minimum:

- `Open()` — called once each time the panel becomes visible. Good place for lazy construction (`CVoteMapPanel` rebuilds its buttons here against the current dynamic map list).
- `Update()` — called every frame while visible. Update timer, vote tallies, button styling.
- `SlotInput(int iSlot)` — keyboard slot selection (1–9 keys).
- `Initialize()` — called on each new level start.

## RANDOM Goes First (Display) / Last (Index)

All three vote panels follow the same convention. The full rationale lives in [voting_system.md → conventions](voting_system.md#1-random-is-always-displayed-first-but-indexed-last); the short version:

| | Display position | Array index / vote ID |
|---|---|---|
| RANDOM | row 0, column 0 (top-left, **first** visible cell) | `count` / vote ID `count + 1` (**last**) |
| Real entries | grid cells 1..N filled left-to-right, top-to-bottom | 0..count-1 / vote IDs 1..count |

`CVoteMapPanel::BuildButtons()` is the canonical (dynamic-count) implementation; `CVoteGameplayPanel` and `CVoteMutatorPanel` constructors do the equivalent with their fixed-size arrays.

## Dynamic Map List

Pre-2026, the client carried a hard-coded `sBuiltInMaps[]` array (38 maps + RANDOM). It is now built from the server's `mapcyclefile` at runtime.

### Wire Format — `MapList` user message

Registered in `player.cpp::LinkUserMessages()` as `REG_USER_MSG("MapList", -1)` (variable length). Sent by `CHalfLifeMultiplay::SendMapListToClient(edict_t*)` from `CHalfLifeMultiplay::InitHUD`. Chunked at 4 maps/chunk to stay under the ~192-byte message cap.

Each chunk:

```
BYTE  seq            // chunk index, 0-based
BYTE  isLast         // 1 on the final chunk
BYTE  total          // total map count (only meaningful when seq == 0)
BYTE  numInChunk     // 1..MAP_LIST_MAPS_PER_CHUNK
repeat numInChunk times:
  BYTE   size        // MAP_SIZE_SMALL/MEDIUM/LARGE/MEGA (0..3)
  STRING name        // null-terminated map name (≤31 chars + null)
```

Even an empty list still sends one chunk so the client knows the manifest arrived.

### Client-side storage

Defined in `vgui_TeamFortressViewport.cpp`, declared `extern` in `vgui_TeamFortressViewport.h`:

```cpp
char g_szClientMaps[MAX_CLIENT_MAPS][32];   // MAX_CLIENT_MAPS = 129 (= 128 server maps + RANDOM slot)
int  g_iClientMapSizes[MAX_CLIENT_MAPS];
int  g_iClientMapCount;                     // real maps only; RANDOM is implicit at index count
bool g_bMapListReceived;
const char *MapSizeLabel(int size);         // "small" / "medium" / "large" / "mega"
```

`MsgFunc_MapList` resets the list on `seq == 0` and sets `g_bMapListReceived = true` on `isLast`. If the list never arrives (private server, modded build, etc.), `CVoteMapPanel::BuildButtons()` falls back to a RANDOM-only menu.

### Server-side storage (mirror)

In `multiplay_gamerules.cpp`:

```cpp
char g_szServerMaps[MAX_SERVER_MAPS][32];   // MAX_SERVER_MAPS = 128
int  g_iServerMapSizes[MAX_SERVER_MAPS];
int  g_iServerMapCount;
```

Built by `BuildServerMapList()` (parses `mapcyclefile`, reads `\size\` info-string key, validates with `IS_MAP_VALID`, de-dupes, sorts case-insensitive). `EnsureServerMapList()` is the cached entry point used by the vote tally and `SendMapListToClient`.

Map size is admin-annotated in `mapcycle.txt`:

```
bounce2 \size\large
canyon  \size\mega
coldice \size\medium
```

Unknown / missing values silently default to `medium`.

### Vote Tally Contract

- Vote IDs are 1-based.
- IDs `1..g_iServerMapCount` map to real maps (server arithmetic) / `g_szClientMaps[id-1]` (client display).
- ID `g_iServerMapCount + 1` is RANDOM. Server-side tally re-rolls into a real index when RANDOM wins.
- `g_pGameRules->m_iVoteCount[entindex - 1]` stores each player's current vote.
- Bots vote randomly via `RANDOM_LONG(1, g_iServerMapCount + 1)` when the menu opens.

## Hooking a New Vote Panel — Cheatsheet

1. Subclass `CMenuPanel` in `vgui_<Name>Window.cpp`. Construct the static furniture (title label, scroll panel) in the ctor; defer dynamic content to `Open()`.
2. Add a `MENU_<NAME>` enum value in `vgui_TeamFortressViewport.h`.
3. Wire it up in `TeamFortressViewport::ShowVGUIMenu` (the giant switch).
4. Server side: register the `Vote<X>` message in `player.cpp` (≤10 chars), broadcast it from the relevant `Think()` branch, and have `Vote()` in `client.cpp` understand the new vote-mode constant.
5. **Always** put RANDOM at display position (0,0) and array index `count`.
