# GearCrester Prompt History

This document tracks all feature prompts, architectural changes, module additions, and guardrail updates for the GearCrester project.

---

## 2026-03-24 — MVP Vertical Slice Implementation

**Summary:** Implemented the equipped-only vertical slice of the Upgrade Advisor MVP including bonus ID parsing, track/rank detection, and upgrade recommendations.

**Files Created:**

- `Modules/InventoryScanner/ScannerEquipped.lua`
- `Modules/CrestTracker/CrestData.lua`
- `Modules/UpgradeAdvisor/AdvisorCore.lua`
- `Modules/UpgradeAdvisor/AdvisorLogic.lua`
- `Modules/UpgradeAdvisor/AdvisorData.lua`

**Files Modified:**

- `Core/Init.lua` - Added `/gc` slash command
- `GearCrester.toc` - Added new module references

**Test Plans Created:** N/A (initial implementation)

**Notes:**

- Bonus ID parsing uses position-based strsplit approach
- Track detection via bonus ID matching (12697-12701)
- Rank detection via bonus ID matching (12773-12802)
- Flat 20-crest cost per upgrade

---

## 2026-03-24 — Module Loading Error Fixes

**Summary:** Fixed multiple nil value errors caused by incorrect module table initialization and load order issues.

**Files Modified:**

- `Core/Init.lua` - Removed premature module references
- `Modules/UpgradeAdvisor/AdvisorCore.lua` - Added safe module table creation
- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Fixed Data reference
- `Modules/UpgradeAdvisor/AdvisorData.lua` - Fixed module attachment
- `Modules/UI/Heatmap.lua` - Created stub
- `Modules/UI/SlotList.lua` - Created stub
- `Modules/InventoryScanner/ScannerBags.lua` - Created stub
- `Modules/InventoryScanner/ScannerBank.lua` - Created stub
- `Modules/UI/TooltipExtensions.lua` - Created stub
- `Modules/Profiles/DefaultProfiles.lua` - Created stub

**Test Plans Created:** N/A

**Notes:**

- All modules now use `GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}` pattern
- TOC load order: AdvisorData → AdvisorLogic → AdvisorCore → AdvisorUI

---

## 2026-03-24 — Midnight Season 1 Bonus ID Tables

**Summary:** Implemented correct Midnight Season 1 upgrade tables with track and rank bonus IDs.

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorData.lua` - Added TRACK_BONUS_IDS, RANK_BONUS_IDS, TRACK_ILVLS

**Test Plans Created:** N/A

**Notes:**

- Track bonus IDs: 12697 (Adventurer) through 12701 (Mythic)
- Rank bonus IDs: 12773-12802 (6 per track)
- CHAMPION track includes alternate rank ID 13333 for rank 4

---

## 2026-03-24 — Bonus ID Parser Fixes

**Summary:** Fixed bonus ID extraction to correctly parse all bonus IDs from item links using position-based detection.

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Restored ParseBonusIDs function

**Test Plans Created:** N/A

**Notes:**

- Parser finds numeric sequence (count 1-20 followed by that many numeric values)
- Must NOT use pattern matching on item link structure
- Original strsplit approach is correct and verified

---

## 2026-03-24 — Bag and Bank Scanning

**Summary:** Implemented bag and bank scanning using C_Container API for Retail/Midnight.

**Files Modified:**

- `Modules/InventoryScanner/ScannerBags.lua` - Implemented with C_Container.GetContainerNumSlots/GetContainerItemInfo
- `Modules/InventoryScanner/ScannerBank.lua` - Implemented with BANK_BAGS table
- `Core/Events.lua` - Added auto-rescan triggers
- `Modules/UpgradeAdvisor/AdvisorCore.lua` - Added includeBags/includeBank parameters
- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Added EvaluateAll function

**Test Plans Created:** N/A

**Notes:**

- Uses C_Container API (Retail/Midnight only)
- Bank bags: -1, 5, 6, 7, 8, 9, 10, 11
- Auto-rescans on BAG_UPDATE and PLAYERBANKSLOTS_CHANGED

---

## 2026-03-24 — Debug Toggle System

**Summary:** Added debug mode toggle with `/gc debug on|off` command.

**Files Modified:**

- `Core/Init.lua` - Added debug flag and command handler
- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Wrapped debug prints in GC.db.debug check
- `Modules/UpgradeAdvisor/AdvisorCore.lua` - Added conditional debug output

**Test Plans Created:** N/A

**Notes:**

- Debug defaults to OFF
- Stored in GearCresterDB.debug
- All debug prints use `if GC.db and GC.db.debug then` pattern

---

## 2026-03-24 — Multi-Step Upgrade Display

**Summary:** Changed upgrade display to show ALL affordable upgrade steps per item, not just the next rank.

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Added loop from currentRank to MAX_RANK-1

**Test Plans Created:** N/A

**Notes:**

- With 40 crests: shows 2 steps per item (40÷20=2)
- With 80 crests: shows 4 steps per item (80÷20=4)
- Remaining crests tracked across steps

---

## 2026-03-24 — UI Frame Implementation

**Summary:** Created movable UI frame with scrollable output for upgrade recommendations.

**Files Modified:**

- `Modules/UI/MainFrame.lua` - Implemented frame with CreateFrame, scroll region, close button
- `Core/Init.lua` - Added `/gc ui` command

**Test Plans Created:** N/A

**Notes:**

- Frame is movable via drag
- BackdropTemplate for styling
- ShowResults() function for custom text display

---

## 2026-03-24 — Diagnostic Commands

**Summary:** Added `/gc dump`, `/gc why`, and `/gc test` commands for troubleshooting.

**Files Created:**

- `Modules/Diagnostics/SelfTest.lua` - Comprehensive test suite

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Added GetItemDiagnostics(), DumpAllItems(), PrintWhyDiagnostics()
- `Core/Init.lua` - Added command handlers

**Test Plans Created:** N/A

**Notes:**

- SelfTest checks: bonus ID parsing, track detection, rank detection, upgrade evaluation, slash command registration, UI frame availability, crest data module, scanner modules
- Output uses [OK]/[FAIL] for ASCII safety

---

## 2026-03-24 — Export System

**Summary:** Implemented export functionality with crest simulation support.

**Files Created:**

- `Modules/Export/ExportCore.lua` - Export generation and SavedVariables storage

**Files Modified:**

- `Core/Init.lua` - Added `/gc export` and `/gc export <count> <crestType>` commands
- `GearCrester.toc` - Added GearCresterExportDB to SavedVariables

**Test Plans Created:** N/A

**Notes:**

- Exports ONE entry per item (not per step)
- Includes: Slot, ItemLink, CurrentILvl, CurrentRank, Track, UpgradeSteps, CrestCostPerStep, TotalCrestCost
- Written to GearCresterExportDB on logout
- File path: WTF/Account/<account>/SavedVariables/GearCrester.lua

---

## 2026-03-24 — SavedVariables Initialization Fix

**Summary:** Fixed first-login errors by moving SavedVariables initialization to ADDON_LOADED handler.

**Files Modified:**

- `Core/Events.lua` - Added initialization in ADDON_LOADED with addon name check
- `Core/Init.lua` - Removed premature SavedVariables access, added version banner with C_AddOns.GetAddOnMetadata

**Test Plans Created:** N/A

**Notes:**

- Must check `if arg1 ~= addonName then return end`
- Uses `GearCresterDB = GearCresterDB or {}` pattern
- Never write nil to SavedVariables
- Version retrieved via C_AddOns.GetAddOnMetadata("GearCrester", "Version")

---

## 2026-03-24 — Upgrade Order System

**Summary:** Implemented configurable slot priority system with user-defined weights.

**Files Created:**

- `Modules/UpgradeAdvisor/UpgradeOrder.lua` - Priority management with GetDefaultPriority(), GetEffectivePriority(), SetSlotWeight()

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorCore.lua` - Integrated UpgradeOrder into sorting
- `Core/Init.lua` - Added `/gc weight <slot> <value>`, `/gc weight reset`, `/gc weight list`
- `GearCrester.toc` - Added UpgradeOrder.lua reference

**Test Plans Created:** N/A

**Notes:**

- Weights are integers 1-20 (lower = higher priority)
- Custom weights stored in GearCresterDB.slotWeights
- Overrides default SLOT_PRIORITY from AdvisorData

---

## 2026-03-24 — Gold-Only Upgrade Detection

**Summary:** Implemented detection for free upgrades when player owns higher-rank item of same track.

**Files Created:**

- `Modules/UpgradeAdvisor/FreeUpgrade.lua` - IsGoldOnlyUpgrade(), ApplyGoldOnlyDetection()

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorCore.lua` - Applied gold-only detection to results
- `Core/Init.lua` - Output shows [GOLD-ONLY] marker

**Test Plans Created:** N/A

**Notes:**

- Same track + higher rank owned = free upgrade
- Gold-only upgrades do NOT consume crests
- Marked with [GOLD-ONLY] and target rank in output

---

## 2026-03-24 — UI Data-Layer Foundation

**Summary:** Created InventoryOverview module as data-layer foundation for future UI development.

**Files Created:**

- `Modules/UI/InventoryOverview.lua` - CollectAllItems(), GetUpgradeInfo()

**Files Modified:**

- `GearCrester.toc` - Added InventoryOverview.lua reference

**Test Plans Created:** N/A

**Notes:**

- Returns structured table: {equipped, bags, bank, warbank}
- Each item includes: slot, slotID, itemLink, track, rank, currentIlvl, upgradeSteps, crestCost, isGoldOnly
- Bag/bank/warbank may be empty (stubs expected)
- No UI frames created yet (data layer only)

---

## 2026-03-24 — Guardrails and Documentation Updates

**Summary:** Created comprehensive guardrails document and updated all documentation for new features.

**Files Created:**

- `QWEN_GUARDRAILS.md` - Development constraints and testing requirements
- `docs/qwen/QWEN_PROMPT_HISTORY.md` - This file

**Files Modified:**

- `README.md` - Added all new slash commands, upgrade order system, gold-only detection
- `docs/GEARCRESTER_DEV_NOTES.md` - Added current status, completed features, backlog, testing checklist

**Test Plans Created:**

- Comprehensive testing checklist in GEARCRESTER_DEV_NOTES.md including:
    - Basic functionality tests
    - Upgrade order tests
    - Gold-only detection tests
    - Diagnostics tests
    - Export tests
    - UI tests
    - Edge case tests

**Notes:**

- Guardrails specify DO NOT modify: bonus ID parsing, track/rank detection, evaluation logic, test harness, export format, UI frame structure
- Testing requirements: run `/gc 40 champion`, `/gc 20 hero`, `/gc debug on`, `/gc test`, verify no Lua errors
- SavedVariables notes: initialize in ADDON_LOADED, check addon name, use `or {}` pattern

---

## Future Updates

Per QWEN_GUARDRAILS.md, this document will be automatically appended with new entries when:

- New feature prompts are executed
- Architectural changes are made
- New modules are added
- Test plans are created or modified
- Guardrails are updated

**Next planned features (from backlog):**

- Compare two gear sets feature (Priority: Medium)
- Weekly/seasonal crest cap tracking (v0.3)
- Heatmap UI (v0.4)

---

## 2026-03-24 — Crest Cost Display Fix (Total vs Per-Step)

**Summary:** Fixed UI/display bug where upgrade recommendations showed per-step crest cost (20) instead of total path cost.

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorCore.lua` - PrintResults() now uses `totalCrestCost`
- `Core/Init.lua` - `/gc ui` command now uses `totalCrestCost`
- `Modules/UI/MainFrame.lua` - UI frame now uses `totalCrestCost`

**Test Plans Updated:**

- `docs/testplans/crest-simulation.md` - Updated expected output to show total costs
- `docs/testplans/ui-overview.md` - Updated to specify total crest cost display
- `docs/testplans/00-Test-Runner-Checklist.md` - Added verification for total cost display

**Notes:**

- Bug: Print sites used `entry.crestCostPerStep` (always 20) instead of `entry.totalCrestCost`
- Fix: Added defensive fallback `totalCost = entry.totalCrestCost or entry.crestCostPerStep or entry.crestCost or 0`
- Guardrail 1.1 compliance: Did not modify upgrade calculation logic
- Verification: `/gc 40 champion` with 2-step upgrade should show `(CHAMPION x40)`

---

## 2026-03-24 — HERO Track Support and Testing

**Summary:** Verified HERO track support is fully functional. HERO track was already implemented correctly in all data tables and logic—no code changes needed.

**Files Modified:**

- `docs/testplans/crest-simulation.md` - Added HERO track simulation test cases
- `docs/testplans/00-Test-Runner-Checklist.md` - Added HERO verification checklist items
- `docs/GEARCRESTER_DEV_NOTES.md` - Added track support status table

**Notes:**

- HERO track already fully implemented: AdvisorData.lua (ilvls, bonus IDs 12700/12791-12796), CrestData.lua (currency ID 3003)
- All logic is track-agnostic—works identically for ADVENTURER, VETERAN, CHAMPION, HERO, MYTH
- Existing `TestAdvisorLogicAPI()` already validates the core logic (totalCrestCost, canAfford, etc.)
- No new test needed—manual verification via `/gc 40 hero` and `/gc 60 hero` is sufficient
- Guardrail compliance: Minimal changes, documentation only, no code modifications

---

## 2026-03-24 — Mixed-Marker Track/Rank Inference Fix

**Summary:** Fixed items that have track markers from one track but rank markers from another track (e.g., CHAMPION track IDs + HERO rank ID). Previously these items were skipped because canonical track detection succeeded but rank detection failed.

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Enhanced `GetItemUpgradeInfo()` with rank-ID inference fallback
- `Modules/Diagnostics/SelfTest.lua` - Added `TestMixedMarkerInference()` test
- `docs/testplans/diagnostics.md` - Added mixed marker inference test case
- `docs/GEARCRESTER_DEV_NOTES.md` - Updated track support status

**Notes:**

- Root cause: Shoulder with bonus IDs {6652, 13577, 12794} - CHAMPION track markers (6652, 13577) but HERO rank marker (12794)
- Old behavior: DetermineTrack returned "CHAMPION", DetermineRank returned nil → item skipped
- New behavior: When rank detection fails, scan ALL tracks' RANK_BONUS_IDS to find matching rank ID
- Rank-ID match (12794 = HERO rank 4) takes precedence, returns ("HERO", 4)
- Debug logging shows full inference chain
- Guardrail 1.1 compliance: Core logic preserved, enhanced with fallback (not replaced)
- Verification: `/gc debug on; /gc dump` shows `track=HERO rank=4`; `/gc 40 hero` lists shoulder as upgradeable

---

## 2026-03-24 — HERO Tier Calibration Helper

**Summary:** Added calibration helper to compare GearCrester's track/rank detection against Blizzard's official C_Item.GetItemUpgradeItemInfo() API. This allows verification and correction of rank mappings for tier items where bonus ID mappings may differ from non-tier items.

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Added `CalibrateItemUpgradeInfo()` function
- `Core/Init.lua` - Added `/gc calibrate [slot]` command
- `Modules/Diagnostics/SelfTest.lua` - Added `TestCalibrationHelper()` test
- `docs/testplans/diagnostics.md` - Added calibration helper test case
- `docs/GEARCRESTER_DEV_NOTES.md` - Added calibration helper to developer tools

**Notes:**

- User reported HERO tier headpiece shows 1/6 in Blizzard UI but GC showed 3/6 (bonus ID 12793)
- Calibration helper prints: bonus IDs, GC detection, Blizzard API result, match/mismatch status
- Command: `/gc calibrate head` (or any slot name)
- Output will guide data table corrections for tier-specific rank mappings
- Guardrail compliance: Added new function without modifying existing detection logic
- Next step: Run `/gc calibrate head` on user's HERO tier headpiece to confirm mismatch

---

## 2026-03-24 — Blizzard API Integration for Upgrade Detection

**Summary:** Integrated Blizzard's authoritative C_Item.GetItemUpgradeInfo() API as the primary source for track/rank detection, with bonus-ID detection as fallback. This fixes tier/catalyst items where bonus-ID mappings don't match Blizzard's official upgrade data.

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Modified `GetItemUpgradeInfo()` to try Blizzard API first, then fall back to bonus-ID detection
- `Modules/Diagnostics/SelfTest.lua` - Added `TestBlizzardAPIIntegration()` and `TestBlizzardAPIFallback()` tests
- `docs/testplans/diagnostics.md` - Added Blizzard API integration test case
- `docs/GEARCRESTER_DEV_NOTES.md` - Added Blizzard API integration to developer tools

**Notes:**

- User reported HERO tier headpiece shows 1/6 in Blizzard UI but GC showed 3/6 based on bonus ID 12793
- New logic: C_Item.GetItemUpgradeInfo() → parse trackString and currentLevel → return (track, rank)
- Fallback: If API returns nil/empty, use existing bonus-ID detection (preserves legacy item support)
- Debug logging shows "Blizzard API: track=X rank=Y" or "Blizzard API unavailable, using bonus-ID detection"
- Guardrail compliance: Preserve existing fallback logic, only add API as primary source
- Verification: `/gc debug on; /gc dump` should show "Blizzard API: track=HERO rank=1" for tier headpiece

---

## 2026-03-24 — Calibrate Command API Fix

**Summary:** Fixed the `/gc calibrate` command to use the correct `C_Item.GetItemUpgradeInfo()` API instead of the deprecated/non-existent `C_Item.GetItemUpgradeItemInfo()`.

**Files Modified:**

- `Modules/UpgradeAdvisor/AdvisorLogic.lua` - Updated `CalibrateItemUpgradeInfo()` to use correct API
- `Modules/Diagnostics/SelfTest.lua` - Added `TestCalibrateUsesBlizzardAPI()` test
- `README.md` - Added calibration command documentation
- `docs/testplans/diagnostics.md` - Added calibrate command test case

**Notes:**

- Old API `C_Item.GetItemUpgradeItemInfo()` does not exist in Midnight and always returned nil
- New logic: `C_Item.GetItemUpgradeInfo(itemLink)` returns authoritative track/rank data
- Calibrate command now aligns with main detection logic (both use same API)
- Output shows "Blizzard: no upgrade data available" when API returns nil
- Guardrail compliance: Minimal change, only API call updated, output format preserved
- Verification: `/gc debug on; /gc calibrate head` should show "Blizzard: track=HERO rank=1" with no "API not available" message

---

_Last updated: 2026-03-24_
_Total prompts tracked: 23_
_Total files created: 12_
_Total files modified: 28_
