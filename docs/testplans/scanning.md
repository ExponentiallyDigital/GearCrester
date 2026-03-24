# GearCrester Test Plan — Inventory Scanning (Equipped, Bags, Bank)

This test plan validates the scanning subsystem.
Note: Bag/bank scanning may be stubbed depending on development stage.

---

## 1. Equipped Scanning

### 1.1 Change equipped gear

Equip a different item.

### 1.2 Run:

/gc

Expected:

- The new item appears in results.
- No Lua errors.

---

## 2. Bag Scanning

### 2.1 Move an item between bag slots

Expected:

- No errors.
- `/gc` still works.

### 2.2 Add/remove upgradeable items from bags

Expected:

- Items appear/disappear from results once scanning is implemented.

---

## 3. Bank Scanning

### 3.1 Open your bank

Expected:

- No errors.

### 3.2 Move items in bank

Expected:

- No errors.

### 3.3 Gold‑only detection

If a higher‑rank item is in the bank:

- `/gc` must show `[GOLD-ONLY]`.

---

## 4. Regression Checks

- No duplicate items.
- No nil entries in DataModel tables.
- Debug mode shows scanning events firing.

---

# End of Test Plan
