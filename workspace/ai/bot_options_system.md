# Bot-Options Voting System — Spoke

> Parents: [voting_system.md](voting_system.md) · related to [vgui_system.md](vgui_system.md) · siblings: [server_options_system.md](server_options_system.md), [game_options_system.md](game_options_system.md) · bot cvars: [gravebot.md](gravebot.md) · server entry [server.md](server.md)

An **RTV-only** vote for bot cvars. Items are loaded from `redist/botoptions.txt`, streamed to clients a few seconds after they connect, voted per row, and applied via `CVAR_SET_STRING`. Players start it by typing `botoptions` in chat during a match.

It reuses the server-options row format, parser, chunk layout and tally (shared helpers in `multiplay_gamerules.cpp`). The differences from server-options:

| | Server-options | Bot-options |
|---|---|---|
| File | `serveroptions.txt` | `botoptions.txt` |
| Row cap | 64 (`MAX_SERVER_OPTIONS`) | **16** (`MAX_BOT_OPTIONS`) |
| End-of-game vote phase | yes (`VOTE_SERVEROPTIONS_*`) | **never**; no `VOTE_*` constants |
| Mid-game RTV | `serveroptions` (in-match only) | `botoptions` (in-match only) |
| Manifest timing | streamed right after connect | held back `BOT_OPTIONS_SEND_DELAY` (5s) after connect |
| `restart=1` | changelevel on RTV apply | changelevel on apply, except when force-closed by `GoToIntermission` |

## File Format (`redist/botoptions.txt`)

Identical to `serveroptions.txt` (see [server_options_system.md → File Format](server_options_system.md#file-format-redistserveroptionstxt)). Source KV blocks, 2-5 label/value pairs, no `game` key, values reject `; \n \r " \ $`, max 16 rows.

```
"Bot Accuracy"
{
    "cvar"    "sv_botaccuracy"
    "restart" "0"
    "Deadly"  "0"
    "Default" "1"
    "Sloppy"  "2"
}
```

Shipped default rows:

| Title | Cvar | Options | Live? |
|---|---|---|---|
| Bot Count | `sv_defaultbots` | Zero 0 / Three 3 / Six 6 / Twelve 12 | yes, grave-bot adds or kicks one bot every 5s toward the target |
| Bot Accuracy | `sv_botaccuracy` | Deadly 0 / Default 1 / Sloppy 2 | yes, synced into `bot_aim_difficulty` the next frame |
| Bots Melee | `sv_botsmelee` | No 0 / Yes 1 | yes |
| Bots Hook | `sv_bots_hook` | No 0 / Yes 1 | yes |
| Bots Vote | `sv_botsvote` | No 0 / Yes 1 | yes; game DLL cvar, so this row loads even without grave-bot. Takes effect from the next vote panel (bots already voted in this one) |

"Bots Melee" moved here from `serveroptions.txt`, so one cvar is never voted in two menus.

The `sv_bot*` cvars other than `sv_botsvote` are registered by grave-bot (`grave-bot-src/dlls/dll.cpp`); `sv_botsvote` is a game DLL cvar (`game.cpp`). The parser requires a registered cvar (`CVAR_GET_POINTER`), so on a server without the bot plugin the grave-bot rows are logged and skipped, leaving only "Bots Vote".

### `sv_botaccuracy` (grave-bot)

`bot_aim_difficulty` was a console command backed by a plain float, which a cvar vote cannot drive. `sv_botaccuracy` (default `1`) is its votable mirror:

- `StartFrame()` copies any change of `sv_botaccuracy` (clamped to `[0, 2]`, non-finite → 1) into `bot_aim_difficulty`.
- The `bot_aim_difficulty <v>` command also writes `sv_botaccuracy`, so the two never disagree.
- Registered in both the metamod (`Meta_Attach`) and non-metamod (`GameDLLInit`) paths, like the other `sv_bot*` cvars.

## Lifecycle

```
InitHUD (human client)
   |  queue BotOpts stream: cursor 0, start = time + BOT_OPTIONS_SEND_DELAY
   v
PumpClientManifestSends (every Think)
   |  after MapList / GameOpts / SrvOpts are done and start time passed:
   |  EnsureBotOptionsList() -> BuildBotOptionsList() (first use on the map)
   |  one BotOpts chunk per MANIFEST_STREAM_INTERVAL -> MsgFunc_BotOpts -> g_BotOptionsClient[]
   v
chat "botoptions" -> BotOptionsVote() (client.cpp)
   |  rejects during intermission / single player; shared RTV gate + majority quorum
   v
VoteForBotOptions()
   |  0 rows -> "[VOTE] No bot options available." to initiator, gate -> cooldown
   |  release held streams / restart stale ones for every human (G5)
   |  gmsgVoteBotOp(rev, timer, N, idx..., mode, flags=1) -> CVoteBotOptionsPanel
   |  bots (sv_botsvote 1) vote row by row 0.75-4.5s after opening (ScheduleBotVotes, mirrored via BOptFor)
   |  humans click -> "votebotopt R O" -> VoteBotOption() -> BOptFor mirror
   v
CheckBotOptionsRTV()  (Think, when m_fBotOptionsVoteTime expires)
   |  VoteBotOp timer=0 closes panels; TallyBotOptionsVote(allowRestart=TRUE)
   |  m_fBotOptionsVoteTime is pulled in ~2.0s after the last vote once every
   |  eligible human has voted every row (voting_system.md → Early Close)
   v
GoToIntermission() while a bot vote is open
      SettleOpenRTVVotes() -> CheckBotOptionsRTV(forceClose=TRUE): close + tally
      now, skip restart rows, so the bot panel never sits on top of the
      end-of-game vote panels (every other open RTV is settled the same way).
```

The panel auto-closes about 2.0s after the local player has voted every row (`flags bit0`), like the other RTV option panels.

## Wire Protocol

| Message | Size | Direction | Body |
|---|---|---|---|
| `BotOpts` | `-1` | S→C unicast | Same chunk layout as `SrvOpts`: `BYTE revision, seq, isLast, total, numInChunk` then per item `STRING cvar, STRING title, BYTE restart, BYTE numOptions, {STRING label, STRING value}...`. Client drains `cvar`/`value`. Written by `WriteGlobalOptionsChunk()`. |
| `VoteBotOp` | `-1` | S→C broadcast | `BYTE revision; BYTE timer (0 closes); BYTE activeCount; BYTE[] activeIndices; BYTE mode; BYTE flags` |
| `BOptFor` | `3` | S→C broadcast | `BYTE clientIndex; BYTE item; BYTE option` (1-based) |

Registered in `player.cpp::LinkUserMessages()` (`gmsgBotOpts`, `gmsgVoteBotOp`, `gmsgBOptFor`).

Revision handling matches server-options (G6): every chunk and the open message carry the revision. On mismatch or a missing manifest the client fires `botoptions_resend` and opens a "Waiting for bot-options manifest..." placeholder. Unlike the other option panels, `CVoteBotOptionsPanel::Update()` **rebuilds its rows** once the manifest for the vote's revision (`g_iBotOptionsVoteRevisionClient`) lands, and falls back to the placeholder if a newer revision starts replacing it.

## Console Commands

| Command | Where | Notes |
|---|---|---|
| `botoptions` | chat RTV | Majority RTV; shares the gate and `mp_rtvcooldown` with the other RTVs. Rejected during intermission. |
| `votebotopt <item> <option>` | client → server | 1-based; only while `m_fBotOptionsVoteTime` is in the future. |
| `botoptions_resend` | client → server | Rate-limited (5s, `m_fBotOptsResendCoolDown`); restarts the paced stream and skips the connect delay. |
| `botoptions_status` | client → server | Listenserver host or `sv_cheats 1`; dumps revision, parse log and current cvar values. |
| `sv_botaccuracy <0-2>` | server cvar (grave-bot) | Votable mirror of `bot_aim_difficulty`. |

## Key Files

### Server (`workspace/src/dlls`)
- `gamerules.h` — `MAX_BOT_OPTIONS` (defined above `CHalfLifeMultiplay`), `bot_option_t` (typedef of `server_option_t`), `g_BotOptions[]` externs, bot vote/stream members (`m_iActiveBotOptions`, `m_iBotOptionsVotes[32][16]`, `m_fBotOptionsVoteTime`, `m_iBotOptionsStream*`, `m_fBotOptionsStreamStart`, `m_fManifestNextSend`).
- `multiplay_gamerules.cpp` — `global_option_manifest_t` descriptors (`g_ServerOptionsManifest`, `g_BotOptionsManifest`), `BuildGlobalOptionsList()`, `BuildBotOptionsList()` / `EnsureBotOptionsList()`, `WriteGlobalOptionsChunk()`, `PumpClientManifestSends()`, `SendBotOptionsToClient()`, `BuildActiveBotOptions()`, `TallyGlobalOptionRows()` / `TallyBotOptionsVote()`, `VoteForBotOptions()`, `CheckBotOptionsRTV()`, the `GoToIntermission()` guard.
- `client.cpp` — `RTV_GATE_KIND_BOTOPTIONS`, `BotOptionsVote()` / `BotOptionsOpenVote()`, `VoteBotOption()`, `votebotopt` / `botoptions_resend` / `botoptions_status`; `"botoptions"` is excluded from the generic `rtv` match.
- `player.h` — `m_fBotOptsResendCoolDown`. `player.cpp` — message registration.

### Bot (`workspace/grave-bot-src/dlls/dll.cpp`)
- `sv_botaccuracy` cvar, registration, `StartFrame()` sync, `bot_aim_difficulty` write-back.

### Client (`workspace/src/cl_dll`)
- `vgui_TeamFortressViewport.{h,cpp}` — `MENU_VOTEBOTOPTIONS` (17), `g_BotOptionsClient[]` and friends, `MsgFunc_BotOpts` / `MsgFunc_VoteBotOp` / `MsgFunc_BOptFor`, `Create/ShowVoteBotOptionsMenu`. Not in the intermission menu allow-list.
- `vgui_VoteBotOptionsWindow.cpp` — `CVoteBotOptionsPanel` (registered in `hl_cdll.vcxproj`, `.filters`, `linux/Makefile.hl_cdll`).
- `hud.cpp` — `HOOK_MESSAGE(BotOpts/VoteBotOp/BOptFor)`. `hud_redraw.cpp` — chat tip.

### Distribution
- `workspace/redist/botoptions.txt`, listed in `workspace/manifest`.
- `redist/commandmenu.txt` ("RTV Bot Options"), `client_commands.txt`, `server_commands.txt` (`sv_botaccuracy`), `readme.txt`.

## Adding a Bot-Option

1. The cvar must be registered (grave-bot or game DLL). Grave-bot console commands backed by plain globals (`botskill`, `botdontshoot`, `bot_reaction_time`, ...) cannot be voted until they get a cvar mirror like `sv_botaccuracy`.
2. Append a block to `workspace/redist/botoptions.txt` (16-row cap).
3. Prefer cvars the bot code reads live. Use `"restart" "1"` only if the change needs a fresh map.
4. Check with `botoptions_status` (host / `sv_cheats 1`).
