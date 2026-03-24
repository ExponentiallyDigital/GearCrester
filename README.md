# GearCrester

GearCrester is a modular World of Warcraft addon for Midnight that helps players understand and plan their crest-based gear upgrades.

## Core Principles

- No performance simulation (AMR handles that)
- No stat weighting
- Pure upgrade visibility and planning
- Modular architecture
- Clean UI, minimal cognitive load

## Slash Commands

| Command                   | Description                                                            |
| ------------------------- | ---------------------------------------------------------------------- |
| `/gc`                     | Show upgrade recommendations for equipped gear, bags, and bank         |
| `/gc <count> <crestType>` | Simulate upgrades with specified crest count (e.g., `/gc 40 champion`) |
| `/gc debug on`            | Enable debug output                                                    |
| `/gc debug off`           | Disable debug output                                                   |
| `/gc dump`                | Dump all equipped items with bonus IDs, track, and rank                |
| `/gc why`                 | Show diagnostics explaining why items are not upgradeable              |
| `/gc ui`                  | Toggle the upgrade advisor UI frame                                    |

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
```

## Modules

- **Upgrade Advisor** - Evaluates upgradeability and provides recommendations
- **Inventory Scanner** - Scans equipped gear, bags, and bank
- **Crest Tracker** - Tracks crest currency counts
- **UI Framework** - Provides UI frames and components
- **Profiles** - Manages user profiles (stub)

## Features

- Bonus ID parsing for track and rank detection
- Multi-step upgrade path display
- Bag and bank scanning
- Debug mode for troubleshooting
- Movable UI frame with scrollable output

## Roadmap

- v0.1: Equipped-only Upgrade Advisor ✓
- v0.2: Bag scanning ✓
- v0.3: Crest caps + reset timer
- v0.4: Heatmap UI

For development progress, see: [docs/roadmap.md](docs/roadmap.md)

## Development

See [docs/GEARCRESTER_DEV_NOTES.md](docs/GEARCRESTER_DEV_NOTES.md) for development notes.

See [QWEN_GUARDRAILS.md](QWEN_GUARDRAILS.md) for development constraints.
