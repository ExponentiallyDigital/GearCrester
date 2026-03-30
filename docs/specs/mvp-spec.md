# GearCrester MVP Specification

This document defines the minimum viable product for GearCrester. The goal is
to produce a working in‑game addon that evaluates upgradeability for equipped
items only and prints recommendations to chat.

---

## MVP Scope

### In Scope (✅ COMPLETE)

- Equipped gear scanning
- Crest currency reading
- Upgradeability evaluation
- Slot priority ordering
- Crest cost lookup
- Chat‑based output
- Slash command `/gc`
- Bags and bank scanning ✅
- UI frames (Dashboard + MainFrame) ✅
- Simulation mode ✅
- Gold-only upgrade detection ✅

### Out of Scope (Future Phases)

- Weekly/seasonal caps tracking
- Reset timer
- Tier rollover logic automation
- Crest efficiency score
- Visual heatmap UI

---

## MVP Data Flow

1. **ScannerEquipped**
    - Reads equipped items
    - Populates `GC.DataModel.equipped`

2. **CrestData**
    - Reads crest currency counts
    - Populates `GC.DataModel.crests`

3. **AdvisorData**
    - Provides:
        - slot priorities
        - crest cost tables
        - upgrade track mappings

4. **AdvisorLogic**
    - For each equipped item:
        - Determine upgrade track
        - Determine current rank
        - Determine next rank
        - Determine crest type required
        - Determine crest cost
        - Determine next ilvl
    - Apply slot priority
    - Sort results

5. **AdvisorCore**
    - Exposes `GetRecommendedUpgrades()`
    - Returns sorted upgrade list

6. **Slash Command**
    - `/gc` prints upgrade recommendations to chat

---

## MVP Output Format

Example:

GearCrester Upgrade Recommendations:
MainHand: 476 -> 480 (Hero Crest x2)
Head: 470 -> 473 (Veteran Crest x1)
Chest: 470 -> 473 (Veteran Crest x1)

---

## MVP Success Criteria

- Addon loads without errors
- `/gc` prints a sorted list of upgradeable equipped items
- Crest costs and types are correct
- Slot priority is respected
- No UI required
