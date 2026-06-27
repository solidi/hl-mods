# Voting System — Cross-cutting Spoke

> Parents: [cir.md](cir.md) · related to both [server.md](server.md) and [client.md](client.md) · sibling: [vgui_system.md](vgui_system.md)

The voting system spans both DLLs: the server runs the timer / tally / decision logic, the client renders the panels and forwards `vote N` console commands. There are **five** votes that fire in sequence at intermission — gameplay, **game-options**, **server-options**, mutator, map — and they all follow the same conventions.

## Vote Flow (one intermission)

```
GoToIntermission()  (multiplay_gamerules.cpp)
    │  if voting >= 10 …
    ▼
m_iVoteUnderway = VOTE_GAMEPLAY_TRANSITION
    │ wait voting*1 seconds
    ▼
VOTE_GAMEPLAY_OPEN   ──▶ gmsgVoteGameplay(timer)  ─────▶ CVoteGameplayPanel
    │ wait voting*1 seconds; tally; broadcast result
    ▼
VOTE_GAMEOPTIONS_TRANSITION
    │ wait voting*1 seconds; build active set for new g_GameMode
    │   (skip phase if 0 items match current mode)
    ▼
VOTE_GAMEOPTIONS_OPEN ─▶ gmsgVoteOpts(rev,timer,N,idx…) ▶ CVoteGameOptionsPanel
    │ wait voting*1 seconds; tally per row; CVAR_SET_STRING winners
    ▼
VOTE_SERVEROPTIONS_TRANSITION
    │ wait voting*1 seconds; build active global server-options set
    │   (skip phase if 0 rows loaded from serveroptions.txt)
    ▼
VOTE_SERVEROPTIONS_OPEN ─▶ gmsgVoteSrvOp(rev,timer,N,idx…) ▶ CVoteServerOptionsPanel
    │ wait voting*1 seconds; tally per row; CVAR_SET_STRING winners
    ▼
VOTE_MUTATOR_OPEN    ──▶ gmsgVoteMutator(timer)   ─────▶ CVoteMutatorPanel (plus synthetic INSTANT MUTATORS slot)
    │ wait voting*1 seconds; tally; broadcast result
    ▼
VOTE_MAPS_TRANSITION
    │ wait voting*1 seconds
    ▼
VOTE_MAPS_OPEN       ──▶ gmsgVoteMap(timer)       ─────▶ CVoteMapPanel
    │ EnsureServerMapList() runs here
    │ bots cast random votes
    │ wait voting*1 seconds; tally; pick winner
    ▼
m_iDecidedMapIndex set; ChangeLevel() honors it
```

`VOTE_*` constants live in `gamerules.h`; the timer cvar is `voting` (seconds per phase, ×5 phases, ≥10 to trigger). Total intermission scales to `voting*5 + 15` seconds.

## What Each Vote Decides

| Vote | Decides | Authoritative array | RANDOM behavior |
|------|---------|---------------------|-----------------|
| Gameplay | `g_GameMode` for next map | `gamePlayModes[]` in `multiplay_gamerules.cpp` | Wins → server picks any mode |
| Game-options | Per-row `CVAR_SET_STRING` of each item in `gameoptions.txt` whose `game` matches new `g_GameMode` or is `*` | `g_GameOptions[]` parsed at boot/mtime change | Each row picks the most-voted option; ties resolved with `RANDOM_LONG` |
| Server-options | Per-row `CVAR_SET_STRING` of each item in `serveroptions.txt` (global, no mode filtering) | `g_ServerOptions[]` parsed at boot/mtime change | Each row picks the most-voted option; ties resolved with `RANDOM_LONG` |
| Mutator  | `sv_mutatorlist` to apply on next map, plus `sv_instantmutators` toggle | `g_szMutators[]` in gamerules (+ synthetic "INSTANT MUTATORS" vote slot) | RANDOM wins → server picks one (or two) via `RandomizeMutator()` |
| Map      | `m_iDecidedMapIndex` overriding the cycle's next-up | `g_szServerMaps[]` (dynamic; see [vgui_system.md](vgui_system.md#dynamic-map-list)) | Wins → server re-rolls into a real index |

## Common Conventions (all vote panels)

### RTV gate and cooldown (mutator/gameoptions/serveroptions)

- Chat RTV paths for `mutator`, `gameoptions`, and `serveroptions` now share one lock.
- While one of these RTVs is collecting votes or has its vote panel open, the other RTV commands are blocked.
- Blocked callers receive explicit feedback naming which RTV currently owns the lock and how many seconds remain.
- After an RTV ends (or its collection window expires), `mp_rtvcooldown` seconds must pass before any of the three RTV types can be started again.

### 1. RANDOM is always **displayed first** but **indexed last**

| | Display position | Array index | Vote ID (1-based, sent over `vote N`) |
|---|---|---|---|
| RANDOM | row 0, column 0 — top-left, **first** visible cell | `count` (0-based) | `count + 1` (the highest possible) |
| Real entry *i* | grid cells filled left-to-right, top-to-bottom skipping (0,0) | `0..count-1` | `1..count` |

Display and storage are deliberately decoupled: the server tally arithmetic stays branch-free (vote ID `count + 1` is always RANDOM), while the UI keeps RANDOM in the most prominent slot. This rule is enforced in:

- `vgui_VoteMapWindow.cpp::CVoteMapPanel::BuildButtons` — canonical, dynamic-count implementation.
- `vgui_VoteGameplayWindow.cpp::CVoteGameplayPanel` — fixed-count equivalent.
- `vgui_VoteMutatorWindow.cpp::CVoteMutatorPanel` — fixed-count equivalent.

When adding a new vote panel, copy this pattern. Do **not** simply iterate left-to-right and put RANDOM at the end of the grid.

### 2. Vote IDs are 1-based on the wire

The console command is literally `vote N`. `client.cpp::Vote()` is the server-side dispatcher; it stores `N` in `g_pGameRules->m_iVoteCount[entindex - 1]`. Tally code reads `mapIndex - 1` to find the array slot.

### 3. Tie-breaking is 50/50 RNG

In each tally loop, when the highest count is matched, `RANDOM_LONG(0, 1)` decides whether to switch the leader. This is intentional — multi-way ties pick uniformly across all tied entries.

### 4. Bots vote randomly when the panel opens

Each open broadcast iterates fake clients and calls `::Vote(pPlayer, RANDOM_LONG(1, count + 1))`. The `count + 1` upper bound includes the synthetic RANDOM slot, which is fine because the server resolves it just like a player's RANDOM vote.

### 5. "Not enough votes" fallback

If the highest tally is `<= 0`, the server prints `[VOTE] Not enough votes received for next map. Using mapcycle.txt.` and falls back to the normal cycle (or, for gameplay/mutator, leaves the cvar untouched).

## User Messages — The Server↔Client Contract

| Message | Size | Direction | Body |
|---------|------|-----------|------|
| `VoteGame` | `1` | S→C broadcast | `BYTE timer` (0 closes the panel) |
| `VoteMutator` | `1` | S→C broadcast | `BYTE timer` |
| `VoteMap` | `1` | S→C broadcast | `BYTE timer` |
| `VoteFor` | `3` | S→C broadcast | `BYTE clientIndex; SHORT vote` (so every panel can show every player's running tally) |
| `MapList` | `-1` | S→C unicast | chunked map manifest; see [vgui_system.md](vgui_system.md#wire-format--maplist-user-message) |
| `GameOpts` | `-1` | S→C unicast | chunked game-options manifest (see [game_options_system.md](game_options_system.md)) |
| `VoteOpts` | `-1` | S→C broadcast | `BYTE rev; BYTE timer; BYTE activeCount; BYTE[] activeIndices` (timer=0 closes panel) |
| `VOptFor`  | `3`  | S→C broadcast | `BYTE clientIndex; BYTE item; BYTE option` (1-based) |
| `SrvOpts` | `-1` | S→C unicast | chunked server-options manifest (global scope; no `game` token) |
| `VoteSrvOp` | `-1` | S→C broadcast | `BYTE rev; BYTE timer; BYTE activeCount; BYTE[] activeIndices` (timer=0 closes panel) |
| `SOptFor`  | `3`  | S→C broadcast | `BYTE clientIndex; BYTE item; BYTE option` (1-based) |

All registered in `player.cpp::LinkUserMessages()`. **Names ≤10 chars** (≤8 is the safe target; see [server.md → User-Message Registry](server.md#user-message-registry)).

Missing/empty/malformed manifest behavior:
- `gameoptions.txt` and `serveroptions.txt` are optional. Missing/empty files do not crash and result in zero loaded rows.
- Parser drops malformed rows and keeps valid rows from the same file.
- If a manifest finishes with zero valid rows, that vote phase is skipped/ignored (RTV path reports no options; intermission path transitions to next phase).

## Mutator Vote Synthetic Slot

Mutator voting now includes one synthetic option that is **not** part of
`g_szMutators[]`:

- Display label: `INSTANT MUTATORS`
- Display position: injected immediately after `CHAOS` in the mutator panel grid
- Vote ID on wire: `MAX_MUTATORS + 2` (1-based)
- Tally index server-side: `MAX_MUTATORS + 1` (0-based)

Server mutator tally arrays are sized `MAX_MUTATORS + 2` and interpreted as:

- `0 .. MAX_MUTATORS-1`: real mutators from `g_szMutators[]`
- `MAX_MUTATORS`: RANDOM
- `MAX_MUTATORS + 1`: INSTANT MUTATORS (synthetic)

Selection/apply semantics:

- If INSTANT MUTATORS appears in the **top 3** mutator vote winners,
    server queues `sv_instantmutators 1` for next map.
- Otherwise, server queues `sv_instantmutators 0`.
- INSTANT MUTATORS does not consume a `sv_mutatorlist` slot; the mutator
    list is built from top winners filtered to real mutator indices only.

## Key Files (everything voting touches)

### Server
- `src/dlls/multiplay_gamerules.cpp` — vote phase machine in `Think()`, `RandomizeMutator()`, `BuildServerMapList()`, `SendMapListToClient()`, `ChangeLevel()` map override.
- `src/dlls/client.cpp::Vote()` — handles the `vote N` console command, dispatches `VoteFor`.
- `src/dlls/player.cpp::LinkUserMessages()` — vote and manifest user-message registration (`Vote*`, `MapList`, `GameOpts/VoteOpts/VOptFor`, `SrvOpts/VoteSrvOp/SOptFor`).
- `src/dlls/gamerules.h` — `VOTE_*` constants, `m_iVoteCount[MAX_PLAYERS]`, `m_iVoteUnderway`, `m_iDecidedMapIndex`, dynamic-map-list externs.

### Client
- `src/cl_dll/vgui_TeamFortressViewport.{h,cpp}` — `MsgFunc_VoteGame`, `MsgFunc_VoteMutator`, `MsgFunc_VoteMap`, `MsgFunc_VoteFor`, `MsgFunc_MapList`; dynamic-map-list globals.
- `src/cl_dll/vgui_VoteGameplayWindow.cpp` — `CVoteGameplayPanel`.
- `src/cl_dll/vgui_VoteMutatorWindow.cpp` — `CVoteMutatorPanel`.
- `src/cl_dll/vgui_VoteMapWindow.cpp` — `CVoteMapPanel` (dynamic; rebuilds buttons in `Open()`).
- `src/cl_dll/vgui_VoteGameOptionsWindow.cpp` — `CVoteGameOptionsPanel` (dynamic rows from active filtered game-options).
- `src/cl_dll/vgui_VoteServerOptionsWindow.cpp` — `CVoteServerOptionsPanel` (dynamic rows from active global server-options).
- `src/cl_dll/hud.cpp` — `HOOK_MESSAGE` registrations.

## Adding a New Vote — Cheatsheet

1. **Pick a name ≤10 chars** for the user message (e.g. `VoteSkin`, not `VoteCharacterSkin`).
2. **Server**:
   - Add `VOTE_<X>_TRANSITION` / `VOTE_<X>_OPEN` constants to `gamerules.h`.
   - Add a phase to the vote sequencer in `CHalfLifeMultiplay::Think`.
   - Register `gmsgVote<X>` in `player.cpp::LinkUserMessages()`.
   - Extend `Vote()` in `client.cpp` to format the result string for the new mode.
3. **Client**:
   - Subclass `CMenuPanel` in `vgui_Vote<X>Window.cpp`. **Construct furniture in the ctor; build buttons in `Open()`.**
   - Add `MENU_VOTE<X>` to `vgui_TeamFortressViewport.h` and the `ShowVGUIMenu` switch.
   - Add `MsgFunc_Vote<X>` mirroring `MsgFunc_VoteMap`.
   - Add `__MsgFunc_Vote<X>` forwarder + `HOOK_MESSAGE(Vote<X>)` in `hud.cpp`.
4. **RANDOM rule**: top-left cell, last array index, vote ID = `count + 1`.
5. If the entries are dynamic (like the map list), follow the chunked-user-message pattern in [vgui_system.md → Wire Format](vgui_system.md#wire-format--maplist-user-message). Reset on `seq == 0`, commit on `isLast`.
