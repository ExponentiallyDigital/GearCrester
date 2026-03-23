# GearCrester Architecture

## Core

- Init.lua: addon bootstrap
- Events.lua: event routing
- Utils.lua: shared helpers
- Constants.lua: slot IDs, enums
- DataModel.lua: shared state

## Modules

### UpgradeAdvisor

- AdvisorCore.lua: public API
- AdvisorLogic.lua: upgrade evaluation
- AdvisorData.lua: crest tables, slot priorities
- AdvisorUI.lua: UI for recommendations

### InventoryScanner

- ScannerEquipped.lua
- ScannerBags.lua
- ScannerBank.lua

### CrestTracker

- CrestData.lua
- CrestCaps.lua
- ResetTimer.lua

### UI

- MainFrame.lua
- Heatmap.lua
- SlotList.lua
- TooltipExtensions.lua

### Profiles

- ProfileManager.lua
- DefaultProfiles.lua
