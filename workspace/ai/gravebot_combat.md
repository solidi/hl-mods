# Grave Bot Combat System — Reference

Source of truth for how the Grave bot fights. Covers target selection, reaction time, aim error, firing, melee, and the `bot_aim_difficulty` softening layer added in 2026-04. Use this as the starting point for future combat tuning or behavior work.

Skill index is 0-based throughout (`bot_skill = botskill_cvar - 1`). **Skill 0 is HARDEST, skill 4 is EASIEST.** Default is skill 2 (`default_bot_skill = 2`).

All code paths live under [workspace/grave-bot-src/dlls/](workspace/grave-bot-src/dlls/).

---

## 1. Per-Skill Tuning Arrays

All arrays are indexed by `pBot->bot_skill` and defined in [bot_combat.cpp](workspace/grave-bot-src/dlls/bot_combat.cpp) or [bot.cpp](workspace/grave-bot-src/dlls/bot.cpp).

| Array | File | Skill 0 | 1 | 2 | 3 | 4 | Purpose |
|---|---|---|---|---|---|---|---|
| `yaw_speed` | bot.cpp | 786 | 640 | 384 | 256 | 192 | Horizontal turn rate (deg/s) |
| `pitch_speed` | bot.cpp | 832 | 786 | 640 | 384 | 256 | Vertical turn rate (deg/s) |
| `aim_tracking_x_scale` | bot_combat.cpp | 2.0 | 3.0 | 4.5 | 6.0 | 7.5 | Step aim error magnitude (deg) |
| `aim_tracking_y_scale` | bot_combat.cpp | 2.0 | 3.0 | 4.5 | 6.0 | 7.5 | Same, vertical |
| `aim_jitter_scale` | bot_combat.cpp | 0.15 | 0.25 | 0.35 | 0.50 | 0.60 | Per-frame continuous jitter (deg) |
| `react_time_min` | bot_combat.cpp | 0.51 | 0.55 | 0.58 | 0.60 | 0.65 | Reaction delay min (s, before multiplier) |
| `react_time_max` | bot_combat.cpp | 0.51 | 0.58 | 0.60 | 0.75 | 0.70 | Reaction delay max (s) |
| `renderamt_threshold` | bot_combat.cpp | 16 | 32 | 48 | 64 | 80 | Transparency cutoff (lower = better vision) |
| `sound_sense` | bot.cpp | 768 | 512 | 384 | 256 | 128 | Sound-hearing range |
| `pause_frequency` | bot.cpp | 4 | 7 | 10 | 15 | 20 | Out of 1000 ticks |
| `pause_time[skill][0/1]` | bot.cpp | {0.2,0.5} | {0.5,1.0} | {0.7,1.3} | {1.0,1.7} | {1.2,2.0} | Random pause range (s) |
| `speed_mod` | bot.cpp | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | Unused (all 1.0) |

Per-weapon firing delays live in `bot_fire_delay_t` structs; see `bot_weapons_hldm.cpp` for VALVE/Crabbed and `bot_weapons_si.cpp` for Science & Industry. Each weapon has `primary_base_delay`, `primary_min_delay[5]`, `primary_max_delay[5]` plus secondary-fire equivalents.

---

## 2. Enemy Detection (`BotFindEnemy`, bot_combat.cpp ~L1701)

Runs every think frame. Two passes: monsters first, then players.

- **Initial search sphere:** 2500 units via `UTIL_FindEntityInSphere`.
- **Remembered enemy narrows sphere** to current distance so the bot re-locks on the remembered target faster.
- **Remembered window:** 2 seconds normally, 5 seconds in Arena mode. If LOS is lost but the bot is `b_engaging_enemy`, the enemy is kept longer — EXCEPT in CTF / Arena / Cold Spot modes where the objective always wins.
- **FOV + visibility gate:** `FInViewCone()` + `FVisible()` (engine functions). No custom corner detection; no smoke handling; engine traces only.
- **Transparency:** enemy skipped if `rendermode == kRenderTransTexture && renderamt < renderamt_threshold[skill]`. Hard-skip at `renderamt < 60` (regardless of skill) or `EF_NODRAW`.
- **Teamplay:** teammates are always skipped (with S&I scientist exception when bot holds mindray).
- **Live grenades** within 192 units and >2s from detonation pre-empt player targeting (`VALVE_DLL` only).

**Gamemode overrides at the top of the function:**
- `GAME_PROPHUNT` while paused → no enemy
- `GAME_KTS` while bot holds ball → no enemy
- `GAME_COLDSKULL` with a skull <300u and health >25 → no enemy
- `GAME_CTC` rules (chumtoad holder behavior, health gating)
- `GAME_KTS` non-holder → enemy must be the current ball dribbler (`kts_snowball->v.euser1`)
- `GAME_COLDSPOT` → in-zone/near-zone intruders get a 1500/500 distance bonus for target selection

---

## 3. Reaction Time

### First sight (new enemy)
```c
delay = RANDOM_FLOAT(react_time_min[skill] * bot_reaction_time,
                     react_time_max[skill] * bot_reaction_time)
        * log10(distance) * 0.8;
```
- `bot_reaction_time` is a CVAR, default **2.0**. Setting it to 0 disables reaction delay entirely.
- Distance multiplier is clamped to min 1.0 (no advantage when enemy is at point-blank).
- Written to `pBot->f_reaction_target_time`; `BotShootAtEnemy` gates firing on `gpGlobals->time >= f_reaction_target_time`.
- Only applied when `pNewEnemy != pBot->pBotEnemy && !pRemember` — i.e. truly new target, not a re-lock.

### Re-acquire (same enemy, LOS break ≥ 0.5s)
Added 2026-04 to fix "corner-snap" where a bot that briefly lost LOS would laser-beam you instantly on reappearance.
```c
delay = RANDOM_FLOAT(min * 2.0 * 0.6, max * 2.0 * 0.6) * bot_aim_difficulty
```
- 60% of first-sight magnitude (noticeable hesitation, not broken).
- **Skipped in `GAME_ARENA`** so 1v1 duels stay snappy.
- Also snaps `f_aim_x/y_angle_delta` to ±per-skill max so the first shot after re-appearing is off-target, and resets `i_burst_count`.
- Tracked via new field `pBot->f_last_enemy_los_time`, updated every frame the enemy is in view.

Console tuning:
- `bot_reaction_time <value>` — scale all reaction delays.
- `bot_reaction_time_min <skill 1-5> <value>` — edit one skill's min.
- `bot_reaction_time_max <skill 1-5> <value>` — edit one skill's max.

---

## 4. Aim Model (`BotShootAtEnemy`, bot_combat.cpp ~L2730)

Pipeline:
1. **Target point** — `BotBodyTarget` picks head (skill 0–1) or torso (skill 2+). Mindray always torso vs scientists.
2. **Lead** — `BotGetLead` adds `velocity * distance / projectile_speed` for projectile weapons; hitscan skips lead.
3. **Step error** — every `RANDOM_FLOAT(0.25, 1.25)` seconds, `f_aim_x_angle_delta` / `f_aim_y_angle_delta` are regenerated from `±aim_tracking_*_scale[skill] * bot_aim_difficulty`.
4. **Step error application** — applied every frame (all skill tiers, including 0). Scaled by `max(enemy_velocity * 0.01, 1.0)` so fast strafers are harder to track.
5. **Per-frame jitter** — `±aim_jitter_scale[skill] * bot_aim_difficulty` added each frame on top of step error, so aim is never pixel-perfect between refreshes.
6. **Ideal yaw/pitch** written; `BotChangeYaw` / `BotChangePitch` rotate the bot toward it at `yaw_speed`/`pitch_speed` per frame.

The pre-2026-04 model had (a) skill-0 bots bypassing error entirely, (b) a 0.5–3.0s refresh window causing aim to "lock" for seconds, and (c) no per-frame jitter. All three were flagged as the cause of the "exacting" feel.

---

## 5. Engagement Gate (`BotShouldEngageEnemy`, bot_combat.cpp ~L2135)

Decides whether the bot fights or flees after an enemy has been found.

- Must be a player target (monsters skip the gate).
- Must have usable ammo — returns false if both primary and secondary are `AMMO_CRITICAL`.
- **S&I exception:** if carrying a sci/resource, never engage (deliver first).
- **CTC exception:** if holding chumtoad with `health > 25`, never engage.
- **Aggressiveness roll** (in `BotShootAtEnemy`, not `BotShouldEngageEnemy` itself): `RANDOM_LONG(1,100) < i_engage_aggressiveness`, checked every 0.5s. `i_engage_aggressiveness` is seeded in `BotCreate` as `RANDOM_LONG(50, 100)` — per-bot personality.
- **Arena mode always engages** (skip aggressiveness roll).
- **Close-range commit**: distance < 512 AND in FOV AND visible → `f_ignore_wpt_time = time + 0.1` so the bot abandons waypoints and pursues the fight.

This layer is deliberately **not tuned** by the softening changes — we want bots to keep fighting, we just want them to hit less.

---

## 6. Firing (`BotFireWeapon`, bot_combat.cpp ~L2232)

Picks a weapon from the `weapon_select` table, runs ammo/range/distance checks, sets `IN_ATTACK` / `IN_ATTACK2`.

Weapon flags that matter:
- `primary_fire_hold` — trigger stays pressed (MP5, MAC-10, pulse rifle, etc.). Per-shot delay = 0.
- `primary_fire_charge` — hold-to-charge weapons (gauss, charged pulse secondary, etc.). Uses `f_primary_charging` timer.
- Normal fire — `f_shoot_time = time + base_delay + RANDOM_FLOAT(min_delay[skill], max_delay[skill])`.
- Weapon switch penalty: +0.5s before first shot.

### Burst Discipline (added 2026-04)
For automatic weapons (`primary_fire_hold && !primary_fire_charge`) at distance > 350 units:
- After `RANDOM_LONG(3, 6)` shots, enter a pause of `RANDOM_FLOAT(0.25, 0.60) * bot_aim_difficulty * (1 + skill*0.1)` seconds.
- During the pause, `BotFireWeapon` returns FALSE without pressing `IN_ATTACK`, and `f_shoot_time` is held at the pause deadline.
- State: `pBot->i_burst_count` and `pBot->f_burst_pause_until` (new fields in `bot_t`).
- Melee range (<=350u) still full auto; shotguns / RPG / charging weapons unaffected.
- Re-acquire resets `i_burst_count = 0` so the first post-peek contact is a fresh short burst.
- `bot_aim_difficulty` is clamped to `[0.5, 2.0]` for pause scaling so pauses never vanish at 0.0 — the *frequency* of pauses is fixed (every 3-6 shots) but duration scales.

### Melee Impulses (close-range showpieces)
Within the same `use_primary` branch, the bot sets `pEdict->v.impulse` to the mod's martial-arts commands:
- ≤80u: 206/207 (kick or punch)
- ≤120u: 210–212 (flip)
- ≤250u: 208 or 214 (slide)
- ≤450u: 209 (grenade toss)
- >450u: 10% chance of 215 (force grab) / 216 (drop explosive)

Gated by `sv_botsmelee.value > 0 && is_gameplay != GAME_GUNGAME`.

**Difficulty-scaled frequency (added 2026-04):** the entire impulse block is wrapped in a probability roll:
```c
melee_chance = clamp(1.0 - 0.45 * bot_aim_difficulty, 0.10, 1.0)
```
| `bot_aim_difficulty` | Melee chance |
|---|---|
| 0.0 | 100% (original behavior) |
| 1.0 | 55% |
| 2.0 | 10% (floor) |

Weapon still fires on fail — only the flashy impulse is skipped. This was added because softened aim made bots easier at range but close-quarters CQC was still murderous.

---

## 7. `bot_aim_difficulty` — Master Softening Scalar

CVAR-style global (not a real CVAR; a `float` tuned via console command in [dll.cpp](workspace/grave-bot-src/dlls/dll.cpp)). Default **1.0**, range **0.0–2.0**, clamped on command.

Console command:
```
bot_aim_difficulty <0.0 - 2.0>
```
- 0.0 → hardest (step error, jitter, re-acquire delay, melee gate all disabled or minimized)
- 1.0 → tuned human-feel baseline (default)
- 2.0 → very sloppy bots

Points where it multiplies:
| Use | File / function | Effect |
|---|---|---|
| Step aim error magnitude | `BotShootAtEnemy` L2762 | `xscale * difficulty`, `yscale * difficulty` |
| Per-frame aim jitter | `BotShootAtEnemy` L2790ish | `jitter * difficulty` |
| Re-acquire reaction delay | `BotFindEnemy` | `* difficulty` (delay inflation) |
| Re-acquire aim snap | `BotFindEnemy` | `xscale * difficulty`, `yscale * difficulty` for the penalty |
| Burst pause duration | `BotFireWeapon` | clamped `[0.5, 2.0]` to avoid zero-length pauses |
| Melee impulse chance | `BotFireWeapon` | `1 - 0.45*difficulty`, floor 0.10 |

First-sight reaction delay (in `BotFindEnemy`) is **NOT** multiplied by `bot_aim_difficulty` — it already has `bot_reaction_time` as its scalar. They're independent knobs.

---

## 8. `bot_t` Fields Relevant to Combat

Defined in [bot.h](workspace/grave-bot-src/dlls/bot.h). Initialized in `BotSpawnInit` ([bot.cpp](workspace/grave-bot-src/dlls/bot.cpp) ~L260).

| Field | Type | Purpose |
|---|---|---|
| `pBotEnemy` | edict_t* | Current enemy |
| `b_engaging_enemy` | bool | In combat (keeps target through LOS breaks) |
| `b_last_engage` | bool | Previous frame's engagement state |
| `i_engage_aggressiveness` | int | 50–100, per-bot personality roll |
| `f_engage_enemy_check` | float | 0.5s interval for aggressiveness roll |
| `f_bot_see_enemy_time` | float | Last time enemy was visible (also used for reload) |
| `f_bot_find_enemy_time` | float | Last time a new enemy was acquired |
| `f_last_enemy_los_time` | float | **NEW 2026-04** — last frame bot had LOS on pBotEnemy (re-acquire detection) |
| `f_reaction_target_time` | float | Bot cannot shoot until this time |
| `f_aim_tracking_time` | float | Next step-error refresh |
| `f_aim_x_angle_delta` | float | Current pitch step error |
| `f_aim_y_angle_delta` | float | Current yaw step error |
| `f_shoot_time` | float | Next time `IN_ATTACK` may be set |
| `f_switch_weapon_time` | float | Weapon-swap cooldown |
| `f_primary_charging` | float | Charge-weapon release time |
| `f_secondary_charging` | float | Same for alt-fire |
| `charging_weapon_id` | int | Which weapon is mid-charge |
| `i_burst_count` | int | **NEW 2026-04** — shots in current auto burst |
| `f_burst_pause_until` | float | **NEW 2026-04** — time the burst pause ends |
| `f_reload_time` | float | Reload pacing |
| `b_combat_longjump` | bool | Mid-longjump evasion |
| `f_combat_longjump` | float | Last combat longjump time |
| `f_longjump_time` | float | Longjump cooldown |
| `b_strafe_direction` | bool | Combat strafe left/right |
| `f_strafe_chng_dir` | float | Next strafe flip time |
| `dmg_origin` / `f_dmg_time` | Vector/float | Last damage source (for return-fire) |

---

## 9. Gamemode Combat Overrides

Non-exhaustive list of gamemode-specific combat branches. Most live at the top of `BotFindEnemy`, `BotShouldEngageEnemy`, or inside `BotThink`.

- **GAME_ARENA** — always engages, remembered window 5s instead of 2s, re-acquire penalty skipped, enemies from CTF/Cold Spot-style objective flushes are ignored.
- **GAME_CTF** — objective (flag) always wins; see [ctf_gamerules.md](workspace/ai/ctf_gamerules.md). Enemy dropped if role is CARRIER returning to base.
- **GAME_COLDSPOT** — in-zone/near-zone targets get distance bonus for selection; HOLDER role keeps bot in zone, HUNTER role rushes to displace a scoring enemy. See [coldspot_gamerules.md](workspace/ai/coldspot_gamerules.md).
- **GAME_COLDSKULL** — skull <300u + healthy bot suppresses enemy targeting. See [coldskull_gamerules.md](workspace/ai/coldskull_gamerules.md).
- **GAME_CTC** — chumtoad holder evades instead of fighting; see [ctc_gamerules.md](workspace/ai/ctc_gamerules.md).
- **GAME_KTS** — only target the authoritative dribbler; holder never engages. See [kts_gamerules.md](workspace/ai/kts_gamerules.md).
- **GAME_PROPHUNT** — paused/hiding bots have no enemy.
- **GAME_GUNGAME** — disables the martial-arts impulse block.

---

## 10. CVARs & Console Commands Touching Combat

Registered in [dll.cpp](workspace/grave-bot-src/dlls/dll.cpp):
- `sv_bot` / `gravebot` — placeholder cvar
- `sv_defaultbots` — number of bots at map start
- `sv_botsmelee` — 0/1 toggle for martial-arts impulses

Globals exposed via `ProcessCommand`:
- `bot_reaction_time <value>` — reaction-delay scalar (default 2.0)
- `bot_reaction_time_min <skill 1-5> <value>`
- `bot_reaction_time_max <skill 1-5> <value>`
- `bot_aim_difficulty <0.0-2.0>` — **NEW 2026-04**, master softening scalar
- `botskill <1-5>` — sets `default_bot_skill` for new bots

No external config file drives combat — all tuning is through these commands or hardcoded arrays.

---

## 11. Change History

### 2026-04 — Human-feel combat softening
- Raised `aim_tracking_x/y_scale` baselines from `{1.0, 2.0, 4.0, 5.0, 6.0}` to `{2.0, 3.0, 4.5, 6.0, 7.5}`.
- Removed `bot_skill > 0` perfect-aim bypass in `BotShootAtEnemy`.
- Tightened step-error refresh from `RANDOM_FLOAT(0.5, 3.0)` to `RANDOM_FLOAT(0.25, 1.25)`.
- Added `aim_jitter_scale[5]` per-frame continuous jitter.
- Added `f_last_enemy_los_time` tracking + re-acquire reaction delay (60% of first-sight) + aim-snap penalty on corner re-peek.
- Added burst discipline for automatic weapons at range > 350u (`i_burst_count`, `f_burst_pause_until`).
- Added `bot_aim_difficulty` scalar + console command.
- Added melee-impulse probability gate scaled by `bot_aim_difficulty`.

### 2026-04 — Code-review hardening (immediate follow-up)
- Added `i_burst_last_weapon` to `bot_t`; `BotFireWeapon` resets `i_burst_count` / `f_burst_pause_until` whenever the burst-active condition flips or the current weapon id changes. Stale burst state can no longer leak across weapon switches and cause a spurious pause on the first frame of the next auto burst.
- Clarified that `i_burst_count` counts *trigger-held think-frames* for an auto at range > 350u, not individual rounds. The 3–6 threshold is a feel knob, not ballistic. Comment in [bot.h](workspace/grave-bot-src/dlls/bot.h) and an in-function block comment in `BotFireWeapon` were updated accordingly. A per-bullet counter would require hooking the engine's weapon-fire timing.
- Removed a redundant `{ ... }` scope block inside `BotFindEnemy`'s "enemy still visible" branch so the control flow no longer looks like a removed conditional.
- Hardened `bot_aim_difficulty` console parsing: swapped `atof` for `strtof` with an end-pointer check and `std::isfinite` validation. Non-numeric input, `"nan"`, and `"inf"` are now rejected with an "invalid" message instead of silently storing 0 / NaN / Inf and corrupting downstream aim math. Required `<cstdlib>` and `<cmath>` includes in [dll.cpp](workspace/grave-bot-src/dlls/dll.cpp).
- Captured `pPrevEnemy = pBot->pBotEnemy` at the very top of `BotFindEnemy` (before any LOS-loss nulling) and keyed the re-acquire penalty off `pNewEnemy == pPrevEnemy` instead of `pBot->pBotEnemy`. The common "enemy nulled on LOS loss → re-discovered via remember/search" path now actually fires the penalty — which is the scenario the feature was designed for.

---

## 12. Lessons Learned (for future combat work)

Mistakes / gotchas caught during the softening pass + code review. Read these before extending the combat system to avoid repeating them.

- **`BotFindEnemy` clears `pBotEnemy` during its own execution.** Multiple branches null `pBot->pBotEnemy` on LOS loss / gamemode rules before the new-enemy search runs. Any logic that wants to compare "last frame's enemy" to the newly-selected one MUST capture `pBot->pBotEnemy` into a local (`pPrevEnemy`) at function entry. Don't read it back near the bottom of the function — it may already be NULL.
- **`pRemember` is not the same as "previous enemy".** It is only set in two specific branches (enemy still visible, or LOS lost but within the remember window). In the LOS-lost + `b_engaging_enemy` path, `pRemember` stays NULL while `pBotEnemy` is preserved. Don't use `pRemember` as a proxy for "had an enemy last frame".
- **`atof` silently accepts garbage.** Returns 0.0 for non-numeric strings and happily parses `"nan"` / `"inf"` into IEEE non-finite floats that bypass `min <= x <= max` range checks. Any new CVAR-style console command that feeds a float into aim / angle / velocity math MUST use `strtof`/`strtod` with an end-pointer check plus `std::isfinite`.
- **Per-frame accumulators leak across state transitions.** Counters like `i_burst_count` only reset inside the branch that uses them. If the bot switches weapons, changes range bracket, or re-acquires an enemy, any accumulator that informs firing decisions must be reset at the state-change boundary, not just when the counter "reaches its limit". Record the prior state (e.g. `i_burst_last_weapon`) alongside the counter so changes are detectable.
- **`f_shoot_time` is a shared refire gate.** Burst pauses, weapon-switch penalty, per-weapon min/max delays, and charge release all write to it. When adding a new source of refire delay, take the `max()` of the existing value and the new deadline (as the re-acquire penalty does with `f_reaction_target_time`) so a shorter new delay can't accidentally shorten a longer existing one.
- **Naming must match behavior or the next tuner will miscalibrate.** `i_burst_count` was originally commented as "shots fired" but was actually counting think-frame ticks. A future contributor tweaking the 3–6 threshold would have assumed rounds-per-burst and mistuned. Comment what the counter actually counts and what unit it's in.
- **Comment bare scope blocks or delete them.** The `FInViewCone && FVisible` branch had a bare `{ ... }` inside that looked like a removed `if`. Leaving cosmetic brace nesting behind makes reviewers think they missed a condition. Either remove it or keep the original conditional for intent.
- **Skill 0 = hardest.** All per-skill arrays are indexed with `pBot->bot_skill = skill - 1`, and skill 0 is the top tier. Don't write `if (bot_skill > 0)` as a "skip for low-skill bots" gate — it's actually a "skip for the HARDEST tier". This was the bug that gave skill-0 bots perfect aim for years.
- **Gamemode branches must be considered for every combat tweak.** Arena / CTF / Cold Spot / CTC / KTS / Cold Skulls / Prop Hunt / Gun Game all have their own short-circuits at the top of `BotFindEnemy`, `BotShootAtEnemy`, or `BotFireWeapon`. Any softening / hardening change must be explicitly evaluated against these — e.g. the re-acquire penalty is skipped in Arena, and the melee gate is already gated by `is_gameplay != GAME_GUNGAME`.
- **Build is x86 Release via MSBuild, not CMake.** `grave_bot.sln` builds with `MSBuild ... -p:Configuration=Release -p:Platform=x86`; the output DLL is auto-copied to `workspace/libs/dlls/grave_bot.dll`. Expect ~340 pre-existing C4996 (unsafe-CRT) and C4477 (format-string) warnings in `dll.cpp`; filter for new warnings only when validating changes. Intellisense reports `GAME_*` / `MUTATOR_*` identifiers as undefined in some files — they are pre-existing include-path quirks, the real compiler resolves them.
- **Metamod + non-metamod both live in the same source.** Changes that touch CVARs, command handlers, or globals need to compile under both `#ifdef METAMOD_BUILD` and the non-metamod branch. For the `bot_aim_difficulty` scalar we defined it as a plain `float` global (not a `cvar_t`) which sidesteps the dual-registration dance — prefer this pattern for new internal tuning knobs.

---

## 13. Future Work Hooks

Ideas that were considered and declined in the softening pass, documented here for future work:

- **Flee-on-low-health** — currently not implemented; `BotShouldEngageEnemy` does not check `pEdict->v.health`. Would live there.
- **Turn speed scaling via `bot_aim_difficulty`** — declined because `yaw_speed`/`pitch_speed` also affect navigation and viewing behavior, not just combat.
- **Darkness perception tuning** — `renderamt_threshold` is the knob; not changed because user didn't request stealth gameplay.
- **Per-weapon `bot_aim_difficulty` multiplier** — could weight the master scalar per weapon (e.g. sniper rifles less softened than shotguns).
- **Recoil simulation** — no recoil exists in the model; could be added as cumulative aim error that grows during a sustained burst and resets during burst pause.
- **Per-bullet burst counting** — `i_burst_count` currently counts think-frames, not real rounds. If precise burst sizes become important, hook the engine's weapon-fire timing rather than the trigger-held tick.
- **Sight-through-smoke/glass** — currently just `FVisible` + `renderamt`. A particle/entity-type check could be added if smoke grenades become a thing.
- **Suppression response** — bot doesn't back off when taking fire without seeing source. `dmg_origin` / `f_dmg_time` fields exist but are only used for return-fire direction.
- **Team coordination** — no knowledge-sharing between bots; each bot's `BotFindEnemy` is independent.
