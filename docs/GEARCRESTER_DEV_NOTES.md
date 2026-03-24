# GearCrester Development Context

## Project Overview

World of Warcraft Midnight addon that scans equipped gear, parses bonus IDs to determine upgrade track and rank, and displays upgrade recommendations with crest cost estimates.

## Current State (as of last session)

### Working Features

- `/gc` - Shows upgrade recommendations using real crest counts (equipped, bags, bank)
- `/gc <count> <crestType>` - Simulates upgrade recommendations with specified crest count
- `/gc debug on` - Enables debug output
- `/gc debug off` - Disables debug output (default)
- `/gc dump` - Dumps all equipped items with bonus IDs, track, and rank
- `/gc why` - Shows diagnostics explaining why items are not upgradeable
- `/gc ui` - Toggles the upgrade advisor UI frame

### Core Logic

1. **Bonus ID Parsing** - Extracts bonus IDs from item links by finding numeric sequence (count 1-20 followed by that many numeric values)
2. **Track Detection** - Matches bonus ID 12697-12701 plus shared IDs to determine track (ADVENTURER, VETERAN, CHAMPION, HERO, MYTHIC)
3. **Rank Detection** - Matches bonus ID 12773-12802 to determine rank (1-6)
4. **Upgrade Path** - Shows ALL affordable upgrade steps per item, not just next rank

### Midnight Season 1 Data

**Track Bonus IDs:**

- ADVENTURER: 12697
- VETERAN: 12698
- CHAMPION: 6652, 13577, 12699, 13439, 12787
- HERO: 12700
- MYTHIC: 12701

**Rank Bonus IDs:** 12773-12802 (6 per track, some items have alternate rank IDs like 13333)

**Upgrade Costs:** Flat 20 crests per upgrade

**Track ILVLS:** 220-289 (6 ranks per track)

### File Structure

```
Core/
  Init.lua          - Slash command handler, debug toggle
  Constants.lua     - Slot IDs
  DataModel.lua     - Shared state tables
  Events.lua        - Event registration
  Utils.lua         - Helper functions

Modules/
  InventoryScanner/
    ScannerEquipped.lua  - Scans equipped gear
    ScannerBags.lua      - Scans bags using C_Container API
    ScannerBank.lua      - Scans bank using C_Container API
    ScannerCore.lua      - Legacy scanner

  CrestTracker/
    CrestData.lua        - Reads crest currencies, SimulateCrests()
    CrestCaps.lua        - Stub
    ResetTimer.lua       - Stub

  UpgradeAdvisor/
    AdvisorCore.lua      - GetRecommendedUpgrades(), PrintResults()
    AdvisorLogic.lua     - ParseBonusIDs(), DetermineTrack(), DetermineRank(), Evaluate(), GetItemDiagnostics(), DumpAllItems(), PrintWhyDiagnostics()
    AdvisorData.lua      - TRACK_BONUS_IDS, RANK_BONUS_IDS, TRACK_ILVLS, CREST_COST
    AdvisorUI.lua        - Stub

  UI/
    MainFrame.lua   - Movable frame with scrollable output
    Heatmap.lua     - Stub
    SlotList.lua    - Stub
    TooltipExtensions.lua - Stub

  Profiles/
    ProfileManager.lua    - Stub
    DefaultProfiles.lua   - Stub
```

### Key Functions

- `ParseBonusIDs(itemLink)` - Extracts bonus IDs from item link string
- `GetItemUpgradeInfo(itemLink)` - Returns trackName, rank
- `GetDetailedItemLevelInfo(itemLink)` - WoW API for item level
- `GetItemDiagnostics(itemLink)` - Returns structured explanation of upgradeability
- `Logic:EvaluateAll(equipped, bags, bank, simulatedCrests)` - Returns all affordable upgrade steps

### Output Format

```
GearCrester Upgrade Recommendations (Simulated: 40 CHAMPION):
Legs: 253 -> 256 (CHAMPION x20)
Waist: 250 -> 253 (CHAMPION x20)
```

### Known Issues / TODO

- Items without track bonus ID (12697-12701 or shared IDs) are skipped
- Only CHAMPION track fully tested with real bonus IDs
- Other tracks have placeholder bonus ID tables
- Bag/bank scanning uses C_Container API (Retail/Midnight only)
- No weekly/seasonal cap tracking
- UI frame is basic text output

### Testing Commands

```
/gc                    -- Real crest counts
/gc 40 champion        -- Simulate 40 CHAMPION crests
/gc 80 champion        -- Simulate 80 CHAMPION crests (shows 4 steps per item)
/gc debug on           -- Enable verbose debug output
/gc dump               -- Show all items with bonus IDs
/gc why                -- Show why items are not upgradeable
/gc ui                 -- Toggle UI frame
```

### Last Session Achievements

- Fixed bonus ID parsing (position-based with strsplit)
- Fixed track detection (unique bonus ID per track plus shared IDs)
- Added multi-step upgrade display (shows all affordable ranks)
- Added debug toggle (`/gc debug on|off`)
- Added bag/bank scanning with C_Container API
- Added `/gc dump` command for bonus ID inspection
- Added `/gc why` command for upgrade diagnostics
- Added `/gc ui` command for UI frame toggle
- Created QWEN_GUARDRAILS.md for development constraints
- Updated README.md with all slash commands
