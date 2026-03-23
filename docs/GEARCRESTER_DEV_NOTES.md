# GearCrester Development Context

## Project Overview

World of Warcraft Midnight addon that scans equipped gear, parses bonus IDs to determine upgrade track and rank, and displays upgrade recommendations with crest cost estimates.

## Current State (as of last session)

### Working Features

- `/gc` - Shows upgrade recommendations using real crest counts
- `/gc <count> <crestType>` - Simulates upgrade recommendations with specified crest count
- `/gc debug=on` - Enables debug output
- `/gc debug=off` - Disables debug output (default)

### Core Logic

1. **Bonus ID Parsing** - Extracts bonus IDs from item links by finding numeric sequence (count 1-20 followed by that many numeric values)
2. **Track Detection** - Matches bonus ID 12697-12701 to determine track (ADVENTURER, VETERAN, CHAMPION, HERO, MYTHIC)
3. **Rank Detection** - Matches bonus ID 12773-12802 to determine rank (1-6)
4. **Upgrade Path** - Shows ALL affordable upgrade steps per item, not just next rank

### Midnight Season 1 Data

**Track Bonus IDs:**

- ADVENTURER: 12697
- VETERAN: 12698
- CHAMPION: 12699
- HERO: 12700
- MYTHIC: 12701

**Rank Bonus IDs:** 12773-12802 (6 per track)

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
    ScannerBags.lua      - Stub
    ScannerBank.lua      - Stub
    ScannerCore.lua      - Legacy scanner

  CrestTracker/
    CrestData.lua        - Reads crest currencies, SimulateCrests()
    CrestCaps.lua        - Stub
    ResetTimer.lua       - Stub

  UpgradeAdvisor/
    AdvisorCore.lua      - GetRecommendedUpgrades(), PrintResults()
    AdvisorLogic.lua     - ParseBonusIDs(), DetermineTrack(), DetermineRank(), Evaluate()
    AdvisorData.lua      - TRACK_BONUS_IDS, RANK_BONUS_IDS, TRACK_ILVLS, CREST_COST
    AdvisorUI.lua        - Stub

  UI/
    MainFrame.lua   - Stub
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
- `Logic:Evaluate(equipped, simulatedCrests)` - Returns all affordable upgrade steps

### Output Format

```
GearCrester Upgrade Recommendations (Simulated: 40 CHAMPION):
Legs: 253 -> 256 (CHAMPION x20)
Waist: 250 -> 253 (CHAMPION x20)
```

### Known Issues / TODO

- Items without track bonus ID (12697-12701) are skipped (e.g., some trinkets, weapons)
- Only CHAMPION track fully tested
- Other tracks have placeholder bonus ID tables
- No bags/bank scanning (equipped only)
- No weekly/seasonal cap tracking
- No UI frames (chat output only)

### Testing Commands

```
/gc                    -- Real crest counts
/gc 40 champion        -- Simulate 40 CHAMPION crests
/gc 80 champion        -- Simulate 80 CHAMPION crests (shows 4 steps per item)
/gc debug=on           -- Enable verbose debug output
```

### Last Session Achievements

- Fixed bonus ID parsing (dynamic detection, not fixed offsets)
- Fixed track detection (unique bonus ID per track, not shared IDs)
- Added multi-step upgrade display (shows all affordable ranks)
- Added debug toggle (`/gc debug=on/off`)
- Changed arrow from `→` to `->` for console compatibility
