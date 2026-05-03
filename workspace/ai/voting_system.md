# Voting System — Cross-cutting Spoke

> Parents: [cir.md](cir.md) · related to both [server.md](server.md) and [client.md](client.md) · sibling: [vgui_system.md](vgui_system.md)

The voting system spans both DLLs: the server runs the timer / tally / decision logic, the client renders the panels and forwards `vote N` console commands. There are **three** votes that fire in sequence at intermission — gameplay, mutator, map — and they all follow the same conventions.

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
VOTE_MUTATOR_OPEN    ──▶ gmsgVoteMutator(timer)   ─────▶ CVoteMutatorPanel
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

`VOTE_*` constants live in `gamerules.h`; the timer cvar is `voting` (seconds per phase, ×3 phases, ≥10 to trigger).

## What Each Vote Decides

| Vote | Decides | Authoritative array | RANDOM behavior |
|------|---------|---------------------|-----------------|
| Gameplay | `g_GameMode` for next map | `gamePlayModes[]` in `multiplay_gamerules.cpp` | Wins → server picks any mode |
| Mutator  | `sv_mutatorlist` to apply on next map | `g_szMutators[]` in gamerules | Wins → server picks one (or two) via `RandomizeMutator()` |
| Map      | `m_iDecidedMapIndex` overriding the cycle's next-up | `g_szServerMaps[]` (dynamic; see [vgui_system.md](vgui_system.md#dynamic-map-list)) | Wins → server re-rolls into a real index |

## Common Conventions (all three votes)

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

All registered in `player.cpp::LinkUserMessages()`. **Names ≤10 chars** (≤8 is the safe target; see [server.md → User-Message Registry](server.md#user-message-registry)).

## Key Files (everything voting touches)

### Server
- `src/dlls/multiplay_gamerules.cpp` — vote phase machine in `Think()`, `RandomizeMutator()`, `BuildServerMapList()`, `SendMapListToClient()`, `ChangeLevel()` map override.
- `src/dlls/client.cpp::Vote()` — handles the `vote N` console command, dispatches `VoteFor`.
- `src/dlls/player.cpp::LinkUserMessages()` — `gmsgVoteGameplay`, `gmsgVoteMutator`, `gmsgVoteMap`, `gmsgVoteFor`, `gmsgMapList` registration.
- `src/dlls/gamerules.h` — `VOTE_*` constants, `m_iVoteCount[MAX_PLAYERS]`, `m_iVoteUnderway`, `m_iDecidedMapIndex`, dynamic-map-list externs.

### Client
- `src/cl_dll/vgui_TeamFortressViewport.{h,cpp}` — `MsgFunc_VoteGame`, `MsgFunc_VoteMutator`, `MsgFunc_VoteMap`, `MsgFunc_VoteFor`, `MsgFunc_MapList`; dynamic-map-list globals.
- `src/cl_dll/vgui_VoteGameplayWindow.cpp` — `CVoteGameplayPanel`.
- `src/cl_dll/vgui_VoteMutatorWindow.cpp` — `CVoteMutatorPanel`.
- `src/cl_dll/vgui_VoteMapWindow.cpp` — `CVoteMapPanel` (dynamic; rebuilds buttons in `Open()`).
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
