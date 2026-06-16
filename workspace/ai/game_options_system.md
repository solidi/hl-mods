# Game-Options Voting System — Spoke

> Parents: [voting_system.md](voting_system.md) · related to [vgui_system.md](vgui_system.md) · server entry [server.md](server.md)

A fourth, **dynamic** vote in the intermission sequence. Server-defined items are loaded from `redist/gameoptions.txt`, filtered against the just-decided `g_GameMode`, sent to all clients, voted per-row, and applied via `CVAR_SET_STRING`.

## File Format (`redist/gameoptions.txt`)

Source KV style. One block per item, ≤32 items per file. Each block defines one row in the vote panel.

```
"Friendly Fire"
{
    "game"    "*"               // mode short-name (szGameModeList) or "*" for all
    "cvar"    "mp_friendlyfire" // [A-Za-z0-9_]+ only
    "restart" "0"               // 1 = changelevel after mid-game RTV apply
    "Off"     "0"               // 2-5 label→value pairs follow
    "On"      "1"
}
```

Forbidden in values: `; \n \r " \ $` (G7 injection guard — values reach `CVAR_SET_STRING` directly, never the command parser).

See the file's leading comment for full details; example with several rows ships in `workspace/redist/gameoptions.txt` and mirrors to mod redists (`ci/`, `hla/`).

## Lifecycle

```
boot / mtime change
   │
   ▼
BuildGameOptionsList()  → g_GameOptions[]  (validated + revision++)
   │
   ▼ (per client InitHUD or gameoptions_resend cmd)
SendGameOptionsToClient(edict)  → MsgFunc_GameOpts chunks → g_GameOptionsClient[]
   │
   ▼ (at intermission, after gameplay vote tally)
VOTE_GAMEOPTIONS_TRANSITION → BuildActiveGameOptions() (filter for new g_GameMode)
   │   if 0 items: G8 path -- skip phase, advance to mutator
   │
   ▼
VOTE_GAMEOPTIONS_OPEN  → gmsgVoteOpts(rev,timer,N,idx…)  → CVoteGameOptionsPanel
   │   bots cast RANDOM_LONG per row; humans click buttons → "voteopt R O" cmd
   │   each vote echoes via gmsgVOptFor for live tally
   │
   ▼
TallyGameOptionsVote(fromRTV=FALSE)
   │   per row: pick max-vote option (ties → RANDOM_LONG)
   │   G7.1: re-validate forbidden chars before applying
   │   G7.2: re-resolve cvar pointer before applying
   │   CVAR_SET_STRING(cvar, winnerValue)
   │
   ▼
VOTE_MUTATOR_TRANSITION ...
```

## Mid-game RTV Path

Chat `gameoptions` → `Host_Say` → `GameOptionsVote()` accumulates substring matches (same threshold logic as mutator RTV). On success: `VoteForGameOptions(TRUE)` opens the panel immediately. Tally runs on a small standalone timer (`CheckGameOptionsRTV()` checked every Think frame). If any winning row had `restart=1`, the server issues a `changelevel <current>` so the new cvars take effect on a fresh round.

G9 path: if `BuildActiveGameOptions()` finds 0 matches at RTV time, the initiator gets a direct chat reply ("No game options available for the current mode") rather than spamming everyone.

## Wire Protocol Details

### `GameOpts` — manifest, chunked (S→C unicast on connect / on resend request)

Each chunk:
```
BYTE   revision         // bumps on every BuildGameOptionsList() run; clients use this for G6 detection
BYTE   seq              // 0 = first chunk
BYTE   isLast
BYTE   total            // total items being sent
BYTE   numInChunk       // items in THIS chunk (GAME_OPTIONS_PER_CHUNK = 2)
For each item in chunk:
  STRING game           // 1-15 chars
  STRING title          // 1-63 chars
  BYTE   restart
  BYTE   numOptions     // 2-5
  For each option:
    STRING label        // 1-23 chars (values are NEVER sent client-side)
```

G6: revision is included on every chunk. If a client sees a mismatch mid-stream, it drops the partial buffer and auto-requests `gameoptions_resend`.

### `VoteOpts` — open/close panel (S→C broadcast)

```
BYTE revision
BYTE timer              // 0 closes (clear votes + hide)
BYTE activeCount        // 0..32
BYTE[] activeIndices    // each indexes into g_GameOptionsClient[]
```

If client revision mismatches and panel opened, render a "waiting" placeholder row (G4) and auto-fire `gameoptions_resend`.

### `VOptFor` — mirrored per-row vote (S→C broadcast)

```
BYTE clientIndex   // 1-based
BYTE item          // 1-based, indexes into the ACTIVE list, not the full manifest
BYTE option        // 1-based, into the item's labels
```

Server stores into `m_iGameOptionsVotes[player-1][item-1]`. Clients also mirror into `g_PlayerOptVote[client][item-1]` for live tally rendering.

## Console Commands

| Command | Where | Notes |
|---------|-------|-------|
| `voteopt <item> <option>` | client → server | Bound from each panel button. Item and option are 1-based. Sets `m_fVoteCoolDown += 1.0`. Plays `CLIENT_SOUND_GREATJOB`. |
| `gameoptions_resend`     | client → server | Rate-limited: `m_fGameOptsResendCoolDown` (5 sec). Re-streams the manifest to the requesting client. |
| `gameoptions_status`     | client → server | Listenserver host or `sv_cheats 1` only. Dumps revision, parse log, item table with current cvar values. |
| `gameoptions`            | chat (RTV)      | `GameOptionsVote()` in `client.cpp` — substring match in `Host_Say`, threshold count via existing RTV mechanism. |

## Key Files

### Server
- `src/dlls/multiplay_gamerules.cpp` — `BuildGameOptionsList()`, `EnsureGameOptionsList()`, `SendGameOptionsToClient()`, `BuildActiveGameOptions()`, `TallyGameOptionsVote()`, `VoteForGameOptions()`, `CheckGameOptionsRTV()`, vote sequencer integration.
- `src/dlls/gamerules.h` — `VOTE_GAMEOPTIONS_*` constants, `game_option_t` struct, all `m_iGameOptions*` / `m_iActiveGameOptions*` / RTV state on `CHalfLifeMultiplay`.
- `src/dlls/client.cpp` — `VoteOption()`, `GameOptionsVote()` (RTV chat handler), `voteopt` / `gameoptions_resend` / `gameoptions_status` console commands.
- `src/dlls/player.cpp::LinkUserMessages()` — `gmsgGameOpts`, `gmsgVoteOpts`, `gmsgVOptFor` registration.

### Client
- `src/cl_dll/vgui_TeamFortressViewport.{h,cpp}` — `MsgFunc_GameOpts`, `MsgFunc_VoteOpts`, `MsgFunc_VOptFor`; all `g_GameOptionsClient*` globals; `MENU_VOTEGAMEOPTIONS` switch case + factory.
- `src/cl_dll/vgui_VoteGameOptionsWindow.cpp` — `CVoteGameOptionsPanel` (dynamic row rebuild in `BuildRows()` at every `Open()`).
- `src/cl_dll/hud.cpp` — `HOOK_MESSAGE` registrations and `__MsgFunc_*` shims.

### Distribution
- `workspace/redist/gameoptions.txt` — canonical example; mirrors to `ci/redist/`, `hla/redist/`.
- `workspace/manifest` — server-side file list includes `gameoptions.txt` (alongside `mapcycle.txt`).

## Limits

| Constant | Value | Where |
|----------|-------|-------|
| `MAX_GAME_OPTIONS` | 32 | `gamerules.h` |
| `MAX_GAME_OPTION_VALUES` | 5 | `gamerules.h` |
| `MAX_GAME_OPTION_TITLE` | 64 | `gamerules.h` |
| `MAX_GAME_OPTION_CVAR` | 32 | `gamerules.h` |
| `MAX_GAME_OPTION_LABEL` | 24 | `gamerules.h` |
| `MAX_GAME_OPTION_GAME` | 16 | `gamerules.h` |
| `MAX_GAME_OPTION_VALUE` | 32 | `gamerules.h` |
| `GAME_OPTIONS_PER_CHUNK` | 2 | (compile-time in `SendGameOptionsToClient`; keeps each user-message ≤192 bytes) |

## Safety / Validation Rules (G-series)

| Rule | What | Where enforced |
|------|------|---------------|
| G1.a | Skip blank/malformed blocks; log line number | `BuildGameOptionsList()` |
| G1.b | Cvar names match `[A-Za-z0-9_]+` | `GameOptionsCvarNameClean()` |
| G1.c | `game` matches `*` or a `szGameModeList` entry | `GameOptionsGameTagValid()` |
| G1.d | 2-5 options per item | `BuildGameOptionsList()` |
| G1.e | Length caps on all strings | `BuildGameOptionsList()` |
| G1.f | Cvar must currently resolve (`CVAR_GET_POINTER`) | `BuildGameOptionsList()` |
| G1.g | Reject duplicate option labels per item | `BuildGameOptionsList()` |
| G1.h | Values reject forbidden chars `; \n \r " \ $` | `GameOptionsValueClean()` |
| G3   | Sequence/total check on chunked receive | `MsgFunc_GameOpts` |
| G4   | Stale revision → placeholder panel + auto-resend | `MsgFunc_VoteOpts` |
| G5   | Resend manifest to stale clients before opening panel | `Think()` VOTE_GAMEOPTIONS_TRANSITION, `VoteForGameOptions()` |
| G6   | Revision byte on every chunk and panel open | `SendGameOptionsToClient()`, `MsgFunc_GameOpts/VoteOpts` |
| G7   | Apply via `CVAR_SET_STRING` (NOT `SERVER_COMMAND`) | `TallyGameOptionsVote()` |
| G7.1 | Re-validate value forbidden chars at tally | `TallyGameOptionsVote()` |
| G7.2 | Re-resolve cvar pointer at tally | `TallyGameOptionsVote()` |
| G8   | Skip phase if 0 items match current mode | `Think()` VOTE_GAMEOPTIONS_TRANSITION |
| G9   | Zero-items RTV → direct reply to initiator only | `VoteForGameOptions()` |

## Adding a New Game-Option

1. Append a block to `workspace/redist/gameoptions.txt` (and mirror to mod redists).
2. Pick a `game` value: `*` or any `szGameModeList` short-name (`ffa`, `arena`, `ctc`, `ctf`, etc.).
3. `cvar` must already be `CVAR_REGISTER`-ed on the server (the parser verifies).
4. 2-5 label/value pairs. Values cannot contain `; \n \r " \ $`.
5. Save -- next intermission picks it up (revision bumps, clients re-receive).
6. To verify in-game: type `gameoptions_status` (host / sv_cheats 1) to dump parser state.
