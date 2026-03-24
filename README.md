# GearCrester

GearCrester is a modular World of Warcraft addon for Midnight that helps players understand and plan their crest-based gear upgrades.

## Core Principles

- No performance simulation (AMR handles that)
- No stat weighting
- Pure upgrade visibility and planning
- Modular architecture
- Clean UI, minimal cognitive load

## Slash Commands

| Command                          | Description                                                                     |
| -------------------------------- | ------------------------------------------------------------------------------- |
| `/gc`                            | Show upgrade recommendations for equipped gear, bags, and bank                  |
| `/gc <count> <crestType>`        | Simulate upgrades with specified crest count (e.g., `/gc 40 champion`)          |
| `/gc debug on\|off`              | Enable/disable debug output                                                     |
| `/gc dump`                       | Dump all equipped items with bonus IDs, track, and rank                         |
| `/gc why`                        | Show diagnostics explaining why items are not upgradeable                       |
| `/gc ui`                         | Toggle the upgrade advisor UI frame                                             |
| `/gc ui <count> <crestType>`     | Show simulated upgrade results in UI frame (e.g., `/gc ui 40 champion`)         |
| `/gc test`                       | Run self-diagnostics and display subsystem status                               |
| `/gc export`                     | Export all upgradeable items to SavedVariables                                  |
| `/gc export <count> <crestType>` | Export upgradeable items with crest simulation (e.g., `/gc export 40 champion`) |
| `/gc weight <slot> <value>`      | Set slot priority weight (1-20, lower = higher priority)                        |
| `/gc weight reset`               | Reset all slot weights to default                                               |
| `/gc weight list`                | Show all slot weights                                                           |
| `/gc help`                       | Show all commands with descriptions                                             |

### Crest Types

Valid crest types for simulation:

- `adventurer`
- `veteran`
- `champion`
- `hero`
- `myth`

### Examples

```
/gc                          -- Show real upgrade recommendations
/gc 40 champion              -- Simulate with 40 Champion crests
/gc 80 hero                  -- Simulate with 80 Hero crests
/gc debug on                 -- Enable debug mode
/gc dump                     -- Show all items and their bonus IDs
/gc why                      -- Explain why items can't be upgraded
/gc ui                       -- Open/close the UI frame
/gc ui 40 champion           -- Show simulated results in UI frame
/gc ui 60 myth               -- Show 60 Myth crest simulation in UI frame
/gc test                     -- Run self-diagnostics
/gc export                   -- Export upgradeable items (no simulation)
/gc export 40 champion       -- Export with 40 Champion crest simulation
/gc weight MainHand 1        -- Set MainHand to highest priority
/gc weight list              -- Show all slot weights
/gc weight reset             -- Reset weights to default
/gc help                     -- Show this help
```

### Export Notes

- Export data is saved to `GearCresterExportDB` SavedVariables
- File is written on logout: `WTF/Account/<ACCOUNT>/SavedVariables/GearCrester.lua`
- Export includes only upgradeable items with full details (slot, track, rank, ilvl, crest cost)

### Upgrade Order System

- Default slot priorities are defined in AdvisorData.lua
- User can override priorities with `/gc weight <slot> <value>` (1-20)
- Lower numbers = higher priority
- Custom weights persist across sessions in SavedVariables

### Gold-Only Upgrades

- If you own two items of the SAME TRACK and one has a HIGHER RANK:
    - Upgrading the lower-rank item up to the higher rank costs ZERO crests
    - These are marked as `[GOLD-ONLY]` in output
    - Gold-only upgrades do NOT consume crests

## Modules

- **Upgrade Advisor** - Evaluates upgradeability and provides recommendations
- **UpgradeOrder** - Configurable slot priority system
- **FreeUpgrade** - Gold-only upgrade detection
- **Inventory Scanner** - Scans equipped gear, bags, and bank
- **Crest Tracker** - Tracks crest currency counts
- **UI Framework** - Provides UI frames and components
- **InventoryOverview** - UI data-layer foundation
- **Profiles** - Manages user profiles (stub)
- **Diagnostics** - Self-test and diagnostic tools
- **Export** - Export upgradeable items to file

## Features

- Bonus ID parsing for track and rank detection
- Multi-step upgrade path display
- Bag and bank scanning
- Debug mode for troubleshooting
- Movable UI frame with scrollable output
- Self-diagnostic test suite
- Export functionality for upgradeable items
- User-defined slot weighting system
- Gold-only upgrade detection

## Roadmap

- v0.1: Equipped-only Upgrade Advisor ✓
- v0.2: Bag scanning ✓
- v0.3: Crest caps + reset timer
- v0.4: Heatmap UI

For development progress, see: [docs/roadmap.md](docs/roadmap.md)

## Development

See [docs/GEARCRESTER_DEV_NOTES.md](docs/GEARCRESTER_DEV_NOTES.md) for development notes.

See [QWEN_GUARDRAILS.md](QWEN_GUARDRAILS.md) for development constraints.
