# GearCrester Test Plans — Master Index

This directory contains all test plans required to validate GearCrester functionality after any code change.

Each test plan is self‑contained and must be executed whenever its corresponding subsystem is modified.

---

## Core Test Plans

### 1. Upgrade Order & Weighting

- **File:** `weightings.md`
- Validates:
    - Slot priority system
    - User-defined weighting (1–20)
    - Sorting integration

### 2. Gold‑Only Upgrade Detection

- **File:** `free-upgrades.md`
- Validates:
    - Detection of free (gold-only) upgrade steps
    - Integration with AdvisorCore
    - Crest simulation compatibility

### 3. UI Data Layer

- **File:** `ui-overview.md`
- Validates:
    - InventoryOverview data collection
    - Debug output
    - No UI errors

### 4. Inventory Scanning

- **File:** `scanning.md`
- Validates:
    - Equipped scanning
    - Bag scanning (when implemented)
    - Bank scanning
    - Event-driven updates

### 5. Export System

- **File:** `export.md`
- Validates:
    - Export command
    - Crest simulation export
    - SavedVariables output

### 6. Diagnostics & Self-Test

- **File:** `diagnostics.md`
- Validates:
    - `/gc test`
    - Debug mode
    - Subsystem health

### 7. Crest Simulation

- **File:** `crest-simulation.md`
- Validates:
    - `/gc <count> <crestType>`
    - UI simulation
    - Sorting + weighting + gold-only interactions

---

## How to Use This Directory

- When modifying any subsystem, run the corresponding test plan(s).
- When adding new features, create a new test plan file.
- When modifying existing logic, update the relevant test plan(s).
- Qwen must always update test plans as part of any code change.

---

# End of Master Index
