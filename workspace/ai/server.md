# Server DLL — AI Context Hub

Everything that ships in `hl.dll`. Source: `workspace/src/dlls/`. Built by `src/projects/vs2019/hldll.sln`.

> Parent: [cir.md](cir.md). Use this as the launch point when the work is **server-side**: gameplay logic, weapons, entities, bots, vote/intermission flow, level transitions.

## Major Systems

| System | Entry points | Spoke |
|--------|-------------|-------|
| Game rules / mode dispatch | `gamerules.cpp::InstallGameRules()`, `multiplay_gamerules.{h,cpp}` | [gamerules.md](gamerules.md) |
| Mutators / pause | `MutatorPause()`, `g_szMutators[]` | [mutator_pause_system.md](mutator_pause_system.md) |
| Bot AI | `grave-bot-src/dlls/` | [gravebot.md](gravebot.md) (sub-spoke: [gravebot_combat.md](gravebot_combat.md)) |
| Weapons / `weapon_*` entities | `weapons.{h,cpp}`, `<weapon>.cpp`, `wpn_shared/` | [weapons.md](weapons.md) |
| Map cycle / map vote | `multiplay_gamerules.cpp::ReloadMapCycleFile`, `BuildServerMapList`, `SendMapListToClient` | this file (below); cross-cutting flow: [voting_system.md](voting_system.md) |
| Gameplay / mutator / map vote sequencer | `CHalfLifeMultiplay::Think` (`VOTE_*` branches) | [voting_system.md](voting_system.md) |
| User-message registry | `player.cpp::LinkUserMessages()` | this file (below) |
| Client lifecycle | `client.cpp::ClientPutInServer`, `ClientCommand`, `Vote()` | this file (below) |
| Level transitions / intermission | `multiplay_gamerules.cpp::GoToIntermission`, `ChangeLevel` | this file (below) |

## File Map (high-traffic)

- `gamerules.{h,cpp}` — abstract base; mode dispatcher.
- `multiplay_gamerules.{h,cpp}` — `CHalfLifeMultiplay` plus all common multiplayer logic.
- `<mode>_gamerules.{h,cpp}` — one per game mode; subclass of `CHalfLifeMultiplay`.
- `player.{h,cpp}` — `CBasePlayer`, plus `LinkUserMessages()` (the one and only place user messages are registered).
- `client.{h,cpp}` — engine callbacks (`ClientConnect`, `ClientPutInServer`, `ClientDisconnect`, `ClientCommand`, plus the `Vote()` dispatcher).
- `cbase.cpp` — engine function table (`gFunctionTable`) wiring the SDK callbacks to our exports.
- `weapons.{h,cpp}` and `wpn_*.cpp` — server-side weapon implementations. Pair each with a client-side prediction event in `cl_dll/ev_hldm.cpp` if the firing code needs to feel snappy.

## Weapon Effects: Server vs Client

- Keep **damage, authoritative traces, and game-state mutations** in `src/dlls/<weapon>.cpp` under server code paths.
- Move **visual-only beam/trail/impact effects** to client events (`ev_hldm.cpp`) driven by `PLAYBACK_EVENT_FULL` from the weapon fire path.
- Register each new event in both places: server `PRECACHE_EVENT("events/<name>.sc")` and client `hl_events.cpp::Game_HookEvents()`.
- Ensure the corresponding script exists in `workspace/redist/events/<name>.sc` (stub content is fine).

Reference implementation: `weapon_railgun` / `weapon_dual_railgun` now use this split so lagging clients still see immediate local firing effects.

## User-Message Registry

The one place to register a `gmsg<Name>` user message is `player.cpp::LinkUserMessages()`. Two things to know:

1. **Name length limit (≤10 chars; aim for ≤8).** The engine truncates / corrupts long names. `AnnounceWeapon` (14 chars) crashed the server in this codebase. Names like `MapList` (7), `VoteMap` (7), `MOTD` (4), `Acrobatics` (10) all work. `VoteMutator` (11) is at the cliff edge — historically tolerated but do not add new ones at that length.
2. **Size byte:** pass a positive number for fixed-size messages, `-1` for variable-length. Variable-length messages have a hard ~192-byte cap per `MESSAGE_BEGIN`/`END` — chunk anything larger.

Pattern for chunked messages (used by both `SendMOTDToClient` and `SendMapListToClient`):

```
WRITE_BYTE(seq);          // chunk index, 0-based
WRITE_BYTE(isLast);       // 1 on the final chunk
WRITE_BYTE(total);        // total item count (only meaningful when seq == 0)
WRITE_BYTE(numInChunk);   // count of items packed in this chunk
... per-item data ...
```

The client resets its accumulator on `seq == 0` and commits on `isLast`.

## Map Cycle and Map Voting

The mod parses `mapcyclefile` (cvar; defaults to `mapcycle.txt`) twice for two different purposes:

1. **`ReloadMapCycleFile()`** (`multiplay_gamerules.cpp` ~line 3200) — builds the linked-list `mapcycle_t` used by the engine's normal "next map" rotation. Reads `\minplayers\` / `\maxplayers\` info-string keys per entry.
2. **`BuildServerMapList()`** (just before `ChangeLevel`) — builds the flat `g_szServerMaps[MAX_SERVER_MAPS][32]` / `g_iServerMapSizes[]` arrays that drive the dynamic vote menu. Reads the `\size\` info-string key (`small`/`medium`/`large`/`mega`, default `medium`). Sorts case-insensitive, de-duplicates, caps at 128. Cached; re-parses only when the cvar changes.

`mapcycle.txt` line format:

```
mapname [\key\value\key\value...]
```

`COM_Parse` only supports `//` comments — no `#`, no `;`. Whitespace separates the map name from the optional info-string blob; the blob itself is one token because `\` is `> 32` ASCII.

`SendMapListToClient(edict_t*)` streams the array to a client in chunks (4 maps/chunk) under the `MapList` user message. It is called from `CHalfLifeMultiplay::InitHUD` for every non-bot client; the client side is documented in [vgui_system.md](vgui_system.md).

`Vote()` in `client.cpp` dispatches the player's `vote N` console command. Vote IDs are 1-based; `1..g_iServerMapCount` are real maps, `g_iServerMapCount + 1` is the synthetic RANDOM. Tally lives in `CHalfLifeMultiplay::Think` (the `VOTE_MAPS_OPEN` branch) and writes the winner into `m_iDecidedMapIndex`, which `ChangeLevel()` then reads to override `szNextMap`.

Mid-game map/gameplay RTV path:
- Chat `maps` and `gamemodes` are handled in `client.cpp` RTV helpers (`MapVoteRTV`, `GameModeVoteRTV`) with majority collection (`rtvtime`) and shared RTV lock/cooldown (`mp_rtvcooldown`).
- On majority success they call `CHalfLifeMultiplay::VoteForMapRTV()` / `VoteForGameplayRTV()`.
- The vote window closes via `CheckMapRTV()` / `CheckGameplayRTV()`, which tallies votes, prints the selected result, and calls `EndMultiplayerGame()` on success.

The map vote is the final phase of a five-vote sequence (gameplay → game-options → server-options → mutator → map). The full state machine, conventions (RANDOM-first display / last-index, 50/50 tie-breaking, bot vote randomization), and message contract are documented in [voting_system.md](voting_system.md).

## Level Transitions

`CHalfLifeMultiplay::GoToIntermission()` schedules an intermission and (if `voting >= 10`) opens the gameplay/mutator/map vote sequence. When a map/gameplay RTV already produced a winner, `m_bSkipIntermissionVoting` keeps intermission short (`mp_chattime` only) and skips the full intermission vote chain.

`ChangeLevel()` resolves the next map by:

1. Mapcycle linked-list iteration (the default rotation, with `\minplayers\` filtering).
2. If `m_iDecidedMapIndex > -1` and within range, override with `g_szServerMaps[m_iDecidedMapIndex]`.
3. Validate with `IS_MAP_VALID`; fall back to first list entry on failure.
4. `CHANGE_LEVEL(szNextMap, NULL)` and execute any `\rule\value\` server commands attached to the entry.

## Hand-off to the Client

These user messages are the contract between server and client:

| Message | Sender | Receiver | Purpose |
|---------|--------|----------|---------|
| `MOTD` | `SendMOTDToClient` | `MsgFunc_MOTD` | server message of the day, chunked |
| `MapList` | `SendMapListToClient` | `MsgFunc_MapList` | dynamic map manifest with size annotations, chunked |
| `GameOpts` / `VoteOpts` / `VOptFor` | game-options parser + vote branches | `MsgFunc_GameOpts` / `MsgFunc_VoteOpts` / `MsgFunc_VOptFor` | mode-filtered per-row game-options voting |
| `SrvOpts` / `VoteSrvOp` / `SOptFor` | server-options parser + vote branches | `MsgFunc_SrvOpts` / `MsgFunc_VoteSrvOp` / `MsgFunc_SOptFor` | global per-row server-options voting |
| `VoteMap` / `VoteGame` / `VoteMutator` | `Think()` + RTV vote-open branches | `MsgFunc_Vote*` | open/close vote panels (`VoteMap`/`VoteMutator` may include optional mode byte) |
| `VoteFor` | `Vote()` in `client.cpp` | `MsgFunc_VoteFor` | broadcast a player's vote so everyone's tally updates |
| `Acrobatics`, `Banner`, `Particle`, `FlameMsg`, `RoundTime`, `Objective`, … | various | various HUD/HUD2 hooks | gameplay overlays |

For client-side handling, jump to [client.md](client.md) and from there [vgui_system.md](vgui_system.md).
