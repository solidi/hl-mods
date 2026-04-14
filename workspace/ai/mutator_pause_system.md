# Mutator Pause/Restore System for Round-Based Game Modes

## Overview
This system prevents mutators from changing, expiring, or triggering during the spectator/countdown phase between rounds in round-based game modes. When a round ends, all active mutators are saved and removed. When the next round begins, mutators are restored with adjusted timers.

## Implementation Details

### Modified Files

#### 1. gamerules.h
**Added member variables (private):**
- `m_bMutatorsPaused` - Tracks whether mutators are currently paused
- `m_SavedMutators` - Linked list storing saved mutator state
- `m_flSavedChaosMutatorTime` - Saved chaos mode timer remaining time
- `m_flPausedTimeDelta` - Timestamp when mutators were paused (for time delta calculation)

**Added public methods:**
- `PauseMutators()` - Saves and clears all active mutators
- `RestoreMutators()` - Restores saved mutators with adjusted timers

#### 2. gamerules.cpp
**PauseMutators() implementation:**
- Guards against double-pause (early return if already paused)
- Deep copies the entire mutator linked list (ID + TTL)
- Saves chaos mode timer remaining time as `m_flChaosMutatorTime - gpGlobals->time`
- Records pause timestamp in `m_flPausedTimeDelta`
- Forces all active mutators to expire (sets TTL to `gpGlobals->time - 1.0f`)
- Sends `gmsgChaos` with `WRITE_BYTE(0)` to stop client chaos timer display
- Sends `gmsgAddMutator` with `WRITE_BYTE(254)` to clear all client-side mutator HUD
- Logs pause event to console

**RestoreMutators() implementation:**
- Guards against unpaired restore (early return if not paused)
- Calculates pause duration (`gpGlobals->time - m_flPausedTimeDelta`)
- Deletes all expired mutators from `m_Mutators` (all should be expired from PauseMutators)
- Rebuilds `m_Mutators` from saved list with TTL extended by pause duration
- Handles permanent mutators (TTL = -1) correctly — kept permanent
- Handles expired edge cases — resets TTL to `gpGlobals->time + mutatorTime`
- Sends `gmsgAddMutator` per restored mutator with time remaining (permanent = 0, timed = clamped ≥ 1)
- Restores chaos mode timer with saved remaining time via `gmsgChaos`
- Cleans up saved mutator list and resets pause state variables
- Sets `m_flDetectedMutatorChange = gpGlobals->time + 0.5` to trigger `EnvMutators()` reapplication
- Logs each restored mutator and chaos timer to console

**MutatorsThink() modification:**
- Early return at function entry if `m_bMutatorsPaused` is TRUE (prevents all mutator processing)
- Redundant `!m_bMutatorsPaused` guards on chaos mode and instant mutator sections (defense-in-depth; unreachable due to early return)

#### 3. multiplay_gamerules.cpp
**GoToIntermission() modification:**
- Calls `PauseMutators()` at the start of `GoToIntermission()` before sending `SVC_INTERMISSION`
- Ensures mutators pause when the game ends/map changes

**ResetGameMode():**
- Does NOT call `PauseMutators()` — only resets round state variables (`g_GameInProgress`, countdown, timers)
- Each round-based game mode handles pausing directly in its own lifecycle code

#### 4. Round-Based Game Modes
**Modified modes:** Arena, LMS, Chilldemic, Horde, JVS, Loot, PropHunt, Shidden

Each mode follows a consistent pattern with `PauseMutators()` / `RestoreMutators()` calls at multiple lifecycle points:

| Lifecycle Point | Call | Purpose |
|----------------|------|---------|
| Constructor | `PauseMutators()` | Start paused during warmup/waiting phase |
| Round ended (players eliminated) | `PauseMutators()` | Freeze mutators during intermission |
| Round winner detected | `PauseMutators()` | Freeze for post-round downtime |
| Round begins (`g_GameInProgress = TRUE`) | `RestoreMutators()` | Re-activate saved mutators when play starts |

## Behavior

### During Round Intermission (g_GameInProgress = FALSE)
- ✅ Active mutators are saved with remaining time
- ✅ All mutator effects are removed from gameplay
- ✅ Client HUD displays cleared
- ✅ Chaos mode timer saved and stopped
- ✅ No new mutators can be added
- ✅ No instant mutators can trigger
- ✅ Existing mutator timers frozen

### When Round Begins (g_GameInProgress = TRUE)
- ✅ Saved mutators restored to active list
- ✅ Mutator TTLs extended by pause duration (time compensation)
- ✅ Permanent mutators remain permanent
- ✅ Chaos mode timer resumed with remaining time
- ✅ Client displays updated with restored mutators
- ✅ Mutator effects reapplied to gameplay

### Time Compensation
The system calculates how long the pause lasted and extends all mutator TTLs by that amount, ensuring mutators don't lose time during spectator phases.

**Example:**
```
Mutator "Low Gravity" has 30 seconds remaining → Round ends
↓ (15 seconds of spectator/countdown)
Round begins → "Low Gravity" restored with 30 seconds remaining
```

## Console Logging
The system provides detailed console output:
```
[Mutators] Pausing mutators for round intermission
[Mutators] Restoring mutators after round intermission
[Mutators] Restored mutator 'Low Gravity' with 28 seconds remaining
[Mutators] Restored chaos timer with 45.00 seconds remaining
```

## Network Messages
- **gmsgAddMutator with WRITE_BYTE(254)** — Special "clear all" signal that tells clients to remove all mutator HUD entries during pause
- **gmsgAddMutator (standard)** — Restores individual mutators with time remaining on resume; permanent mutators sent with `WRITE_SHORT(0)`, timed mutators with remaining seconds (≥ 1)
- **gmsgChaos with WRITE_BYTE(0)** — Stops client-side chaos mode timer display during pause
- **gmsgChaos (standard)** — Restores chaos timer display with remaining seconds on resume

## Game Modes Supported
- ✅ Arena (1v1)
- ✅ Last Man Standing (Battle Royale)
- ✅ Chilldemic (Infection)
- ✅ Horde (PvE waves)
- ✅ Juggernaut vs Soldiers
- ✅ Loot (Crate Hunt)
- ✅ Prop Hunt
- ✅ Shidden (Hidden-style)

## Game Modes Not Affected
Continuous play modes without round intermissions are unaffected:
- Deathmatch
- Team Deathmatch
- Capture the Flag
- Cold Skulls
- Freeze Tag
- Gun Game
- Instagib
- One in the Chamber
- Sticks & Stones

## Technical Notes
- Uses deep copy to preserve mutator state (prevents pointer issues when originals are force-expired)
- Handles permanent mutators (TTL = -1) correctly — preserved through pause/restore cycle
- PauseMutators() and RestoreMutators() are idempotent — guarded against double-pause and unpaired restore
- Runs on server tick (single-threaded game loop)
- Memory cleaned up properly — saved list deleted after restore, expired originals deleted before rebuild
- Works with chaos mode and instant mutators simultaneously
- Compatible with manual mutator additions during rounds
- Deeper `!m_bMutatorsPaused` guards in MutatorsThink chaos/instant sections are redundant (unreachable due to early return) but kept as defense-in-depth
- `GoToIntermission()` in multiplay_gamerules.cpp provides a catch-all pause for map changes/game end
- Each round-based mode manages its own pause lifecycle (constructor, round end, winner, round begin) rather than relying on a centralized ResetGameMode() call
- `m_flDetectedMutatorChange` is set 0.5s after restore to trigger `EnvMutators()` which reapplies world effects (gravity, lighting, etc.)
