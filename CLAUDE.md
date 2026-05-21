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

## Completed tasks

1. **UpgradeUnit errors** (2026-05-16) — Four-branch error handling in `M28Economy.lua:173+` for empty UpgradesTo, recursion, CanBuild failures. Follow-up: fixed `ConsiderHydroUpgradeLoop` and `UpgradeShieldsCoveringSMD` callers passing wrong `bUpdateUpgradeTracker`.
2. **Support-factory warnings** (2026-05-16) — Investigated, working as designed. T2-support→T3-support CanBuild fails until T3 HQ exists; M28 self-heals on next sweep.
3. **GE templates with mod shields** (2026-05-17) — Removed vanilla `refbCanBuildExperimentalShields` gate in `M28Engineer.lua:4108` that blocked template creation when Small exp shields are available.
4. **Large shields in cluster path** (2026-05-17) — Subtract `refiLargeExperimentalShieldCategory` after TECH3+EXPERIMENTAL expansion in `M28Engineer.lua:5248`.
5. **Large-shield build trigger** (2026-05-18) — `ConsiderLargeShieldBuild` in `M28Building.lua`, triggered from `M28Events.lua:2877`. Caps 1–3 per brain based on enemy GE count. Placement near own GEs and high-value LZs.
6. **ASF ignore satellites** (2026-05-18) — Filter `refCategorySatellite` out of `AssignAirAATargets` in `M28Air.lua:3474`.
7. **Protect hydros/mass storage** (2026-05-18) — Excluded HYDROCARBON from all self-destruct paths (CheckUnitCap, GE-template slots, AssistShield, naval unstuck). T1 mass storage excluded from CheckUnitCap.
8. **PD edge placement** (2026-05-18, REVERTED) — Approach failed; see `HANDOVER-pd-edge-placement.md` before revisiting.
9. **Non-Seraphim navy stuck** (2026-05-21) — Missing `oUnit.UnitId` arg in `EntityCategoryContains` at `M28Navy.lua:1855` (MAA classification guard). After dynamic `refCategoryNavalAA` expansion added AA-capable frigates, the 1-arg call errored and silently skipped UEF/Cybran/Aeon combat ships from classification. Pre-existing bug in upstream M28AI v297.

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

- Activate **only** `M28AI-Blackops+Shields` in FAF lobby (not original M28AI).
- Mod stack: Total Mayhem, BlackOps FAF Merged, BlackOpsFAF-ACUs-Enhanced, Shields Enhanced, Savers Unitspack
- Logs: `C:\Users\etien\AppData\Roaming\Forged Alliance Forever\logs\game_*.log`
- Crash exit code `0` = clean, `-1073741819` (0xC0000005) = engine access violation

## Why a direct fork (not a hook mod)

An earlier addon-mod approach (`M28-MyAddon`) using FAF hooks was abandoned
due to SCR_LuaDoFileConcat parser bugs, top-level `import()` state corruption,
and `categories[sBP]` C-API crashes. Direct fork sidesteps all three.

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
