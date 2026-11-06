# Award System (GoldenEye 007 style)

Multiplayer-only scoreboard awards modeled after GoldenEye 007 (N64). Each connected human player sees one extra scoreboard header row with their **weapon of choice** and up to **two play awards**, for example:

```
Dual RPGs / Most Professional / Longest Innings
```

> Parents: [server.md](server.md) (computation) and [client.md](client.md) (display). Reference logic: `thirdparty/007/src/game/mpmenu.c::mpCalculateAwards()`, `bondinv.c::bondinvGetWeaponOfChoice()`, award enum in `thirdparty/007/src/bondconstants.h`.

## Files

| File | Role |
|------|------|
| `workspace/src/common/awards_shared.h` | `award_e` (wire indices) and the `AWARDS_PACK` / `AWARDS_WEAPON` / `AWARDS_FIRST` / `AWARDS_SECOND` macros. Shared by both DLLs. |
| `workspace/src/dlls/awards.{h,cpp}` | `CMultiplayAwards` and the global `g_Awards`. Owns every statistic, every award rule and the network update. |
| `workspace/src/cl_dll/scoreboard.cpp` | `CHudScoreboard::MsgFunc_Awards`, the award name table, the short weapon name table, `GetAwardsText()`, and the third header row of the old HUD scoreboard. |
| `workspace/src/cl_dll/vgui_ScorePanel.{h,cpp}` | `m_AwardsLabel`, the second header row of the VGUI scoreboard. |

## Design

- **The server is authoritative and centralized.** Entity code only reports raw events through one-line calls on `g_Awards`. All thresholds, rankings and award selection live in `awards.cpp`. Gamerules are not touched, so every multiplayer mode (FFA, Teamplay and every mode in [gamerules.md](gamerules.md)) is supported automatically.
- **Bots are hidden rivals.** Bots (`FL_FAKECLIENT`) are tracked and join the ranking pool, so a human playing against bots is ranked against them, for example "Mostly Harmless" if the bots out-frag you. A bot never receives anything, and an award a bot wins is simply not shown, as it would be on another player's N64 screen. HLTV proxies (`FL_PROXY`) are never tracked.
- **Single player is not supported.** Every entry point returns early unless `g_pGameRules->IsMultiplayer()` is true. The client hides the row when `gEngfuncs.GetMaxClients() <= 1`.
- **Nothing is persisted.**
  - `InstallGameRules()` calls `Reset()`, so every slot starts from the baseline on a map change.
  - `ClientPutInServer()` gives a connecting or reconnecting player a fresh baseline.
  - `ClientDisconnect()` wipes the slot. This runs before the `g_fGameOver` early return, so the wipe also happens during intermission.

### Event hooks

| Event | Hook location | `g_Awards` call |
|-------|---------------|-----------------|
| Shot fired | `CBasePlayer::SetAnimation` (every weapon plays `PLAYER_ATTACK1` when firing), at most one per frame | `ShotFired` |
| Headshot (player victim) | `CBasePlayer::TraceAttack`, only when the hit was accepted (`canBleed`) | `Headshot` |
| Headshot (monster victim) | `CBaseMonster::TraceAttack` | `Headshot` |
| Hit landed / back hit | `CBasePlayer::TakeDamage`, after `CBaseMonster::TakeDamage`, whenever health dropped (killing blows return 0, so the return value alone is not enough) | `PlayerDamaged` |
| Player death | `CBasePlayer::Killed`, right after `g_pGameRules->PlayerKilled` (after the Headshot-mutator early return) | `PlayerKilled` |
| Monster death | `CBaseMonster::Killed`, inside the once-only `MonsterKilled` guard | `MonsterKilled` |
| Armor pickup | `CItemBattery::MyTouch` | `ArmorPickedUp` |
| Map change | `InstallGameRules` | `Reset` |
| Connect / disconnect | `ClientPutInServer` / `ClientDisconnect` | `ClientPutInServer` / `ClientDisconnected` |
| Client HUD reset | `CBasePlayer::UpdateClientData`, right after `InitHUD` | `ClientHUDInitialized` |
| Every frame | `StartFrame`, after `g_pGameRules->Think()` | `Think` |

Monster kills and headshots count only for "real" creatures (`IsCountedMonster`). Classless entities and thrown bioweapons (`CLASS_PLAYER_BIOWEAPON`, `CLASS_ALIEN_BIOWEAPON`: snarks, chumtoads, hornets) are excluded. Horde-mode kills therefore feed the kill-based awards.

### Sampling (`Think` → `Sample`, every 0.25 s, stopped while `g_fGameOver`)

For each tracked player (human or bot) the sampler records the following.

**Life tracking.** "In play" means alive, not an observer and not a spectator.
- Entering play starts a life.
- Leaving play without dying (switching to spectator, a round reset) closes the life. It can update Longest Innings but never Shortest Innings.
- A death closes the life in `PlayerKilled`.

**While alive:**
- **Time alive** accumulates.
- **Longest life** includes the life in progress, as the N64 menu tick does.
- **Weapon time** is credited to the active weapon's `m_iId`. It is the last tie-breaker for weapon of choice, after kills and shots per weapon.
- **Horizontal distance** travelled accumulates. A sample step faster than 2000 u/s counts as a teleport and is skipped.
- **Other players in view** adds one player-second for each other in-play, drawn player who is inside the view cone (`pev->fov`, default 90) and has clear line of sight (`UTIL_TraceLine` eye to eye, `ignore_monsters`, `ignore_glass`). This approximates the N64 per-frame "other character drawn" counter.

### Refresh (`Refresh`)

A refresh runs every 1.0 s. A scoreboard-type event (kill, death, headshot, armor, connect or disconnect) brings the next refresh forward to 0.25 s after the last one. This keeps awards "accurate within a refresh" without recomputing on every event.

- **Ranking pool:** tracked, connected players (humans and bots) with at least 10 s alive. Awards 1–14 are comparisons and need **at least two** pool members, as the N64 always compared two or more players. A refresh is skipped entirely when no human is connected.
- **Ties:** each slot gets a random `tieBreak` once per baseline. The N64 flipped a coin on every call, which would make a live board flicker.
- **Picking two awards:** Quad Kill is always first, as on the N64. The rest follow a per-slot random award order shuffled once per baseline. The result keeps the N64's random feel but stays stable between refreshes.
- **Weapon of choice:** the weapon with the most kills, then the most shots fired, then the most time held. Kills and shots are credited to the active weapon (`m_pActiveItem->m_iId`) when they happen; time held comes from the sampler. The N64 (`bondinvGetWeaponOfChoice`) used time held alone, but every Cold Ice respawn deploys the spawn loadout (`spawnweaponlist`, for example the Silenced Handgun). For a player who dies often, that idle time used to win over the weapons they actually fought with. Dual weapons have their own IDs, so they rank as their own weapons. Known approximation: a kill from a projectile still in flight (rocket, grenade) is credited to whatever weapon is in hand when it lands.

## Award Rules

`kills` includes player victims (other than self) and counted monsters. `deaths` includes every death. km/h uses 1 unit = 1 inch.

| # | Award (client text) | Rule | N64 origin / translation |
|---|---------------------|------|--------------------------|
| 1 | Lemming Award | most suicides, > 0 | suicides = self kills **plus** world deaths (falls, triggers, crushers): any attacker that is neither a player nor a monster |
| 2 | Where's the Ammo? | fewest shots, < 100 | shots = `PLAYER_ATTACK1` animations |
| 3 | Where's the Armor? | fewest armor pickups, ≤ 2 | N64 summed armor fractions; HL counts `item_battery` pickups |
| 4 | AC-10 Award | most armor pickups, > 6 | same as above |
| 5 | Marksmanship Award | most headshots, > 0 | headshot = accepted `HITGROUP_HEAD` hit, at most one per attacker per frame (shotgun pellets) |
| 6 | Most Professional | best `kills*100/(shots+1)`, > 0 | unchanged |
| 7 | Most Deadly | best `kills*100/(deaths+1)`, > 0 | unchanged |
| 8 | Mostly Harmless | worst K/D among players with ≥ 1 death; never the Most Deadly player | N64 always awarded it; the live board needs a death for it to mean anything |
| 9 | Most Cowardly | least player-seconds with others in view | always awarded (pool members only) |
| 10 | Most Frantic | fastest average horizontal speed while alive, > 10 km/h | N64 divided by match time; here it is time alive, because players join mid-match |
| 11 | Most Honorable | fewest back hits among players who landed ≥ 1 hit | N64 always awarded it; here the player must have actually fought |
| 12 | Most Dishonorable | most back hits, > 0, never the Most Honorable player | back hit = damage source (the inflictor, or the attacker for hitscan) is in the victim's rear half (2D dot with the victim's facing < 0) |
| 13 | Shortest Innings | shortest completed life (requires a death); never the Longest Innings player | N64 seeded with `S32_MAX`, which awarded it to a player who had never died |
| 14 | Longest Innings | longest life, including the current one, > 0 | unchanged |
| 15–17 | Double / Triple / Quad Kill (Doh!) | best number of kills, each within 2 s of the latest (window = N64 `0x78` frames at 60 Hz); 2 → Double, 3 → Triple, ≥ 4 → Quad | HL has more than 4 players, so 5+ still counts as Quad |

## Network Contract

`Awards` user message, registered in `player.cpp::LinkUserMessages()` as fixed size `2`.

```
SHORT packed   // bits 15..10 weapon of choice (WEAPON_* id, 0 = none)
               // bits  9..5  first award  (award_e, 0 = none)
               // bits  4..0  second award (award_e, 0 = none)
```

- Sent `MSG_ONE`, only to the owning player, and only when the packed value changes (`lastSentPacked`). Players receive nothing while values are stable. Bots and players whose HUD is not initialized (`m_fGameHUDInitialized`) are skipped.
- The client clears its value in `CHudScoreboard::InitHUDData()` (every map or connect). The server mirrors this: `ClientHUDInitialized()` sets `lastSentPacked = 0` and the next refresh resends any non-zero value.
- `static_assert`s in `awards.cpp` fail the build if `MAX_WEAPONS` grows past 64 or `AWARD_COUNT` past 32. If either happens, widen the payload (switch to `WRITE_LONG` and the size to `4`) and update the macros.
- The client reads with `READ_SHORT() & 0xFFFF`: weapon IDs ≥ 32 set bit 15, which makes the signed short negative.
- Award indices are wire-visible. Append new awards before `AWARD_COUNT` and add the name to `g_szAwardNames[]` in `scoreboard.cpp` in the same position. Client and server ship together.

This is a separate message rather than extra bytes on `ScoreInfo` for three reasons:
- `ScoreInfo` is sent from about 75 places across the game modes, and growing it would add bytes to every send.
- Awards are per viewer. Each player sees only their own row, so a 2-byte unicast that fires only on change costs less.
- The design keeps the award system independent of gamerules.

## Client Display

`CHudScoreboard::GetAwardsText()` builds `Weapon / Award / Award`, skipping empty parts. It falls back to `No awards yet` when nothing is set, and returns false in single player.

- **Weapon names** come from `gWR.GetWeapon(id)->szName` (the `WeaponList` classname), mapped through the short-name table `g_AwardWeaponNames[]`, for example `weapon_dual_rpg` → `Dual RPGs`. Classnames that are not in the table are formatted automatically (`weapon_new_gun` → `New Gun`). Keying on the classname means the table survives `WEAPON_*` renumbering. When adding a weapon, add a short name (aim for 18 characters or fewer).
- **Award names** are the N64 strings (`g_szAwardNames[]`). The longest is 18 characters, so the row is at most about 60 characters.
- **Old HUD scoreboard** (`cl_oldscoreboard 1`, the default): a third header row under `Server` and `Game | Map`, using the same 50-alpha HUD-color band and `DrawHudString`. `m_iAwardsRowHeight` (20) shifts the column header, separator, team rows and `DrawPlayers` rows down. If `GetConsoleStringSize` reports that the row is wider than the band, `m_iAwardsExtraWidth` widens the band (`FAR_RIGHT`) and re-centers the board.
- **VGUI scoreboard** (`cl_oldscoreboard 0`): `m_AwardsLabel` is a second header row under the title, in the title font and HUD color. The header grid and player list move down by `SBOARD_AWARDS_SIZE_Y`. `ScorePanel::Update()` falls back to `Scoreboard Small Text` if the title font does not fit the label width.
- **Refresh:** `MsgFunc_Awards` calls `gViewPort->UpdateOnPlayerInfo()`, the same refresh path as `ScoreInfo`.

## Tuning Constants (`awards.cpp`)

| Constant | Value | Meaning |
|----------|-------|---------|
| `AWARDS_SAMPLE_INTERVAL` | 0.25 s | movement, view and weapon sampling |
| `AWARDS_REFRESH_INTERVAL` | 1.0 s | periodic recompute |
| `AWARDS_REFRESH_DIRTY` | 0.25 s | recompute delay after an event |
| `AWARDS_MIN_PLAY_TIME` | 10 s alive | ranking-pool eligibility |
| `AWARDS_MULTIKILL_WINDOW` | 2.0 s | multi-kill window |
| `AWARDS_MAX_SPEED` | 2000 u/s | teleport rejection |
| `AWARDS_AMMO_MAX_SHOTS`, `AWARDS_ARMOR_FEW`, `AWARDS_ARMOR_MANY`, `AWARDS_FRANTIC_KMH` | 100, 2, 6, 10 | N64 thresholds |

## Validation Checklist

- Build `hldll` and `hl_cdll` on Windows, and `make hl` / `make hl_cdll` on Linux. `awards.o` is listed in `linux/Makefile.hldll`.
- Listen server plus bots: confirm the row reads `No awards yet` at spawn and shows a weapon after a few seconds. After about 10 s alive, comparison awards appear relative to the bots: get out-fragged for Mostly Harmless, and fire very little for Where's the Ammo?. Kill two bots quickly to get Double Kill.
- Toggle `cl_oldscoreboard 0/1`: check that both rows align with spectating (`g_iUser1` margin), in team modes (team header rows) and with `cl_showpacketloss 1`.
- Reconnect, and change the map: confirm the row resets to `No awards yet`.
- Single player (`maxplayers 1`): no row, no `Awards` messages.
