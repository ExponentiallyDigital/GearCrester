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

## 3. Track Detection Fallback

**Scenario:** HERO shoulder with bonus IDs `{6652, 13577, 12794}` (canonical HERO ID 12700 absent)

**Command:**

```
/gc debug on
/gc dump
```

**Expected Debug Output:**

```
[DEBUG] Track=CHAMPION found but rank missing - running rank-id fallback
[DEBUG] FALLBACK: Inferred HERO track rank 4 from 1 rank bonus ID(s): 12794
```

**Verification:**

- Shoulder shows `track=HERO rank=4`
- `/gc 40 hero` lists the shoulder as upgradeable
- Items with canonical track IDs still use canonical detection (no fallback)

---

## 4. Mixed Marker Inference

**Scenario:** Item with CHAMPION track markers but HERO rank marker

- Bonus IDs: `{6652, 13577, 12794}`
- 6652, 13577 are in CHAMPION's TRACK_BONUS_IDS
- 12794 is HERO rank 4 bonus ID

**Command:**

```
/gc debug on
/gc dump
```

**Expected Debug Output:**

```
[DEBUG] Track=CHAMPION found but rank missing - running rank-id fallback
[DEBUG] FALLBACK: Inferred HERO track rank 4 from 1 rank bonus ID(s): 12794
```

**Verification:**

- Shoulder shows `track=HERO rank=4`
- Rank ID inference takes precedence over track marker when rank detection fails
- `/gc 40 hero` lists the shoulder as upgradeable

---

## 5. Regression Checks

- SelfTest must not modify SavedVariables.
- SelfTest must not change upgrade results.
- SelfTest must not require UI.

---

# End of Test Plan
