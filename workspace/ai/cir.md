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

Use this section as the source of truth for builds. Do not guess paths or invent solution files. Every fact below has been verified by running it.

### TL;DR — one command that works

```powershell
# from C:\hl-mods\workspace
pwsh -File .\Build-Windows.ps1 -ConfigFile steam
```

That's it. This builds all three DLLs (bot + server + client) and copies them into `redist/`, `redist_hd/`, `redist_sp/` for `Start-Windows.ps1`. **Always pass `-ConfigFile steam`** — without it, the script defaults `$Config['msBuild']` to the literal string `"msbuild"`, fails immediately because MSBuild is not on PATH, and you waste a turn debugging it.

`steam.ps1` is what supplies the verified MSBuild path (`C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild`) plus the full `$Config['defintions']` preprocessor set (`VEST;SILENCER;…;NUKE`) that the project must compile with. Do not invent your own config; edit `steam.ps1` if a definition really must change.

### Visual Studio project locations (Windows)

MSVC project files live under `workspace/src/projects/vs2019/` — **not** under `workspace/src/dlls/` or `workspace/src/cl_dll/`. The DLL filename comes from `<TargetName>` in each vcxproj and does **not** match the project base name.

| Target | Solution | Project file | Output (under `src/projects/vs2019/Release/`) |
|--------|----------|--------------|------------------------------------------------|
| Server DLL  | `hldll.sln`   | `hldll.vcxproj`   | `hldll/ice.dll`     (TargetName = `ice`) |
| Client DLL  | `hl_cdll.sln` | `hl_cdll.vcxproj` | `hl_cdll/client.dll`                     |
| Grave bot   | `workspace/grave-bot-src/dlls/grave_bot.sln` | (in that sln) | `workspace/grave-bot-src/dlls/.../grave_bot.dll` |

There is **no** `hl.vcxproj` and **no** `hl.dll` in this repo. The server library is named `ice.dll` (per `<TargetName>ice</TargetName>` in `hldll.vcxproj`). The first place the wrapper drops it is `workspace/libs/dlls/ice.dll` (see the `<Copy>` task at the bottom of `hldll.vcxproj`), then `Build-Windows.ps1` redistributes it.

Engine is 32-bit. **Do not try `x64`.**

### Direct MSBuild invocation (when the wrapper is overkill)

For a fast targeted rebuild during iteration, drive MSBuild directly. The platform-name string is **not** the same for `.sln` and `.vcxproj` — get this wrong and you get `MSB4126: invalid solution configuration`.

| Target you pass | `/p:Platform=` value |
|-----------------|----------------------|
| `*.sln`         | `x86`                |
| `*.vcxproj`     | `Win32`              |

Verified recipe (use the full MSBuild path; do not rely on PATH):

```powershell
$msbuild = 'C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe'

# Server DLL (ice.dll) — via solution:
& $msbuild C:\hl-mods\workspace\src\projects\vs2019\hldll.sln `
    /t:Build /p:Configuration=Release /p:Platform=x86 /m /nologo /v:minimal

# Client DLL (client.dll) — via solution:
& $msbuild C:\hl-mods\workspace\src\projects\vs2019\hl_cdll.sln `
    /t:Build /p:Configuration=Release /p:Platform=x86 /m /nologo /v:minimal

# Either DLL via vcxproj directly — note Win32, not x86:
& $msbuild C:\hl-mods\workspace\src\projects\vs2019\hl_cdll.vcxproj `
    /p:Configuration=Release /p:Platform=Win32 /m /nologo /v:minimal
```

To find MSBuild on a machine where the path above is wrong:

```powershell
Get-ChildItem 'C:\Program Files\Microsoft Visual Studio','C:\Program Files (x86)\Microsoft Visual Studio' `
    -Recurse -Filter MSBuild.exe -ErrorAction SilentlyContinue |
    Where-Object FullName -notmatch 'amd64' | Select-Object -First 1 -ExpandProperty FullName
```

### Inspecting build output cleanly

MSBuild emits hundreds of C4996 (`stricmp`, `strcpy`, etc.) warnings that drown real errors. Capture to a file and filter:

```powershell
& $msbuild ...args... 2>&1 | Out-File C:\Temp\build.log -Encoding utf8
"exit=$LASTEXITCODE"
Get-Content C:\Temp\build.log | Where-Object { $_ -match ' error ' } | Select-Object -First 20
```

`exit=0` does **not** mean the DLL was produced if you targeted the wrong configuration — also `Test-Path` the expected output:

```powershell
Test-Path 'C:\hl-mods\workspace\src\projects\vs2019\Release\hldll\ice.dll'
Test-Path 'C:\hl-mods\workspace\src\projects\vs2019\Release\hl_cdll\client.dll'
```

### Common pitfalls (don't repeat these)

- **Don't run `Build-Windows.ps1` without `-ConfigFile steam`.** The bare script can't find msbuild.
- **Don't pass `Platform=Win32` to a `.sln`** — solutions use `x86`. Don't pass `Platform=x86` to a `.vcxproj` — vcxprojs use `Win32`. Mixing them yields `MSB4126`.
- **Don't look for `hl.dll`.** The server library is `ice.dll`. Building "hl" succeeds but produces `ice.dll` under `Release/hldll/`.
- **Don't pass `workspace/src/cl_dll/hl_cdll.vcxproj`** — that path doesn't exist. The vcxprojs live under `src/projects/vs2019/`.
- **Don't use `cl.exe` directly** or hand-rolled compile commands. The vcxproj carries the include paths, the steam.ps1 `defintions` list (`CLIENT_DLL`, `CLIENT_WEAPONS`, all weapon defs), and the correct link order. You will not reproduce them by hand.
- **Rebuild both DLLs when changing shared headers** (`src/common/`, `src/pm_shared/`, anything gated on `CLIENT_WEAPONS`). Mismatched builds fail silently — see Cross-cutting Lessons.
- **Don't bypass `Build-Windows.ps1` for a *release*.** Direct MSBuild leaves the DLL in `Release/`; only the wrapper copies into `redist/`, `redist_hd/`, `redist_sp/` where `Start-Windows.ps1` actually reads from.
- **Linux builds** go through `workspace/build-linux.sh` and the images in `workspace/docker/`. Don't run `make` directly from `src/`.
- **`Start-Sleep` / polling is forbidden in agent loops** — MSBuild here generally finishes in under a minute even cold; use a single sync run with `timeout` ~600000 ms.

### Quick recipes

| You changed | Build this | Then |
|-------------|------------|------|
| Client HUD / VGUI only                       | `hl_cdll.sln` (Platform=x86) | `Start-Windows.ps1 -ConfigFile steam -map <name>` |
| Gamerules / weapons / entities (server only) | `hldll.sln`   (Platform=x86) | same |
| Shared header touched by prediction          | both DLLs                    | same |
| Bot AI                                        | `grave-bot-src/dlls/grave_bot.sln` (no platform override) | same |
| Assets (models/maps/wads/sounds/sprites)     | matching `Build-*.ps1`        | re-run `Copy-Distribution.ps1` if needed |
| Full release ready to ship                   | `Build-Windows.ps1 -ConfigFile steam` | — |

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
- [game_options_system.md](game_options_system.md) — fourth vote phase; server-defined dynamic cvar items from `gameoptions.txt`.
- [runes.md](runes.md) — rune entities, effects, spawn cycle, `drop_rune` mechanic. Server-side reference for the bot rune logic in `gravebot.md`.
- [grappling_hook.md](grappling_hook.md) — `CHook` / `grapple_hook` projectile, lifecycle, cvars, and post-scan hardening notes. Compiled-out in the live Steam build but fully wired.

### Server-side (loaded from [server.md](server.md))
- [gamerules.md](gamerules.md) — `CGameRules` hierarchy and per-mode dispatch (the Mode Roster lives here).
- [arena_gamerules.md](arena_gamerules.md), [busters_gamerules.md](busters_gamerules.md), [coldskull_gamerules.md](coldskull_gamerules.md), [coldspot_gamerules.md](coldspot_gamerules.md), [ctc_gamerules.md](ctc_gamerules.md), [ctf_gamerules.md](ctf_gamerules.md), [kts_gamerules.md](kts_gamerules.md), [shidden_gamerules.md](shidden_gamerules.md) — per-mode spokes.
- [mutator_pause_system.md](mutator_pause_system.md) — mutator lifecycle and pause semantics.
- [gravebot.md](gravebot.md) — bot AI overview (lifecycle, navigation, item & rune handling, CVars). Sub-spoke: [gravebot_combat.md](gravebot_combat.md) for deep combat detail (memory: `/memories/repo/gravebot_combat_mechanics.md`).
- [player.md](player.md) — Cold Ice player abilities (impulses 206-218): punch, kick, hurricane kick, flips, double/triple jump, force grab (incl. world-item tractor), grapple, throw weapon, off-hand grenade, slide, taunt, iron sights.
- [weapons.md](weapons.md) — `weapon_*` entity inventory, `CBasePlayerWeapon` mechanics, proximity-mine deploy on satchel & tripmine. (Also linked from [client.md](client.md).)

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
