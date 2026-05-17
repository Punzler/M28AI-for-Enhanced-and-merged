# Changelog — M28AI-Blackops+Shields

A fork of [maudlin27/M28AI](https://github.com/maudlin27/M28AI) v297, tuned for play with **Shields Enhanced** and **BlackOpsFAF-Merged** in FAF.

Fork-specific changes on top, vanilla baseline `M28AI v297` (upstream state 2026-05-13).

---

## [Unreleased] — 2026-05-17

### Fixed
- **GE templates now form correctly with mod Small shields.** The vanilla gate in `DecideOnExperimentalToBuild` (M28Engineer.lua line 4108) was skipping the template-conversion branch whenever `refbCanBuildExperimentalShields = true` (under the assumption: exp-shields = T4-sized = template not needed). That assumption breaks with mod Small shields (50–63k HP, smaller radius) — game-enders ended up with only 1–2 lone shields. Removing the gate makes the action conversion (21 → 75) fire and templates get created.
- **Cluster path no longer accidentally builds Large exp shields.** Vanilla M28's tech-level expansion at `GetCategoryToBuildOrAssistFromAction` (M28Engineer.lua line 5248) widens `FixedShield * TECH3` to `FixedShield * (TECH3 OR EXPERIMENTAL)` when `iMinTechLevel == 3`. With Shields Enhanced installed this matches Large variants (`uab9401`/`ueb9401`/`urb9407`/`xsb9401`, all EXPERIMENTAL), causing M28 to build a Large shield ~1-3× per match without going through Phase A's controlled upgrade trigger. The fix subtracts `refiLargeExperimentalShieldCategory` right after the expansion. A deliberate endgame Large-build trigger is tracked as Task #3 in CLAUDE.md.

### Removed
- Temporary diagnostic `LOG` markers (`M28-BLACKOPS-DEBUG-GAMEENDER-*`, `GE-MGR`, `GE-ASSIGN`, `GE-PICK`, `KILL path-6825/6873`, `GE call-1st-wave/2nd-wave`) added during investigation.

---

## [Phase A] — 2026-05-17 (commit `699f8ac1`)

### Added
- **Global 2:1 allocation** for T3→Exp shield upgrades. New trigger `ConsiderGlobalT3ToExpUpgrade` (M28Building.lua) aggregates team-wide T3+/Exp shields (LZ clusters + GE templates), checks the 2:1 ratio (post-upgrade `T >= 2E + 3`) and issues *one* upgrade per trigger on the highest-priority candidate.
- **Threat-mode flip** to 1:2 ratio once enemy has ≥3 T3 artillery or any EXPERIMENTAL-tagged nuke launcher (`bUnderHeavyThreat` detection).
- **Separate `refiLargeExperimentalShieldCategory` bucket** for Large variants (>25k mass cost). Keeps `GetMostExpensiveBlueprintOfCategory` from picking Mavor-tier shields for single-unit coverage in `ActiveShieldMonitor`.

### Changed
- **Cluster ratio raised from 1.2× to 2.0×** (M28Building.lua `AssessT3EngineerConstructionOptions`). With mod Small shields spanning 12k–21.3k mass cost across factions, 1.2× only let the cheapest variant through (UAB9301), leaving the other factions with an empty `refiExperimentalShieldCategory`. 2.0× covers 12k–24k and includes all four faction Smalls.
- **`refActionBuildShield` path** now builds T3 instead of Exp directly — the upgrade trigger later promotes individual T3 shields to Exp where appropriate.
- **`GameEnderTemplateManager`** forces `bOnlyGetT3=true` on all `GETemplateStartBuildingShield` calls. Template slots fill with T3, promotion happens via the global trigger.
- **Upgrade priority order**: Template 1st > LZ 1st > Template 2nd > LZ 2nd (cap at 2 Exp per slot).

### Fixed
- **`ActiveShieldMonitor` LargeExp filter** applied across all 5 faction branches (Aeon, UEF, Seraphim-Mavor, Cybran/else, no-faction fallback). Previously Cybran/Seraphim went through `GetMostExpensiveBlueprintOfCategory(refCategoryFixedShield * FACTION)` and received the Large variant back, then tried to build it as single-unit coverage.

---

## [0.3] — 2026-05-16 (commits `82f8a2e5` / `c9b8f8bb`)

### Added
- **Self-contained fork**: all 467 `import('/mods/M28AI/...')` references rewritten to `/mods/M28AI-Blackops-Shields/...`. The original M28AI mod no longer needs to be installed/active.

### Fixed
- **Silenced `ueb9301`/`urb9207` "no valid upgrade ID" errors.** Added three orthogonal silent-skip branches in `M28Economy.UpgradeUnit`:
  - Empty/nil `UpgradesTo` (top-tier units like `ueb9301`, `xsb9301`, vanilla `urb4302` — FAF normalizes the missing field to `""`, which Lua treats as truthy).
  - Recursion path with `bUpdateUpgradeTracker=false` (race-state retry handler).
  - `CanBuild` fails after `refbTriedIgnoringCanBuildForUpgrade` is set (BlackOps cross-mod chains like `urb1102→brb1202`).
- **Result:** 16 `M28ERROR` → 0 in the test game. 5 throttled `M28Warning` lines remain (T2→T3 support-factory upgrade without T3 HQ, self-healing — see CLAUDE.md Task #1b).

---

## [0.2] — 2026-05-16 (commit `22ce5776`)

### Changed
- **Lowered experimental-shield-detection thresholds** so M28 picks up mod Small shields:
  - `iExperimentalShieldHealthValue`: 90000 → **48000** (Shields Enhanced Small: 50–63k HP)
  - `iMinShieldSize`: 50 → **48** (vanilla Seraphim T3 = 46)
  - `iMaxShieldCost`: 20000 → **25000**
- `mod_info.lua`: title `M28AI-Blackops+Shields`, new UID, attribution to maudlin27.

### Verified
- 53-minute test game: `ueb9301` (UEF Bulwark Small) and `urb9207` (Cybran Iron Veil Small) were built by M28 brains. Large variants (`uab9401`/`ueb9401`/`urb9407`/`xsb9401`) stayed out thanks to the cost cap.

---

## [0.1] — 2026-05-13 (Baseline)

Forked from [maudlin27/M28AI](https://github.com/maudlin27/M28AI) at commit `6df2f85f` (`Merge pull request #378 from maudlin27/v297`). No fork-specific changes yet.
