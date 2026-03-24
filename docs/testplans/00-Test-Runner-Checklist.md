# GearCrester — Master Test Runner Checklist

This checklist validates a full GearCrester build.
Use it after any code change, feature addition, or Qwen-generated update.

---

# 1. Addon Load & Initialization

- [ ] Log in — no Lua errors
- [ ] Version string prints correctly
- [ ] `/gc help` lists all commands
- [ ] SavedVariables initialize correctly
- [ ] `/gc weight list` shows defaults

---

# 2. Core Upgrade Functionality

## 2.1 Basic Recommendations

- [ ] Equip at least 3 upgradeable items
- [ ] Run `/gc`
- [ ] Output appears with:
    - Slot name
    - Current ilvl → next ilvl
    - Crest type + cost
    - Location tag (Equipped/Bag/Bank)

## 2.2 Sorting

- [ ] Weapons appear first
- [ ] Trinkets appear last
- [ ] Change a weight:
      /gc weight Trinket1 1
      /gc

- [ ] Trinket1 now appears at the top

## 2.3 Weight Reset

- [ ] `/gc weight reset`
- [ ] `/gc weight list` shows all defaults

---

# 3. Gold‑Only Upgrade Detection

## Setup:

- Equip a **lower‑rank** item (e.g., 2/6 Champion)
- Put a **higher‑rank** same‑track item in **bank** (e.g., 6/6 Champion)

## Test:

- [ ] Run `/gc`
- [ ] Lower‑rank item shows:
      [GOLD-ONLY] (to rank 6)

- [ ] Crest cost for gold-only steps is 0
- [ ] Sorting still respects priorities

---

# 4. Crest Simulation

## 4.1 Basic Simulation

- [ ] `/gc 40 champion`
- [ ] Title shows:
      (Simulated: 40 CHAMPION)
- [ ] **Crest costs show TOTAL path cost** (2 steps = x40, not x20)
- [ ] Example: `Legs: 253 -> 263 (CHAMPION x40)`

## 4.2 High Crest Simulation

- [ ] `/gc 100 champion`
- [ ] 5-step upgrades show `(CHAMPION x100)`
- [ ] Crest cost = `upgradeSteps * 20`

## 4.3 Invalid Crest Type

- [ ] `/gc 40 banana`
- [ ] Error message appears

## 4.4 UI Simulation

- [ ] `/gc ui 40 champion`
- [ ] UI frame opens and displays results
- [ ] UI shows **total crest costs** (not per-step)

---

# 5. Scanning (Equipped, Bags, Bank)

## 5.1 Equipped

- [ ] Equip a new item
- [ ] `/gc` reflects the change

## 5.2 Bags

- [ ] Move an item between bag slots
- [ ] `/gc` still works
- [ ] No errors

## 5.3 Bank

- [ ] Open bank
- [ ] Move items in bank
- [ ] `/gc` still works
- [ ] Gold-only detection works with bank items

---

# 6. UI

- [ ] `/gc ui` toggles the frame
- [ ] Frame displays results
- [ ] No UI errors
- [ ] Debug mode does not break UI

---

# 7. Export System

## 7.1 Basic Export

- [ ] `/gc export`
- [ ] Confirmation message appears

## 7.2 Crest Simulation Export

- [ ] `/gc export 40 champion`
- [ ] No errors

## 7.3 SavedVariables

- [ ] Logout
- [ ] Inspect `GearCresterExportDB`
- [ ] No nils or malformed tables

---

# 8. Diagnostics

- [ ] `/gc test` runs all diagnostics
- [ ] All subsystems pass
- [ ] No Lua errors

---

# 9. Debug Mode

- [ ] `/gc debug on`
- [ ] `/gc` prints debug lines
- [ ] No missing module errors

---

# 10. Regression Checks

- [ ] No Lua errors in chat
- [ ] No missing modules
- [ ] No broken slash commands
- [ ] No unexpected SavedVariables changes

---

# End of Checklist
