# M28AI-Blackops+Shields — Project Context

## What this is

A fork of [maudlin27/M28AI](https://github.com/maudlin27/M28AI) (v297) by Punzler,
tuned for play alongside Shields Enhanced and BlackOpsFAF-Merged in FAF
(Forged Alliance Forever).

The user (Punzler) is the author of **Shields Enhanced** and
modifies M28AI directly to support typical mod experimental shields in
M28's engineer-strategy chain.

## Current state

**Working:** Lower experimental-shield-detection thresholds in
`M28AI-Blackops-Shields/lua/AI/M28Building.lua` so M28's engineer-strategy
chain activates with mod shields (Shields Enhanced Small variants:
50–63k HP):

- Line 35: `iExperimentalShieldHealthValue = 48000` (was 90000)
- Line 6318: `local iMinShieldSize = 48` (was 50)
- Line 6321: `local iMaxShieldCost = 25000` (was 20000)

Verified in-game over a 53-min match — `ueb9301` (UEF Bulwark Small) and
`urb9207` (Cybran Iron Veil Small) built by M28 brains. Large variants
(`uab9401`/`ueb9401`/`urb9407`/`xsb9401`) correctly filtered out by the
cost-cap + M28's existing `iCheapestShield * 1.2` clustering.

`mod_info.lua` retitled to `M28AI-Blackops+Shields`, new UID, attribution
to maudlin27.

**Self-contained fork (as of 2026-05-16):** All 467 `import('/mods/M28AI/...')`
references were bulk-rewritten to `import('/mods/M28AI-Blackops-Shields/...')`
so the fork loads its own code instead of shadowing the canonical M28AI
mount. Original M28AI mod no longer needs to be installed/active for the
fork to run. Side-effect: BlackOpsFAF-Merged / BlackOpsFAF-ACUs-Enhanced /
Shields Enhanced still hook `/mods/m28ai/...` paths — if the original
M28AI folder isn't mounted those hooks no-op. Accept for now.

## Open tasks (in priority order)

### 1. ✅ Fix `ueb9301`/`urb9207` "no valid upgrade ID" errors (DONE 2026-05-16)

**Root cause:** the bug was *not* a misbehaving caller. It was three orthogonal silent-skip conditions missing inside `M28Economy.UpgradeUnit` itself. Diagnosed via temp debug logging at function entry — once a verification run confirmed the pattern, the debug block was removed and the fix landed at the error site.

Three error flavors all flowed into the same `else`-branch:
1. **Empty/nil `UpgradesTo`** — top-tier units (modded `ueb9301`/`xsb9301`/`beb5205`, also vanilla `urb4302`). Some BP layer in the FAF mod stack normalizes the missing field to `""` (empty string), which is truthy in Lua and slips past the existing `if BP.UpgradesTo then` guards at the ForkThread call sites.
2. **Recursion at [M28Economy.lua:157](M28AI-Blackops-Shields/lua/AI/M28Economy.lua#L157)** — race-state retry handler for the `BeingUpgraded+FractionComplete=1` engine state-flap. The recursion passes `bUpdateUpgradeTracker=false`, which forces the function's outer `if`-condition to fail on re-entry. Architectural quirk: the workaround sabotages its own retry path.
3. **CanBuild fails** — BlackOps cross-mod chains like `urb1102→brb1202` where the upgrade target's BP exists but the engineer can't issue it. After `refbTriedIgnoringCanBuildForUpgrade` is set, subsequent attempts can't even use the fallback path, so they fall into the error.

**Fix:** four-branch logic at [M28Economy.lua:173+](M28AI-Blackops-Shields/lua/AI/M28Economy.lua#L173):
- empty/nil `UpgradesTo` → silent
- restricted (existing) → silent
- `not(bUpdateUpgradeTracker)` (recursion) → silent
- `CanBuild` fails → Warning (`ErrorHandler(msg, true)`) instead of Error, so it surfaces once then auto-throttles
- real bug → Error as before

**Result (game_27069683.log):** 16 `M28ERROR` → 0. 5 throttled `M28Warning` lines remain — see below, working as designed.

### 1b. ✅ Support-factory `CanBuild` warnings — investigated, working as designed (2026-05-16)

The five remaining `M28Warning` lines after Task #1 (`zrb9501→zrb9601`, `zsb9502→zsb9602` etc.) come from Branch 3 of the Task #1 fix and are *correct behaviour*, not a bug to fix.

**FAF naming quick-ref (we kept confusing ourselves):**
- `urb0101` = T1 land factory (the only "T1" — starting tier)
- `urb0201` / `zrb9501` = T2 land factory (regular / support variant); both have BP `Categories.TECH2`
- `urb0301` / `zrb9601` = T3 land factory (regular / support variant); both have BP `Categories.TECH3`
- There is no "T1 support factory" — the support chain starts at T2

So `zrb9501 → zrb9601` is a **T2 support → T3 support** upgrade, BP TECH2 → BP TECH3. Requires the team to have an active T3 HQ (the equivalent of regular factory T2→T3 needing a T3 HQ to allow self-upgrade).

**Source-of-truth checks (FAF GitHub):** all four factions' T2 support factory BPs declare `UpgradesTo` to the T3 variant and have a matching `BuildableCategory` entry (`"BUILTBYTIER2SUPPORTFACTORY <FACTION> STRUCTURE <DOMAIN>"`) that *should* let CanBuild succeed once the HQ-tech condition is met. Verified for `zrb9501`/`zab9501`/`zeb9501`/`zsb9502` — pattern is identical across factions, no mod hooks the BPs (checked BlackOpsFAF-Merged, BlackOpsFAF-ACUs-Enhanced, Shields Enhanced, Total Mayhem, Savers Unitspack).

**Why only Cybran + Seraphim warnings show in the test log:** likely sampling, not a structural asymmetry. In the test game those brains happened to reach `GetAnyMexOrFactoryToUpgrade` with a T2 support factory while their team still lacked a T3 HQ at that moment (engineer present but HQ not yet built or destroyed).

**Caller chain:** [M28Team.lua:3934](M28AI-Blackops-Shields/lua/AI/M28Team.lua#L3934) `ConsiderNormalUpgrades` → [M28Team.lua:3608](M28AI-Blackops-Shields/lua/AI/M28Team.lua#L3608) `GetAnyMexOrFactoryToUpgrade` (backup logic) → `UpgradeUnit`. The filter at Z.3593 (`refCategoryLandFactory - categories.TECH3`) intentionally pulls in support factories for upgrade consideration.

**Why no fix:** the system is self-healing. M28 polls for upgrades, engine refuses while team lacks T3 HQ, M28 retries on next sweep, eventually succeeds once T3 HQ stands. Branch 3 throttles the noise (5 lines / 27-min match). Filtering `SUPPORTFACTORY` out at the caller would prevent legitimate upgrades when conditions ARE met; adding a HQ-tech precondition is more code for no functional improvement.

### 1c. ✅ GE templates never formed with mod Small shields (DONE 2026-05-17)

**Symptom:** in multiple test games the user observed Mavor/Czar/Paragon being built with only 1–2 lone shields around them instead of the structured shield clusters that GE templates normally produce. Test log `game_27075956.log` confirmed: all 7 built game-enders (1 Czar, 6 Mavors) had `engineerAction=21` (`refActionBuildExperimental`) instead of `=75` (`refActionManageGameEnderTemplate`) — no template was ever created.

**Root cause:** vanilla gate at [M28Engineer.lua:4108](M28AI-Blackops-Shields/lua/AI/M28Engineer.lua#L4108) in `DecideOnExperimentalToBuild`:

```lua
if iCategoryWanted and not(aiBrain[M28Overseer.refbCanBuildExperimentalShields]) then
```

Vanilla assumption: *"if the brain can build exp-shields, they're T4-sized → `ActiveShieldMonitor` single-unit coverage is enough, no GE template needed."* Holds for vanilla M28 (T4 = ~600 radius). Does **not** hold for Shields Enhanced Small variants (50–63k HP, much smaller radius).

Phase A (commit `699f8ac1`) + threshold lowering (commit `22ce5776`) flipped `refbCanBuildExperimentalShields = true` for mod setups → the gate becomes `not(true)=false` → the entire block Z.4108–4267, including the template conversion at Z.4171 (`iCategoryWanted = refActionManageGameEnderTemplate`), is skipped → the action conversion at Z.10071 never fires → the engineer builds the game-ender raw under action 21, `AssignEngineerToGameEnderTemplate` is never called, no template is created.

**Fix:** gate removal at Z.4108 — single-line change:

```lua
if iCategoryWanted then --M28AI-Blackops+Shields fork: removed vanilla gate on refbCanBuildExperimentalShields …
```

**Verified in-game:** user confirmed templates now form correctly and shield clusters appear around game-enders.

### 1d. ✅ Cluster path occasionally built Large exp shields (DONE 2026-05-17)

**Symptom:** test log `game_27076350.log` showed 3 Large exp shields completed (`uab94011`, `urb94071`, `urb94073`) with `scope=cluster` — built outside any GE-template or special-assignment context. Phase A's intent was to never build Large via automatic paths, only via a future dedicated trigger.

**Root cause:** vanilla M28 expansion at [M28Engineer.lua:5248](M28AI-Blackops-Shields/lua/AI/M28Engineer.lua#L5248) in `GetCategoryToBuildOrAssistFromAction`:

```lua
if iMinTechLevel == 3 then iCategoryToBuild = iCategoryToBuild * categories.TECH3 + iCategoryToBuild*categories.EXPERIMENTAL
```

For shield contexts where `iCategoryToBuild = M28UnitInfo.refCategoryFixedShield * categories.TECH3` (set at Z.5223 cluster path), this expands by category-distributivity to `SHIELD * STRUCTURE * (TECH3 OR EXPERIMENTAL)` — which matches all Large mod variants (`uab9401`/`ueb9401`/`urb9407`/`xsb9401`, all tagged `EXPERIMENTAL + TECH4 + SIZE12`). Cluster builds picked them ~1-3× per match.

**Fix:** subtract `refiLargeExperimentalShieldCategory` from `iCategoryToBuild` right after the expansion. Keeps Small mod variants pickable (still useful redundancy in case the Phase A upgrade-trigger misses them) but eliminates Large from the cluster path.

### 2. ✅ Endgame dedicated Large-shield build trigger (DONE 2026-05-18)

**Implemented as `ConsiderLargeShieldBuild(aiBrain)` in [`M28Building.lua`](M28AI-Blackops-Shields/lua/AI/M28Building.lua), wired into the same shield-completion hook in [`M28Events.lua:2877`](M28AI-Blackops-Shields/lua/AI/M28Events.lua#L2877) as the existing T3→Exp upgrade trigger.**

**Trigger conditions:** enemy team has ≥2 game-enders (refCategoryGameEnder: Mavor/Czar/Yolona/Paragon, including under-construction) OR ≥5 pure T3 fixed artillery (refCategoryFixedT3Arti, excluding experimentals).

**Caps (per AI brain — NOT team-wide):**
| Enemy GE count | Allowed Large per brain |
|---|---|
| ≥4 | 3 |
| ≥3 | 2 |
| else (only T3-Arti trigger or 2 GE) | 1 |

Hard ceiling 3 per brain. In a multi-M28-brain team, each brain runs independently — team total can exceed 3.

**Placement priority** (per-brain only — each brain protects its own assets):
1. Each of this brain's own GEs not yet covered by this brain's own Large gets a candidate position offset 10–12 ogrids from the GE midpoint (8 compass directions tried, first one that validates `aiBrain:CanBuildStructureAt` wins). Skirt-clear (Large 8×8 skirt + GE ~10×10 skirt → min 9 ogrids apart), well within the ~42 ogrid shield radius for full coverage.
2. Top-5 LZs by `subrefLZSValue` (M28's eco-score) whose midpoints are not yet inside this brain's Large coverage AND don't overlap an active GE-template via `WillBlockTemplateLocation`.

Engineer pick: this brain's free T3 engineers (refiAssignedAction nil/0) within 300 ogrids of the candidate position, can build at least one BP from the brain's Large bucket. Most-expensive Large BP picked (`GetMostExpensiveBlueprintOfCategory`-equivalent inline).

**Helper functions:** `GetLargeShieldsForBrain(aiBrain)`, `IsPositionWithinLargeCoverage(tPos, toExistingLarges, fMultiplier)`, `CountEnemyGEAndT3Arti(iTeam)` — all in M28Building.lua near `ConsiderLargeShieldBuild`.

**Result (game_27080560):** trigger fires, 1 Large built, no `ConsiderLargeShieldBuild`-related errors in log. Per-brain cap tiers ≥2 not exhaustively tested due to enemy GE-count not reaching threshold in test session, but cap logic is symmetric (same code path, different comparison values).

## Workflow

### Code lives in two places

- **Workspace (this folder):** `C:\Users\etien\modding\workspace\M28AI-Blackops-Shields\` — git repo root.
  - Top-level (repo meta only): `.git/`, `.gitattributes`, `.gitignore`, `.claude/`, `CLAUDE.md`, `installation.txt`
  - Mod files in nested subfolder: `M28AI-Blackops-Shields/` containing `mod_info.lua`, `LICENSE`, `M28AI.jpg`, `hook/`, `lua/`, `units/`, `textures/`. Restructured 2026-05-16 so meta-files don't sit next to mod files.
  - `.gitignore` excludes `.idea/` (auto-generated IntelliJ scaffold, no real config — regenerates on next IDE open).
- **FAF live folder:** `C:\Users\etien\Documents\My Games\Gas Powered Games\Supreme Commander Forged Alliance\mods\M28AI-Blackops-Shields\` — needs manual sync from workspace's inner subfolder (`workspace/M28AI-Blackops-Shields/M28AI-Blackops-Shields/`) before each test. 1:1 mapping.

Sync after every edit. The FAF folder is gitignored; only the workspace
is version-controlled.

### Testing

- Activate **only** `M28AI-Blackops+Shields` in FAF lobby. With the
  self-contained rewrite (2026-05-16) the original M28AI mod is no longer
  needed for the fork to load its own code. Activating both at the same
  time risks Lua state confusion.
- Mod stack used: Total Mayhem, BlackOps FAF Merged, BlackOpsFAF-ACUs-
  Enhanced, Shields Enhanced, Savers Unitspack
- Run minimum 8–15 min for T3 engineers to spawn (gate fires on
  `LifetimeCount == 1 + TECH3 * Engineer` in M28Events.lua:3885)
- Logs: `C:\Users\etien\AppData\Roaming\Forged Alliance Forever\logs\game_*.log`
- Crash exit code via `client.log`:
  - `0` = clean exit
  - `-1073741819` (0xC0000005) = engine access violation
- Search log for `M28-BLACKOPS-DEBUG` (current debug marker for the
  UpgradeUnit no-UpgradesTo investigation), `M28-MyAddon` (legacy
  Hook-Addon approach), and `M28AI-Blackops+Shields`

## Important context from earlier diagnosis

The user originally tried to make a separate addon mod (`M28-MyAddon`)
using FAF's `hook/mods/M28AI/lua/AI/M28Building.lua` mechanism instead
of directly forking. **That approach was abandoned** due to:

1. **SCR_LuaDoFileConcat parser bug** — Multi-line `if`/`and`/`or` or
   multi-line function-calls in a hook file break Lua's parser on the
   concatenated original+hook file. Symptom: `unexpected symbol near 'end'`
   error, entire M28Building.lua module fails to load, hundreds of
   `access to nonexistent global` errors at runtime.

2. **Top-level `import()` in hooks** corrupts M28's module state. Got
   1770–14964 `access to nonexistent global variable` errors when hook
   had `import('M28UnitInfo.lua')` and `import('M28Factory.lua')` at
   top level. Only `import('M28Overseer.lua')` worked. Lazy imports
   (inside function body) helped but not fully.

3. **`categories[sBP]`** is an engine-internal C-API call that can
   natively crash (Access Violation `0xC0000005`) on certain mod BPs.

The fork approach sidesteps all three issues — we just edit M28's code
directly. The legacy `M28-MyAddon/` folder is not in the workspace by
default; ask the user to copy it in if its history is needed.

## Sibling reference repos in workspace

Per user's file-access rule: only browse `c:\Users\etien\modding\workspace\`
and the FAF logs folder. Other paths (FAF live mods, system folders) are
off-limits unless the user explicitly copies content in. The workspace is
curated by the user — they add/remove folders as needed. Verify presence
before assuming. For FAF engine code, use the FAF GitHub repo via
WebFetch/WebSearch, not local filesystem hunting.

Currently typical contents (subject to change):
- `BlackOpsFAF-Merged/`, `BlackOpsFAF-ACUs-Enhanced/` — used together in
  the mod stack
- `Shields Enhanced/` — Punzler's own shield mod (the BPs we're targeting)

## User preferences

- German-speaking (replies in German preferred for natural conversation)
- FAF modder, prefers minimal/idiomatic patches, no unnecessary code or
  comments
- Background: software-aware (uses PyCharm for Python work) but Lua/FAF
  modding is the focus here
- Editor: VSCode with Lua + GitLens extensions

## License

Source M28AI is CC BY-NC-SA 4.0. This fork must retain attribution to
maudlin27 and stay under the same license. See `mod_info.lua` for
attribution string.
