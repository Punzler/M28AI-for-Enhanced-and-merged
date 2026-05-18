# Changelog — M28AI-Blackops+Shields

Fork of [maudlin27/M28AI](https://github.com/maudlin27/M28AI) v297, tuned for play with **Shields Enhanced** and **BlackOpsFAF-Merged** in FAF.

---

## [Unreleased]

### Added
- Endgame Large experimental shields. M28 now deliberately builds up to 3 Large exp shields per AI when the enemy fields multiple game-enders or T3 artillery, prioritising coverage of its own game-enders first, then highest-value base areas. Skipped while the team is in a power stall so the 2.2M-energy build does not stall the wider economy.
- M28 now builds SMDs against enemy satellite control centres (Novax / Artemis), treating them like nuke launchers. Combined with the BlackOps AntiSat-modified SMDs, this gives a real defensive answer to enemy satellites.

### Fixed
- Game-ender shields no longer flicker on and off when nothing is shooting at them. M28 only rotates shields once one of them has actually taken damage; otherwise all shields stay up.
- Game-enders are now built inside proper shield clusters again instead of with only 1-2 lone shields next to them.
- Large exp shields are no longer built by accident through the normal cluster path; they only appear from the endgame trigger above.
- Game-ender templates now reclaim adjacent buildings whose skirts overlap a template slot instead of getting stuck and spamming "template location blocked" warnings. M28 only reclaims a neighbour if it actually skirt-overlaps the slot, so unrelated buildings are left alone.
- Limit each AI brain to building at most one T3 Advanced Air Staging Facility.
- ASF no longer fly under enemy Novax satellites trying to engage them. Satellites are now left to dedicated anti-satellite defences.
- T1 mass storage at mass extractors (the adjacency-bonus speichers) is no longer self-destructed when M28 approaches the unit cap.
- Hydrocarbon plants (including modded T2/T3 BlackOps hydros) are no longer self-destructed under any circumstance: not under unit-cap pressure, not when placing a game-ender template or shield, and not when unsticking a T3 naval factory. If a hydro blocks a template slot, M28 picks a different slot instead.
- M28's own Novax satellites no longer fly into enemy AntiSat-SMD range. They prefer safe targets; if only SMD-covered high-value targets exist, the satellite patrols along the SMD boundary and waits for an opening (SMD destroyed or target moves out).
- Mobile anti-air no longer chases enemy satellites it cannot actually shoot. Satellites are skipped when picking the closest enemy air unit to advance toward.
- Rare stuck-Novax-centre fix: if a centre finishes building but its satellite never spawns due to engine state desync, M28 now detects the stuck state and re-issues the satellite build.

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
