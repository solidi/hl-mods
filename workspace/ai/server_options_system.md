# Server-Options Voting System — Spoke

> Parents: [voting_system.md](voting_system.md) · related to [vgui_system.md](vgui_system.md) · server entry [server.md](server.md)

A dynamic intermission vote phase for global server cvars. Items are loaded from `redist/serveroptions.txt`, sent to clients in chunked manifests, voted per-row, and applied via `CVAR_SET_STRING`.

Unlike game-options, this system is global and mode-agnostic: `serveroptions.txt` does not support a `game` token.

## File Format (`redist/serveroptions.txt`)

Source KV style, one block per item, up to 64 items.

```
"Friendly Fire"
{
    "cvar"    "mp_friendlyfire" // [A-Za-z0-9_]+ only
    "restart" "0"               // 1 = if RTV path used, force changelevel after apply
    "Off"     "0"               // 2-5 label->value pairs
    "On"      "1"
}
```

Parser notes:
- `game` key is rejected (`item skipped`) in this file.
- `title` is optional inside the block; header title is used by default.
- `options { ... }` nested form is supported, but flat label/value pairs are also valid.
- Forbidden in values: `; \n \r " \ $`.
- Oversized rows are rejected if they exceed per-chunk message budget.

## Lifecycle

```
boot / mtime change
   |
   v
BuildServerOptionsList() -> g_ServerOptions[] (validated + revision++)
   |
   v (per-client InitHUD or serveroptions_resend)
SendServerOptionsToClient(edict) -> MsgFunc_SrvOpts chunks -> g_ServerOptionsClient[]
   |
   v (intermission, after game-options tally)
VOTE_SERVEROPTIONS_TRANSITION -> BuildActiveServerOptions()
   |   if 0 rows: skip to mutator phase
   |
   v
VOTE_SERVEROPTIONS_OPEN -> gmsgVoteSrvOp(rev,timer,N,idx...,flags) -> CVoteServerOptionsPanel
   |   bots cast RANDOM_LONG per row; humans click -> "votesrvopt R O"
   |   each pick mirrors via gmsgSOptFor for live tallies
   |
   v
TallyServerOptionsVote(fromRTV=FALSE)
   |   per row: highest vote wins (ties -> RANDOM_LONG)
   |   re-validate value + cvar pointer, then CVAR_SET_STRING
   v
VOTE_MUTATOR_TRANSITION ...
```

## Mid-game RTV Path

Chat `serveroptions` in `Host_Say` accumulates RTV threshold votes using existing logic. On threshold hit, `VoteForServerOptions(TRUE)` opens the panel immediately.

RTV gating: this path shares a cross-type lock with `gamemodes`, `maps`, `mutator`, and `gameoptions` RTV. While another RTV is collecting/open, `serveroptions` RTV start attempts are rejected with a message naming the active RTV and remaining wait time. After RTV completion/failure, `mp_rtvcooldown` applies before any new RTV can start.

RTV-specific behavior:
- Sends `flags bit0=1` so clients auto-close about 2.0s after local player has voted all rows.
- Uses `m_fServerOptionsVoteTime` for countdown separate from intermission sequence.
- If any winning row has `restart=1`, server issues `changelevel <current>` after apply.
- If there are zero active rows, initiator gets direct feedback and no global spam.

## Wire Protocol

### `SrvOpts` (manifest, chunked, S->C unicast)

Per chunk:
```
BYTE revision
BYTE seq
BYTE isLast
BYTE total
BYTE numInChunk
repeat numInChunk:
  STRING cvar
  STRING title
  BYTE   restart
  BYTE   numOptions
  repeat numOptions:
    STRING label
    STRING value
```

Client stores only `title/restart/labels`; `cvar/value` are drained for alignment and never used client-side.

### `VoteSrvOp` (open/close panel, S->C broadcast)

```
BYTE revision
BYTE timer          // 0 closes panel
BYTE activeCount
BYTE[] activeIndices
BYTE flags(optional) // bit0: allow RTV auto-close on all-local-voted
```

### `SOptFor` (mirrored per-row vote, S->C broadcast)

```
BYTE clientIndex
BYTE item     // 1-based active row index
BYTE option   // 1-based option index
```

## Console Commands

| Command | Where | Notes |
|---------|-------|-------|
| `votesrvopt <item> <option>` | client -> server | 1-based indices into active rows/options; updates mirrored tallies. |
| `serveroptions_resend` | client -> server | Rate-limited resend of current manifest to requesting client. |
| `serveroptions_status` | client -> server | Listenserver host or `sv_cheats 1` only; dumps parser/log/current values. |
| `serveroptions` | chat RTV | Threshold-triggered RTV for server-options vote. |

## Key Files

### Server
- `src/dlls/multiplay_gamerules.cpp`:
  - `BuildServerOptionsList()`, `EnsureServerOptionsList()`, `SendServerOptionsToClient()`
  - `BuildActiveServerOptions()`, `TallyServerOptionsVote()`, `VoteForServerOptions()`, `CheckServerOptionsRTV()`
  - Intermission state machine branches `VOTE_SERVEROPTIONS_TRANSITION` and `VOTE_SERVEROPTIONS_OPEN`.
- `src/dlls/gamerules.h`:
  - `VOTE_SERVEROPTIONS_*` constants, `server_option_t`, active/vote/RTV members on `CHalfLifeMultiplay`.
- `src/dlls/client.cpp`:
  - `VoteServerOption()`, `ServerOptionsVote()` and command dispatch.
- `src/dlls/player.cpp::LinkUserMessages()`:
  - `gmsgSrvOpts`, `gmsgVoteSrvOp`, `gmsgSOptFor`.

### Client
- `src/cl_dll/vgui_TeamFortressViewport.{h,cpp}`:
  - `MsgFunc_SrvOpts`, `MsgFunc_VoteSrvOp`, `MsgFunc_SOptFor`
  - client manifest storage and menu routing (`MENU_VOTESERVEROPTIONS`).
- `src/cl_dll/vgui_VoteServerOptionsWindow.cpp`:
  - `CVoteServerOptionsPanel` dynamic row build and live tally UI.
- `src/cl_dll/hud.cpp`:
  - `HOOK_MESSAGE(SrvOpts)`, `HOOK_MESSAGE(VoteSrvOp)`, `HOOK_MESSAGE(SOptFor)`.

### Distribution
- `workspace/redist/serveroptions.txt` (canonical sample)
- `workspace/manifest` includes `serveroptions.txt`

## Failure/Skip Semantics

- Missing file (`serveroptions.txt` not found) is non-fatal: parser logs notice, leaves `g_iServerOptionsCount=0`, server continues.
- Empty file is non-fatal and treated the same as no valid rows loaded.
- Malformed rows are skipped item-by-item (line-number parse logs retained); valid rows in the same file still load.
- If final loaded row count is zero (missing, empty, or all malformed), server-options vote phase is skipped in end-of-game flow and RTV prints `No server options available.` to the initiator/all chat path.

## Limits

| Constant | Value | Where |
|----------|-------|-------|
| `MAX_SERVER_OPTIONS` | 64 | `gamerules.h` |
| `MAX_SERVER_OPTION_VALUES` | 5 | `gamerules.h` |
| `MAX_SERVER_OPTION_TITLE` | 64 | `gamerules.h` |
| `MAX_SERVER_OPTION_CVAR` | 32 | `gamerules.h` |
| `MAX_SERVER_OPTION_LABEL` | 24 | `gamerules.h` |
| `MAX_SERVER_OPTION_VALUE` | 32 | `gamerules.h` |
| `SERVER_OPTIONS_MAX_MSG_BYTES` | 192 | `multiplay_gamerules.cpp` |
| `SERVER_OPTIONS_CHUNK_HEADER_BYTES` | 5 | `multiplay_gamerules.cpp` |
| `SERVER_OPTIONS_CHUNK_BUDGET_BYTES` | 188 (`192 - 4`) | `multiplay_gamerules.cpp` |

## Safety Rules

- Reject invalid cvar names and unknown cvars.
- Reject `game` key usage.
- Require 2-5 options per item.
- Reject value strings with command-injection characters.
- Enforce per-item serialized-size budget before accepting row.
- Include revision byte in every chunk and open message; client auto-resend on mismatch.
