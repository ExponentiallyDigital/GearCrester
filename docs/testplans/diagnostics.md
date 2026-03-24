# GearCrester Test Plan — Diagnostics & Self‑Test

This test plan validates the Diagnostics subsystem and `/gc test`.

---

## 1. Run Self‑Test

/gc test

Expected:

- All diagnostic tests run.
- Clear pass/fail output.
- No Lua errors.

---

## 2. Debug Mode

/gc debug on
/gc

Expected:

- Debug messages printed.
- No missing module errors.

---

## 3. Regression Checks

- SelfTest must not modify SavedVariables.
- SelfTest must not change upgrade results.
- SelfTest must not require UI.

---

# End of Test Plan
