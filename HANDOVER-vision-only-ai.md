# Plan: M28 Vision-Only Awareness (Option B1)

## Context

**Ziel:** M28's komplette AI-Logik nutzt Radar-Daten **nur** noch dafür, Ziel-Positionen zu kennen („da steht etwas, das man beschießen könnte"). Alle BP-abhängigen Entscheidungen (Kategorien, Massekosten, Health, Tech-Level, Threat-Klasse) erfordern visuelle LOS-Bestätigung. Radar-Blips ohne jemals visuelle Bestätigung sind generische „unbekannte Objekte" mit Flat-Priorität.

**B1-Trade-off:** Lua-Unit-Referenzen bleiben erhalten (kein Lifecycle-Refactor, kein Spieler-realistisches „Tod im FoW unbekannt"). Stattdessen tragen Units einen Per-Team-Visibility-Tag, den alle Consumer prüfen, bevor sie BP-Info auswerten. Das ist die pragmatische Mittelstufe zwischen dem aktuellen State (volle BP-Info ab Radar) und einem Komplett-Refactor (B2).

**Intended Outcome:**
- M28 fungiert als Echtzeit-Spieler mit Radar-Awareness, aber ohne Insider-Wissen über unaufgedeckte Strukturen.
- Scout-Pressure und Vision-Denial werden zu validen Spielstrategien gegen die AI.
- M28 bleibt schwächer als Upstream — bewusst akzeptiert.

## Architecture

### Visibility-Tag-Mechanik

**Storage-Erweiterung:** Pro Enemy-Unit existiert bereits `oUnit[M28UnitInfo.refbHaveSeenUnitByTeam][iTeam]` (gesetzt in OnDetectedBy für Radar **oder** Vision). Wir fügen ein paralleles Feld hinzu:

```lua
oUnit[M28UnitInfo.refbHaveTeamSeenVisually][iTeam] = true
```

- Wird gesetzt in `OnDetectedBy`, **nur** wenn `oBlip:IsSeenEver(iArmy) == true` (also nicht für reine Radar-Kontakte).
- Wird zusätzlich von einem Refresh-Job periodisch nachgeprüft, weil Radar→Vision-Transitionen `OnDetectedBy` nicht garantiert nochmal feuern.

**Refresh-Job:** Neuer Tick in M28Team (alle ~5 Sekunden) iteriert `tTeamData[iTeam][reftEnemyUnitsTracked]` (Master-Liste aller jemals erkannten Units des Teams) und ruft pro Unit `CanSeeUnit(anyBrainOnTeam, oUnit, true)` auf. Bei `true` → Tag setzen.

**Helper-Funktionen** (in M28UnitInfo.lua):

```lua
-- Single-source-of-truth Visibility-Check
function HasTeamSeenUnitVisually(oUnit, iTeam)
    return oUnit[refbHaveTeamSeenVisually] and oUnit[refbHaveTeamSeenVisually][iTeam] or false
end

-- BP-Mask: gibt Category-Membership nur zurück wenn visuell bestätigt
function GetCategoryMembershipIfVisible(oUnit, iTeam, iCategory)
    if HasTeamSeenUnitVisually(oUnit, iTeam) then
        return EntityCategoryContains(iCategory, oUnit.UnitId)
    end
    return false
end

-- Massekosten-Mask: echte Kosten bei Vision, sonst Flat-Default
function GetUnitMassCostByVisibility(oUnit, iTeam, iRadarDefault)
    iRadarDefault = iRadarDefault or 1000
    if HasTeamSeenUnitVisually(oUnit, iTeam) then
        return oUnit[refiUnitMassCost] or GetUnitMassCost(oUnit)
    end
    return iRadarDefault
end

-- Health-Mask: analog
function GetMaxHealthByVisibility(oUnit, iTeam, iRadarDefault)
    iRadarDefault = iRadarDefault or 1000
    if HasTeamSeenUnitVisually(oUnit, iTeam) then
        return oUnit:GetMaxHealth()
    end
    return iRadarDefault
end

-- Split-Helper für Listen: trennt visuell bestätigte von Radar-Only
function SplitEnemyListByVisibility(tEnemies, iTeam)
    local tVisual, tRadarOnly = {}, {}
    for _, oUnit in tEnemies do
        if HasTeamSeenUnitVisually(oUnit, iTeam) then
            table.insert(tVisual, oUnit)
        else
            table.insert(tRadarOnly, oUnit)
        end
    end
    return tVisual, tRadarOnly
end
```

Alle Consumer rufen diese Helpers statt direkt `EntityCategoryContains(...)`, `oUnit[refiUnitMassCost]`, `oUnit:GetMaxHealth()` zu lesen.

### Generic-Defaults (Tuning-Konstanten)

Zentrale Konstanten in M28UnitInfo.lua, damit ein einziger Ort getuned werden kann:

```lua
refiRadarBlipDefaultMassCost = 1000      -- Targeting-Priority
refiRadarBlipDefaultHealth = 1000        -- Targeting-Priority
refiRadarBlipDefaultThreatLand = 50      -- Threat-Counter
refiRadarBlipDefaultThreatAir = 50
refiRadarBlipDefaultThreatNavy = 50
refiRadarBlipDefaultThreatStructure = 100
```

## Implementation Stages

Jede Stage ist eigenständig committbar und testbar. Bei Regressionen kann revertiert werden ohne nachfolgende Stages zu verlieren.

### Stage A — Foundation + Target-Selection

**Scope:** Tag-Mechanik + Helper + Long-Range Target-Picker.

**Files:**
- `M28UnitInfo.lua` — neue Helper-Funktionen, neue Konstanten, neuer Tag-Slot
- `M28Events.lua` — `OnDetectedBy` (Z.3397) setzt Visibility-Tag wenn `oBlip:IsSeenEver()` true
- `M28Team.lua` — neuer Refresh-Job (Tick alle 5s)
- `M28Logic.lua` — `GetDamageFromBomb` (Z.489) nutzt Visibility-Helpers für Mass-Cost/Health-Reads und Category-Filter
- `M28Building.lua`:
  - `GetT3ArtiTarget` / `GetBestUnitTargetAndValueInZone` (Z.3239-3597)
  - `ConsiderLaunchingMissile` (Z.1930)
- `M28Air.lua` — `AssignTorpOrBomberTargets` (Z.7044)

**Acceptance:**
- Mavor/Czar im FoW wird nicht bevorzugt von T3-Arti / Game-Endern beschossen.
- TML/SML zielen auf AOE-Wert, nicht auf BP-Kategorie der Radar-Blips.
- T3-Bomber bombardieren keine spezifischen High-Value-Strukturen im FoW.

### Stage B — Threat-Assessment

**Scope:** Per-Zone-Threat-Counter respektieren Vision. Radar-Blips tragen Flat-Threat statt BP-Kategorie-spezifischer Werte.

**Files:**
- `M28Map.lua` — Stellen wo `subrefLZThreatEnemyCombatTotal`, `subrefLZTThreatEnemyAA`, `subrefTEnemyAirThreatTotal`, `subrefLZThreatEnemyStructure` etc. aufgebaut werden. Die Funktionen iterieren `subrefTEnemyUnits` und summieren BP-abhängige Threat-Werte → Helper-Replacement.
- `M28Team.lua` — Team-weite Threat-Aggregation. `refiEnemyHighestMobileLandHealth` (Z.3428): nur visuell bestätigte Units zählen für Max-Health-Tracking.
- `M28Logic.lua` — eventuelle Threat-Berechnungs-Hilfsfunktionen.

**Subtle case:** `refbHaveSeenUnitByTeam` wird in M28Events.lua:3424 für Land-Combat-Max-Health-Tracking genutzt. Schon eingebaut für „first sighting" — aber für Radar-only-Sightings würde der Code Mass-Cost lesen. Patch: `HasTeamSeenUnitVisually` statt `refbHaveSeenUnitByTeam` als Gate verwenden.

**Acceptance:**
- M28 baut keine 8 MAA preventiv weil 8 Radar-Blips ungeklärter Air-Threats existieren.
- ASF-Production reagiert nicht auf Radar-only-Strat-Bomber-Schwärme.
- T3-Transition-Trigger ignoriert Radar-blip Tech-Levels.

### Stage C — Defensive Reactions (TMD/SMD/Shield)

**Scope:** Verteidigungs-Strukturen werden nur als Reaktion auf visuell bestätigte Bedrohungen gebaut.

**Files:**
- `M28Building.lua`:
  - TMD-Construction-Logik: identifiziere die Funktion(en) die enemy TML detection auswerten. Vorgehen: grep nach `refCategoryTML`, `refCategoryFixedT2Arti`, BuildTMD-Funktionen. Patch: Vision-Gate vor Category-Check.
  - SMD-Trigger: analog für `refCategorySML`.
  - `ConsiderLargeShieldBuild` (von uns selbst hinzugefügt, siehe CLAUDE.md Tasks): Vision-Gate für Enemy-GE-Detection.
- `M28Air.lua` — ASF-Production: gebunden an Threat-Counter aus Stage B, somit indirekt schon abgedeckt. Aber spezifische ASF-Trigger (z.B. „enemy hat Czar") brauchen Vision-Gate.

**Acceptance:**
- M28 baut kein TMD-Cluster wenn Enemy nur Radar-Blip-T2-Arti hat (Spieler wüsste nicht ob es Arti oder Storage ist).
- SMD wird erst nach LOS-Confirmation der enemy SML errichtet.
- Large-Shield-Placement reagiert nicht auf Radar-only enemy GE-Bau.

### Stage D — Strategic Awareness

**Scope:** ACU-Tracking, Game-Ender-Response, Naval-Threat-Assessment erfordern Vision.

**Files:**
- `M28UnitInfo.lua` — `reftLastKnownPositionByTeam` (existing pattern): erweitern, sodass Position nur dann als „bekannt" gilt wenn jemals visuell bestätigt. Reine Radar-Last-Position bleibt aber für Targeting nutzbar (siehe B1-Definition).
- `M28ACU.lua` — Enemy-ACU-Tracking. Identifiziere wo M28 die enemy-ACU-Lua-Referenz konsultiert. Patch: Vision-Gate.
- `M28Overseer.lua` — Game-Ender-Response-Trigger. Patch.
- `M28Navy.lua` — Enemy-Sub-Count, Enemy-Carrier-Count via Sonar. Patch: nur Sonar-LOS zählt (Sonar ist effektiv Vision für Unterwasser-Ziele, da Sonar `IsSeenEver` setzt — verifizieren).

**Acceptance:**
- M28 reagiert nicht sofort auf Mavor-Bau eines unaufgedeckten Gegners.
- ACU-Snipe-Versuche per TML/SML werden erst gestartet wenn ACU visuell bestätigt.

### Stage E — Scout-Priority (positive Konsequenz)

**Scope:** Naturliche Folge der vorherigen Stages — M28 hat plötzlich Informations-Defizite und sollte mehr scouten.

**Files:**
- `M28Air.lua` — Air-Scout-Target-Priority. Aktuell entfernt M28 Blips aus der Priority-Liste sobald irgendein Intel existiert. Patch: entfernen erst bei Vision-Confirmation.
- `M28Engineer.lua` — Engineer-Scouts: erhöhe Priority von Scout-Builds in early Game weil M28 ohne Vision blind ist.

**Acceptance:**
- Air-Scouts werden aktiv zu unbestätigten Radar-Blips geschickt.
- Mehr T1-Land/Air-Scout-Production in den ersten 5 Minuten.

## Performance Considerations

- **Refresh-Job:** O(tracked_enemies × teams_with_M28). Bei 200 Enemies und 2 Teams = 400 `CanSeeUnit`-Calls alle 5s → vernachlässigbar.
- **Helper-Calls in Hot Paths:** `GetDamageFromBomb` läuft pro Bomb-Test einmal pro Enemy. Helpers sind O(1)-Tag-Reads. Kein nennenswerter Overhead.
- **Caching pro Tick:** Wenn dieselbe Unit in derselben Funktion mehrfach geprüft wird, lokale Variable nutzen statt Helper mehrfach aufrufen.
- **Refresh-Job-Optimization:** Units mit `oUnit.Dead` aus Tracking entfernen damit die Liste nicht endlos wächst (existiert vermutlich schon via `OnKilled`, prüfen).

## Verification Plan

**Pro Stage:** mindestens 2 Test-Matches mit folgendem Pattern:

- Map: mittelgroß (10×10 oder 20×20), unterschiedliche Start-Distanzen.
- Mod-Stack: Standard (Total Mayhem + BlackOps Merged + BlackOps ACUs Enhanced + Shields Enhanced + Savers).
- Konfiguration: M28-Brain vs M28-Brain (selbe Bedingungen für beide Seiten).
- Log-Check: `M28ERROR` und `M28Warning` in `game_*.log` post-game — keine neuen Einträge.

**Stage-spezifisch:**
- **Stage A:** Manuell überprüfen via UI-Camera (während M28 spielt) ob T3-Arti gezielt auf Radar-blip Mavor schießt oder nicht.
- **Stage B:** MAA/ASF/Threat-Reaction-Timing beobachten — werden Defense-Strukturen erst nach LOS gebaut?
- **Stage C:** TMD/SMD Bau-Trigger gegen unaufgedeckten Enemy-TML/SML — verzögert sich der Bau?
- **Stage D:** ACU-Snipe gegen unaufgedeckten ACU — wird verzögert? Game-Ender-Response auf unaufgedeckten Mavor — passiert nicht?
- **Stage E:** Scout-Aktivität in den ersten 5 Min — wird sie erhöht?

**Regression-Risiko-Marker:** M28 verliert in Test-Match gegen Vorgänger-Version mit großem Margin → Tuning der `refiRadarBlipDefault*`-Konstanten erforderlich.

## Risks

1. **Balance-Degradation:** M28 wird signifikant schwächer als Upstream. Tuning-Iteration nötig (Konstanten pro Stage). Kein Showstopper, aber Aufwand.
2. **Divergenz von Upstream M28:** Künftige maudlin27-Merges werden schwieriger. Mitigation: jede Stage als separater Commit mit klarer Begründung; Merge-Konflikt-Workflow akzeptieren.
3. **Übersehene BP-Reads:** Eine vergessene Stelle wo BP-Info direkt gelesen wird = inkonsistente Halb-Lösung. Mitigation: pro Stage Grep nach `EntityCategoryContains.*oUnit.UnitId`, `oUnit[refiUnitMassCost]`, `oUnit:GetMaxHealth()` in den Stage-Files; manueller Code-Review jedes Treffers.
4. **Sonar vs. Vision-Semantik (Stage D Naval):** Sonar setzt `IsSeenEver` für Unterwasser-Ziele → check ob das ausreicht oder ob explizite Vision-Confirmation für naval gewollt ist. Wahrscheinlich Sonar = OK weil im FAF-Spielerverhalten Sonar auch Identifikation gibt.
5. **Performance bei sehr vielen Enemies:** Bei extremen Stack-Counts (>500 Enemies) könnte Refresh-Job spürbar werden. Mitigation: Refresh-Intervall auf 10s erhöhen falls nötig.
6. **`bIncludePreviouslySeenEnemies`-Pfade:** Wenn eine Unit *einmal* visuell bestätigt war und später wieder ins FoW geht, soll BP-Wissen erhalten bleiben (das ist fair). Tag bleibt `true` — keine Logik nötig die Tag wieder auf `false` setzt. **Tag ist sticky once true.**

## CHANGELOG-Entry (player-facing, pro Stage einer)

- Stage A: „M28 long-range weapons no longer prioritise specific enemy structures detected by radar only — they treat unconfirmed radar contacts as generic targets."
- Stage B: „M28 threat assessment now requires visual confirmation to identify enemy unit types; radar-only contacts contribute generic threat values."
- Stage C: „M28 builds anti-missile and anti-nuke defences only after visually confirming the corresponding enemy threat."
- Stage D: „M28's strategic responses (ACU snipes, game-ender counters) now require visual confirmation of the target."
- Stage E: „M28 sends scouts more aggressively to investigate unconfirmed radar contacts."

## Open Questions (vor Implementierungs-Start klären)

1. **Generic-Default-Werte initial:** 1000 Massekosten, 1000 Health, 50 Threat — sinnvoll oder anders kalibrieren?
2. **Sonar-Behandlung:** Wird Sonar als „Vision für Wasserziele" behandelt oder explizit als Radar-Äquivalent (kein BP-Info)? FAF-Konvention: Spieler sehen Sonar-Kontakte als „Sub-shape" → BP-Erkennung ist möglich.
3. **Reihenfolge der Stages:** A→B→C→D→E oder anders? A muss erst (Foundation). B macht Sinn vor C (Threat-Counter werden in Defensive-Logic genutzt). D vor oder nach E unkritisch.
4. **Scope-Schnitt:** Welche Stages willst du jetzt machen, welche später / nie? Stage A allein liefert schon den größten Effekt für „T3-Arti-Cheat".
