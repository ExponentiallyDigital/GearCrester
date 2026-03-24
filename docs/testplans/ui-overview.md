# GearCrester Test Plan — InventoryOverview Data Layer

This test plan validates the InventoryOverview module, which collects item data for future UI use.

---

## 1. Enable Debug Mode

/gc debug on

Expected:

- Debug mode enabled message.

---

## 2. Trigger a Scan

/gc

Expected debug output:
[DEBUG] GetRecommendedUpgrades called
[DEBUG] Scanning: equipped=yes bags=yes bank=yes

---

## 3. Validate InventoryOverview Output

Expected:
InventoryOverview: collected X equipped, 0 bags, 0 bank, 0 warbank

Notes:

- Bag/bank/warbank counts may be 0 because scanning is not implemented yet.
- No Lua errors should occur.

---

## 4. Validate Item Data Structure

Each item entry must include:

- Slot
- slotID
- ItemLink
- Track
- Rank
- CurrentILvl
- UpgradeSteps
- CrestCostPerStep
- TotalCrestCost
- isGoldOnly (optional)

---

## 5. Regression Checks

- No UI frames should appear (UI not implemented yet).
- No errors when opening bank or moving items.
- `/gc ui` should toggle the existing MainFrame without errors.

---

# End of Test Plan
