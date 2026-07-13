# Grave Bot — AI Overview

The Grave bot is a HPB-derived bot DLL for Cold Ice Remastered. Source lives
under [grave-bot-src/dlls/](../grave-bot-src/dlls/) and builds into
`grave_bot.dll`. This doc is the entry point for any work on bot AI:
lifecycle, navigation, items (including runes), and a short combat summary.
For the deep combat tuning reference, drill into the sub-spoke
[gravebot_combat.md](gravebot_combat.md).

Build target: `workspace/grave-bot-src/dlls/grave_bot.sln`. Bot DLL changes do
**not** require rebuilding the server or client DLL.

---

## 1. Lifecycle

| Step | Function | File |
|---|---|---|
| Engine creates fake client | `CREATE_FAKE_CLIENT` → `BotCreate` | [bot.cpp 585–951](../grave-bot-src/dlls/bot.cpp#L585-L951) |
| Per-bot state allocation | `bots[i]` slot in `bot_t bots[32]` | [bot.cpp 67](../grave-bot-src/dlls/bot.cpp#L67) |
| Skill assignment | `pBot->bot_skill = skill - 1` (0 = hardest, 4 = easiest) | [bot.cpp 867](../grave-bot-src/dlls/bot.cpp#L867) |
| Aggressiveness roll | `i_engage_aggressiveness = RANDOM_LONG(50, 100)` | [bot.cpp 873](../grave-bot-src/dlls/bot.cpp#L873) |
| Per-spawn reset | `BotSpawnInit(pBot)` | [bot.cpp 178+](../grave-bot-src/dlls/bot.cpp#L178) |
| Frame tick | `BotThink(pBot)` (called from `StartFrame`) | [bot.cpp 1696+](../grave-bot-src/dlls/bot.cpp#L1696) |
| Item pickup callback | `BotClient_Valve_ItemPickup` | [bot_client.cpp 398–423](../grave-bot-src/dlls/bot_client.cpp#L398-L423) |
| Weapon pickup callback | `BotClient_Valve_WeapPickup` | [bot_client.cpp 425+](../grave-bot-src/dlls/bot_client.cpp#L425) |

`BotSpawnInit` resets all per-life state (`b_rune`, `pBotPickupItem`,
waypoint timers, etc.). Anything that should not survive death belongs here.

The bot drives itself through the normal client pipeline — `FakeClientCommand`
([dll.cpp 1266–1311](../grave-bot-src/dlls/dll.cpp#L1266-L1311)) packs args
into the global `g_argv` buffer and hands them to `ClientCommand` exactly as
if a human typed them. This is how bots issue `spectate`, `setteam`,
`setmodel` (see [bot_start.cpp 53–114](../grave-bot-src/dlls/bot_start.cpp#L53-L114))
and how they will issue `drop_rune` — see Rune handling below.

---

## 2. Navigation

Detail in [bot_navigate.cpp](../grave-bot-src/dlls/bot_navigate.cpp). High-level
pieces a feature dev should know:

- Movement intent is set by writing to `pBot->v_goal` and `pBot->f_move_speed`
  every frame; the rest of `BotThink` translates that into yaw/pitch/forward.
- Turn rate is per-skill: `yaw_speed` / `pitch_speed` arrays in
  [bot.cpp 124–125](../grave-bot-src/dlls/bot.cpp#L124-L125).
- Pathing is waypoint-based via the `waypoints[]` graph. Combat at
  distance < 512 u temporarily abandons waypoints
  (`f_ignore_wpt_time = time + 0.1`).
- Stuck detection is in `BotStuckInCorner` / `BotCantMoveForward`
  ([bot_navigate.cpp 3069+](../grave-bot-src/dlls/bot_navigate.cpp#L3069)).
- Gamemode-specific overlays (CTF carrier routing, Loot crate breaking, KTS
  ball chase, Cold Skull greedy pickup, Cold Spot zone control) live in
  [bot_combat.cpp](../grave-bot-src/dlls/bot_combat.cpp) as `BotCtfThink` /
  `BotLootThink` / `BotKtsThink` / `BotColdskullThink` / `BotCtcThink`.

### 2a. Ladders, lifts, and other special-traversal waypoints

Ladder/lift/jump waypoints (`W_FL_LADDER`, `W_FL_LIFT`, `W_FL_JUMP`,
`W_FL_DUCKJUMP`, `W_FL_DOUBLEJUMP`) are **path-shape dependencies**: the
bot must touch a very specific brush (ladder face, lift platform, jump
launch spot) for the engine to do the work (`MOVETYPE_FLY` on ladders,
trigger_multiple on lifts, the jump itself). A direct line from the bot
to any other point in the world bypasses that brush and the traversal
silently fails.

That means **every code path that synthesises a movement vector must
defer to waypoint routing when the current waypoint has a traversal
flag**. There are five such paths today — leave the guards in place
when adding new behavior:

1. **Goal-snap guard** in `BotHeadTowardWaypoint`
   ([bot_navigate.cpp ~L612–L620](../grave-bot-src/dlls/bot_navigate.cpp#L612-L620)).
   The per-gamemode "snap `curr_waypoint_index` to nearest reachable"
   blocks (KTS / Cold Skulls / CTC / CTF / Arena / Cold Spot / LMS /
   Busters / Horde / Loot) all gate on `bSafeToSnap`, which is forced
   false when `pEdict->v.movetype == MOVETYPE_FLY` or the current
   waypoint has any traversal flag. Snapping mid-climb (or at the foot
   of a ladder where "nearest reachable" is the foot waypoint itself)
   undoes the routing promotion to the next ladder waypoint and freezes
   the bot in place.
2. **Direct-steer guard** in `BotThink`'s movement-direction block
   ([bot.cpp ~L3371–L3389](../grave-bot-src/dlls/bot.cpp#L3371-L3389)).
   When `bGoGoal == true` the bot's forward+strafe vector is synthesised
   from `pBot->v_goal - origin` regardless of yaw, so the *actual*
   velocity goes toward `v_goal`. The guard forces `bGoGoal = false`
   when `curr_waypoint_index` has a traversal flag. Without this, a
   bot at the foot of a ladder with the zone/flag/ball visible above
   walks toward `v_goal` (i.e. into the wall beside the ladder), never
   touches the ladder brush, and `MOVETYPE_FLY` never engages.
3. **Elevated-jump guard** in `BotGoalElevatedJump`
   ([bot_combat.cpp ~L491–L520](../grave-bot-src/dlls/bot_combat.cpp#L491-L520)).
   This helper fires a 3-phase multi-jump combo whenever the goal is
   within 300u horizontally and > 20u above the bot. It is called
   every frame by Cold Spot (HUNTER/SEEKER/HOLDER and the PreUpdate),
   CTF carrier/retriever, Loot RECOVERER/COLLECTOR, Arena, LMS, and
   the combat stall force-trigger. At the foot of a ladder under the
   goal, both gate conditions are true — so without the guard the
   bot would jump in place (forcing `ideal_yaw` toward the goal and
   pressing `IN_JUMP`) instead of walking horizontally into the
   ladder brush. The guard returns false and resets
   `f_goal_jump_stall_time = 0.0f` so the 0.5s stall timer cleanly
   re-arms after the bot exits the traversal waypoint. **This was
   the second-pass fix after the FFA-vs-Cold-Spot regression** —
   FFA bots had no `BotGoalElevatedJump` caller so they climbed
   fine; Cold Spot bots had `BotColdSpotThink` triggering the combo
   under any elevated spot.
4. **Proximity-stop guard** in `BotThink`
   ([bot.cpp ~L3468–L3495](../grave-bot-src/dlls/bot.cpp#L3468-L3495)).
   Right after the forward+strafe synthesis there is a state modifier
   that zeroes `f_move_speed`/`f_strafe_speed` when the 3-D distance
   from the bot to `v_goal` drops below `f_goal_proximity`. With a
   goal directly *above* the bot (cold-spot zone at the top of a
   ladder shaft, dribbler on a catwalk, LMS shrink-zone elevation)
   the 3-D distance is small while the actual path is the climb
   height. Without this guard, HOLDER-classified Cold Spot bots
   (any bot within 256u 3-D of the spot — `f_goal_proximity = 128`
   inside `CSPOT_HOLDER_RADIUS`) freeze at the foot of the ladder
   the instant they enter the zone. LMS HOLDER (`LMS_ZONE_SLACK =
   96`) and KTS dribble-chase (proximity = 48) have the same trap.
   FFA / Gungame never set `f_goal_proximity > 0`, which is why the
   bug was custom-gamemode-only. The guard sets `bNearTraversal`
   from the same flag set and skips the stop when true.
5. **Gamemode yaw-skip guard** in `BotHeadTowardWaypoint`
   ([bot_navigate.cpp ~L1141–L1180](../grave-bot-src/dlls/bot_navigate.cpp#L1141-L1180)).
   The waypoint-facing override block (`idealpitch = -v_angles.x`,
   `ideal_yaw = v_angles.y` toward `curr_waypoint_index`) is
   intentionally skipped in KTS when the bot doesn't carry the ball,
   so the bot can face the ball instead of the next waypoint. That
   skip *also* skips the `idealpitch` assignment, so at the foot of
   a ladder with the upper waypoint directly above, `idealpitch`
   stays at 0 and the bot stares at the floor. Symptom matches the
   user-observed "will not look up and follow the next up the
   ladder." The guard re-enables the override (overriding the skip)
   when the curr waypoint carries a traversal flag, so the bot tilts
   toward the upper ladder waypoint and `MOVETYPE_FLY` can engage.
   Any future gamemode-specific yaw/pitch skip added to this block
   must apply the same flag exception.

Lifecycle of a successful climb (mental model — keep this in mind when
adding new movement-tweaking code):
- Bot reaches the foot ladder waypoint (`distance < 20`).
- Touching block in `BotEvaluateGoal` advances `curr_waypoint_index` to
  the upper ladder waypoint via `WaypointRouteFromTo`.
- The 1141-area yaw block sets `ideal_yaw`/`idealpitch` toward the
  upper waypoint. Pitch is then reset to 0 at
  [bot.cpp ~L2516](../grave-bot-src/dlls/bot.cpp#L2516) for any
  non-water non-FLY frame — that is **intentional**; the ladder
  trigger doesn't care about pitch and `BotOnLadder` re-sets pitch
  once `MOVETYPE_FLY` engages.
- Bot walks horizontally into the ladder brush → engine flips
  `movetype` to `MOVETYPE_FLY`.
- `BotOnLadder` ([bot_navigate.cpp ~L2793](../grave-bot-src/dlls/bot_navigate.cpp#L2793))
  takes over: sets `v_angle.x = -60` for `LADDER_UP` (or `+60` for
  `LADDER_DOWN`), holds `IN_FORWARD`, and watches `moved_distance` to
  flip direction if stuck against another player on the ladder.
- `ladder_dir` was pre-set in [bot.cpp ~L3029–L3045](../grave-bot-src/dlls/bot.cpp#L3029-L3045)
  by comparing the upper waypoint's z to the bot's z when the W_FL_LADDER
  flag was first noticed.

Things to **avoid** when working near this code:
- Never compute `f_move_speed`/`f_strafe_speed` from a world position
  (`v_goal`, item origin, enemy origin, defend spot, etc.) without
  honouring the same traversal-flag gate that `bGoGoal` does. If you
  add a new mode that pushes the bot toward an arbitrary point, copy
  the guard at [bot.cpp ~L3371–L3389](../grave-bot-src/dlls/bot.cpp#L3371-L3389)
  into the new code path.
- Don't add new "snap to nearest reachable" calls outside the
  `bSafeToSnap`-gated section. If you need a fresh snap, route it
  through the same gate.
- Don't gate ladder behavior on `pEdict->v.movetype == MOVETYPE_FLY`
  alone — the failure mode is **pre-engagement** (bot near the brush,
  still `MOVETYPE_WALK`). Use `waypoints[curr_waypoint_index].flags &
  W_FL_LADDER` for the "about to climb" predicate.
- The item-pickup direct-steer branch at
  [bot.cpp ~L3392–L3396](../grave-bot-src/dlls/bot.cpp#L3392-L3396)
  is safe **only because** `pBot->item_waypoint` is set when an item
  has been routed through waypoints (including ladders). If you ever
  zero `item_waypoint` while keeping `pBotPickupItem`, this branch
  will reproduce the same ladder-stall bug.
- Don't add a new helper that presses `IN_JUMP` / `IN_USE` /
  `IN_DUCK` based on a world-position trigger (height-diff,
  proximity, line-of-sight, etc.) without copying the traversal
  guard from `BotGoalElevatedJump`. Pressing `IN_JUMP` at the foot
  of a ladder leaves the ground and stops the bot from touching the
  ladder brush. `BotGoalElevatedJump` callers (Cold Spot, CTF,
  Loot, Arena, LMS, combat stall) all funnel through that single
  guard — keep it that way rather than duplicating jump logic per
  gamemode.

Deep-dive log: `/memories/repo/gravebot_traversal_guard.md`.

---

## 3. Item handling — `BotFindItem`

[bot.cpp 1037–1619](../grave-bot-src/dlls/bot.cpp#L1037-L1619). Runs at most
once per second (gated by `pBot->f_find_item`). Walks all entities within
~256–512 u, classnames matched by `strcmp` / `strncmp`, deciding what to
pick up.

Key behaviors:

- Sets `pBot->pBotPickupItem` and routes the bot toward it via `v_goal`.
- Several gamemodes early-return so item scanning doesn't override role
  routing: `GAME_KTS`, `GAME_COLDSKULL`, `GAME_CTC`, `GAME_LOOT`,
  `GAME_ARENA`, and Buster role in `GAME_BUSTERS` — see
  [bot.cpp 1051–1120](../grave-bot-src/dlls/bot.cpp#L1051-L1120).
- Pickups happen by collision: the bot navigates onto the entity and the
  server-side `Touch` handler fires.
- **Grappling-hook detour** (added 2026-06): after `pBotPickupItem` is
  assigned, `BotConsiderHookForItem` is called. If the bot has no enemy,
  the item is > 96u above the bot, there's a hookable ceiling above the
  item, and the bot has LOS to that anchor (all gates inside
  `BotComputeHookAimForItem`), the bot fires impulse 217 toward the
  anchor. The hook is released on any pickup notification via
  `BotClient_Valve_ItemPickup`. Master cvar: `sv_bots_hook`. Full reference
  in [grappling_hook.md §7](grappling_hook.md#7-bot-usage-grave_bot).
- Several item branches are simple boolean gates (e.g.
  `if (!pBot->b_longjump)`); the rune branch used to be the same but is
  now context-aware (see next section).

The actual pickup is reported back via `BotClient_Valve_ItemPickup`
([bot_client.cpp 398–423](../grave-bot-src/dlls/bot_client.cpp#L398-L423))
which sets the bot's mirror state (`b_longjump`, `b_rune`, `i_rune_type`).

---

## 4. Rune handling

Background on what runes do and how they spawn / drop is in
[runes.md](runes.md). This section covers the bot side only.

### State mirror

The bot does not read `CBasePlayer::m_fHasRune` — the bot DLL does not have
direct access to the server DLL's player class. Instead each bot keeps its
own mirror in `bot_t`:

| Field | Meaning |
|---|---|
| `bool b_rune` | True iff bot is carrying any rune. |
| `int  i_rune_type` | The `RUNE_*` value (1–9), or 0 if `b_rune` is false. |
| `float f_rune_drop_cooldown` | Until this time, bot ignores all `rune_*` entities (used right after a swap-drop so the bot does not immediately re-grab the rune it just discarded). |

Mirrored `RUNE_*` constants live in [bot.h](../grave-bot-src/dlls/bot.h)
(see the `// rune type IDs (must match src/dlls/items.h)` comment block).
Keep them in lock-step with [src/dlls/items.h 30–42](../src/dlls/items.h#L30-L42).

All three fields are reset in `BotSpawnInit` so dying clears them — this
matches the server-side `m_fHasRune = 0` clear in
[player.cpp 876–909](../src/dlls/player.cpp#L876-L909).

### Pickup detection

`BotClient_Valve_ItemPickup` fires whenever the engine reports a pickup. The
rune branch parses the classname (`rune_frag` → `RUNE_FRAG`, etc.) via the
helper `BotRuneClassToType` and writes both `b_rune = true` and
`i_rune_type = <id>`. This is the bot's only way to learn which rune it
just grabbed.

### Scoring — what makes a rune "better"

Helper `BotEvaluateRuneScore(pBot, type)` in
[bot_combat.cpp](../grave-bot-src/dlls/bot_combat.cpp) returns a float. The
base table:

| Rune | Base | Why |
|---|---:|---|
| STRENGTH | 90 | +50% damage is the strongest direct combat power-up. |
| HASTE    | 85 | Faster fire rate scales with weapon DPS. |
| VAMPIRE  | 80 | Effective HP gain proportional to damage dealt. |
| PROTECT  | 80 | Halves all incoming damage. |
| REGEN    | 70 | Slow heal — strong over time, weak burst. |
| FRAG     | 65 | Score-only; no combat advantage. |
| CLOAK    | 60 | Situational; useless during a firefight. |
| AMMO     | 55 | Refilling magazines — neutral when ammo is plentiful. |
| GRAVITY  | 50 | Movement utility; no direct combat boost. |

Context bonuses on top of the base:

- `REGEN`  — `+50` if `pev->health < 30`, `+25` if `< 60`.
- `VAMPIRE` — `+20` if `pev->health < 60`.
- `PROTECT` — `+15` while `b_engaging_enemy`.
- `CLOAK`  — `+15` if `pev->health < 40` AND not engaging.
- `AMMO`   — `+30` if either `BotAssessPrimaryAmmo` or
  `BotAssessSecondaryAmmo` for the current weapon is `AMMO_CRITICAL`.
- `HASTE`  — `+20` while `bot_has_flag` (carrier wants to move + shoot fast).
- `FRAG`   — `+15` when `is_team_play == 0` (only meaningful in DM).

### Swap-on-contact protocol

Tuned to be cheap and robust:

1. `BotFindItem` rune branch (per-second cadence) decides the bot wants the
   rune. If the bot is empty-handed, behave as before. If the bot already
   holds a rune, compute `BotEvaluateRuneScore` for both; only set
   `pBotPickupItem` to the new rune when
   `new_score > held_score + RUNE_SWAP_MARGIN` (margin = 8.0 to prevent
   thrashing between near-equal runes). Skip all rune entities while
   `f_rune_drop_cooldown` is in the future.
2. `BotMaybeDropRuneForSwap(pBot)` runs every frame from `BotThink` right
   after `BotFindItem`. When the bot still holds a rune AND its current
   `pBotPickupItem` is a rune (so the previous step OK'd a swap) AND the
   target is within ~120 u, the bot:
   - Issues `FakeClientCommand(pEdict, "drop_rune", NULL, NULL)` — same path
     a human uses. The server runs `CWorldRunes::DropRune` exactly as for
     a player.
   - Locally clears `b_rune` and `i_rune_type`.
   - Sets `f_rune_drop_cooldown = time + 1.5` so the bot does not re-acquire
     the discarded rune (which is now flying ~400 u/s away from it).
3. The bot continues into the new rune and `BotClient_Valve_ItemPickup`
   re-populates `b_rune` / `i_rune_type` for the new pickup.

### Limitations & follow-ups

- No detour: bots only swap when the new rune happens to be inside their
  normal item-search radius. They will not divert from a flag run or a
  combat goal to grab a better rune.
- No proactive drops: a bot will not voluntarily drop a "bad" rune unless a
  better one is right there.
- No teammate-aware drops (e.g. dropping STRENGTH for a low-HP teammate).
- No CVar tuning: the base table, bonuses, margin, distance threshold and
  cooldown are hard-coded. Promote to CVars if balancing demands.

---

## 5. Combat summary

Bots reach combat via:

- `BotFindEnemy` (every think frame) — 2500 u sphere, FOV + `FVisible`,
  per-skill transparency cutoff.
- `BotShouldEngageEnemy` — gates engagement on ammo state and gamemode role.
- `BotShootAtEnemy` — body-target selection, lead, step error, per-frame
  jitter, all gated on recent line-of-sight.
- Bio-weapon safety gate (2026-07): versus `monster_snark` /
  `monster_chumtoad`, bots never deploy `weapon_snark` or
  `weapon_chumtoad` as a counter. If a non-melee weapon is usable at the
  current range, they use it; if only melee options remain, they evade
  until the threat is gone.

Tuning arrays (`yaw_speed`, `pitch_speed`, `aim_tracking_*_scale`,
`aim_jitter_scale`, `react_time_min/max`, `renderamt_threshold`,
`sound_sense`, `pause_*`) and per-weapon fire delays are all per-skill.

Full reference (target selection, reaction-time model, aim model with the
LOS-gated wobble, engagement gate, firing, melee, the `bot_aim_difficulty`
CVAR) is in [gravebot_combat.md](gravebot_combat.md).

---

## 6. CVars

Registered in [dll.cpp 142–144](../grave-bot-src/dlls/dll.cpp#L142-L144) and
configured at [dll.cpp 1944–2001](../grave-bot-src/dlls/dll.cpp#L1944-L2001).

| CVar | Default | Meaning |
|---|---|---|
| `gravebot` | "" | Console command channel (`gravebot add`, etc.). |
| `sv_defaultbots` | 0 | Bots auto-added on map load. |
| `sv_botsmelee` | 1 | Allow melee impulses (kick / punch / flip / slide / grenade / force-grab). |
| `bot_reaction_time` | 2.0 | Multiplier on `react_time_min/max`. 0 disables reaction delay. |
| `bot_reaction_time_min <skill 1-5> <v>` | — | Edit one skill row. |
| `bot_reaction_time_max <skill 1-5> <v>` | — | Edit one skill row. |
| `bot_aim_difficulty` | 1.0 | Multiplier on aim tracking/jitter and re-acquire reaction delay. |
| `botskill <1-5>` | — | Sets `default_bot_skill` for new bots (1=hardest, 5=easiest). |
