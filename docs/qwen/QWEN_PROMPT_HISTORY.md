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

*Last updated: 2026-03-24*
*Total prompts tracked: 16*
*Total files created: 12*
*Total files modified: 20+*
