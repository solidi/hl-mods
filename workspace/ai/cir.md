# Cold Ice Remastered — AI Context Hub (Root)

This is the top-level entry point for any work in this repository. Every other context document under `workspace/ai/` is reachable from here. Load this file first; then follow the relevant link below.

## Repo at a Glance

- **Engine**: GoldSrc (Half-Life 1 SDK), MSVC 2019 on Windows, gcc on Linux.
- **Build**: `workspace/Build-Windows.ps1 -ConfigFile steam` (also `-ConfigFile <other>`). Linux via `workspace/build-linux.sh` and the `workspace/docker/` images. Output DLLs land under `redist/dlls/` and `redist/cl_dlls/`.
- **Run**: `workspace/Start-Windows.ps1 -ConfigFile steam -map <name>`.
- **Source layout**:
  - `workspace/src/dlls/` — server DLL (`hl.dll`).
  - `workspace/src/cl_dll/` — client DLL (`client.dll`).
  - `workspace/src/common/`, `src/engine/`, `src/pm_shared/` — shared headers from the HLSDK.
  - `workspace/grave-bot-src/` — the bot DLL (`grave_bot.dll`).
- **Asset pipelines**: `Build-Models.ps1`, `Build-Maps.ps1`, `Build-Wads.ps1`, `Build-Sound.ps1`, `Build-Sprites.ps1`, `Copy-Distribution.ps1`. Source assets live alongside their pipeline scripts under `workspace/`.

## Building (Read This Before Compiling)

Use this section as the source of truth for builds. Do not guess paths or invent solution files.

### Canonical wrapper
- Preferred: run `workspace/Build-Windows.ps1 -ConfigFile steam` from `C:\hl-mods\workspace`. It builds everything (server + client + bot) into the matching `redist*` folder for the chosen config.
- For a quick, targeted rebuild of just one DLL during iteration, drive MSBuild directly using the exact paths below.

### Visual Studio project locations (Windows)
The MSVC project files live under `workspace/src/projects/vs2019/` — **not** under `workspace/src/dlls/` or `workspace/src/cl_dll/`.

| Target | Project file | Output |
|--------|--------------|--------|
| Server DLL (`hl.dll`) | `workspace/src/projects/vs2019/hl.vcxproj` | `workspace/src/projects/vs2019/Release/hl/hl.dll` |
| Client DLL (`client.dll`) | `workspace/src/projects/vs2019/hl_cdll.vcxproj` | `workspace/src/projects/vs2019/Release/hl_cdll/client.dll` |
| Grave bot (`grave_bot.dll`) | `workspace/grave-bot-src/dlls/grave_bot.sln` | `workspace/grave-bot-src/dlls/.../grave_bot.dll` |

Always build with `Configuration=Release` and `Platform=Win32`. The engine is 32-bit; do **not** try `x64`.

### MSBuild invocation (verified)
MSBuild is **not** on PATH by default. Use the full path to the VS2022 Community MSBuild — it can build the vs2019 toolset projects fine:

```powershell
$env:PATH = 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin;' + $env:PATH
& 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe' `
    'C:\hl-mods\workspace\src\projects\vs2019\hl_cdll.vcxproj' `
    /p:Configuration=Release /p:Platform=Win32 /m /nologo /v:minimal
```

Swap `hl_cdll.vcxproj` → `hl.vcxproj` for the server DLL. For the bot, point at `workspace/grave-bot-src/dlls/grave_bot.sln` (no `Platform` override needed — the solution sets it).

To trim noise when piping output back into the agent, append `2>&1 | Select-Object -Last 30`.

### Common pitfalls (don't repeat these)
- **Do not pass `workspace/src/cl_dll/hl_cdll.vcxproj`** — that path does not exist. The vcxproj is under `src/projects/vs2019/`. Same for `hl.vcxproj`.
- **Do not use `cl.exe` directly** or hand-rolled compile commands. The vcxproj defines includes, defines (`CLIENT_DLL`, `CLIENT_WEAPONS`, etc.), and link order that you will not reproduce correctly by hand.
- **Rebuild both DLLs when changing shared headers** (`src/common/`, `src/pm_shared/`, anything touching `CLIENT_WEAPONS`). Mismatched builds fail silently — see Cross-cutting Lessons.
- **Do not bypass `Build-Windows.ps1` for full release output.** Direct MSBuild produces the DLL in the project's `Release/` folder, but `Build-Windows.ps1` is what copies the artifacts into `redist/` (and `redist_hd/`, `redist_sp/`) where `Start-Windows.ps1` will actually pick them up.
- **Linux builds** go through `workspace/build-linux.sh` and the images in `workspace/docker/`. Don't try `make` directly from `src/`.

### Quick recipes
- Iterating on client HUD/VGUI only → MSBuild `hl_cdll.vcxproj`, then re-run with `Start-Windows.ps1`.
- Iterating on gamerules / weapons / entities → MSBuild `hl.vcxproj`. If you also touched a shared header used by prediction, build `hl_cdll.vcxproj` too.
- Iterating on bot AI → MSBuild `grave-bot-src/dlls/grave_bot.sln`.
- Touching assets (models/maps/wads/sounds/sprites) → use the matching `Build-*.ps1` script under `workspace/`; do not edit the binary outputs by hand.

## The Two Halves

```
cir.md (you are here)
├── server.md   — everything that lives in src/dlls/ (game logic, gamerules, bots, weapons server-side)
└── client.md   — everything that lives in src/cl_dll/ (HUD, VGUI menus, prediction, rendering)
```

Most features cut across both halves via a registered user-message; if you are touching one, skim the other.

## Spoke Index

### Cross-cutting (server + client together)
- [voting_system.md](voting_system.md) — gameplay / mutator / map vote sequence; conventions every vote panel must follow.
- [runes.md](runes.md) — rune entities, effects, spawn cycle, `drop_rune` mechanic. Server-side reference for the bot rune logic in `gravebot.md`.

### Server-side (loaded from [server.md](server.md))
- [gamerules.md](gamerules.md) — `CGameRules` hierarchy and per-mode dispatch (the Mode Roster lives here).
- [arena_gamerules.md](arena_gamerules.md), [busters_gamerules.md](busters_gamerules.md), [coldskull_gamerules.md](coldskull_gamerules.md), [coldspot_gamerules.md](coldspot_gamerules.md), [ctc_gamerules.md](ctc_gamerules.md), [ctf_gamerules.md](ctf_gamerules.md), [kts_gamerules.md](kts_gamerules.md) — per-mode spokes.
- [mutator_pause_system.md](mutator_pause_system.md) — mutator lifecycle and pause semantics.
- [gravebot.md](gravebot.md) — bot AI overview (lifecycle, navigation, item & rune handling, CVars). Sub-spoke: [gravebot_combat.md](gravebot_combat.md) for deep combat detail (memory: `/memories/repo/gravebot_combat_mechanics.md`).
- [player.md](player.md) — Cold Ice player abilities (impulses 206-216): punch, kick, hurricane kick, flips, double/triple jump, force grab (incl. world-item tractor), grapple, throw weapon, off-hand grenade, slide, taunt, iron sights.

### Client-side (loaded from [client.md](client.md))
- [vgui_system.md](vgui_system.md) — VGUI viewport, menu panels, vote menus, and the dynamic map list.
- [radar_system.md](radar_system.md) — radar HUD overlay.
- [banner_system.md](banner_system.md) — banner HUD overlay.

## Cross-cutting Lessons

These come from `workspace/plan/learnings.md` and from in-repo discoveries; they apply regardless of which half you are touching.

- **`REG_USER_MSG` name has a ~10-character limit.** `AnnounceWeapon` (14) crashed the server. Stay ≤10 chars; ≤8 is the safe target. See [server.md → User-Message Registry](server.md#user-message-registry).
- **User messages are capped at ~192 bytes per `MESSAGE_BEGIN`/`MESSAGE_END`**. Anything larger must be chunked. The canonical chunk header is `BYTE seq; BYTE isLast; BYTE total; BYTE numInChunk; …items…` — the client resets on `seq == 0` and commits on `isLast`. See `SendMOTDToClient` and `SendMapListToClient`.
- **`COM_Parse` only supports `//` comments.** No `#`, no `;`. To attach metadata to a `mapcycle.txt` entry, use Quake/Source-style info-string keys on the same line: `mapname \size\large \minplayers\4`. Read individual keys with `g_engfuncs.pfnInfoKeyValue(buf, "size")`.
- **VGUI vote menus decouple display position from array index.** RANDOM is rendered at row 0 / column 0 (first visible cell) but stored at the **last** array index — so server-side tally arithmetic stays branch-free at vote ID `count + 1`. See [voting_system.md](voting_system.md#1-random-is-always-displayed-first-but-indexed-last).
- **Defer dynamic VGUI construction to `Open()`, not the panel constructor.** Data sourced from user messages (e.g. the map manifest) may not have arrived at construction time. `CVoteMapPanel::BuildButtons()` is called from `Open()` and tears down any previous buttons before rebuilding.
- **Always rebuild both DLLs when toggling preprocessor defines** like `CLIENT_WEAPONS`. Mismatched builds fail silently or behave weirdly.
- **`globalvars_t` is "stomped" every frame.** When working with angles, capture state with macros like `UTIL_MakeVectors(anglesAim)` immediately. See `CRpg`.
- **`SetThink` value changes don't propagate to the client** for client-side weapons. Use a user message or `pev->iuser*` if the client needs to see it.
- **Client-side weapon prediction lives in `src/cl_dll/ev_hldm.cpp`.** Any new server weapon that fires while the local player is shooting needs a matching event there or it will feel laggy.
- **Localizable strings prefixed with `#`** are looked up in `resource/valve_english.txt` (and friends). Use `BufferedLocaliseTextString` to resolve them in VGUI.
- **VGUI fonts ≠ engine fonts ≠ HUD fonts.** They live in different schemes; do not mix. `fonts.wad` is no longer used by the modern engine.
- **Sort case-insensitively for player-facing lists.** Use `qsort` + `stricmp` (Windows) / `strcasecmp` (POSIX). The dynamic map list is alphabetized this way before transmission so the menu order matches what players expect.

For the full historical list, see `workspace/plan/learnings.md`.
