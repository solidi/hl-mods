# Voting System — Cross-cutting Spoke

> Parents: [cir.md](cir.md) · related to both [server.md](server.md) and [client.md](client.md) · sibling: [vgui_system.md](vgui_system.md)

The voting system spans both DLLs: the server runs the timer / tally / decision logic, the client renders the panels and forwards `vote N` console commands. There are **five** votes that fire in sequence at intermission — gameplay, **game-options**, **server-options**, mutator, map — and they all follow the same conventions. A sixth, **bot-options** vote is mid-match RTV only and never joins the intermission sequence (see [bot_options_system.md](bot_options_system.md)).

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
| Bot-options (RTV only) | Per-row `CVAR_SET_STRING` of each item in `botoptions.txt` (global, max 16 rows) | `g_BotOptions[]` parsed on first use | Each row picks the most-voted option; ties resolved with `RANDOM_LONG` |
| Mutator  | `sv_mutatorlist` to apply on next map, plus `sv_instantmutators` toggle | `g_szMutators[]` in gamerules (+ synthetic "INSTANT MUTATORS" vote slot) | RANDOM wins → server picks one (or two) via `RandomizeMutator()` |
| Map      | `m_iDecidedMapIndex` overriding the cycle's next-up | `g_szServerMaps[]` (dynamic; see [vgui_system.md](vgui_system.md#dynamic-map-list)) | Wins → server re-rolls into a real index |

## Common Conventions (RANDOM-slot convention: gameplay/mutator/map)

### RTV gate and cooldown (gamemodes/maps/mutator/gameoptions/serveroptions/botoptions)

- Chat RTV paths for `gamemodes`, `maps`, `mutator`, `gameoptions`, `serveroptions`, and `botoptions` share one lock.
- While one of these RTVs is collecting votes or has its vote panel open, the other RTV commands are blocked.
- Blocked callers receive explicit feedback naming which RTV currently owns the lock and how many seconds remain.
- After an RTV ends (or its collection window expires), `mp_rtvcooldown` seconds must pass before another RTV type can be started.
- RTV static collection windows are epoch-synced to server/map lifetime in `client.cpp`, so stale collect/vote state does not survive a map restart.
- Startup cooldown is anchored to map-start time (not first chat attempt), so fresh map loads cannot trigger immediate RTV.
- RTV collection quorum is computed as majority (`eligibleHumans/2 + 1`) using connected human net-clients only: bots/proxies/disconnected clients are excluded.
- During an active RTV collection window, required votes are recalculated on each contribution and the tally only counts currently eligible humans, preventing stale "need one more vote" states after disconnect/state churn.

### Mid-game RTV chat commands

- `gamemodes` in chat starts/joins a majority RTV collection window (`rtvtime`), then opens the gameplay vote panel (`VoteForGameplayRTV`).
- `maps` in chat starts/joins a majority RTV collection window (`rtvtime`), then opens the map vote panel (`VoteForMapRTV`).
- `botoptions` in chat starts/joins a majority RTV collection window, then opens the bot-options panel (`VoteForBotOptions`). It is rejected during intermission, and `GoToIntermission()` force-closes and tallies an open bot vote so it never overlaps the end-of-game panels.
- The generic `vote`/`rtv` match in `GameplayVote()` ignores text that names a specific RTV (`gamemodes`, `maps`, `mutators`, `gameoptions`, `serveroptions`, `botoptions`). Add new RTV keywords to that exclusion list.
- Spectators/observers are allowed to start and participate in RTV collection (policy change); only bots/proxies are excluded from quorum math.
- On successful gameplay/map RTV tally, the server prints an explicit success line naming the selected mode/map, then calls `EndMultiplayerGame()`.
- Successful gameplay/map RTV sets `m_bSkipIntermissionVoting = TRUE`, so intermission is short (`mp_chattime` only) and does not run the full five-phase intermission vote sequence again.
- Mid-game RTV panel close UX uses a grace delay instead of immediate hide:
    - gameplay/maps: panel hides about 2.0s after local vote selection.
    - game-options/server-options/bot-options (RTV flags bit0 path): panel hides about 2.0s after local player has voted every active row.
    - intermission/end-of-round flow remains server-driven (`timer=0` close), so panels stay up through the phase.

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

### 2.1 Vote confirmation text must follow active vote context

- `client.cpp::Vote()` is shared by gameplay, map, and mutator vote panels, so display-name formatting must infer which vote is currently open.
- Intermission path uses `m_iVoteUnderway` (`VOTE_GAMEPLAY_OPEN`, `VOTE_MAPS_OPEN`).
- Mid-game RTV path also checks active RTV vote windows (`RTV_GATE_STATE_VOTING` + gate kind) and RTV timers (`m_fGameplayVoteTime`, `m_fMapVoteTime`).
- Map context is resolved before gameplay/mutator fallback so map selections cannot print mutator labels.
- Mutator name lookup is fallback-only when no gameplay/map context is active.

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
| `VoteMutator` | `-1` | S→C broadcast | `BYTE timer` + optional `BYTE mode` (mode-aware title/context) |
| `VoteMap` | `-1` | S→C broadcast | `BYTE timer` + optional `BYTE mode` (mode-aware title/context) |
| `VoteFor` | `3` | S→C broadcast | `BYTE clientIndex; SHORT vote` (so every panel can show every player's running tally) |
| `MapList` | `-1` | S→C unicast | chunked map manifest; see [vgui_system.md](vgui_system.md#wire-format--maplist-user-message) |
| `GameOpts` | `-1` | S→C unicast | chunked game-options manifest (see [game_options_system.md](game_options_system.md)) |
| `VoteOpts` | `-1` | S→C broadcast | `BYTE rev; BYTE timer; BYTE activeCount; BYTE[] activeIndices` (timer=0 closes panel) |
| `VOptFor`  | `3`  | S→C broadcast | `BYTE clientIndex; BYTE item; BYTE option` (1-based) |
| `SrvOpts` | `-1` | S→C unicast | chunked server-options manifest (global scope; no `game` token) |
| `VoteSrvOp` | `-1` | S→C broadcast | `BYTE rev; BYTE timer; BYTE activeCount; BYTE[] activeIndices` (timer=0 closes panel) |
| `SOptFor`  | `3`  | S→C broadcast | `BYTE clientIndex; BYTE item; BYTE option` (1-based) |
| `BotOpts` | `-1` | S→C unicast | chunked bot-options manifest (same layout as `SrvOpts`; streamed ~5s after connect) |
| `VoteBotOp` | `-1` | S→C broadcast | `BYTE rev; BYTE timer; BYTE activeCount; BYTE[] activeIndices; BYTE mode; BYTE flags` (timer=0 closes panel) |
| `BOptFor`  | `3`  | S→C broadcast | `BYTE clientIndex; BYTE item; BYTE option` (1-based) |

All registered in `player.cpp::LinkUserMessages()`. **Names ≤10 chars** (≤8 is the safe target; see [server.md → User-Message Registry](server.md#user-message-registry)).

Missing/empty/malformed manifest behavior:
- `gameoptions.txt`, `serveroptions.txt` and `botoptions.txt` are optional. Missing/empty files do not crash and result in zero loaded rows.
- Parser drops malformed rows and keeps valid rows from the same file.
- If a manifest finishes with zero valid rows, that vote phase is skipped/ignored (RTV path reports no options; intermission path transitions to next phase).

## Manifest Streaming (connect-time balancing)

Every human client receives four dynamic manifests: `MapList`, `GameOpts`, `SrvOpts`, `BotOpts`. `InitHUD` only queues them (per-client cursor = 0); `CHalfLifeMultiplay::PumpClientManifestSends()` (every `Think`) streams them so connecting never floods the reliable channel:

- **Pacing:** at most one manifest chunk per client every `MANIFEST_STREAM_INTERVAL` (0.1s, ≤ ~1.9 KB/s), gated by `m_fManifestNextSend[]`.
- **Serialized priority:** one manifest at a time per client, in order MapList → GameOpts → SrvOpts → BotOpts.
- **Bot delay:** `BotOpts` is held until `m_fBotOptionsStreamStart[]` = InitHUD + `BOT_OPTIONS_SEND_DELAY` (5s), because it is only needed for a mid-match RTV. Opening a bot vote or a `botoptions_resend` releases it immediately.
- **Resends are paced too:** `gameoptions_resend` / `serveroptions_resend` / `botoptions_resend` restart the client's stream (`Send*OptionsToClient` only resets the cursor) instead of bursting every chunk in one frame.
- `Ensure*List()` is called lazily, only when a chunk of that manifest is about to be written.
- Vote openers that find a stale client (`m_i*RevisionSent != g_i*Revision`) restart that client's stream (G5). The open message still goes out right away, so a stale client may briefly see the "Waiting for ... manifest" placeholder.

When adding a new streamed manifest: add cursor/seq arrays, reset them in `InitHUD`/`ClientDisconnected`, add a branch at the right priority in `PumpClientManifestSends()`, and never write chunks outside the pump.

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
- `src/dlls/multiplay_gamerules.cpp` — vote phase machine in `Think()`, mid-game RTV tallies (`CheckGameplayRTV`, `CheckMapRTV`, `CheckMutatorRTV`, `CheckGameOptionsRTV`, `CheckServerOptionsRTV`, `CheckBotOptionsRTV`), vote openers (`VoteForGameplayRTV`, `VoteForMapRTV`, `VoteForMutator`, `VoteForGameOptions`, `VoteForServerOptions`, `VoteForBotOptions`), `RandomizeMutator()`, `BuildServerMapList()`, `PumpClientManifestSends()` (paced manifest streaming), shared server/bot option helpers (`BuildGlobalOptionsList`, `WriteGlobalOptionsChunk`, `TallyGlobalOptionRows`), `ChangeLevel()` map override.
- `src/dlls/client.cpp::Vote()` — handles the `vote N` console command, dispatches `VoteFor`, and resolves user-facing vote confirmation text from intermission or mid-game RTV vote context. Per-row option votes use `voteopt` / `votesrvopt` / `votebotopt`.
- `src/dlls/player.cpp::LinkUserMessages()` — vote and manifest user-message registration (`Vote*`, `MapList`, `GameOpts/VoteOpts/VOptFor`, `SrvOpts/VoteSrvOp/SOptFor`, `BotOpts/VoteBotOp/BOptFor`).
- `src/dlls/gamerules.h` — `VOTE_*` constants, `m_iVoteCount[MAX_PLAYERS]`, `m_iVoteUnderway`, `m_iDecidedMapIndex`, dynamic-map-list externs.

### Client
- `src/cl_dll/vgui_TeamFortressViewport.{h,cpp}` — `MsgFunc_VoteGame`, `MsgFunc_VoteMutator`, `MsgFunc_VoteMap`, `MsgFunc_VoteFor`, `MsgFunc_MapList`; dynamic-map-list globals.
- `src/cl_dll/vgui_VoteGameplayWindow.cpp` — `CVoteGameplayPanel`.
- `src/cl_dll/vgui_VoteMutatorWindow.cpp` — `CVoteMutatorPanel`.
- `src/cl_dll/vgui_VoteMapWindow.cpp` — `CVoteMapPanel` (dynamic; rebuilds buttons in `Open()`).
- `src/cl_dll/vgui_VoteGameOptionsWindow.cpp` — `CVoteGameOptionsPanel` (dynamic rows from active filtered game-options).
- `src/cl_dll/vgui_VoteServerOptionsWindow.cpp` — `CVoteServerOptionsPanel` (dynamic rows from active global server-options).
- `src/cl_dll/vgui_VoteBotOptionsWindow.cpp` — `CVoteBotOptionsPanel` (RTV-only bot-options rows; rebuilds when a late manifest lands).
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
5. If the entries are dynamic (like the map list), follow the chunked-user-message pattern in [vgui_system.md → Wire Format](vgui_system.md#wire-format--maplist-user-message). Reset on `seq == 0`, commit on `isLast`. Stream it through `PumpClientManifestSends()` (see [Manifest Streaming](#manifest-streaming-connect-time-balancing)); never burst all chunks in one frame.
6. **RTV-only votes** (like bot-options) skip steps 2's `VOTE_*` constants and sequencer phase. They need their own `RTV_GATE_KIND_*` in `client.cpp`, a `Check<X>RTV()` timer in `Think()`, an exclusion in `GameplayVote()`'s generic `rtv` match, and a `GoToIntermission()` force-close so the panel never overlaps the end-of-game sequence. Leave the menu ID out of the intermission allow-list in `ShowVGUIMenu`.
