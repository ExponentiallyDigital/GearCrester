# GearCrester Development Notes

## Project Overview

World of Warcraft Midnight addon that scans equipped gear, parses bonus IDs to determine upgrade track and rank, and displays upgrade recommendations with crest cost estimates.

## Current Status

**Version:** 0.0.1
**State:** MVP Complete - Equipped + Bags + Bank scanning functional
**Last Tested:** Equipped gear scanning, bonus ID parsing, track/rank detection working correctly for CHAMPION track

## Completed Features

### Core Functionality

- [x] Bonus ID parsing from item links
- [x] Track detection (ADVENTURER, VETERAN, CHAMPION, HERO, MYTHIC)
- [x] Rank detection (1-6 per track)
- [x] Multi-step upgrade path display
- [x] Flat 20-crest cost per upgrade

### Scanning

- [x] Equipped gear scanning
- [x] Bag scanning (C_Container API)
- [x] Bank scanning (C_Container API)
- [x] Auto-rescan on equipment/bag/bank changes

### Slash Commands

- [x] `/gc` - Show upgrade recommendations
- [x] `/gc <count> <crestType>` - Simulate with crest count
- [x] `/gc debug on|off` - Toggle debug output
- [x] `/gc dump` - Dump all items with bonus IDs
- [x] `/gc why` - Show upgrade diagnostics
- [x] `/gc test` - Run self-diagnostics
- [x] `/gc export` - Export upgradeable items
- [x] `/gc export <count> <crestType>` - Export with simulation
- [x] `/gc ui` - Toggle UI frame
- [x] `/gc ui <count> <crestType>` - Show simulation in UI
- [x] `/gc help` - Show all commands

### UI

- [x] Movable frame with scrollable output
- [x] Close button
- [x] Display upgrade recommendations
- [x] Display simulation results

### Developer Tools

- [x] Self-diagnostic test suite (`/gc test`)
- [x] Export functionality (`/gc export`)
- [x] Debug mode (`/gc debug on|off`)
- [x] Bonus ID dump (`/gc dump`)
- [x] Upgrade diagnostics (`/gc why`)

### Data Tables

- [x] TRACK_BONUS_IDS (all 5 tracks)
- [x] RANK_BONUS_IDS (all 5 tracks, 6 ranks each)
- [x] TRACK_ILVLS (220-289 ilvl range)
- [x] CREST_COST (flat 20)
- [x] SLOT_PRIORITY (all 16 slots)

## Backlog

### Compare Two Gear Sets (Priority: Medium)

**Description:** Allow users to compare upgrade potential between two gear sets (e.g., current gear vs. bag items).

**Expected Behavior:**

- User runs `/gc compare` to compare equipped gear with items in bags/bank
- Output shows which bag/bank items are upgrades over equipped gear
- Shows ilvl difference, track difference, and upgrade cost for each slot

**Example Usage:**

```
/gc compare                      -- Compare equipped vs. bags/bank
/gc compare 40 champion          -- Compare with crest simulation
```

**Implementation Notes:**

- Create new module: `Modules/Comparison/ComparisonCore.lua`
- Need to match items by slot (Head vs. Head, etc.)
- Compare track first, then rank, then ilvl
- Show only items that are strict upgrades
- Consider adding to UI frame with color coding (green = upgrade, red = downgrade)

**Files to Create:**

- `Modules/Comparison/ComparisonCore.lua`
- `Modules/Comparison/ComparisonUI.lua` (optional)

**Slash Command:**

- `/gc compare [count] [crestType]`

### Future Features (Not Prioritized)

- Weekly/seasonal crest cap tracking
- Reset timer for weekly caps
- Heatmap UI for upgrade priorities
- Profile system for alts
- Tooltip extensions showing upgrade info
- Simulation mode integration

## Next Steps

1. Test all tracks (ADVENTURER, VETERAN, HERO, MYTHIC) with real items
2. Collect missing bonus IDs for tracks with incomplete data
3. Implement compare feature from backlog
4. Add crest cap tracking (v0.3)
5. Build heatmap UI (v0.4)

## Testing Checklist

### Basic Functionality

- [ ] `/gc` displays upgrade recommendations
- [ ] `/gc 40 champion` shows simulation with 40 crests
- [ ] `/gc 80 champion` shows more upgrade steps than 40 crests
- [ ] `/gc debug on` enables debug output
- [ ] `/gc debug off` disables debug output

### Diagnostics

- [ ] `/gc test` runs and all tests show [OK]
- [ ] `/gc dump` shows all equipped items with bonus IDs
- [ ] `/gc why` explains why items are not upgradeable

### Export

- [ ] `/gc export` exports upgradeable items
- [ ] `/gc export 40 champion` exports with simulation
- [ ] Export file is written on logout to SavedVariables

### UI

- [ ] `/gc ui` toggles the UI frame
- [ ] `/gc ui 40 champion` shows simulation in UI
- [ ] UI frame is movable
- [ ] UI frame has close button

### Edge Cases

- [ ] No upgradeable items shows appropriate message
- [ ] Items at max rank are skipped
- [ ] Items without track bonus IDs are skipped
- [ ] SavedVariables file loads without errors on fresh install

## Known Issues

- Only CHAMPION track fully tested with real bonus IDs
- Other tracks may have incomplete bonus ID tables
- Bag/bank scanning requires C_Container API (Retail/Midnight only)

## Development Constraints

See `QWEN_GUARDRAILS.md` for strict development rules.

## Continue From Here

To continue development, say: **"Continue from GEARCRESTER_DEV_NOTES.md"**
