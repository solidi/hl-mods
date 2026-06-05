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
  - code under `src/`,
  - scripts/manifests under `workspace/`,
  - distributable assets under `redist/`, `maps/`, `models/`, `sound/`, `sprites/`, and related folders.
- Do not request large refactors unless they are required to fix correctness or stability risks.

## Tone and Behavior
- Be concise, specific, and technical.
- Prefer concrete examples over generic advice.
- Separate confirmed issues from assumptions or open questions.

## Future Customization
As review patterns emerge, tighten this file by adding:
- module-specific checklists,
- known fragile systems,
- required test maps/scenarios,
- branch or release-specific gates.
