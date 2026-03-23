# Upgrade Advisor Specification

This document defines the logic, data requirements, and evaluation flow for the
Upgrade Advisor module. It is the authoritative reference for how upgrade
recommendations are computed.

---

## Module Responsibilities

### AdvisorCore

- Public API for the Upgrade Advisor
- Exposes `GetRecommendedUpgrades()`
- Coordinates with:
    - InventoryScanner
    - CrestTracker
    - AdvisorLogic
    - AdvisorData

### AdvisorLogic

- Performs upgrade evaluation
- Applies slot priority
- Sorts results
- Returns structured upgrade list

### AdvisorData

- Static data tables:
    - slot priorities
    - crest cost tables
    - upgrade track mappings
    - rank → ilvl tables

---

## Upgrade Evaluation Flow

1. **Input**
    - Equipped items from `GC.DataModel.equipped`
    - Crest counts from `GC.DataModel.crests`

2. **For each item**
    - Determine upgrade track (Adventurer, Veteran, Champion, Hero, Myth)
    - Determine current rank
    - Determine next rank
    - Determine next ilvl
    - Determine crest type required
    - Determine crest cost
    - Determine if player has enough crests

3. **Filtering**
    - Exclude items that:
        - cannot be upgraded
        - are at max rank
        - require crests the player does not have

4. **Priority Assignment**
    - Use `AdvisorData.SLOT_PRIORITY[slotID]`
    - Lower number = higher priority

5. **Sorting**
    - Sort by:
        1. slot priority
        2. crest efficiency (future)
        3. ilvl delta (future)

6. **Output**
    - A list of upgrade entries:
        ```
        {
          slot = "MainHand",
          link = itemLink,
          currentIlvl = 476,
          nextIlvl = 480,
          crestType = "Hero",
          crestCost = 2,
          priority = 1
        }
        ```

---

## Data Requirements

### Slot Priority Table

- Weapons first
- Tier slots next
- Mid slots
- Rings
- Trinkets

### Crest Cost Table

- Rank → crest cost
- Track → crest type

### Ilvl Table

- Track + rank → ilvl

---

## Non‑Goals

- No stat weighting
- No performance simulation
- No BIS evaluation
- No AMR/Pawn overlap

The Upgrade Advisor focuses solely on upgradeability and crest usage.
