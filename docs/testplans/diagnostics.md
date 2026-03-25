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

## 6. Calibration Helper

**Purpose:** Compare GearCrester's track/rank detection against Blizzard's official upgrade API.

**Command:**

```
/gc calibrate [slotName]
```

**Default:** Head slot if no slot specified.

**Expected Output:**

```
[CALIBRATE] Head
  Bonus IDs: 6652, 13577, 12793
  GearCrester: track=HERO rank=3
  Blizzard:    track=HERO rank=1
  [MISMATCH] GC and Blizzard disagree
```

**Verification:**

- If MISMATCH shown, report bonus IDs and both rank values for data table adjustment
- If OK shown, detection matches Blizzard's data
- Use to calibrate HERO tier item rank mappings

---

## 7. Blizzard API Integration

**Purpose:** Verify GearCrester uses Blizzard's C_Item.GetItemUpgradeInfo() API as primary detection source.

**Command:**

```
/gc test
```

**Expected Test Results:**

- `TestBlizzardAPIIntegration` - [OK] - Verifies API integration logic exists
- `TestBlizzardAPIFallback` - [OK] - Verifies bonus-ID fallback works when API unavailable
- `TestCalibrateUsesBlizzardAPI` - [OK] - Verifies calibrate command uses correct API

**Verification:**

- `/gc debug on; /gc dump` should show "Blizzard API: track=HERO rank=1" for tier items
- When API unavailable, should show "Blizzard API unavailable, using bonus-ID detection"
- Fallback must preserve existing bonus-ID detection for legacy items

---

## 8. Calibrate Command

**Purpose:** Compare GearCrester's detection against Blizzard's authoritative API for a specific slot.

**Command:**

```
/gc calibrate <slot>
```

**Example:**

```
/gc calibrate head
```

**Expected Output:**

```
[CALIBRATE] Head
  Bonus IDs: 6652, 13577, 12793
  GearCrester: track=HERO rank=1
  Blizzard:    track=HERO rank=1
  [OK] Match
```

**Verification:**

- Should use C_Item.GetItemUpgradeInfo() (not deprecated GetItemUpgradeItemInfo)
- Should show "Blizzard: no upgrade data available" if API returns nil
- Should show [OK] or [MISMATCH] based on comparison

---

## 9. Regression Checks

- SelfTest must not modify SavedVariables.
- SelfTest must not change upgrade results.
- SelfTest must not require UI.

---

## 10. Crest Inventory

**Purpose:** Verify GearCrester reads real crest inventory from Blizzard's currency API.

**Command:**

```
/gc crests
```

**Expected Output:**

```
GearCrester: Current Crest Inventory
  Adventurer: 110
  Veteran:    400
  Champion:    55
  Hero:        85
  Myth:         0
```

**Verification:**

- `/gc` without simulation should use real crest counts
- `/gc 80 hero` should show same upgrades as real inventory when Hero crests = 80
- SelfTest includes TestCrestInventoryLookup, TestUpgradeEvaluationUsesRealCrests, TestSlashCrestsCommandExists

---

# End of Test Plan
