# Changelog — M28AI-Blackops+Shields

Fork of [maudlin27/M28AI](https://github.com/maudlin27/M28AI) v297, tuned for play with **Shields Enhanced** and **BlackOpsFAF-Merged** in FAF.

---

## [Unreleased]

### Added
- Endgame Large experimental shields. M28 now deliberately builds up to 3 Large exp shields per AI when the enemy fields multiple game-enders or T3 artillery, prioritising coverage of its own game-enders first, then highest-value base areas.

### Fixed
- Game-enders are now built inside proper shield clusters again instead of with only 1-2 lone shields next to them.
- Large exp shields are no longer built by accident through the normal cluster path; they only appear from the endgame trigger above.

---

## 2026-05-17

### Added
- Self-contained fork: the original M28AI mod no longer needs to be installed or active.
- Cluster strategy for mod Small exp shields: M28 builds T3 shields first and then deliberately upgrades a portion of them to Small exp under a global 2:1 ratio, with a 1:2 flip under heavy T3-arti / nuke pressure.

### Fixed
- "No valid upgrade ID" errors on mod Small exp shields no longer flood the log.

---

## 2026-05-16

### Changed
- Lowered the experimental-shield-detection thresholds so M28 recognises and uses Shields Enhanced Small variants (Bulwark / Iron Veil / etc.) without picking up the much larger Mavor-tier shields.
- Renamed mod to `M28AI-Blackops+Shields`, new UID, attribution to maudlin27.

---

## 2026-05-13 — Baseline

Forked from upstream M28AI v297. No fork-specific changes yet.
