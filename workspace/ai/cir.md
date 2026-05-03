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

### Server-side (loaded from [server.md](server.md))
- [gamerules.md](gamerules.md) — `CGameRules` hierarchy and per-mode dispatch (the Mode Roster lives here).
- [arena_gamerules.md](arena_gamerules.md), [busters_gamerules.md](busters_gamerules.md), [coldskull_gamerules.md](coldskull_gamerules.md), [coldspot_gamerules.md](coldspot_gamerules.md), [ctc_gamerules.md](ctc_gamerules.md), [ctf_gamerules.md](ctf_gamerules.md), [kts_gamerules.md](kts_gamerules.md) — per-mode spokes.
- [mutator_pause_system.md](mutator_pause_system.md) — mutator lifecycle and pause semantics.
- [gravebot_combat.md](gravebot_combat.md) — bot AI combat behaviors (memory: `/memories/repo/gravebot_combat_mechanics.md`).

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
