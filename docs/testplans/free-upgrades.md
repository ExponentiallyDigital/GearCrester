# GearCrester Test Plan — Gold‑Only Upgrade Detection

This test plan validates the FreeUpgrade module and its integration with AdvisorCore.

---

## 1. Setup

1. Equip a **lower‑rank** item of a given track (e.g., 2/6 Champion Chest).
2. Place a **higher‑rank** item of the same track in your **bank** (e.g., 6/6 Champion Chest).
3. Ensure both items are the same track (Adventurer, Veteran, Champion, Hero, Myth).

---

## 2. Run Upgrade Recommendations

/gc

Expected:

- The lower‑rank item appears in the results.
- It includes:
    - `[GOLD-ONLY]`
    - `(to rank X)` where X is the highest rank found in bags/bank.

Example:
Chest: 476 -> 490 (Champion x0) [GOLD-ONLY] (to rank 6)

---

## 3. Crest Simulation

/gc 40 champion

Expected:

- Gold‑only items still show `[GOLD-ONLY]`.
- Crest simulation does **not** consume crests for gold‑only steps.

---

## 4. Regression Checks

- No Lua errors.
- Items without higher‑rank duplicates must **not** show `[GOLD-ONLY]`.
- Items of different tracks must **not** trigger gold‑only detection.
- Sorting must still respect UpgradeOrder priorities.

---

# End of Test Plan
