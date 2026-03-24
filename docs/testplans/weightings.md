# GearCrester Test Plan — Upgrade Order, Weighting, and Gold‑Only Logic

This test plan validates all functionality related to:

- Upgrade order sorting
- User‑defined slot weighting (1–20)
- Gold‑only upgrade detection
- Crest simulation
- Slash commands
- SavedVariables initialization
- Event‑driven scanning
- InventoryOverview data layer

Run this test plan after any change to:

- AdvisorCore sorting
- UpgradeOrder module
- FreeUpgrade module
- Slash command handling
- SavedVariables structure
- InventoryOverview

---

## 1. Addon Load

### 1.1 Login

Expected:
GearCrester vX.Y.Z: GearCrester loaded...

### 1.2 No Lua errors

---

## 2. SavedVariables Initialization

### 2.1 Run:

/gc weight list

Expected:

- All slots listed
- All marked **default**
- No errors

---

## 3. Weighting System

### 3.1 Set a weight

/gc weight Chest 1

Expected:
`Set Chest weight to 1.`

### 3.2 Verify

/gc weight list

Expected:

- Chest = 1 (custom)

### 3.3 Invalid weight

/gc weight Chest 21

Expected:
`Weight must be between 1 and 20.`

### 3.4 Invalid slot

/gc weight Banana 5

Expected:
`Unknown slot name.`

### 3.5 Reset

/gc weight reset

Expected:
`All slot weights reset to default.`

---

## 4. Upgrade Order Sorting

### 4.1 Equip several Champion items

### 4.2 Run:

/gc

Expected:

- Sorted by slot priority
- Weapons first, trinkets last (unless overridden)

### 4.3 Override priority

/gc weight Trinket1 1
/gc

Expected:

- Trinket1 appears first

---

## 5. Gold‑Only Upgrade Detection

### Setup:

- Equip a lower‑rank Champion item (e.g., 2/6)
- Put a higher‑rank same‑track item in bank (e.g., 6/6)

### 5.1 Run:

/gc

Expected:

- Lower‑rank item shows:
  [GOLD-ONLY] (to rank 6)

Code

---

## 6. Crest Simulation

### 6.1 Run:

/gc 40 champion

Expected:

- Title shows simulated crest count
- Sorting still correct
- Gold‑only markers still appear

---

## 7. InventoryOverview Data Layer

### 7.1 Enable debug

/gc debug on

### 7.2 Run:

/gc

Expected debug:
[DEBUG] GetRecommendedUpgrades called
[DEBUG] Scanning: equipped=yes bags=yes bank=yes

### 7.3 InventoryOverview output

Expected:
InventoryOverview: collected X equipped, 0 bags, 0 bank, 0 warbank

---

## 8. Slash Commands

### 8.1 Help

/gc help

Expected:

- All new commands listed

### 8.2 Dump

/gc dump

### 8.3 Why

/gc why

### 8.4 Test

/gc test

---

## 9. Export System Regression

### 9.1 Run:

/gc export

### 9.2 Logout and inspect SavedVariables

Expected:

- Export table present
- No nils or malformed entries

---

## 10. Event‑Driven Scanning

### 10.1 Change gear

Expected: `/gc` reflects new item

### 10.2 Move items in bags

Expected: no errors

### 10.3 Open bank

Expected: no errors

---

# End of Test Plan
