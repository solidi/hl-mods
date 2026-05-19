# Prop Hunt Gamerules (`GAME_PROPHUNT`, id 15)

Asymmetric hide-and-seek for Cold Ice Remastered.  One squad of **Props**
disguises as world entities and must outlast the round; the other squad of
**Hunters** must convert every prop before the timer (`mp_prophunttime`)
expires.  Conversion happens on damage — there are no kills, only side-swaps.

Spoke document for [gamerules.md](gamerules.md#mode-roster) row 15.
Implementation lives in [`workspace/src/dlls/prophunt_gamerules.cpp`](../src/dlls/prophunt_gamerules.cpp)
and [`workspace/grave-bot-src/dlls/bot_prophunt.cpp`](../grave-bot-src/dlls/bot_prophunt.cpp).

---

## Win condition

| Trigger                                 | Winner   |
| --------------------------------------- | -------- |
| Round timer (`mp_prophunttime`) expires | Props    |
| All props converted before timer        | Hunters  |
| Last prop killed but timer still alive  | Hunters  |

`CHalfLifePropHunt::Think()` checks `m_iPropsRemain` every tick and triggers
end-of-round when it reaches zero.

## Teams

| Team        | `fuser4` | Loadout                                  |
| ----------- | -------- | ---------------------------------------- |
| Props       | 1..30    | `weapon_fists` only, no ammo, `haste=1`  |
| Hunters     | 0        | `weapon_flamethrower` + uranium ammo     |

The `fuser4` value on a prop doubles as its **decoy body index** — pressing
IN_ATTACK with fists equipped cycles the value forward, IN_ATTACK2 cycles
it backward, with a 0.25 s cadence (the weapon's `m_flNextPrimaryAttack`).
Body cycling lives **exclusively** in `CBasePlayerWeapon::ItemPostFrame`
(see [`weapons.cpp`](../src/dlls/weapons.cpp) ~line 1106).  Do not also
handle morph in `CHalfLifePropHunt::PlayerThink` — `PlayerThink` runs
inside `CBasePlayer::PreThink`, **before** `ItemPostFrame`, so any
duplicated `m_afButtonPressed` / `pev->button` read advances the body
twice per press and produces "skipped" bodies and racing cooldowns.
The decoy spawned via `monster_propdecoy` reads the same `fuser4`.

## Cvars

| Cvar                  | Default | Effect                                                                 |
| --------------------- | ------- | ---------------------------------------------------------------------- |
| `mp_prophunttime`     | 180     | Round duration in seconds.                                             |
| `mp_prophealth`       | 20      | HP buffer per prop; conversion only fires when buffer ≤ 0.             |
| `mp_hunterselfcost`   | 1       | HP a hunter loses per primary-fire event (excludes fists/grenade).     |
| `mp_floatingweapons`  | (inh.)  | Inherited from base; controls dropped-weapon behaviour.                |

## Round lifecycle

1. **Spawn** — `PlayerSpawn` sets per-team loadout, clears render fx, seeds
   `fuser4`, sets `haste="1"` on prop edicts via
   `g_engfuncs.pfnSetPhysicsKeyValue`.
2. **Freeze window** — hunters are pinned for `prophuntfreeze` while props
   scatter.  Server signals via `pev->fuser3 = gpGlobals->time + duration`.
3. **Active play** —
   * Prop damage path: `FPlayerCanTakeDamage` subtracts `PROP_DAMAGE_PROXY = 5`
     HP per hit, plays pain sound, returns FALSE (no engine damage).  When
     `pev->health <= 0` the prop is converted to a hunter (team swap, glow
     cleared, `haste="0"`, weapon swap).
   * Hunter self-cost: `PlayerThink` watches the active weapon's
     `m_flNextPrimaryAttack` delta; on a fresh shot subtract
     `hunterselfcost.value` HP, floor at 5.
   * Kill-heal: converting a prop tops the responsible hunter's HP up to
     `max_health`.
4. **Last prop buff** — when `m_iPropsRemain == 1 && m_iPropsStarted >= 2`
   stamp `pev->fuser3 = -1` on the survivor (the cross-DLL DESPERATE flag
   read by the bot), top HP to `prophealth*2`, broadcast a chat line
   announcing the last prop standing, and resupply one hand grenade every
   5 s.  `m_fNextLastPropGrenade` is reset both at round start and on the
   first-time trigger so the initial resupply is immediate.  This used to
   key off `kRenderFxGlowShell` but that field collides with the freeze
   rune in `player.cpp` (and with weapon-box / corpse render fx), so the
   trigger could be missed or clobbered.
5. **Round end** — winner pulse, banner, `EndMultiplayerGame()` rotate.

## Cross-DLL signals (server ↔ bot)

`pev->fuser*` floats are the only cheap channel between the gamedll
(`CBasePlayer`) and the bot dll which only sees `edict_t`:

| Field        | Direction         | Meaning                                                        |
| ------------ | ----------------- | -------------------------------------------------------------- |
| `fuser4`     | server → bot      | Team marker + decoy body (1..70 prop, 0 hunter).               |
| `fuser3`     | server → bot      | **Props only.** Multi-signal: `> 1` = freeze deadline (gpGlobals->time + d), `== 1` = unstick request, `< 0` = last-prop-standing (DESPERATE).  The negative sentinel intentionally cannot collide with the positive freeze deadline. |
| `fuser2`     | server → server   | Morph cooldown (server-side, set by weapon morph in `weapons.cpp`).  |
| `fuser1`     | server → server   | Hunter last-shot `m_flNextPrimaryAttack` snapshot.             |
| `flags & FL_FROZEN` | server → bot | **Hunters only.** Set by `EnableControl(FALSE)` during the round-start freeze.  Bot must check this flag, **not** `fuser3`, for hunter-frozen state — `fuser3` is stale prop-role data on a hunter and was the source of a recurring "frozen hunter jumps when attacked" bug. |

## Entities

* `monster_propdecoy` — short-lived prop decoy spawned by props during
  panic; its `pev->body` is forced to match the owner's `fuser4` so it
  visually matches the prop that dropped it.

## Bot AI implementation

See [`bot_prophunt.cpp`](../grave-bot-src/dlls/bot_prophunt.cpp).  The bot
exposes two entry points used by `BotThink`:

* `BotProphuntPreUpdate` — called every tick **before** `BotFindEnemy`.
  Evaluates the role (PROP_ROLE_FREEZE/HIDE/PANIC/DESPERATE or
  HUNT_SEARCH/PURSUE/HELP) at ~0.75 s cadence, picks a hide spot or search
  cluster, drives the morph button presses, gates `pBotEnemy` so hunters
  ignore frozen props and props only engage hunters within 192 u (384 u
  while DESPERATE).
* `BotProphuntThink` — fallback when no enemy is present.  Stands still at
  the chosen hide spot for HIDE, otherwise sets `v_goal` toward the
  hide spot or search cluster.

The `bot_t` struct gained the following fields (declared in `bot.h`):

```cpp
int      i_pp_role;
float    f_pp_role_eval_time;
Vector   v_pp_hide_spot;
int      i_pp_target_body;
float    f_pp_next_morph;
float    f_pp_panic_until;
edict_t *p_pp_target_item;
float    f_pp_search_pick_time;
Vector   v_pp_search_target;
float    f_pp_lookaround_until;
float    f_pp_decoy_drop_time;
```

`GAME_PROPHUNT` is added to the `v_goal` zero-out exclusion in
[`bot.cpp`](../grave-bot-src/dlls/bot.cpp) so navigation respects the
pre-set goal.

### Hunter avoidance & path obstacle dodge

Props treat hunters as **poison anchors** even when paused.  The bot
defends against three failure modes:

| Failure mode (observed)                                              | Defence                                                                                                                                                                                                                                                                                                       |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Prop picks a `weapon_*` next to a paused hunter and runs to it       | `PP_FindHideAnchor` rejects any anchor whose origin is within `PP_HUNTER_ANCHOR_AVOID = 384u` of **any** live hunter (`PP_AnyHunterNear`).  Combined with the existing `FL_CLIENT`/`FL_FAKECLIENT`/`"player"` classname filters, hunters cannot become anchors and cannot be neighbours of anchors.            |
| Frozen hunter around a corner counts as "safe" because of LOS gate   | Role eval now panics on ANY hunter within `PP_HUNTER_FEAR_DIST = 640u`, regardless of `FVisible`.  The old `PP_PANIC_HUNTER_DIST = 512u` + LOS gate let paused hunters appear safe; that gate is gone for the fear check.                                                                                      |
| Hunter wanders next to the chosen hide spot mid-route                | Every frame (not just on the throttled role-eval tick), if `v_pp_hide_spot` is within `PP_HUNTER_ANCHOR_AVOID` of any hunter the spot is dropped, the waypoint goal is invalidated, and `needsPick` is forced true.                                                                                            |
| Hunter standing in the prop's path                                   | After the v_goal pre-set, the prop scans every live hunter: if any is within `PP_HUNTER_BLOCK_DIST = 160u` and dot(forward-to-hide, forward-to-hunter) ≥ 0.4, `IN_JUMP` is pressed that frame.  Repeated presses produce a double/triple-bound that hops past the blocker rather than ramming into them.       |

### Frozen-actor enemy clamps

Both sides have explicit clamps in `BotProphuntPreUpdate` that run AFTER
the role evaluator and AGAIN as a post-`BotFindEnemy` filter in `bot.cpp`
(because PreUpdate runs *before* the enemy picker, so a re-acquire could
slip through):

* **Props**: if `bFrozen` (own `fuser3` in the future) OR the candidate
  enemy is a hunter with `FL_FROZEN`, drop `pBotEnemy`, zero
  `f_pp_panic_until`, strip `IN_ATTACK | IN_ATTACK2 | IN_RELOAD`.
* **Hunters**: if `pEdict->v.flags & FL_FROZEN`, drop `pBotEnemy`, zero
  `f_move_speed` and `v_goal`, set `f_pause_time`, strip every action
  button including movement keys.  The buffered `IN_JUMP` engine quirk
  (frozen players could still squeak a jump through) is closed because
  `IN_JUMP` is stripped explicitly here.

The helper `PP_HunterIsFrozen(p)` returns `(p->v.flags & FL_FROZEN) != 0`
— **never** use `fuser3` for hunter-frozen detection.  `fuser3` is only
written on **props** at round start; on a hunter it's stale data from a
previous round's prop role.

## Objective HUD bar (`gmsgObjective`)

The HUD bar attached to the second info line of `gmsgObjective` is scaled
against the **starting** team population so it renders 100% at round
start and depletes proportionally as players are eliminated.

Payload order: `WRITE_STRING(goal) ; WRITE_STRING(info) ; WRITE_BYTE(percent) ; WRITE_STRING(wins)`.
The client (`cl_dll/objective.cpp::CHudObjective`) interprets the percent
byte as **0..100** and renders `bar_width = (size + padding) * percent / 100`.

Snapshots captured during the Fisher-Yates team balance (once per round
in `CHalfLifePropHunt::Think`):

```cpp
int count = m_iPropsStarted = m_iHuntersStarted = 0;
// ... shuffle / assign teams ...
if (plr->pev->fuser4 >= TEAM_PROPS) m_iPropsStarted++;
else                                m_iHuntersStarted++;
```

All four `WRITE_BYTE` percent calls use the same safe form:

```cpp
WRITE_BYTE(m_iPropsStarted > 0
    ? (int)(float(props_left) / float(m_iPropsStarted) * 100.0f)
    : 0);
```

| View                          | Numerator      | Denominator         |
| ----------------------------- | -------------- | ------------------- |
| Prop sees "Hunters alive: N"  | `hunters_left` | `m_iHuntersStarted` |
| Hunter sees "Props remain: N" (multi) | `props_left`  | `m_iPropsStarted`  |
| Hunter sees "Props remain: N" (last)  | `props_left`  | `m_iPropsStarted`  |
| Spectator "Props left: N"     | `m_iPropsRemain` | `m_iPropsStarted` |

**Bug previously fixed**: the spectator-view bar used `m_iPlayersInGame`
(props + hunters combined) as denominator — at round start with 4 props
+ 4 hunters that rendered `4 / 8 = 50%`, "never full".  Replaced with
`m_iPropsStarted` so the spectator bar tracks prop survival the same way
as the hunter view.
