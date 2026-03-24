# GearCrester Test Plan — Export System

This test plan validates the export subsystem and SavedVariables output.

---

## 1. Basic Export

/gc export

Expected:

- Confirmation message:
  Export complete. File will be written on logout.

---

## 2. Crest Simulation Export

/gc export 40 champion

Expected:

- Export runs using simulated crest data.
- No Lua errors.

---

## 3. Validate SavedVariables

Logout, then open:
WTF/Account/<account>/SavedVariables/GearCrester.lua

Expected:

- `GearCresterExportDB` contains structured data.
- No nil values.
- No malformed tables.
- No unexpected keys.

---

## 4. Regression Checks

- `/gc export` must not modify slot weights.
- Export must not affect upgrade recommendations.
- Export must not require UI.

---

# End of Test Plan
