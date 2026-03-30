# GearCrester Development Notes

## Project Overview

World of Warcraft Midnight addon that scans equipped gear, parses bonus IDs to determine upgrade track and rank, and displays upgrade recommendations with crest cost estimates.

**Purpose:** Make it easy to see what gear needs to be or can be upgraded with crests/gold.

**Why:** Character frames and addons like Pawn show item levels but don't display upgrade track types or show what can be upgraded with available crests. GearCrester fills this gap by showing upgrade paths, crest costs, and optimal upgrade sequences.

**Important:** GearCrester does NOT advise whether gear _should_ be upgraded—that's the domain of AskMrRobot (AMR) and simulation tools. GearCrester only shows what _can_ be upgraded and the costs involved.

---

## Current Status

**Version:** 0.0.4
**State:** MVP Complete + Upgrade Order + Gold-Only Detection + Crest Simulation
**Last Tested:** Equipped gear scanning, bonus ID parsing, track/rank detection working correctly for CHAMPION track

### Known Issues

- None reported

### Track Support Status

| Track          | Bonus ID | Rank IDs    | Tested  | Status                                     |
| -------------- | -------- | ----------- | ------- | ------------------------------------------ |
| ADVENTURER     | 12697    | 12773-12778 | Pending | Data complete                              |
| VETERAN        | 12698    | 12779-12784 | Pending | Data complete                              |
| CHAMPION       | 12699    | 12785-12790 | ✓ Yes   | Fully tested                               |
| HERO           | 12700    | 12791-12796 | ✓ Yes   | Fully tested + mixed-marker fix            |
| MYTH           | 12701    | 12797-12802 | Pending | Data complete                              |
| CRAFTED        | N/A      | N/A         | Pending | **Detection enabled** via TradeSkillUI API |
| CRAFTED-HERO   | N/A      | N/A         | Pending | **Detection enabled** via TradeSkillUI API |
| CRAFTED-MYTHIC | N/A      | N/A         | Pending | **Detection enabled** via TradeSkillUI API |

**Mixed-Marker Fix:** Items with track markers from one track but rank markers from another (e.g., CHAMPION track IDs + HERO rank ID) are now correctly identified using rank-ID inference fallback. Rank ID takes precedence when canonical rank detection fails.

**Crafted Gear Detection:** Crafted items are detected via `C_TradeSkillUI.GetItemCraftedQualityByItemInfo(itemLink)` to confirm the item is crafted, then track is determined by final item level:

- **CRAFTED**: Base crafted (ilvl ~252)
- **CRAFTED-HERO**: HERO infusion (ilvl ~272)
- **CRAFTED-MYTHIC**: MYTHIC infusion (ilvl ~285)

Note: Crafting quality (1-5) only indicates the item is crafted, NOT the crest infusion track. Track is determined by ilvl thresholds.

Detection is implemented in:

- `ScannerEquipped` - uses `GetInventoryItemLink()` then `GC.GetCraftedTrackName(itemLink)`
- `ScannerBags` - uses `C_Container.GetContainerItemInfo().hyperlink` then `GC.GetCraftedTrackName(itemLink)`
- `ScannerBank` - uses `C_Container.GetContainerItemInfo().hyperlink` then `GC.GetCraftedTrackName(itemLink)`
- `UpgraderScanner` - uses `GetInventoryItemLink()` then `GC.GetCraftedTrackName(itemLink)`

---

## What GearCrester DOES Do (Implemented Features)

### Core Functionality

- [x] **Bonus ID parsing** from item links (position-based with strsplit)
- [x] **Track detection** for all 5 tracks: ADVENTURER, VETERAN, CHAMPION, HERO, MYTH
- [x] **Rank detection** (1-6 per track)
- [x] **Multi-step upgrade path display** (shows all affordable steps, not just next rank)
- [x] **Flat 20-crest cost** per upgrade step
- [x] **Total crest cost display** (shows full path cost: upgradeSteps × 20)
- [x] **Upgrade order system** with default slot priorities (weapons -> armor -> trinkets)
- [x] **User-defined slot weights** (1-20, lower = higher priority, saved to SavedVariables)
- [x] **Gold-only upgrade detection** (same track, higher rank owned = free upgrade to that rank)
- [x] **Crest simulation** (test scenarios: "what if I have 40/100/150 crests?")
- [x] **InventoryOverview data layer** for future UI development

### Scanning

- [x] **Equipped gear scanning** (all 16 slots)
- [ ] **Bag scanning** (stub - C_Container API ready but not fully implemented)
- [ ] **Bank scanning** (stub - C_Container API ready but not fully implemented)
- [x] **Auto-rescan triggers** on equipment changes, bag updates, bank changes

### Slash Commands

| Command                          | Description                                                               |
| -------------------------------- | ------------------------------------------------------------------------- |
| `/gc`                            | Show upgrade recommendations for equipped gear (uses actual crest counts) |
| `/gc <count> <crestType>`        | Simulate upgrades with specified crest count (e.g., `/gc 40 champion`)    |
| `/gc debug on\|off`              | Enable/disable debug output                                               |
| `/gc dump`                       | Dump all equipped items with bonus IDs, track, and rank                   |
| `/gc why`                        | Show diagnostics explaining why items are not upgradeable                 |
| `/gc test`                       | Run self-diagnostics (validates all subsystems)                           |
| `/gc export`                     | Export upgradeable items to SavedVariables                                |
| `/gc export <count> <crestType>` | Export with crest simulation                                              |
| `/gc ui`                         | Toggle movable UI frame with upgrade recommendations                      |
| `/gc ui <count> <crestType>`     | Show simulation results in UI frame                                       |
| `/gc help`                       | Show all commands with descriptions                                       |
| `/gc weight <slot> <value>`      | Set slot priority weight (1-20)                                           |
| `/gc weight reset`               | Reset all slot weights to defaults                                        |
| `/gc weight list`                | Show all slot weights (default vs custom)                                 |

**Notes:**

- All crest type names are case-insensitive (`champion`, `Champion`, `CHAMPION` all work)
- All slot names are case-insensitive (`mainhand`, `MainHand`, `MAINHAND` all work)

### UI Features

- [x] **Movable frame** (drag to reposition)
- [x] **Scrollable text output** (handles long upgrade lists)
- [x] **Close button**
- [x] **Color-coded output** (green = affordable, red = cannot afford)
- [x] **Gold-only markers** ([GOLD-ONLY] tag for free upgrades)
- [x] **Location tags** ([Equipped], [Bag X, Slot Y], [Bank Bag X, Slot Y])
- [x] **Simulation title** (shows crest count and type being simulated)

### Developer Tools

- [x] **Self-diagnostic test suite** (`/gc test` - validates 10+ subsystems)
- [x] **Export functionality** (`/gc export` - outputs to SavedVariables)
- [x] **Debug mode** (detailed logging for troubleshooting)
- [x] **Bonus ID dump** (inspect raw bonus IDs from items)
- [x] **Upgrade diagnostics** (explains why items can't be upgraded)
- [x] **Slot weight management** (view, set, reset priorities)
- [x] **Calibration helper** (`/gc calibrate [slot]` - Compare GC vs Blizzard upgrade data)
- [x] **Blizzard API integration** (uses C_Item.GetItemUpgradeInfo() as primary detection source)

### Data Tables (Complete)

- [x] **TRACK_BONUS_IDS** (all 5 tracks: 12697-12701 plus shared IDs)
- [x] **RANK_BONUS_IDS** (all 5 tracks, 6 ranks each: 12773-12802)
- [x] **TRACK_ILVLS** (220-289 ilvl range, all tracks)
- [x] **CREST_COST** (flat 20 per step)
- [x] **SLOT_PRIORITY** (all 16 slots with default priorities)
- [x] **CREST_TYPES** (ADVENTURER, VETERAN, CHAMPION, HERO, MYTH)

### Modules

- [x] **UpgradeOrder** - Configurable slot priority system
- [x] **FreeUpgrade** - Gold-only upgrade detection
- [x] **InventoryOverview** - UI data-layer foundation
- [x] **AdvisorCore** - Public API for upgrade recommendations
- [x] **AdvisorLogic** - Bonus ID parsing, track/rank detection, evaluation
- [x] **AdvisorData** - Static data tables (tracks, ranks, ilvls, costs)
- [x] **CrestData** - Crest currency reading and simulation
- [x] **ScannerEquipped** - Equipped gear scanning
- [x] **SelfTest** - Diagnostic test suite
- [x] **Export** - Export functionality

---

## What GearCrester Does NOT Do (Not Implemented)

### Not Implemented (Backlog / Future Features)

- [ ] **Weekly/seasonal crest cap tracking** - Does not track how many crests you can earn per week/season
- [ ] **Reset timer** - Does not show time until weekly reset or when new crests become available
- [ ] **Tier breakpoint detection** - Does not warn when upgrading rank 5->6 "wastes" crests (should upgrade to next tier instead)
- [ ] **Visual gear list by tier/ilevel** - No graphical display, grid view, or sortable list (text output only)
- [ ] **Bag/bank item upgrades** - Cannot show what bag/bank items can be upgraded (scanning is stubbed)
- [ ] **Gold cost display** - Does not show actual gold cost for gold-only upgrades
- [ ] **Crest efficiency score** - Does not calculate crest cost per ilevel gained
- [ ] **Alt impact analysis** - Does not track or show impact of upgrades on alts
- [ ] **"What should I upgrade" advice** - Does not recommend which items to prioritize (that's AMR's role)
- [ ] **Total crests to max calculation** - Does not calculate total crests needed to upgrade everything to track 6/6
- [ ] **Average ilevel projection** - Does not show resulting average ilevel after upgrades
- [ ] **Multi-week planning** - Does not plan upgrade paths across multiple weekly resets
- [ ] **Profile system for alts** - No alt character support or profile switching
- [ ] **Tooltip extensions** - Does not show upgrade info in item tooltips
- [ ] **Heatmap UI** - No visual heatmap for upgrade priorities

### Partially Implemented

- [~] **Bag/bank scanning** - Modules exist with C_Container API but not fully functional
- [~] **Gold-only detection** - Works for equipped items; requires both items to be scanned (bag/bank scanning needed for full functionality)

---

## Backlog Items (From User Feedback)

1. **Case insensitivity** - All names (crest types, slots) should be case-insensitive ✓ DONE
2. **Total crests calculator** - Function to calculate crests required to upgrade everything to specific track/rank (e.g., Champion 6/6)
3. **Average ilevel projection** - Show resulting average ilevel for all equipped items after simulated upgrades
4. **Current crest view** - `/gc` only shows what you can spend existing crests on (already implemented)
5. **All track support** - Only CHAMPION fully tested; need real items for ADVENTURER, VETERAN, HERO, MYTH
6. **Optimal upgrade planner** - With 100 crests, show which items to upgrade and which will still need upgrades
7. **Visual representation** - Graphical display of upgrade paths, costs, and priorities

---

## Slash Command Reference

### Basic Commands

```
/gc                              -- Show upgrades affordable with current crests
/gc 40 champion                  -- Simulate with 40 CHAMPION crests
/gc 100 hero                     -- Simulate with 100 HERO crests
/gc debug on                     -- Enable debug logging
/gc debug off                    -- Disable debug logging
```

### Diagnostic Commands

```
/gc test                         -- Run self-diagnostics (validates all subsystems)
/gc dump                         -- Show all equipped items with bonus IDs
/gc why                          -- Explain why items are not upgradeable
/gc help                         -- Show all available commands
```

### Export Commands

```
/gc export                       -- Export upgradeable items to SavedVariables
/gc export 40 champion           -- Export with 40 CHAMPION crest simulation
```

### UI Commands

```
/gc ui                           -- Toggle movable UI frame
/gc ui 40 champion               -- Show 40 CHAMPION simulation in UI frame
```

### Weight Commands

```
/gc weight list                  -- Show all slot weights (default vs custom)
/gc weight MainHand 1            -- Set MainHand to highest priority (1)
/gc weight Trinket1 20           -- Set Trinket1 to lowest priority (20)
/gc weight reset                 -- Reset all weights to defaults
```

---

## Default Slot Priorities

Lower number = higher priority (upgraded first)

| Priority | Slot     | Priority | Slot     |
| -------- | -------- | -------- | -------- |
| 1        | MainHand | 9        | Shoulder |
| 2        | OffHand  | 10       | Feet     |
| 3        | Head     | 11       | Neck     |
| 4        | Chest    | 12       | Back     |
| 5        | Legs     | 13       | Finger1  |
| 6        | Waist    | 14       | Finger2  |
| 7        | Wrist    | 15       | Trinket1 |
| 8        | Hands    | 16       | Trinket2 |

---

## Upgrade Track Reference

| Track | Crest Type | Ranks | ILvl Range | Crest IDs |
| ----- | ---------- | ----- | ---------- | --------- |
| 1-6   | ADVENTURER | 6     | 220-237    | 12697     |
| 1-6   | VETERAN    | 6     | 233-250    | 12698     |
| 1-6   | CHAMPION   | 6     | 246-263    | 12699     |
| 1-6   | HERO       | 6     | 259-276    | 12700     |
| 1-6   | MYTH       | 6     | 272-289    | 12701     |

**Notes:**

- All upgrades cost 20 crests per step
- Rank 5->6 of one tier equals rank 1-2 of next tier (tier breakpoint)
- Gold-only upgrades available when owning higher-rank item of same track

---

## Testing Checklist

### Basic Functionality

- [ ] `/gc` displays upgrade recommendations
- [ ] `/gc 40 champion` shows simulation with correct **total crest costs** (2 steps = x40)
- [ ] `/gc 100 champion` shows 5-step upgrades as `(CHAMPION x100)`
- [ ] Crest cost displayed = `upgradeSteps × 20` (total path cost, not per-step)
- [ ] `/gc debug on` enables debug output
- [ ] `/gc debug off` disables debug output

### Upgrade Order

- [ ] `/gc weight MainHand 1` sets MainHand to highest priority
- [ ] `/gc weight list` shows all slot weights
- [ ] `/gc weight reset` resets to defaults
- [ ] Sorting respects custom weights

### Gold-Only Detection

- [ ] Items with same track, higher rank owned show `[GOLD-ONLY]`
- [ ] Gold-only upgrades don't consume crests
- [ ] Gold-only detection disabled during simulation

### Diagnostics

- [ ] `/gc test` runs and all tests show `[OK]`
- [ ] `/gc dump` shows all equipped items with bonus IDs
- [ ] `/gc why` explains why items are not upgradeable

### Export

- [ ] `/gc export` exports upgradeable items
- [ ] `/gc export 40 champion` exports with simulation
- [ ] Export file written to SavedVariables on logout

### UI

- [ ] `/gc ui` toggles the UI frame
- [ ] `/gc ui 40 champion` shows simulation in UI
- [ ] UI frame is movable
- [ ] UI frame has close button
- [ ] UI displays **total crest costs** (not per-step)

### Edge Cases

- [ ] No upgradeable items shows appropriate message
- [ ] Items at max rank are skipped
- [ ] Items without track bonus IDs are skipped
- [ ] SavedVariables file loads without errors on fresh install
- [ ] Case-insensitive input works (e.g., `champion`, `CHAMPION`, `Champion`)

---

## Development Constraints

See `QWEN_GUARDRAILS.md` for strict development rules including:

- Never modify core logic (bonus ID parsing, track/rank detection, evaluation)
- Never rename functions or variables
- Always update test plans when adding features
- Always update prompt history
- Always follow SavedVariables initialization pattern
- Never write `nil` to SavedVariables

---

## Architecture

See `docs/architecture/GEARCRESTER_ARCHITECTURE.md` for detailed architecture diagrams.

See `docs/architecture/GEARCRESTER_DEPENDENCY_MAP.md` for module dependency mapping.

---

## Continue From Here

To continue development, say: **"Continue from GEARCRESTER_DEV_NOTES.md"**

---

_Last updated: 2026-03-24_
_Version: 0.0.4_
_Status: MVP Complete + Upgrade Order + Gold-Only Detection + Crest Simulation_
