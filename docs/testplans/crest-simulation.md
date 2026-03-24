# GearCrester Test Plan — Crest Simulation

This test plan validates crest simulation logic and integration with AdvisorCore.

---

## 1. Basic Simulation

/gc 40 champion

Expected:

- Title shows:
  (Simulated: 40 CHAMPION)

- Results reflect simulated crest availability.

---

## 2. Invalid Crest Type

/gc 40 murloc

Expected:
Invalid crest type. Valid types: ADVENTURER, VETERAN, CHAMPION, HERO, MYTH

---

## 3. UI Simulation

/gc ui 40 champion

Expected:

- UI frame opens.
- Results displayed inside frame.
- No Lua errors.

---

## 4. Regression Checks

- Gold‑only items still show `[GOLD-ONLY]`.
- Sorting still respects UpgradeOrder.
- Weighting overrides still apply.
- Simulation must not modify actual crest totals.

---

# End of Test Plan
