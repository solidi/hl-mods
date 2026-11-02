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
VOTE_MUTATOR_OPEN    ──▶ gmsgVoteMutator(timer)   ─────▶ CVoteMutatorPanel (plus synthetic INSTANT MUTATORS and CLEAR slots)
    │ wait voting*1 seconds; tally; broadcast result
    ▼
VOTE_MAPS_TRANSITION
    │ wait voting*1 seconds
    ▼
VOTE_MAPS_OPEN       ──▶ gmsgVoteMap(timer)       ─────▶ CVoteMapPanel
    │ EnsureServerMapList() runs here
    │ every phase: ScheduleBotVotes(); bots pick 0.75-4.5s after opening (sv_botsvote)
    │ wait voting*1 seconds (or close ~2s after everyone voted); tally; pick winner
    ▼
m_iDecidedMapIndex set; ChangeLevel() honors it
```

`VOTE_*` constants live in `gamerules.h`; the timer cvar is `voting` (seconds per phase, ×5 phases, ≥10 to trigger). Total intermission scales to `voting*5 + 15` seconds, minus any time cut by [early close](#early-close-when-everyone-has-voted) or skipped empty option phases.

## What Each Vote Decides

| Vote | Decides | Authoritative array | RANDOM behavior |
|------|---------|---------------------|-----------------|
| Gameplay | `g_GameMode` for next map | `gamePlayModes[]` in `multiplay_gamerules.cpp` | Wins → server picks any mode |
| Game-options | Per-row `CVAR_SET_STRING` of each item in `gameoptions.txt` whose `game` matches new `g_GameMode` or is `*` | `g_GameOptions[]` parsed at boot/mtime change | Each row picks the most-voted option; ties resolved with `RANDOM_LONG` |
| Server-options | Per-row `CVAR_SET_STRING` of each item in `serveroptions.txt` (global, no mode filtering) | `g_ServerOptions[]` parsed at boot/mtime change | Each row picks the most-voted option; ties resolved with `RANDOM_LONG` |
| Bot-options (RTV only) | Per-row `CVAR_SET_STRING` of each item in `botoptions.txt` (global, max 16 rows) | `g_BotOptions[]` parsed on first use | Each row picks the most-voted option; ties resolved with `RANDOM_LONG` |
| Mutator  | `sv_mutatorlist` to apply on next map, plus `sv_instantmutators` toggle | `g_szMutators[]` in gamerules (+ synthetic "INSTANT MUTATORS" and "CLEAR" vote slots) | RANDOM wins → server picks one (or two) via `RandomizeMutator()`; CLEAR tying or beating the leader → no mutators at all |
| Map      | `m_iDecidedMapIndex` overriding the cycle's next-up | `g_szServerMaps[]` (dynamic; see [vgui_system.md](vgui_system.md#dynamic-map-list)) | Wins → server re-rolls into a real index |

## Common Conventions (RANDOM-slot convention: gameplay/mutator/map)

### RTV gate and cooldown (gamemodes/maps/mutator/gameoptions/serveroptions/botoptions)

- Chat RTV paths for `gamemodes`, `maps`, `mutator`, `gameoptions`, `serveroptions`, and `botoptions` share one lock.
- **No RTV after the match ends.** `RTVGateBlocksCall()` first calls `RTVBlockedAfterMatch()`, which refuses every keyword RTV once `g_fGameOver` is set (the end-of-game votes own `m_iVoteCount[]`, the option matrices and the panels, so an RTV opened then would reset the open phase). The generic `vote`/`rtv` in `GameplayVote()` calls the same helper. Every `VoteFor*` RTV opener is only reachable through these guarded handlers; a new RTV must go through `RTVGateBlocksCall()` too.
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
- `botoptions` in chat starts/joins a majority RTV collection window, then opens the bot-options panel (`VoteForBotOptions`). Like every RTV it is rejected once the match is over (see the RTV gate above).
- **RTV votes never run into intermission.** `GoToIntermission()` calls `SettleOpenRTVVotes()` first, which force-closes and tallies every open RTV (`Check*RTV(TRUE)`): option rows apply without a map restart, a mutator RTV records `sv_instantmutators` without firing an instant mutator, and a winning gameplay/map RTV sets `m_bSkipIntermissionVoting` instead of ending the game a second time. Without this, a leftover RTV would share ballots and panels with the matching end-of-game phase (which early close can start sooner). `CheckGameplayRTV`/`CheckMapRTV` clear their `m_f*VoteTime` before tallying so the `EndMultiplayerGame()` → `GoToIntermission()` → settle path does not re-enter them.
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

### 4. Bots vote shortly after the panel opens (`sv_botsvote`)

All bot voting is centralized in `multiplay_gamerules.cpp`. Every vote opener (the 5 end-of-game phases and the 6 RTV openers) calls `ScheduleBotVotes(BOT_VOTE_*)` after resetting its ballot; nothing else casts bot votes.

- **`sv_botsvote`** (game DLL cvar, `game.cpp`, default `1`): `0` keeps bots out of every vote. Also votable from `botoptions.txt` and the listen-server dialog (`settings.scr`). Switching it to `0` mid-vote drops pending bot votes.
- **Timing:** each bot's first pick lands at a random time between `BOT_VOTE_MIN_DELAY` (0.75s) and `BOT_VOTE_MAX_DELAY` (4.5s) after the panel opens, using the average of two rolls so most bots pick mid-window and a few are quick or slow. For short RTV windows both bounds shrink to fit within half of `mp_voting`.
- **Option ballots** (game/server/bot options) are voted one row at a time, top to bottom, `0.25-0.7s` apart. Rows that would fall after the deadline are all cast on it, so every bot has a full ballot within 4.5s of the panel opening.
- **Choices** match a human's panel: gameplay `RANDOM_LONG(1, TOTAL_GAME_MODES + 2)` and map `RANDOM_LONG(1, count + 1)` (last ID is RANDOM), mutator `RandomizeMutator()` (a real mutator the mode allows) or CLEAR `BOT_VOTE_CLEAR_CHANCE` (5%) of the time; bots never pick RANDOM or INSTANT MUTATORS. Option rows are uniform per row.
- **Casting:** single picks go through `::Vote()` (same `VoteFor` broadcast, tally and `m_fLastVoteCastTime` stamp as a human). Row picks write the per-row matrix, stamp `m_fLastVoteCastTime` and broadcast `VOptFor` / `SOptFor` / `BOptFor`, as `VoteOption()` does for humans.
- **`ProcessBotVotes()`** runs first in `VoteThink()`. It drops all pending bot votes once the vote they belong to is no longer open (`BotVoteKindOpen()`), so a bot never votes into a closed or later ballot. A bot that leaves is skipped, and `ClientConnected` clears a reused slot's schedule.
- **Early close waits for bots:** `VoteEarlyCloseTime()` holds while `BotVotesPending()`, and bot picks stamp `m_fLastVoteCastTime`, so a vote never closes before the bots have voted. Worst case it closes about `4.5 + 2.0`s after opening.
- Bots still never count toward RTV quorum (typing `rtv`/`maps`/... in chat) and are not "eligible voters" for early close; a server with only bots runs each vote its full length.

### 5. "Not enough votes" fallback

If the highest tally is `<= 0`, the server prints `[VOTE] Not enough votes received for next map. Using mapcycle.txt.` and falls back to the normal cycle (or, for gameplay/mutator, leaves the cvar untouched).

### 6. Votes reset when a panel opens

Every vote opener clears its ballot before bots vote: `m_iVoteCount[]` for gameplay/mutator/map (intermission and RTV), and the per-row matrices for game/server/bot options. `vote N` from the console is accepted outside a vote window, so without the reset a stale pick would be tallied and would count as "voted" for early close. Ballots are stored per player slot, so `CHalfLifeMultiplay::ClientConnected` also clears the slot's ballots: a player joining mid-vote never inherits the previous occupant's votes.

## Early Close When Everyone Has Voted

Every RTV vote and every end-of-game phase closes early once all eligible voters are in, instead of idling out the `voting` timer.

- **Eligible voters:** `RTVIsEligibleHumanVoter()` (client.cpp), the same set used for RTV quorum: connected human net clients, spectators included; bots, HLTV proxies and disconnecting clients excluded. With zero eligible humans the vote runs its full length.
- **Voted:** gameplay/mutator/map need `m_iVoteCount[idx] >= 1`; game/server/bot options need every active row voted (`m_i*OptionsVotes[idx][k] >= 0`), matching the client's RTV auto-close rule.
- **When:** `min(normal end, m_fLastVoteCastTime + VOTE_EARLY_CLOSE_DELAY)` (2.0s), and never while a bot vote is still pending (see [§4](#4-bots-vote-shortly-after-the-panel-opens-sv_botsvote)). `m_fLastVoteCastTime` is set by `Vote()`, `VoteOption()`, `VoteServerOption()`, `VoteBotOption()` and bot row picks, so revising a vote pushes the close out again, never past the normal end. If the last holdout disconnects, the vote closes right away.
- **Notice:** `[VOTE] All votes are in. Closing the vote early.` once per vote window (`m_fEarlyCloseNoticeEnd`), only when it saves at least 1s.
- **RTV path:** `CheckRTVVoteEarlyClose()` → `EarlyCloseRTVWindow()` pulls the RTV's `m_f*VoteTime` in to now, so its `Check*RTV()` tallies the same frame, and calls `RTVGateVoteClosedEarly()` so the shared RTV gate's vote window (and therefore the cooldown) ends with it.
- **Intermission path:** `CheckIntermissionVoteEarlyClose()` runs at the top of the voting block in `Think()`. Phase *k* (1 gameplay … 5 map) ends at `m_flIntermissionEndTime - mp_chattime - (timeLeft - voting*k - 3k)`; closing early adds the remaining time to `m_flIntermissionVoteShift`, which pulls the whole schedule forward. The 3s transitions, later phases and post-vote `mp_chattime` keep their lengths.
- **`m_flIntermissionVoteShift`:** `Think()` recomputes `m_flIntermissionEndTime` from `g_flIntermissionStartTime` every frame, so any schedule cut must go through this member (reset in `GoToIntermission()`), never a bare `m_flIntermissionEndTime -=`. The G8 "no options to vote on" skips use it too.
- Clients need no change: panels close on the server's `timer=0` close message as usual. The countdown label keeps the original timer until then.

### `VoteThink()` must run in every mode

`CHalfLifeMultiplay::VoteThink()` runs delayed bot votes (`ProcessBotVotes()`), the early-close check, every `Check*RTV()` timer and `PumpClientManifestSends()`. The base `Think()` calls it each frame. `CHalfLifeTeamplay::Think` and `CHalfLifeGunGame::Think` only chain to the base `Think()` at game over, so they call `VoteThink()` themselves mid-match. Before this, no RTV vote closed mid-match in Teamplay, only the mutator RTV did in GunGame, and the manifests only streamed at intermission in both. A new mode `Think()` that does not call the base every frame must call `VoteThink()`.

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

## Mutator Vote Synthetic Slots

The mutator vote has three synthetic options that are **not** part of
`g_szMutators[]`. Their vote IDs are defined once in `common/const.h` and
shared by the server tally and the client panel:

| Option | Vote ID (`vote N`) | Slot (vote ID − 1) | Panel position | Subtitle |
|---|---|---|---|---|
| RANDOM | `MUTATOR_VOTE_RANDOM` = `MAX_MUTATORS_CL` = `MAX_MUTATORS + 1` | `MAX_MUTATORS` | row 0, left | (from `sMutators[]`) |
| INSTANT MUTATORS | `MUTATOR_VOTE_INSTANT` = `MAX_MUTATORS + 2` | `MAX_MUTATORS + 1` | row 1, left | "swapped stats, tripmines, etc." |
| CLEAR | `MUTATOR_VOTE_CLEAR` = `MAX_MUTATORS + 3` | `MAX_MUTATORS + 2` | row 1, right (under CHAOS) | "No mutators, please." |

`MUTATOR_VOTE_SLOTS` (= `MUTATOR_VOTE_CLEAR`) is the highest vote ID. CHAOS is row 0 right; every other mutator follows CLEAR. A `typedef` in `multiplay_gamerules.cpp` fails the build if `MAX_MUTATORS` (server) and `MAX_MUTATORS_CL` (client) stop lining up with these IDs.

Both mutator tallies (end-of-game phase and `CheckMutatorRTV`) go through `TallyMutatorVotes()`, which counts every vote ID and ranks the top three of the real mutators, RANDOM and INSTANT MUTATORS. CLEAR is never ranked.

Selection/apply semantics:

- **CLEAR wins** when it has at least one vote and **ties or beats** the most-voted other option. Then nothing else applies: `sv_mutatorlist ""` and `sv_instantmutators 0` (end-of-game: no mutators next map; RTV: the running mutators, already cleared when the vote opened, stay cleared, and no instant mutator fires). It is announced as `[VOTE] CLEAR wins with N votes. ...`.
- Otherwise CLEAR votes are ignored and the top three apply as before:
    - If INSTANT MUTATORS is in the **top 3**, the server sets `sv_instantmutators 1` (RTV also fires one instant mutator now), else `0`.
    - INSTANT MUTATORS does not consume a `sv_mutatorlist` slot; the mutator list is built from top winners filtered to real mutator indices only.
    - A RANDOM winner is re-rolled with `RandomizeMutator()`.
- Bots (`sv_botsvote 1`) vote CLEAR `BOT_VOTE_CLEAR_CHANCE` (5%) of the time and otherwise a `RandomizeMutator()` pick; they never vote RANDOM or INSTANT MUTATORS. Because one CLEAR vote ties a field where every mutator has one vote, raise this chance with care.
- `Vote()` confirms CLEAR as `You voted for "CLEAR"`; the client panel outlines only CLEAR in green while it would win, mirroring the server rule.

## Key Files (everything voting touches)

### Server
- `src/dlls/multiplay_gamerules.cpp` — vote phase machine in `Think()`, `VoteThink()` (bot votes + RTV timers + early close + manifest pump), bot voting (`ScheduleBotVotes`, `ProcessBotVotes`, `BotVotesPending`, `BotVoteKindOpen`), early close (`CheckRTVVoteEarlyClose`, `CheckIntermissionVoteEarlyClose`, `AllEligibleVotersVoted`, `VoteEarlyCloseTime`), mid-game RTV tallies (`CheckGameplayRTV`, `CheckMapRTV`, `CheckMutatorRTV`, `CheckGameOptionsRTV`, `CheckServerOptionsRTV`, `CheckBotOptionsRTV`), vote openers (`VoteForGameplayRTV`, `VoteForMapRTV`, `VoteForMutator`, `VoteForGameOptions`, `VoteForServerOptions`, `VoteForBotOptions`), `RandomizeMutator()`, `BuildServerMapList()`, `PumpClientManifestSends()` (paced manifest streaming), shared server/bot option helpers (`BuildGlobalOptionsList`, `WriteGlobalOptionsChunk`, `TallyGlobalOptionRows`), `ChangeLevel()` map override.
- `src/dlls/teamplay_gamerules.cpp`, `src/dlls/gungame_gamerules.cpp` — mode `Think()` overrides that call `VoteThink()` mid-match.
- `src/dlls/client.cpp::Vote()` — handles the `vote N` console command, dispatches `VoteFor`, and resolves user-facing vote confirmation text from intermission or mid-game RTV vote context. Per-row option votes use `voteopt` / `votesrvopt` / `votebotopt`. All vote handlers stamp `m_fLastVoteCastTime`. Also home of `RTVIsEligibleHumanVoter()` and `RTVGateVoteClosedEarly()`.
- `src/dlls/player.cpp::LinkUserMessages()` — vote and manifest user-message registration (`Vote*`, `MapList`, `GameOpts/VoteOpts/VOptFor`, `SrvOpts/VoteSrvOp/SOptFor`, `BotOpts/VoteBotOp/BOptFor`).
- `src/dlls/gamerules.h` — `VOTE_*` constants, `bot_vote_kind_e` (`BOT_VOTE_*`), `m_iVoteCount[MAX_PLAYERS]`, `m_iVoteUnderway`, `m_iDecidedMapIndex`, bot vote schedule members (`m_iBotVoteKind`, `m_fBotVoteNext[]`, `m_iBotVoteRow[]`, `m_fBotVoteDeadline`), dynamic-map-list externs.
- `src/dlls/game.cpp` — `sv_botsvote` (`botsvote`) registration, next to `mp_voting` / `mp_rtvtime` / `mp_rtvcooldown`.

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
   - Reset the new ballot when the panel opens, then call `ScheduleBotVotes()` with a new `BOT_VOTE_*` kind (add it to `BotVoteKindOpen()` and the pick logic in `ProcessBotVotes()`); never cast bot votes inline. Stamp `m_fLastVoteCastTime` in its vote handler, and add it to early close (a `vote_ballot_e` value in `AllEligibleVotersVoted`, plus a `case` in `CheckIntermissionVoteEarlyClose` or an `EarlyCloseRTVWindow` call in `CheckRTVVoteEarlyClose`). Run its RTV timer from `VoteThink()`, not from `Think()` directly.
3. **Client**:
   - Subclass `CMenuPanel` in `vgui_Vote<X>Window.cpp`. **Construct furniture in the ctor; build buttons in `Open()`.**
   - Add `MENU_VOTE<X>` to `vgui_TeamFortressViewport.h` and the `ShowVGUIMenu` switch.
   - Add `MsgFunc_Vote<X>` mirroring `MsgFunc_VoteMap`.
   - Add `__MsgFunc_Vote<X>` forwarder + `HOOK_MESSAGE(Vote<X>)` in `hud.cpp`.
4. **RANDOM rule**: top-left cell, last array index, vote ID = `count + 1`.
5. If the entries are dynamic (like the map list), follow the chunked-user-message pattern in [vgui_system.md → Wire Format](vgui_system.md#wire-format--maplist-user-message). Reset on `seq == 0`, commit on `isLast`. Stream it through `PumpClientManifestSends()` (see [Manifest Streaming](#manifest-streaming-connect-time-balancing)); never burst all chunks in one frame.
6. **RTV-only votes** (like bot-options) skip steps 2's `VOTE_*` constants and sequencer phase. They need their own `RTV_GATE_KIND_*` in `client.cpp`, a `Check<X>RTV()` timer in `Think()`, an exclusion in `GameplayVote()`'s generic `rtv` match, and a `GoToIntermission()` force-close so the panel never overlaps the end-of-game sequence. Leave the menu ID out of the intermission allow-list in `ShowVGUIMenu`.
