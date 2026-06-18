# Shidden Gamerules (`GAME_SHIDDEN`, id 16)

Asymmetric stalking mode for Cold Ice Remastered.  A small squad of
**Dealters** (invisible, low-gravity, fists + knife only) must convert
the **Smelter** team via a two-step combo: a close-range fart freezes the
target for five seconds, and a primary-fire knife strike on a frozen
smelter is an instant one-shot kill.  Smelters carry standard loadouts
and survive by spotting the (mostly invisible) dealters and shooting
back.

Spoke document for [gamerules.md](gamerules.md#mode-roster) row 16.
Implementation lives in [`workspace/src/dlls/shidden_gamerules.cpp`](../src/dlls/shidden_gamerules.cpp)
(round + win-state + freeze + knife one-shot), with the fart attack in
[`workspace/src/dlls/weapons.cpp`](../src/dlls/weapons.cpp) (lines ~1168-1210)
and the freeze counter / thaw block in
[`workspace/src/dlls/player.cpp`](../src/dlls/player.cpp) (~line 4294).

Bot AI lives in [`workspace/grave-bot-src/dlls/bot_shidden.cpp`](../grave-bot-src/dlls/bot_shidden.cpp),
wired through `bot.cpp` (`BotShiddenPreUpdate` + `BotShiddenThink` dispatch,
dealter button/impulse guards, dead-player audio gates), `bot_func.h`
(forward declarations), `bot.h` (role enum + 6 per-bot state fields),
`bot_client.cpp` (smelter damage-reaction hook), `bot_combat.cpp`
(dealter weapon selection / fire branch + cloaked-enemy retention
hysteresis), and `util.cpp` (existing team identification via `fuser3`
plus a dead-player audio gate).

---

## Win condition

Last-team-standing per round.  `DetermineWinner` walks live players and
counts smelters vs dealters; the team whose opponents reach zero wins
the round.  Round wins are tracked via `pPlayer->m_iRoundWins++` for
each winning team member, and a `gmsgWinningTeam` user message
broadcasts the result before the round resets.

The per-team tally starts at `highest = 0` (initial value 1 would have
tied a true 1-survivor scenario against an empty enemy team and skipped
the winner broadcast).

`PlayerKilled` recounts the per-team survivor totals straight from
`UTIL_PlayerByIndex` filtered by `IsPlayer && IsInArena && IsAlive &&
!IsSpectator && !HasDisconnected`.  The old `m_iPlayersInArena[]`
index table is no longer consulted — it desyncs from the live world
state when players late-join, disconnect, or move to spectator
mid-round.

---

## Teams

`pev->fuser4` carries the team value, mirrored by `pev->fuser3` for the
bot DLL's `UTIL_GetTeam` resolver:

| `fuser4` | Symbol            | `fuser3` | Team string | Notes                              |
|----------|-------------------|----------|-------------|------------------------------------|
| `0`      | `SHIDDEN_SMELTER` | `0`      | `smelters`  | Visible, normal loadout, normal gravity. |
| `1`      | `SHIDDEN_DEALTER` | `1`      | `dealters`  | `MakeInvisible()`, `gravity = 0.70`, `"haste" = 1`, inventory cleared to `weapon_fists` + `weapon_knife`. |

Team assignment runs in `Think()` at round start (shuffle loop) and is
re-applied by `PlayerSpawn` for any client respawning mid-round.

At round-start the team-assignment loop also:

- Snapshots `m_iSmeltersStart` and `m_iDealtersStart` from the actual
  assignments (not the pre-filter pool) — these are the denominators
  the HUD progress bar uses (see HUD bar denominators below).
- Sets `pev->fuser3 = pev->fuser4` synchronously so the bot DLL
  resolves the team correctly even before the spawned client's first
  `PlayerSpawn` runs.

`PlayerSpawn` has three branches:

1. **Late-join / non-actor** (`g_GameInProgress && !IsInArena`, or
   `!g_GameInProgress && IsRoundBased`).  Resets the player to a clean
   smelter-like profile and returns early: `fuser4 = fuser3 =
   SHIDDEN_SMELTER`, `gravity = 1.0`, `m_iFreezeCounter = -1`,
   `iuser4 = -1`, `"haste" = 0`.  Without this reset a player rejoining
   after being a dealter the previous round would keep `gravity = 0.70`
   and `haste = 1` while waiting on the sidelines.
2. **Dealter** (`fuser4 == SHIDDEN_DEALTER`).  `"haste" = 1`,
   `gravity = 0.70`, inventory cleared to `weapon_fists` +
   `weapon_knife`, `MakeInvisible()`.
3. **Smelter** (else).  `"haste" = 0`, `gravity = 1.0`, `fuser3 = 0`,
   `MakeVisible()`, standard loadout.

---

## Fart attack (freeze)

`weapons.cpp` PrimaryAttack / SecondaryAttack guard:

```cpp
if ((MutatorEnabled(MUTATOR_DEALTER) && oktofire) ||
    (IsShidden() && m_pPlayer->pev->fuser4 > 0 && m_iId != WEAPON_KNIFE))
```

A dealter on a Shidden round farts when they press primary OR secondary
on **anything except the knife** (held knife is exempt — that's the
finisher slot).  The press fires:

- `RadiusDamage(origin, 800 dmg, 256u, DMG_FART)` — only smelters take
  it; dealters are immune via `FPlayerCanTakeDamage`.
- `EMIT_SOUND_DYN("fart.wav")`, smoke temp-ent, green screen-fade on
  the dealter.
- Weapon cooldown: `m_flNextPrimaryAttack = +0.75s`.

Smelters caught in radius enter the freeze branch in
`shidden_gamerules.cpp::FPlayerCanTakeDamage`.  The trigger is
`IsFartedOn || (gMultiDamage.type & DMG_FART)`; the `DMG_FART` bit is
the authoritative signal and `IsFartedOn` is kept as a legacy fallback
for weapon paths that pre-date the multidamage tag.

Key constants (named locally inside the branch):

| Constant                       | Value | Meaning                                       |
|--------------------------------|-------|-----------------------------------------------|
| `SHIDDEN_FREEZE_TICKS`         | `50`  | Counter ticks; freeze duration = 50 * 0.1 s. |
| `SHIDDEN_FREEZE_SHELL_MAX`     | `25`  | Cap on `pev->renderamt` (glow-shell thickness). |

```cpp
pPlayer->m_iFreezeCounter = SHIDDEN_FREEZE_TICKS;       // 5s frozen
pPlayer->pev->renderamt   = SHIDDEN_FREEZE_SHELL_MAX;   // visual cap
pPlayer->pev->iuser4      = pPlayer->m_iFreezeCounter;  // cross-DLL signal
pPlayer->pev->renderfx    = kRenderFxGlowShell;
pPlayer->pev->rendercolor = Vector(120, 220, 50);
pPlayer->pev->flags      |= FL_FROZEN;
```

The duration counter and the glow thickness used to be the same
variable (`= 50`), which produced a very thick shell.  Splitting them
keeps the freeze gameplay-length stable while taming the visual.

The freeze counter ticks down once per `PlayerThink` (every 0.1s).  At
zero, the thaw block in `player.cpp` clears `renderamt`, `renderfx`,
`rendercolor`, and `m_iFreezeCounter` and mirrors `pev->iuser4 = 0`.

### Stuck-frozen recovery (player.cpp PostThink)

If an external path (gamerules `Killed()`, godmode toggle, respawn)
resets `m_iFreezeCounter` without also dropping `FL_FROZEN`, the
player stays glued in place forever.  A guard branch in `PostThink`
detects `m_iFreezeCounter < 0 && (pev->flags & FL_FROZEN) && !GODMODE`
and clears the flag, the glow render-fx, and mirrors `iuser4 = -1`.
This catches the edge case but the per-path explicit resets are still
the primary correctness mechanism.

### `IceExplode` glow cap (DMG_FREEZE)

Unrelated to the fart freeze but living in the same `PostThink`-touched
region: `IceExplode` previously did `renderamt += 15` unbounded.  It is
now capped at `60` (one stack above the shatter-kill threshold of 45),
so repeated `DMG_FREEZE` hits no longer grow the shell without limit
while still allowing the shatter branch to fire on overflow.

---

## Knife one-shot (finish)

`FPlayerTookDamage` checks every damage event for the finisher
signature:

- Killer is a player with `fuser4 == SHIDDEN_DEALTER`.
- Killer's active item is `WEAPON_KNIFE` (primary-fire stab, not the
  off-hand kick — `isOffhand` flag excludes `DMG_PUNCH|DMG_KICK`
  multidamage entries from `m_pActiveItem`).
- Victim is a smelter with `m_iFreezeCounter > 0` and `IsAlive()`.

When all three match, the function forces `pVictim->pev->health = 0`,
calls `Killed(...)`, sets `iuser4 = -1` so the bot DLL sees the
clear, and emits the fart-smoke effect at the victim's origin.

Note: the same function only fires on knife primary.  Pressing fire
with fists, or kicking the frozen target, does **not** finish — that
deals normal melee damage which the freeze shield absorbs without
killing.

`FPlayerTookDamage` short-circuits on a null `pVictim` before any of
the finisher checks run; the calling damage path can race a victim
disconnect on the same tick.

### Frozen-smelter input gate (player.cpp ImpulseCommands)

While `FL_FROZEN`, `m_Activity` clamps to `ACT_FROZEN`, but the
off-hand action impulses (205-216: kick / punch / slide / flips /
hurricane kick / grab / throw-weapon / throw-grenade / swap-dual /
etc.) still fire their server-side actions with no visible animation —
letting a frozen smelter kick the dealter that's mid-finish.
`ImpulseCommands` now zeroes any impulse in `[205, 216]` for frozen
players before the impulse switch runs.  Flashlight, decal, and cheat
impulses are unaffected; only the action set is gated.  This protects
any gameplay that uses `FL_FROZEN`, not just Shidden.

---

## Cross-DLL signals (server ↔ bot)

The bot DLL cannot read private `CBasePlayer` members like
`m_iFreezeCounter`.  We mirror it onto a free entvar so the bot can
see freeze state through the engine boundary:

| Slot          | Owner         | Meaning                                               |
|---------------|---------------|-------------------------------------------------------|
| `pev->fuser4` | server        | `0` = smelter, `1` = dealter (see Teams table).       |
| `pev->fuser3` | server        | Mirror of `fuser4` for `bot/util.cpp::UTIL_GetTeam`.  |
| `pev->iuser4` | server → bot  | Freeze counter mirror.  `> 0` = currently frozen for that many ticks.  `0`/`-1` = clear.  Set in `FPlayerCanTakeDamage` (apply), `FPlayerTookDamage` (finisher clear), `player.cpp` PostThink thaw + stuck-recovery branches (timeout clear), `player.cpp` `Killed` (unfreeze-on-death), `player.cpp` `Spawn` (`-1` reset), and `shidden_gamerules.cpp::PlayerSpawn` late-joiner branch (`-1` reset). |

`iuser4` was verified unused elsewhere on player entities across both
the server (`workspace/src/dlls`) and client (`workspace/src/cl_dll`)
trees before being repurposed for this signal.

---

## Bot AI implementation

`bot_shidden.cpp` follows the same PreUpdate + Think + role-eval pattern
as `bot_loot.cpp` / `bot_prophunt.cpp`.

### Entity cache (`BotShiddenBuildCache`)

A single per-frame walk of `clients[0..maxClients]` builds three lists:

- `pDealters[]`  — live players with `fuser4 == SHIDDEN_DEALTER`.
- `pSmelters[]`  — live players with `fuser4 == SHIDDEN_SMELTER`.
- `pFrozenSmelters[]` — subset of smelters with `iuser4 > 0`.

The cache is timestamped (`f_built_time`) and reused within the same
server frame, so `BotShiddenPreUpdate` + `BotShiddenThink` only walk
once per tick.

### Per-bot state (`bot_t`, added to `bot.h`)

```cpp
int      i_shidden_role;           // SHIDDEN_ROLE_* enum
float    f_shidden_role_eval_time; // next role eval (0.5s cadence)
edict_t *p_shidden_target;         // FINISHER locked target
float    f_shidden_target_time;    // lock expiry
float    f_shidden_fart_cooldown;  // local fart-press cooldown (> weapon's 0.75s)
float    f_shidden_unseen_until;   // smelter alert window (post-fart hit)
```

All six fields are zeroed in `BotSpawnInit`.

### Dealter roles

| Role       | Trigger                                          | Behaviour |
|------------|--------------------------------------------------|-----------|
| `HUNTER`   | No frozen smelter exists, or all freezes already locked by other dealters. | Hold `weapon_fists` (force-switched via `UTIL_SelectItem` with a 0.25s cooldown).  Pursue nearest visible smelter (fallback: nearest known).  When within `SHID_FART_RANGE` (240u, slightly inside the gameplay 256u radius) and LoS holds and the local cooldown has expired, press `IN_ATTACK` to fart.  Local cooldown `SHID_FART_COOLDOWN = 0.85s` is intentionally larger than the weapon's 0.75s to avoid wasted presses on the same target. |
| `FINISHER` | A frozen smelter exists in the cache.  The dealter locks onto the closest one (lock-time `SHID_FINISHER_LOCK_TIME = 2.5s`, refreshed every tick the target remains frozen).  Promotion to FINISHER is immediate (does **not** wait for the 0.5s role-eval tick) the moment a freeze lands. | Force-switch to `weapon_knife`.  Force-target via `pBot->pBotEnemy = pFinishTarget` so `BotShootAtEnemy` aims at them through invisibility.  Sprint at `f_max_speed`.  When within `SHID_KNIFE_RANGE = 64u` and holding the knife and the target is in view-cone, press `IN_ATTACK`.  Gamerules then forces the one-shot kill. |

#### Dealter weapon ownership in `BotFireWeapon`

The priority-table weapon picker normally chooses based on
`weapon_priority[]`, where `weapon_knife` (9) outranks `weapon_fists`
(10) — that would override the role-selected weapon every combat tick.
`BotFireWeapon` (in `bot_combat.cpp`) has a Shidden dealter early-out
branch that owns BOTH weapon selection and the fire press:

- `wantId` is derived from the **live** enemy state, not
  `pBot->i_shidden_role`.  `i_shidden_role` only updates inside
  `BotShiddenThink`, which is skipped once `pBotEnemy` is set; using the
  role here would keep the knife held past the frag (target dead,
  `iuser4 = -1`) and on the first combat tick of any round whose
  predecessor ended as FINISHER.  Instead: knife only when
  `pBotEnemy && IsAlive(pBotEnemy) && pBotEnemy->v.iuser4 > 0`; fists
  otherwise.
- Fires `IN_ATTACK` if the current weapon matches `wantId` and the
  enemy is inside the fire range (`64u` for knife, `240u` for fists).
  Fists' default `primary_max_distance` is 100u, which is below the
  240u fart radius — without this override the default picker would
  never even press fire at fart range.
- Returns `TRUE` to skip the rest of the combat pipeline.

#### Dealter button / impulse guards (`bot.cpp` just before `pfnRunPlayerMove`)

- `IN_ATTACK2` is stripped from `pev->button` for every Shidden dealter
  tick.  `IN_ATTACK2` on `weapon_knife` is a throw that destroys the
  weapon and ends the fart→finish loop for the rest of the round.
- `IN_RELOAD` is stripped for the same reason on the knife (knife's
  `Reload()` toggles a sniper-style zoom that disrupts close-range aim).
- When the active weapon is `weapon_knife`, impulses in `[205, 216]`
  (kick / punch / slide / flips / hurricane kick / grab / throw / etc.)
  are zeroed.  `StartKick` / `StartPunch` fire `DMG_KICK` / `DMG_PUNCH`
  on contact, which races the knife primary stab — gamerules'
  `isOffhand` check then rejects the frag and the bot bounces off the
  frozen target instead of finishing it.  Melee re-enables automatically
  the moment the bot drops back to fists.

### Smelter roles

| Role        | Trigger                                                                                   | Behaviour |
|-------------|--------------------------------------------------------------------------------------------|-----------|
| `DEFENDER`  | At least one teammate has `iuser4 > 0` (is frozen).                                        | Move toward the frozen teammate (proximity 96u).  Scan dealters within `SHID_DEFEND_SCAN_RADIUS = 640u` around the frozen teammate — any visible dealter is force-set as `pBotEnemy` so the bot shoots through invisibility before the knife finish lands. |
| `FLOCK`     | No frozen teammate; smelter count ≥ 2.                                                     | Move to the team centroid with a per-bot jitter `(entindex * 71) % 96` so bots don't pile onto the same pixel.  Slow to `0.65 * f_max_speed` once within `SHID_FLOCK_RADIUS = 384u`.  Opportunistic dealter spotting at `SHID_DEALTER_SPOT_RANGE = 768u`. |
| `SCOUT`     | Solo (1 smelter alive).                                                                    | Fall through to default waypoint roam; still opportunistically force-target any visible dealter. |
| (frozen)    | `pev->iuser4 > 0`.                                                                         | Engine `FL_FROZEN` already locks input; we also clear `pBotEnemy`, zero `f_move_speed`, and strip `IN_ATTACK | IN_ATTACK2 | IN_JUMP`. |

### Damage-reaction hook (`bot_client.cpp::BotClient_Valve_Damage`)

When a Shidden smelter (`fuser4 == SHIDDEN_SMELTER`) that is **not
currently frozen** (`iuser4 == 0`) takes damage, the standard 1-second
`f_dmg_time` window is extended to 3 seconds, and
`f_shidden_unseen_until` is armed for 3 seconds.  Skipping the boost
while already frozen avoids a duplicate alert on the freeze tick
(the frozen smelter can't act on it anyway).  While the alert window
is active, FLOCK and SCOUT widen their dealter-spot range to `1.5x`
and drop the view-cone gate so the bot whirls around to face the
(still invisible) attacker, dramatically increasing the chance of
acquiring the dealter before the freeze + knife combo completes.

#### Smelter alert auto-clear

When `BotShiddenPreUpdate` sees `n_dealters == 0` (the dealter team is
fully dead / in spectator), it clears `f_dmg_time`, `dmg_origin`, and
`f_shidden_unseen_until` on the smelter bot.  The alert is normally
armed from the killing-fart frame; without this sweep the surviving
smelter would lock pitch on the stale `dmg_origin` for the full 3
seconds (pitch wobbles as the bot bobs / steps) and would also stop
waypoint following / pickup yaw, because the navigation block gates
on `f_dmg_time < now`.  Visible symptom previously: the bot "freezes
facing nothing" for ~3 s after winning the round.

### PreUpdate dispatch (`bot.cpp`)

Two call sites mirror the CTF / Loot pattern:

- **Early** (in the waypoint-acquisition gate, before
  `BotHeadTowardWaypoint`): ensures `v_goal` is valid on the first frame
  after spawn so `BotFindWaypointGoal` doesn't return -1 with a 0.5s
  cooldown.
- **Late** (in the no-enemy branch, just before `BotFindEnemy`):
  refreshes the role state so the enemy filter sees the right team
  context.

`BotShiddenPreUpdate` also force-switches dealters to `weapon_fists`
the moment `n_frozen_smelters == 0`.  This covers two cases the
follow-on `BotFireWeapon` path cannot:

- Round-start frame where the engine auto-switched to the knife (lower
  priority number) when `GiveNamedItem` ran.
- Any stale state lingering between rounds — `BotShiddenThink` doesn't
  run while `pBotEnemy` is set, but PreUpdate runs every tick.

### Think dispatch (`bot.cpp`)

```cpp
else if (is_gameplay == GAME_SHIDDEN && BotShiddenThink(pBot))
{
    // BotShiddenThink sets v_goal + f_move_speed for dealter
    // HUNTER/FINISHER and smelter FLOCK/DEFENDER/SCOUT roles.
}
```

Sits in the else-if chain alongside the other mode-specific Think
functions.

### Item-pickup gate (`bot.cpp::BotFindItem`)

Shidden dealters (`fuser4 == SHIDDEN_DEALTER`) early-return from
`BotFindItem` with `pBotPickupItem = NULL` and `item_waypoint = -1`.
The gamerules clear the dealter inventory on each spawn, so any world
weapon scan would route them off-objective for an item they can't keep
and would override `BotShiddenThink`'s hunt goal.  Smelters fall
through and pick up normally.

### Cloaked-enemy retention + acquisition (`bot_combat.cpp::BotFindEnemy`)

Dealters are `kRenderTransAlpha` (`MakeInvisible`), but the bot's
acquisition loops historically only checked `kRenderTransTexture`.
Three changes were made to handle them:

- Both acquisition loops (monsters + players) now accept
  `kRenderTransTexture || kRenderTransAlpha` when applying the
  `renderamt_threshold[skill]` floor.
- Retention (drop the current enemy when their alpha goes too low)
  uses hysteresis: distance threshold dropped from 192 to 80, alpha
  threshold halved to `renderamt_threshold[skill] / 2`.  Without the
  gap a cloaked enemy whose `renderamt` jitters around the acquisition
  floor caused per-frame acquire/drop flicker, snapping the bot's
  `idealpitch` to the enemy on one tick and back to 0 the next — a
  visible 15-25° pitch oscillation, easiest to see on the dealter
  whose alpha is scaled by next-attack time in `player.cpp::PostThink`.

### Dead-player audio gates (`bot.cpp` + `util.cpp`)

Killed players keep their edicts (and `FL_CLIENT`) for a moment with
leftover velocity from death knockback and `pev->button` possibly
holding `IN_ATTACK` from the death frame.  Without filtering, every
nearby bot would refresh `dmg_origin` on the corpse and oscillate its
pitch toward the body for ~3 s:

- `bot.cpp::BotListenForFakeSound` skips edicts whose `IsAlive()` is
  false.
- `bot.cpp::BotListenForSound` skips `FL_CLIENT` edicts that aren't
  alive.
- `util.cpp::UpdateSounds` returns FALSE for non-alive players before
  the velocity threshold runs.

---

## Key constants

| Constant                       | Value         | Meaning |
|--------------------------------|---------------|---------|
| `SHIDDEN_SMELTER`              | `0`           | `fuser4` value for smelter team. |
| `SHIDDEN_DEALTER`              | `1`           | `fuser4` value for dealter team. |
| `SHIDDEN_FREEZE_TICKS`         | `50`          | Freeze counter ticks; duration = ticks * 0.1 s = 5 s. |
| `SHIDDEN_FREEZE_SHELL_MAX`     | `25`          | Glow-shell thickness cap on `pev->renderamt`. |
| Fart damage                    | `800`         | Smelters survive via the freeze shield; non-smelters take the raw hit. |
| Fart radius                    | `256u`        | Gameplay-side `RadiusDamage` range. |
| Fart cooldown (weapon)         | `0.75s`       | `m_flNextPrimaryAttack` on the active weapon. |
| `SHID_ROLE_EVAL_PERIOD`        | `0.5s`        | Role re-evaluation cadence. |
| `SHID_FART_RANGE`              | `240u`        | Bot-side fart trigger distance. |
| `SHID_FART_COOLDOWN`           | `0.85s`       | Local press cooldown (> weapon 0.75s to avoid waste). |
| `SHID_KNIFE_RANGE`             | `64u`         | Bot-side knife trigger distance. |
| `SHID_FINISHER_LOCK_TIME`      | `2.5s`        | FINISHER target lock duration. |
| `SHID_FLOCK_RADIUS`            | `384u`        | Smelter pack arrive-distance. |
| `SHID_DEFEND_SCAN_RADIUS`      | `640u`        | DEFENDER dealter-scan radius around frozen teammate. |
| `SHID_DEALTER_SPOT_RANGE`      | `768u`        | Smelter opportunistic dealter-spot range. |
| `SHID_SWITCH_COOLDOWN`         | `0.25s`       | Throttle on `UTIL_SelectItem` to avoid spam. |
| `SHID_UNSEEN_BOOST_TIME`       | `2.0s`        | Defined but not currently referenced; `3.0s` is used inline in `bot_client.cpp`. |

### HUD bar denominators (gameplay-side)

| Field              | Where set                                    | Used by |
|--------------------|----------------------------------------------|---------|
| `m_iSmeltersStart` | Round-start team assignment loop in `Think`. | Smelter HUD bar: `smelters_left / m_iSmeltersStart`. |
| `m_iDealtersStart` | Same loop.                                   | Dealter HUD bar: `dealters_left / m_iDealtersStart`. |
| (total of both)    | Same loop.                                   | Spectator bar: `(smelters_left + dealters_left) / total`. |

Denominators were previously `m_iPlayersInGame`, which capped the
starting bar near ~66 % when the opposing team was included in the
total.  Per-team start counts make each bar read 100 % at round start
and deplete to 0 % cleanly as that team is eliminated.

The spectator bar reflects total survivors (sum of both teams) as a
fraction of the round-start total, so it reads 100 % at the start and
0 % on a mutual wipe.

---

## Detection flags

- `IsShidden()` (`gamerules.cpp:2094`) returns `g_GameMode == GAME_SHIDDEN`.
  Used by `weapons.cpp` to gate the fart code path.
- `MutatorEnabled(MUTATOR_DEALTER)` is a parallel path — the fart attack
  also fires when this mutator is active in any other gameplay mode, so
  the `IsShidden() && ... && m_iId != WEAPON_KNIFE` clause is the
  Shidden-specific gate.
- `gHUD.m_GameMode == GAME_SHIDDEN` (`cl_dll/hud.cpp:1146`) drives the
  client-side scoreboard / spectator-panel / util colour overrides.

---

## Files touched

| File | Section |
|------|---------|
| `src/dlls/shidden_gamerules.cpp` | Round + win-state (`DetermineWinner` `highest = 0`, per-team start counters, HUD bar denominator switch, `PlayerKilled` survivor-count rewrite), `FPlayerCanTakeDamage` (freeze + `iuser4` mirror, `SHIDDEN_FREEZE_TICKS` / `SHIDDEN_FREEZE_SHELL_MAX` split, `DMG_FART` trigger), `FPlayerTookDamage` (null-victim guard, knife one-shot + `iuser4` clear), `PlayerSpawn` (3 branches: late-joiner reset, dealter, smelter — each sets `haste` / `gravity` / `fuser4` / `fuser3` / `iuser4`). |
| `src/dlls/shidden_gamerules.h`   | `m_iSmeltersStart`, `m_iDealtersStart` members. |
| `src/dlls/player.cpp`            | `Killed` (`iuser4 = 0`), `PostThink` thaw block (`rendercolor = g_vecZero`, `iuser4` mirror), `PostThink` stuck-frozen recovery branch, `Spawn` (`iuser4 = -1` reset), `ImpulseCommands` frozen impulse 205-216 gate, `IceExplode` `renderamt` cap. |
| `src/dlls/weapons.cpp`           | Fart attack body (`PrimaryAttack` / `SecondaryAttack` Shidden + dealter-mutator branch). |
| `grave-bot-src/dlls/bot_shidden.cpp` | New TU — entity cache, PreUpdate (with dealter weapon-force + smelter alert-clear), Think, role dispatch. |
| `grave-bot-src/dlls/bot.h`       | `SHIDDEN_ROLE_*` enum + 6 `i_shidden_*` / `f_shidden_*` / `p_shidden_target` fields. |
| `grave-bot-src/dlls/bot.cpp`     | `BotSpawnInit` clear block (6 fields), two `BotShiddenPreUpdate` dispatch calls, `BotShiddenThink` else-if branch, `BotFindItem` dealter early-return, dealter `IN_ATTACK2` / `IN_RELOAD` / impulse 205-216 guard before `pfnRunPlayerMove`, `BotListenForFakeSound` / `BotListenForSound` dead-player skip. |
| `grave-bot-src/dlls/bot_combat.cpp` | `BotFindEnemy` cloaked-enemy retention hysteresis + acquisition `kRenderTransAlpha` coverage, `BotFireWeapon` Shidden dealter weapon-selection + fire branch. |
| `grave-bot-src/dlls/bot_func.h`  | `BotShiddenPreUpdate` / `BotShiddenThink` forward declarations. |
| `grave-bot-src/dlls/bot_client.cpp` | `BotClient_Valve_Damage` smelter alert-window extension (gated on `iuser4 == 0`) + `f_shidden_unseen_until` arming. |
| `grave-bot-src/dlls/util.cpp`    | `UpdateSounds` dead-player skip. |
| `grave-bot-src/dlls/grave_bot.vcxproj`, `makefile_linux`, `makefile_mm` | Build wiring for the new TU. |
