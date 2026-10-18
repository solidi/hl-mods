# Copilot Instructions for hl-mods Reviews

These instructions guide Copilot when reviewing code and repository artifacts in this project.

## Review Goal
- Focus on correctness, regressions, and maintainability for Half-Life mod code and packaging assets.
- Prioritize actionable findings over broad summaries.

## Review Priorities
1. Gameplay and engine safety
- Flag logic that can break gameplay flow, entity lifecycle, spawning, damage, scoring, inventory, or round state.
- Watch for unsafe pointer use, null handling gaps, out-of-bounds access, and risky assumptions in C/C++ code.

2. Network and compatibility behavior
- Check client/server consistency (`cl_dll` vs `dlls`) and protocol-sensitive changes.
- Call out changes that may break demo playback, map scripts, bot behavior, or existing configs.
- Exception: renumbering `MUTATOR_*` IDs to keep them alphabetical is intended (see Module Checklists → Mutators).

3. Build and release integrity
- Verify script and manifest changes in `workspace/` produce expected outputs.
- Confirm artifacts (maps, models, sprites, sound, WADs, redist files) are placed and referenced correctly.

4. Asset and content consistency
- Validate naming, paths, casing, and references across map/model/sound/sprite assets.
- Flag missing or stale files in release/redist packaging.

5. Test and validation expectations
- Recommend practical validation steps for each risky change:
  - compile/build steps,
  - smoke test scenarios in-game,
  - packaging verification.

## Review Output Format
- Start with findings, ordered by severity: Critical, High, Medium, Low.
- For each finding, include:
  - what is wrong,
  - why it matters,
  - affected file(s),
  - a concrete fix suggestion.
- If no major issues are found, explicitly state that and list residual risks or untested paths.

## Scope Guidance
- Review both source and non-source artifacts when present in a change:
  - code under `workspace/src/` (Cold Ice Remastered submodule) and other top-level mod roots (e.g. `cir/`, `hla/`) when present,
  - scripts/manifests under `workspace/`,
  - distributable assets under `redist/`, `maps/`, `models/`, `sound/`, `sprites/`, and related folders.
- Do not request large refactors unless they are required to fix correctness or stability risks.

## Tone and Behavior
- Be concise, specific, and technical.
- Prefer concrete examples over generic advice.
- Separate confirmed issues from assumptions or open questions.

## Module Checklists

### Mutators (full and instant)
- Mutator IDs are renumbered on purpose. `MUTATOR_*` IDs follow alphabetical order, so a new mutator is inserted at its alphabetical place and every later ID shifts by one. Do not flag the shift or ask to restore old values and append the new mutator at the end. Numeric IDs (`sv_addmutator <number>`, `gmsgAddMutator`, vote numbers, the `startspot` mirror, grave_bot) only have to agree within one release: client, server and bot ship together, and configs should use mutator names.
- Instead, check that every ID list moved in lockstep: `workspace/src/common/const.h`, `workspace/grave-bot-src/common/const.h`, `g_szMutators[]` (`dlls/gamerules.cpp`), `sMutators[]` (`cl_dll/vgui_TeamFortressViewport.cpp`), the renumbered values in `workspace/redist/settings.scr`, `MAX_MUTATORS` / `MAX_MUTATORS_CL`, plus `redist/server_commands.txt`, `redist/readme.txt`, the `sprites/hud.txt` alias and declaration count, and the catalogue in `workspace/ai/mutator_system.md` §8.
- Every new mutator needs an explicit review of every game mode's filter, recorded in the mutator's section of `workspace/ai/mutator_system.md` as a "Mode filters" line (procedure: §9 step 6; current matrix: §3.4). Flag a new mutator that ships without it, even if the answer is "allowed everywhere".
- Full mutators: review `CHalfLifeMultiplay::MutatorAllowed` (base, including the Snowball block), `CHalfLifeRules::MutatorAllowed` (single player) and every mode override in `workspace/src/dlls/*_gamerules.cpp` (Busters, Chilldemic, CtC, CtF, Gun Game, Instagib, KtS, Loot, Prop Hunt, Shidden). Modes without an override (FFA, Teamplay, Arena, LMS, Cold Skull, Cold Spot, Horde, Jesus vs Santa, Snowball) inherit the base and still need a look.
- Blocks use `if (strstr(mutator, g_szMutators[MUTATOR_X - 1]) || atoi(mutator) == MUTATOR_X) return FALSE;` before chaining to the base. `strstr` also blocks any longer name containing the blocked one, so check name overlaps.
- Instant mutators have no `MutatorAllowed` path: mode restrictions must be gates inside the instant (proxy filters such as `MutatorAllowed("randomweapon")`, `CanHaveNamedItem`, `CanHavePlayerAmmo`, `AllowRuneSpawn`, `IsMultiplayer()` re-roll).
- Older mutators predate this rule; a regression pass of their filters is pending, so do not assume existing filters are complete.

## Future Customization
As review patterns emerge, tighten this file by adding:
- module-specific checklists,
- known fragile systems,
- required test maps/scenarios,
- branch or release-specific gates.
