# Capture The Chumtoad (CtC) Game Mode — AI Context

## Overview
- **Game Mode**: `GAME_CTC = 7` (defined in `common/const.h`)
- **String ID**: `"ctc"` (mp_gamemode cvar)
- **Description**: `"Cold Ice Remastered Capture The Chumtoad"` — FFA keep-away with a chumtoad
- **Source**: `src/dlls/ctc_gamerules.cpp`, `src/dlls/ctc_gamerules.h`
- **Class**: `CHalfLifeCaptureTheChumtoad : public CHalfLifeMultiplay`
- **Bot Source**: `grave-bot-src/dlls/bot_combat.cpp` (`BotCtcThink`, `BotFindEnemy` CtC filters), `grave-bot-src/dlls/bot.cpp` (pre-update detection, `BotFindItem` bypass, think dispatch, direct-steer), `grave-bot-src/dlls/bot_navigate.cpp` (frequent re-routing, waypoint goal, snap)

## Win Condition
- First player to reach `scorelimit` value in `m_iRoundWins` wins
- Score tracked per-player via `pPlayer->m_iRoundWins` (not `pev->frags`)
- 1 point awarded every `ctcsecondsforpoint` seconds (cvar, default 10) while running with toad
- Calls `GoToIntermission()` from `PlayerThink` when threshold is reached

## Teams
- **Holder**: Team name `"holder"`, team index 3 (green in scoreboard). Player currently carrying the chumtoad.
- **Chaser**: Team name `"chaser"`, team index 0. All other players.
- Not true team play — FFA with holder vs. everyone. `IsTeamplay()` returns TRUE for scoreboard display only.
- `PlayerRelationship`: returns `GR_NOTTEAMMATE` if either player is holding the chumtoad, `GR_TEAMMATE` between two chasers (chasers cannot hurt each other).
- `FPlayerCanTakeDamage`: returns TRUE only for the holder (or `trigger_hurt`). Chasers are immune to all player damage.
- No model restrictions. No team selection menu.

## Chumtoad Entity (`CCaptureChumtoad`, classname `"monster_ctctoad"`)
- **Model**: `models/w_chumtoad.mdl`
- **Sounds**: `chumtoad_hunt1.wav`, `chumtoad_hunt2.wav`, `chumtoad_hunt3.wav` (bouncing/hunting), `chumtoad_blast1.wav` (death)
- **Physics**: `MOVETYPE_BOUNCE`, `SOLID_TRIGGER`, gravity 0.5, friction 0.5
- **Bbox**: `Vector(-16, -16, 0)` to `Vector(16, 16, 8)`
- **Flags**: `FL_MONSTER`, `DAMAGE_NO` (cannot be killed by players)
- **Rendering**: Green glow shell (`kRenderFxGlowShell`, RGB: 0, 200, 0), green beam trail
- **Radar**: `pev->fuser4 = RADAR_CHUMTOAD`
- **Valid marker**: `pev->iuser1 = 1` (set on creation/drop, used by Think to identify the active toad)
- **Lifetime**: Entity exists while loose; destroyed on pickup (`UTIL_Remove`)

### State Tracking
| Field | Type | Purpose |
|-------|------|---------|
| `m_hOwner` | EHANDLE | Player who spawned/dropped it (for radius damage) |
| `m_hEnemy` | EHANDLE | Current hunt target (nearest visible enemy) |
| `m_flNextHunt` | float | Next hunt-think time (every 2s) |
| `m_flNextHit` | float | Debounce for touch events (0.1s) |
| `m_flDie` | float | Not used in CtC (detonation timer commented out) |
| `pev->iuser1` | int | 1 = valid active toad (gamerules checks this) |
| `pev->fuser4` | float | `RADAR_CHUMTOAD` (radar/minimap indicator) |

### Hunt Behavior (`HuntThink`, runs every 0.1s)
1. **Water handling**: Switches to `MOVETYPE_FLY` in water; velocity dampened, floats upward
2. **Hunt cycle** (every 2s): `Look(512)` → `BestVisibleEnemy()` → steers velocity toward target
3. **Movement**: Adjusts velocity toward `m_vecTarget` at 150 u/s blend rate; random jitter if stuck
4. **Lifetime**: Detonation timer is commented out — chumtoad lives indefinitely while loose

### Pickup Mechanism (`SuperBounceTouch`)
- Triggered when a player physically overlaps the entity (SOLID_TRIGGER touch)
- **Conditions**: Player must be alive, `m_iHoldingChumtoad == FALSE`, and not have `weapon_chumtoad`
- **Steps**:
  1. Calls `g_pGameRules->CaptureCharm(pPlayer)` — registers holder in gamerules
  2. `pPlayer->GiveNamedItem("weapon_chumtoad")` — gives chumtoad as a weapon
  3. `pPlayer->SelectItem("weapon_chumtoad")` — auto-selects it
  4. Sets touch debounce, clears touch handler, `UTIL_Remove(this)` — entity disappears
- **Key behavioral note**: Toad actively hunts and moves toward nearby players. A stationary player near the toad will likely get picked up automatically.

## Gamerules Class (`CHalfLifeCaptureTheChumtoad`)

### Key Members
| Field | Type | Purpose |
|-------|------|---------|
| `m_fChumtoadInPlay` | BOOL | TRUE when a player is holding the chumtoad |
| `m_fChumtoadPlayTimer` | float | Next Think cycle time (1s interval) |
| `m_fCreateChumtoadTimer` | float | Scheduled toad spawn time (0 = not pending, -1 = disabled) |
| `m_fMoveChumtoadTimer` | float | Next teleport time for loose toad (every 30s) |
| `m_pHolder` | EHANDLE | Current holder entity (NULL when loose) |

### CaptureCharm (player picks up chumtoad)
1. Early exit if `UTIL_GetPlayerCount() < 2`
2. Set `pPlayer->m_iHoldingChumtoad = TRUE`, `m_fChumtoadInPlay = TRUE`
3. Green glow shell: `kRenderFxGlowShell`, `renderamt = 10`, `rendercolor = (0, 200, 0)`
4. `pPlayer->pev->fuser4 = RADAR_CHUMTOAD` (radar indicator, also used as bot detection flag)
5. `m_pHolder = pPlayer`
6. `TE_BEAMFOLLOW` trail (green beam following player)
7. Chat broadcast: `"[CtC] %s has captured the chumtoad!"`
8. `CLIENT_SOUND_BULLSEYE` sound
9. `cam_chumtoad` status icon shown to holder
10. Team change: `m_szTeamName = "holder"`, broadcast `gmsgTeamInfo` + `gmsgScoreInfo`
11. Reset counters: `m_iChumtoadCounter = 0`, `m_iCaptureTime = 0`
12. Disable create timer (`-1`), clear move timer (`0`)

### DropCharm (chumtoad released)
1. `m_fChumtoadInPlay = FALSE`
2. Clear rendering: `kRenderNormal`, `renderamt = 0`, `renderfx = kRenderFxNone`
3. `pPlayer->pev->fuser4 = 0` (removes radar flag — **key bot detection signal**)
4. `m_pHolder = NULL`
5. `TE_KILLBEAM` — remove trail
6. Chat broadcast: `"[CtC] %s has dropped the chumtoad!"`
7. `CLIENT_SOUND_MANIAC` sound
8. Team change: `m_szTeamName = "chaser"`, broadcast `gmsgTeamInfo` + `gmsgScoreInfo`
9. Spawn new `monster_ctctoad` entity at given origin with `iuser1 = 1`
10. Set `m_fMoveChumtoadTimer = gpGlobals->time + SPAWN_TIME` (30s until teleport)
11. If entity creation fails, retry in 1s via `m_fCreateChumtoadTimer`

### Think (runs every 1s via `m_fChumtoadPlayTimer`)
1. **Intermission cleanup**: Remove all `monster_ctctoad` entities during intermission
2. **HUD objective**: Broadcasts "Get the chumtoad" with holder name or "free" status
3. **Duplicate cleanup**: Walks entity list, keeps first valid toad (`iuser1 == 1`), removes extras
4. **Player count < 2**: Forces holder to drop, removes all toads, resets create timer
5. **No toad + not held**: Schedule creation after 3s delay via `m_fCreateChumtoadTimer`
6. **Toad creation**: Calls `CreateChumtoad()` → spawns at random `info_player_deathmatch`
7. **Loose toad teleport**: Every `SPAWN_TIME` (30s), teleports to a random spawn point
   - Chat broadcast: `"[CtC] The chumtoad has teleported!"`

### CreateChumtoad
- Picks a random `info_player_deathmatch` spawn point (random 1–8 iterations)
- Calls `CBaseEntity::Create("monster_ctctoad", ...)` at spawn origin
- Sets `pToad->pev->iuser1 = 1` on success

### Scoring Mechanic (`PlayerThink`, updates once per second)
```
if (pPlayer->IsAlive() && pPlayer->m_iHoldingChumtoad)
{
    if (pPlayer->pev->velocity.Length() > 50)
    {
        // SCORING: running with toad
        pPlayer->m_iChumtoadCounter++;
        scoringPoints = TRUE;
        pPlayer->m_iChumtoadDropCounter = 10;  // reset drop timer
        
        if (m_iChumtoadCounter % secondsUntilPoint == 0)
            ++pPlayer->m_iRoundWins;  // SCORE POINT
    }
    else
    {
        // PENALTY: standing still
        if (RANDOM_LONG(0, m_iChumtoadDropCounter) == 0 && pPlayer->m_pActiveItem)
        {
            weapon->PrimaryAttack();  // AUTO-DROP: fires chumtoad weapon
        }
        if (m_iChumtoadDropCounter > 0)
            m_iChumtoadDropCounter--;  // increases drop probability over time
    }
}
```

**Scoring rules:**
- Must maintain velocity > 50 u/s to score (must be running)
- 1 point every `ctcsecondsforpoint` seconds (default 10) of continuous running
- Counter resets to 0 after each point scored
- Standing still triggers increasingly likely auto-drop via `PrimaryAttack()`
- `m_iChumtoadDropCounter` starts at 10, decrements each idle second → drop probability = `1/(counter+1)`

### PlayerKilled
- Delegates to `CHalfLifeMultiplay::PlayerKilled` first
- If victim was holding chumtoad: calls `DropCharm` with origin 64u forward from victim

### PlayerSpawn
- `pev->iuser3 > 0`: New player, already handled
- `pev->iuser3 == 0`: Spectator joining — set team to `"chaser"`, `iuser3 = -1`, schedule game mode message
- Always resets `m_iHoldingChumtoad = FALSE` (safety for weapon drop logic)

### ClientDisconnected
- If disconnecting player was holding: `m_iHoldingChumtoad = FALSE`, calls `DropCharm`

### Weapon Restrictions
- `CanHavePlayerItem`: Holder (`fuser4 == RADAR_CHUMTOAD`) can ONLY have `weapon_chumtoad`, nothing else
- `CanHaveNamedItem`: Non-holders (`fuser4 == 0`) cannot pick up `weapon_chumtoad` directly
- `CanHavePlayerAmmo`: Holder cannot pick up ammo
- `IsAllowedToSpawn`: Blocks `weapon_chumtoad`, `weapon_snark`, `rune_ammo` from spawning
- `WeaponShouldRespawn`: Blocks `weapon_chumtoad`, `weapon_snark` from respawning
- `CanRandomizeWeapon`: Blocks chumtoad/snark from random weapon pools
- `IsAllowedToDropWeapon`: Returns FALSE (nobody can manually drop weapons)
- `DeadPlayerWeapons`: If holding chumtoad → `GR_PLR_DROP_GUN_NO` (no weapon drop on death)

### Grappling Hook
- `AllowGrapplingHook`: Returns TRUE only if player is NOT holding chumtoad (`!m_iHoldingChumtoad`)

### Mutators Blocked
- `MUTATOR_999`, `MUTATOR_CHUMXPLODE`, `MUTATOR_NOCLIP`, `MUTATOR_DONTSHOOT`, `MUTATOR_THIRDPERSON`

## Key Constants
```cpp
#define SPAWN_TIME 30.0                    // seconds between loose-toad teleports
#define SQUEEK_DETONATE_DELAY 15.0         // entity lifetime (detonation commented out in CtC)
// cvar: ctcsecondsforpoint (default 10)   // seconds of running to score 1 point
// cvar: scorelimit                        // round wins to win the match
```

## Key Detection Flags
| Check | Value | Meaning |
|-------|-------|---------|
| `pev->fuser4 > 0` | `RADAR_CHUMTOAD` | Player or entity is the chumtoad / holder |
| `pev->fuser4 == 0` | 0 | Player is a chaser (not holding) |
| `m_iHoldingChumtoad` | BOOL | Server-side holding flag (not accessible from bot DLL) |
| `current_weapon.iId == VALVE_WEAPON_CHUMTOAD` | int | Bot's active weapon is the chumtoad |
| `pev->iuser1 == 1` | int | Entity is the valid active chumtoad |
| `pev->effects & EF_NODRAW` | bit | Entity is invisible (not pickable) |

## Bot Behavior (grave-bot-src) — Current State

### Detection (`bot_combat.cpp` — `BotCheckTeamplay`)
- Reads `mp_gamemode` cvar, matches `"ctc"` via `strstr` or `atoi == GAME_CTC`
- Sets `is_gameplay = GAME_CTC`
- **Note**: Unlike KTS/CTF/Coldskull, does NOT force `is_team_play = TRUE` — but the server-side `IsTeamplay()` returns TRUE, so the engine passes team info. Team filtering in `BotFindEnemy` uses `UTIL_GetTeam` checks which already skip same-team players.

### Enemy Filtering (`bot_combat.cpp` — `BotFindEnemy`)

#### Existing Enemy Retention (lines ~676-693)
When bot already has an enemy, the following CtC-specific checks run:
- **Healthy holder** (`health > 25 && current_weapon == VALVE_WEAPON_CHUMTOAD`): Clear enemy → don't fight while carrying
- **Healthy chaser vs non-holder** (`health > 25 && enemy.fuser4 == 0`): Clear enemy → only chase the holder
- **Weak chaser vs non-holder** (`health <= 25 && no toad && enemy.fuser4 == 0`): Clear enemy → both weak, disengage

#### Monster Scan (lines ~761-807)
- Skip `monster_ctctoad` classname entirely (don't treat toad as hostile)
- If bot is healthy holder (`health > 25 && fuser4 > 0`): skip all monsters
- If neither has toad (`bot.fuser4 < 1 && monster.fuser4 < 1`): skip (no toad involvement)

#### Player Scan (lines ~890-898)
- If bot is healthy holder (`health > 25 && fuser4 > 0`): skip all players
- If neither has toad (`bot.fuser4 < 1 && player.fuser4 < 1`): skip (only target holder)

### Combat Engagement (`bot_combat.cpp` — `BotShouldEngageEnemy`)
- If bot has chumtoad (`fuser4 > 0`) and health > 25: return FALSE (don't commit to combat)

### Weapon Switching (`bot_combat.cpp` — `BotFireWeapon`)
- In CtC (`is_gameplay == GAME_CTC`): weapon switching during combat is disabled. Bot keeps whatever weapon is equipped (preserves chumtoad weapon for holder).
- If bot is weak holder (`health <= 25 && fuser4 > 0`): clear `pBotEnemy` (stop fighting, try to survive)

### Item Finding (`bot.cpp` — `BotFindItem`)
- `monster_ctctoad` detected at lines ~1316-1328
- Checks `EF_NODRAW` (skip invisible) and `UTIL_HasWeaponId` (skip if already has chumtoad weapon)
- Sets `can_pickup = TRUE` — treated as standard weapon pickup
- **No early return** for CtC like KTS/Coldskull have — falls through to normal item scanning
- Detection radius: standard 256–512u based on waypoint proximity

### Pre-Update Block (`bot.cpp` — `BotThink`)
- Detects carrier status via `pEdict->v.fuser4 > 0`, sets `b_ctc_has_chumtoad`
- If carrying: clears `pBotPickupItem` / `item_waypoint`
- If chasing: scans players for holder (`fuser4 > 0`), sets `v_goal` toward them. If no holder, finds loose `monster_ctctoad` and sets `v_goal` to its position.

### Think Dispatch (`bot.cpp` — no-enemy branch)
- `BotCtcThink(pBot)` called in dispatch chain (after Coldskull, before pickup fallback)
- Returns true when movement intent is set; false falls through to normal nav

### Post-Combat Reset (`bot.cpp` — `b_engaging_enemy`)
- Clears `waypoint_goal`, `old_waypoint_goal`, forces `f_waypoint_goal_time = 0`
- Prevents bot from returning to stale weapon/ammo waypoints after combat ends

### Navigation (`bot_navigate.cpp` — `BotFindWaypointGoal`)
- Added `GAME_CTC` to 0.5s frequent recalculation condition (alongside KTS/Coldskull)
- Carrier routes toward health waypoints; chaser finds nearest waypoint to holder/toad by pure distance
- Waypoint snap on goal change (identical to KTS/Coldskull pattern)

### Bot Struct Fields (`bot.h` — `bot_t`)
| Field | Type | Purpose |
|-------|------|---------|
| `b_ctc_has_chumtoad` | bool | TRUE when this bot is detected as the active holder |
| `f_ctc_escape_time` | float | Next time to pick a new evasion direction |
| `f_ctc_drop_consider_time` | float | Cooldown for strategic drop evaluation |
| `f_ctc_next_juke_time` | float | Next time to jump or duck evasively |
| `f_ctc_next_move_time` | float | Next time to do a special move (slide/flip/kick) |

## Bot Behavior — Implementation Details

### BotCtcThink Priority (`bot_combat.cpp`, ~line 282)
| Case | Condition | Behavior |
|------|-----------|----------|
| 1 | `b_ctc_has_chumtoad` | Evade: run AWAY from nearest enemy at max speed; re-evaluate escape direction every ~2s. Strategic drop if health ≤ 30. Evasive juking and special moves. Never pause. |
| 2 | Opponent holding toad | Pursue: `v_goal = holder origin`; face and engage carrier aggressively |
| 3 | Toad loose on map | Seek: `v_goal = monster_ctctoad origin`; `f_goal_proximity = 20.0`; run at max speed |
| 4 | No toad in play | Return false — fall through to normal wander/deathmatch |

### Strategic Drop (Case 1, health ≤ 30)
- Bot fires chumtoad weapon (`IN_ATTACK`) to trigger `PrimaryAttack()` → `DropCharm()` server-side
- Gated by `f_ctc_drop_consider_time` cooldown (5s) to prevent spam
- After dropping, bot becomes chaser and seeks health

### Evasion (Case 1, healthy)
- Find nearest enemy player within 1500u
- Compute direction vector AWAY from them (horizontal only)
- Set `v_goal` to point 800u in that direction
- Re-evaluate every `f_ctc_escape_time` (2s) to avoid jitter
- If no threat nearby, keeps running forward
- Always `f_move_speed = f_max_speed`, `f_pause_time = 0`

### Evasive Juking (Case 1 — jump/duck)
- Controlled by `f_ctc_next_juke_time` cooldown timer
- Under pressure (health < 80): 45% chance, cooldown 0.8–1.5s
- Relaxed (health ≥ 80): 15% chance, cooldown 2.0–4.0s
- Randomly picks `IN_JUMP` or `IN_DUCK` each trigger
- Makes carrier harder to track and headshot

### Special Evasive Moves (Case 1 — impulse commands)
- Controlled by `f_ctc_next_move_time` cooldown timer
- Under pressure (health < 80): 35% chance, cooldown 1.5–3.0s
- Relaxed (health ≥ 80): 10% chance, cooldown 3.0–6.0s
- Random selection from:
  - Slide: `impulse 208`
  - Hurricane kick: `impulse 214`
  - Flip (front/back/side): `impulse 210`, `211`, `212`
- Adds unpredictable movement bursts to evasion

### Item Bypass (`bot.cpp` — `BotFindItem`)
- Early return for `GAME_CTC`: clears `pBotPickupItem` and `item_waypoint`
- Prevents generic item scan from interfering with objective navigation

### Direct-Steer (`bot.cpp` — movement direction block)
- Added `ctcChase` bool: when chasing and within 300u with line of sight, bot steers directly toward `v_goal`
- Follows same pattern as KTS/Coldskull `bGoGoal` logic

### v_goal Preservation (`bot.cpp`)
- `GAME_CTC` added to the exclusion list that prevents `v_goal` being wiped to `(0,0,0)` — same as KTS/Coldskull

## Technical Notes
- **MAKE_VECTORS vs UTIL_MakeVectors**: Bot DLL must use `MAKE_VECTORS` (engine callback macro from `enginecallback.h`) NOT `UTIL_MakeVectors` (game DLL utility). Using the latter causes LNK2019 unresolved external.
- **All CtC fields initialized in BotSpawnInit** (`bot.cpp` ~line 321): `b_ctc_has_chumtoad=false`, all timers to `0.0f`
- **Detection relies on `pev->fuser4`**: This is the only cross-DLL signal for chumtoad possession. `m_iHoldingChumtoad` is not accessible from the bot DLL.

## Key Pitfalls (Expected)
1. **Velocity requirement**: Bots MUST maintain > 50 u/s while holding the toad to score. Any pause (charger use, weapon switch, combat engagement) risks an auto-drop. The `f_pause_time = 0` enforcement in Case 1 is critical.
2. **`fuser4` as detection flag**: The bot DLL cannot read `m_iHoldingChumtoad` (server-side CBasePlayer member). All bot detection must use `pev->fuser4` (set to `RADAR_CHUMTOAD` by `CaptureCharm`, cleared to 0 by `DropCharm`).
3. **Touch-based pickup**: The chumtoad is `SOLID_TRIGGER` — bots must physically walk into it. `f_goal_proximity = 20.0` ensures the bot runs all the way through the entity origin. The toad also hunts toward players, which helps.
4. **Weapon restriction while holding**: Holder can ONLY have `weapon_chumtoad`. `CanHavePlayerItem` and `CanHaveNamedItem` enforce this server-side. Bots should not try to pick up weapons while carrying.
5. **`v_goal` wipe**: `bot.cpp` has a `pBot->v_goal = g_vecZero` reset ("always forget goal") that runs after think functions but before the movement block. Must skip this for CtC (same pattern as KTS/Coldskull).
6. **Toad teleports every 30s**: A loose toad moves to a random spawn point every 30 seconds. `v_goal` must be refreshed frequently (0.5s timer) to track the toad's current position.
7. **Chasers can't hurt each other**: `FPlayerCanTakeDamage` returns FALSE for non-holders. Bots already handle this via `BotFindEnemy` filters (skip non-holders), but combat-engaged bots chasing the holder should not waste ammo on other chasers encountered along the way.
8. **Drop mechanism**: `PrimaryAttack()` on the chumtoad weapon triggers the drop. The idle-drop in `PlayerThink` also fires `PrimaryAttack()`. Bot can trigger this via `IN_ATTACK` button while holding chumtoad weapon. This is the intended strategic drop path.
