# Changelog — M28AI-Blackops+Shields

Fork of [maudlin27/M28AI](https://github.com/maudlin27/M28AI) v297, tuned for play with **Shields Enhanced** and **BlackOpsFAF-Merged** in FAF.

---

## [v1.4]

### Added
- Pre-emptive SMD in core base after 15 minutes, even without confirmed enemy nuke launchers.

### Fixed
- Priority scout targets (e.g. nuke subs) no longer attract all available scouts. Each priority target gets exactly one scout; the rest continue normal scouting.

---

## [v1.3]

### Changed
- ACU retreats earlier on large maps (20km+). The retreat trigger at 16:40 game time now applies in all game modes, not just assassination.
- Merged upstream M28AI v298–v300 changes: ACU aggression tuning, bomber targeting without air control, mex upgrade timing, fortify zone rally points, pacifist mode support, campaign mission fixes, T2 support factory logic, and various bugfixes.

---

## [v1.2]

### Added
- **Vision-only AI**: M28 no longer reads blueprint data (unit type, mass cost, health, category) from radar-only enemy contacts. Until a unit is visually confirmed by line-of-sight, M28 treats it as a generic blip with no readable identity. Radar still tells M28 where things are; vision tells M28 what they are. Affects long-range targeting, threat assessments, defensive triggers, enemy classification flags, ACU tracking, and strategic responses.
- Map-coverage-driven scout production. Air factories (all tech levels) build scouts proportional to how much of the map is currently un-scouted. At game start (~100% unexplored) M28 produces 4 scouts; production tapers as visual coverage improves.
- Dedicated T3 spy-plane production tied to map coverage. T3 factories build T3 scouts independently of experimentals existing, so high-tech recon is available early in the T3 phase.
- Zones containing confirmed enemy structures get high-priority scouting cycle (~60s refresh) so known enemy bases get regular visual updates. Previously only enemy starting positions were tagged high-priority and never re-evaluated.

### Changed
- Long-range weapons (T3 artillery, game-enders, TML, SML, strategic bombers) no longer cherry-pick specific target types from radar contacts. Unidentified radar blips have equal priority — M28 still fires at them, but doesn't preferentially aim at Mavor/Czar/SML/ACU without visual confirmation.
- Threat counters per zone treat radar-only contacts as a flat generic threat. M28 no longer reflexively overbuilds MAA/ASF based on radar-blip categories it can't legitimately see.
- Defensive constructions (Large experimental shields, SMD mass-priority elevation) require visually-confirmed enemy game-enders or nuke launchers, not radar-only blips.
- Enemy classification flags — sniper-bot panic, T3-air alarm, ACU tracking, missile-ship recording, T2-transport detection — all require visual line-of-sight. Radar contact alone no longer triggers strategic reactions.
- Air-scout priority list keeps unconfirmed TMD/SML targets on the scout-priority queue. Vanilla removed them on any detection (radar or vision); now only visual confirmation clears them.
- Scout intervals scale with radar-blip count. The more unconfirmed radar contacts, the shorter the scouting cycle (down to 0.5× base intervals at 15+ blips).

---

## [v1.1]

### Fixed
- Large exp shields are now placed at proper distance from game-enders instead of too far away. Previous offsets were too small, causing all nearby positions to fail and the AI to fall back to distant base zones.
- Mobile anti-air no longer gets drawn to zones where only satellite threat exists. Satellites are now fully excluded from zone air-unit tracking so they don't inflate air-to-ground threat values that pull MAA across the map.
- Enemy satellites now trigger SMD construction directly (not just their control centres), giving an earlier defensive response.

---

## [v1]

### Changed
- Radar upgrade chain: T1 radar now automatically upgrades to T2 when eco allows, instead of building a separate T2 next to it. T2-to-omni upgrade no longer requires 20km+ maps, specific zone positions, or bomber/gunship threat — just T3 mexes and sufficient eco.
- Air scouts no longer suppressed by radar coverage or omni vision. Scouts are produced and sent regardless of intel structure coverage.
- AI personalities renamed from "M28 …" to "BlackOps …" in the lobby dropdown (e.g. "AI: BlackOps Adaptive" instead of "AI: M28 Adaptive").
- Hover micro for bombers is now restricted to experimental bombers only (e.g. Ahwassa). T1/T2/T3 bombers and torp bombers use normal attack and move orders instead of tick-by-tick steering.
- Air scouts now ignore radar coverage when deciding which zones to rescan. Previously, zones with good radar had their scouting interval multiplied by 4×, which could delay visual intel by several minutes.
- Bombers now tolerate ~67% more enemy ground AA before aborting an attack run. After heavy bomber losses, the AI retains 50% of its base tolerance instead of collapsing to 25%.
- Snipe-mode bomber pool is now capped at 30. Excess bombers are freed for normal attack duties instead of all sitting at the rally point waiting for the snipe threshold.
- Air control declaration is more aggressive: the AI claims air control at roughly even ASF numbers instead of requiring a 25–55% superiority margin.
- Gunships now attack at threat parity instead of requiring a 1.7× advantage over same-zone enemies. The ground-AA tolerance cap is raised from 2000 to 10000, so large gunship fleets are no longer held back by a few T2 flak.

### Added
- AI now recognises BlackOpsFAF-ACUs-Enhanced ACUs and picks correct multi-tier upgrade chains (Engineering → Defensive → Weapons). On land maps, a cheap weapon boost is researched first; on naval maps, torpedoes are interleaved with engineering and defensive upgrades.
- Bombers now try up to 4 alternative angled routes (±30°, ±60°) when the direct path has too much AA. If a detour path has less AA than the tolerance threshold, bombers fly via a waypoint instead of giving up on the target entirely.
- Idle ASF now escort active T3 and experimental bombers. All qualifying ASF (≥60% fuel, >85% HP) are sent as cover to the furthest-out bomber.
- Hard cap of 150 interceptors/ASF per AI brain (all tiers combined). Once the cap is reached, air factories switch to bombers, gunships, or engineers instead of idling.
- AI no longer gifts units or resources to teammates. ASF transfers, mex gifts, support factory redistribution, energy/mass sharing between AI brains, and Paragon-related transfers are all disabled. Death-fallback (units transfer when an AI is eliminated) and adjacency-only storage swaps remain active.
- Endgame Large experimental shields. M28 now deliberately builds up to 3 Large exp shields per AI when the enemy fields multiple game-enders or T3 artillery, prioritising coverage of its own game-enders first, then highest-value base areas. Skipped while the team is in a power stall so the 2.2M-energy build does not stall the wider economy.
- M28 now builds SMDs against enemy satellite control centres (Novax / Artemis), treating them like nuke launchers. Combined with the BlackOps AntiSat-modified SMDs, this gives a real defensive answer to enemy satellites.
- Defense placement (PD, artillery, AA) now uses a mex-cluster band system along the base→enemy axis instead of building at zone midpoints. Structures are placed at the nearest mex cluster shifted toward the enemy front, keeping defenses where they protect the economy.

### Fixed
- PD and artillery are no longer built inside the core base area. If no suitable defense band position exists, the build is skipped entirely instead of falling back to the base center.
- Hybrid PD+AA structures from TotalMayhem (e.g. the Anode) are no longer incorrectly built through the AA defense path.
- Fixed a vanilla M28 typo that caused ~50 "nonexistent global variable" errors per minute in late game when many engineers are active.
- Game-ender shields no longer flicker on and off when nothing is shooting at them. M28 only rotates shields once one of them has actually taken damage; otherwise all shields stay up.
- Game-enders are now built inside proper shield clusters again (broke because of the new shields) instead with only 1-2 lone shields next to them.
- Large exp shields are no longer built by accident through the normal cluster path; they only appear from the endgame trigger above.
- Game-ender templates more often reclaim adjacent buildings whose skirts overlap a template slot instead of getting stuck and spamming "template location blocked" warnings. M28 only reclaims a neighbour if it actually skirt-overlaps the slot, so unrelated buildings are left alone.
- Limit each AI brain to building at most one T3 Advanced Air Staging Facility.
- Limit each AI brain to building at most one Artemis satellite control centre (bab2404). If the Artemis is destroyed, the brain may rebuild one.
- ASF no longer fly under enemy Novax satellites trying to engage them. Satellites are now left to dedicated anti-satellite defences.
- T1 mass storage at mass extractors (the adjacency-bonus speichers) is no longer self-destructed when M28 approaches the unit cap.
- Hydrocarbon plants (including modded T2/T3 BlackOps hydros) are no longer self-destructed under any circumstance: not under unit-cap pressure, not when placing a game-ender template or shield, and not when unsticking a T3 naval factory. If a hydro blocks a template slot, M28 picks a different slot instead.
- M28's own Novax satellites no longer fly into enemy AntiSat-SMD range. They prefer safe targets; if only SMD-covered high-value targets exist, the satellite patrols along the SMD boundary and waits for an opening (SMD destroyed or target moves out).
- Mobile anti-air no longer chases enemy satellites it cannot actually shoot. Satellites are skipped when picking the closest enemy air unit to advance toward.
- Rare stuck-Novax-centre fix: if a centre finishes building but its satellite never spawns due to engine state desync, M28 now detects the stuck state and re-issues the satellite build.
- Modded BlackOps hydrocarbon plants (T1 → T2 → T3) are now upgraded automatically again. The same fix re-enables T2 → T3 shield upgrades on SMDs when the enemy fields T3 artillery or Novax+SML.
- Non-Seraphim naval combat ships (UEF, Cybran, Aeon frigates and similar) no longer silently stop receiving orders mid-game. A missing argument in the unit classification caused ships with AA weapons to be skipped entirely once their blueprints were evaluated by the threat system.
- T3 air staging facilities (which carry a SHIELD category tag) are no longer misclassified as shield structures. This prevented them from interfering with shield cluster logic and shield-build decisions.

### Removed
- Anti-teleport PD builder. This placed PDs at enemy teleport locations which often landed inside the core base.

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
