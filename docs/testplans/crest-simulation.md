# GearCrester Test Plan — Crest Simulation

This test plan validates crest simulation logic and integration with AdvisorCore.

---

## 1. Basic Simulation

/gc 40 champion

Expected:

- Title shows:
  (Simulated: 40 CHAMPION)

- Results reflect simulated crest availability.
- **Crest cost displayed is TOTAL path cost** (e.g., 2 steps = x40, not x20)

**Example correct output:**

```
Legs: 253 -> 263 (CHAMPION x40)
Waist: 250 -> 256 (CHAMPION x20)
```

---

## 2. High Crest Simulation

/gc 100 champion

Expected:

- Items show maximum affordable upgrade steps
- 5-step upgrades show `(CHAMPION x100)`
- Crest cost matches `upgradeSteps * 20`

---

## 2b. HERO Track Simulation

/gc 40 hero

Expected:

- HERO track items show upgrade paths affordable with 40 crests
- 2-step upgrades show `(HERO x40)`
- 1-step upgrades show `(HERO x20)`
- Crest cost displayed is **total path cost**, not per-step cost
- Track detection uses bonus ID 12700
- Rank detection uses bonus IDs 12791-12796

**Example:**

```
Head: 263 -> 269 (HERO x40)
Chest: 266 -> 269 (HERO x20)
```

/gc 60 hero

Expected:

- 3-step upgrades show `(HERO x60)`
- ILvl progression follows HERO track table (259→263→266→269)

---

## 3. Invalid Crest Type

/gc 40 murloc

Expected:
Invalid crest type. Valid types: ADVENTURER, VETERAN, CHAMPION, HERO, MYTH

---

## 4. UI Simulation

/gc ui 40 champion

Expected:

- UI frame opens.
- Results displayed inside frame.
- **Crest costs show total path cost** (2 steps = x40)
- No Lua errors.

---

## 5. Regression Checks

- Gold‑only items still show `[GOLD-ONLY]`.
- Sorting still respects UpgradeOrder.
- Weighting overrides still apply.
- Simulation must not modify actual crest totals.

---

# End of Test Plan
