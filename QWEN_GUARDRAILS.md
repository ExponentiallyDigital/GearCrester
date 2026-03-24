# GearCrester Guardrails

## Purpose

This document ensures future development does not break verified working functionality.

## Strict Rules

### DO NOT Modify Unless Explicitly Asked

- Bonus ID parsing logic in `AdvisorLogic.lua`
- Track detection logic (`DetermineTrack`)
- Rank detection logic (`DetermineRank`)
- Evaluation logic (`Evaluate`, `EvaluateAll`, `EvaluateItems`)
- `TRACK_BONUS_IDS` tables
- `RANK_BONUS_IDS` tables
- `TRACK_ILVLS` tables
- `CREST_COST` value
- `MAX_RANK` value
- Test harness in `Modules/Diagnostics/SelfTest.lua`
- Export format in `Modules/Export/ExportCore.lua`
- UI frame structure in `Modules/UI/MainFrame.lua`

### DO NOT Do

- Rewrite or optimize existing modules
- Rename functions or variables
- Change slash command syntax without updating README.md
- Remove debug functionality
- Modify the `ParseBonusIDs` function
- Alter the `GetItemUpgradeInfo` function
- Change how `GetDetailedItemLevelInfo` is called
- Modify test harness output format
- Change export file structure
- Modify UI frame structure

### DO Update When Adding Features

- README.md with new slash commands
- GEARCRESTER_DEV_NOTES.md with new features
- This QWEN_GUARDRAILS.md if rules change

### Testing Requirements

Before committing any change:

1. Run `/gc 40 champion` - verify Champion items appear
2. Run `/gc 20 hero` - verify Hero items appear
3. Run `/gc debug on` then `/gc 40 champion` - verify debug output
4. Run `/gc test` - verify all subsystems pass
5. Verify no Lua errors in chat

## Known Working State

- Bonus ID parser: position-based with strsplit
- Track bonus IDs: 12697-12701 plus shared IDs
- Rank bonus IDs: 12773-12802 (6 per track)
- Crest cost: 20 (flat)
- Max rank: 6

## Contact

If unsure whether a change is safe, test with debug mode enabled first.
