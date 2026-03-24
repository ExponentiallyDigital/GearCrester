This file is located at: docs/qwen/QWEN_GUARDRAILS.md
Qwen MUST always reference this exact path when applying guardrails.

# GearCrester Guardrails

## Purpose

This document defines the strict rules Qwen must follow to ensure GearCrester remains stable, predictable, and fully testable.
Every change must preserve verified working functionality and update the appropriate test plans.

---

# 1. STRICT RULES — DO NOT MODIFY WITHOUT EXPLICIT INSTRUCTION

## 1.1 Core Logic (Never Modify)

- Bonus ID parsing logic in `AdvisorLogic.lua`
- Track detection logic (`DetermineTrack`)
- Rank detection logic (`DetermineRank`)
- Evaluation logic (`Evaluate`, `EvaluateAll`, `EvaluateItems`)
- `TRACK_BONUS_IDS` tables
- `RANK_BONUS_IDS` tables
- `TRACK_ILVLS` tables
- `CREST_COST` value
- `MAX_RANK` value

## 1.2 Framework & Architecture (Never Modify)

- Test harness in `Modules/Diagnostics/SelfTest.lua`
- Export format in `Modules/Export/ExportCore.lua`
- UI frame structure in `Modules/UI/MainFrame.lua`
- UpgradeOrder sorting logic
- FreeUpgrade gold-only detection logic
- InventoryOverview data collection
- SavedVariables initialization pattern in `Core/Events.lua`

## 1.3 Prohibited Actions

- Do not rewrite or optimize existing modules
- Do not rename functions or variables
- Do not change slash command syntax without updating README.md
- Do not remove debug functionality
- Do not modify `ParseBonusIDs`
- Do not alter `GetItemUpgradeInfo`
- Do not change how `GetDetailedItemLevelInfo` is called
- Do not modify test harness output format
- Do not change export file structure
- Do not modify UI frame structure
- Do not change slot weight validation (must remain 1–20)
- Do not write `nil` to SavedVariables

---

# 2. REQUIRED UPDATES WHEN ADDING FEATURES

Whenever Qwen adds or modifies functionality, it MUST update:

- `README.md` — new slash commands or user-facing features
- `GEARCRESTER_DEV_NOTES.md` — new features, backlog, or architectural notes
- `GearCrester.toc` — new module files
- `QWEN_GUARDRAILS.md` — if rules change
- **All relevant test plans** (see Section 3)

---

# 3. TEST PLAN ENFORCEMENT SYSTEM (MANDATORY)

Qwen MUST maintain the following test plan files:

### **3.1 Core Test Plans**

- `docs/testplans/weightings.md`
- `docs/testplans/free-upgrades.md`
- `docs/testplans/ui-overview.md`
- `docs/testplans/scanning.md`
- `docs/testplans/export.md`
- `docs/testplans/diagnostics.md`
- `docs/testplans/crest-simulation.md`

### **3.2 Rules for Test Plans**

For every change to any module, Qwen MUST:

1. **Update or create** the corresponding test plan file
2. Include:
    - Exact slash commands to run
    - Expected output
    - Debug-mode expectations
    - Regression checks
    - Error‑free behavior requirements
3. Reference the updated test plan in its output summary:
    - “Test plan updated: docs/testplans/<file>.md”
4. Never remove or overwrite existing test plans unless explicitly instructed
5. Ensure test plans remain **complete, accurate, and executable in-game**

### **3.3 Required Coverage**

Every test plan MUST validate:

- SavedVariables initialization
- Slash command behavior
- Sorting logic
- Weighting logic
- Gold‑only upgrade detection
- Crest simulation
- UI data-layer behavior
- Event-driven scanning
- Regression checks for all existing features
- No Lua errors

---

# 4. KNOWN WORKING STATE (REFERENCE ONLY)

- Bonus ID parser: position-based with `strsplit`
- Track bonus IDs: 12697–12701 plus shared IDs
- Rank bonus IDs: 12773–12802 (6 per track)
- Crest cost: 20 (flat)
- Max rank: 6
- Slot weights: 1–20 (lower = higher priority)
- Gold-only detection: same track, higher rank = free upgrade

---

# 5. SAVEDVARIABLES RULES

- Initialized ONLY in `Events.lua` ADDON_LOADED handler
- Must check `if arg1 ~= addonName then return end`
- Use `GearCresterDB = GearCresterDB or {}`
- Never write `nil`
- File path: `WTF/Account/<account>/SavedVariables/GearCrester.lua`

---

# 6. CONTACT

If unsure whether a change is safe, Qwen must:

- Enable debug mode
- Run all test plans
- Verify no Lua errors

---

# 7. KNOWN ISSUES

- First-login SavedVariables error may occur if file doesn't exist
- Fixed by ensuring initialization happens in ADDON_LOADED only

---

# 8. Test Plan Index & Maintenance Requirements

Qwen MUST maintain the following test plan files:

- `docs/testplans/README.md` (master index)
- `docs/testplans/weightings.md`
- `docs/testplans/free-upgrades.md`
- `docs/testplans/ui-overview.md`
- `docs/testplans/scanning.md`
- `docs/testplans/export.md`
- `docs/testplans/diagnostics.md`
- `docs/testplans/crest-simulation.md`

Whenever Qwen adds or modifies functionality, it MUST:

1. Update the relevant test plan(s)
2. Update the master index if new test plans are added
3. Update the test-runner checklist if new commands or flows are added
4. Use the Qwen Feature Implementation Template for all future prompts
5. Reference updated test plans in its output summary:
    - “Test plan updated: docs/testplans/<file>.md”

---

# 9. Feature implementation

Qwen MUST use the feature implementation template located at:
docs/qwen/QWEN_FEATURE_TEMPLATE.md

These rules are mandatory and apply to all future development tasks.

---

# 10. Prompt History Enforcement

Qwen MUST maintain a complete prompt history in:

- `docs/qwen/QWEN_PROMPT_HISTORY.md`

Whenever Qwen performs any feature implementation, architectural change, module addition, or test plan update, it MUST:

1. Append a new entry to `QWEN_PROMPT_HISTORY.md`
2. Include:
    - Date
    - Summary of the prompt
    - Files created or modified
    - Test plans created or updated
    - Notes or constraints
3. Never overwrite or delete previous entries
4. Reference the update in its output summary:
    - “Prompt history updated: docs/qwen/QWEN_PROMPT_HISTORY.md”
5. Use the structure defined in the initial version of the file
6. Ensure the history remains chronological and complete

This rule is mandatory and applies to all future development tasks.

---

# 11. Checklist for testing GearCrester

Qwen MUST update the master test runner checklist located at:

- docs/testplans/00-Master-Test-Runner-Checklist.md

Whenever:

- A new feature is added
- A test plan is created or modified
- A slash command is added or changed
- A subsystem gains new behavior

The checklist must always reflect the full set of required manual tests.

---

# 12. Architecture Diagram & Dependency Map Enforcement

Qwen MUST maintain the following files:

- docs/architecture/GEARCRESTER_ARCHITECTURE.md
- docs/architecture/GEARCRESTER_DEPENDENCY_MAP.md

Whenever architecture or dependencies change, Qwen MUST:

1. Update both diagrams
2. Use portrait‑oriented Mermaid (`flowchart TB`)
3. Represent each subsystem as a single node for readability
4. Avoid horizontal sprawl, looping arrows, or oversized subgraphs
5. Ensure diagrams render correctly in GitHub and Visual Studio Code
6. Update the file‑level breakdown tables if modules change
7. Confirm updates in its output summary:
   “Architecture diagrams updated.”

These diagrams are **AI‑maintained artifacts**.
Humans SHOULD NOT manually modify the diagrams.

---

# 13. Release History Generator Maintenance

Qwen MUST maintain the correctness of the release history generator located in:

- .github/workflows/release.yml
- scripts/test_release_history.sh

Qwen MUST ensure:

1. Multiline commit messages are fully preserved
2. File statistics remain accurate
3. Formatting remains consistent and readable
4. The local test script and GitHub Action stay in sync
5. Any changes to release formatting are reflected in both files
6. No regressions are introduced when modifying the workflow

Whenever Qwen modifies release generation logic, it MUST:

- Update both the GitHub Action and the local test script
- Confirm updates in its output summary:
  “Release history generator updated.”

---
