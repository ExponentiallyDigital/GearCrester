# GearCrester

GearCrester is a modular World of Warcraft addon for Midnight that helps players understand and plan their crest‑based gear upgrades.

## Why use this?

<strong><span style="color:#ba372a">TL;DR</strong></span> <span style="color:#2dc26b">Clear visibility of your gear's crest upgrade options.</span>

## Core Principles

- No performance simulation (AMR/SimC handle that really well!)
- No stat weighting
- Pure crest upgrade visibility and planning
- Modular architecture
- Clean UI, minimal cognitive load

## Key Features

- **Upgrade Advisor** – evaluates upgradeability and provides clear recommendations
- **Crest‑aware planning** – understands track and rank via bonus IDs and crest rules
- **Gold‑only upgrades** – detects upgrades that cost gold only and marks them as `[GOLD‑ONLY]`
- **Inventory scanning** – scans equipped gear, bags, and bank
- **Export system** – writes upgradeable items to SavedVariables for external analysis
- **Self‑diagnostics** – `/gc test` runs a full subsystem health check
- **Configurable slot weights** – prioritize slots (1–20, lower = higher priority)
- **UI frame** – movable, scrollable UI for recommendations and simulations

---

# Installation

1. Move/copy the `GearCrester` folder to your `_retail_/Interface/AddOns/` directory
2. Restart World of Warcraft or logout and login

On load/login, GearCrester initializes its data model, scanner, advisor, and UI modules.

---

# Configuration

GearCrester works out of the box with default "weights" or priority values for gear slot upgrade sequencing. The order can be modified via `/gc weight <slot <value>` slash commands, see below. Any changes you make to weights are saved, and can be listed or reset via the below commands.

## Slash Commands

| Command                          | Description                                                                              |
| -------------------------------- | ---------------------------------------------------------------------------------------- |
| `/gc`                            | Show upgrade recommendations for equipped gear, bags, and bank                           |
| `/gc <count> <crestType>`        | Simulate upgrades with specified crest count                                             |
| `/gc debug on\|off`              | Enable/disable debug output                                                              |
| `/gc dump`                       | Dump all equipped items with bonus IDs, track, and rank                                  |
| `/gc why`                        | Explain why items are not upgradeable                                                    |
| `/gc ui`                         | Toggle the UI frame                                                                      |
| `/gc ui <count> <crestType>`     | Show simulated results in the UI frame                                                   |
| `/gc test`                       | Run subsystem diagnostics                                                                |
| `/gc export`                     | Export upgradeable items to SavedVariables                                               |
| `/gc export <count> <crestType>` | Export upgradeable items with crest simulation                                           |
| `/gc weight <slot> <value>`      | Set slot priority weight (1–20), lower values = higher priority, see "Slot names" below  |
| `/gc weight reset`               | Reset all slot weights                                                                   |
| `/gc weight list`                | Show all slot weights                                                                    |
| `/gc help`                       | Show all commands                                                                        |
| `/gc calibrate <slot>`           | Compare GearCrester's upgrade detection against Blizzard's C_Item.GetItemUpgradeInfo API |

### Slot names

This is the default priority sequence from highest to lowest:

```text
    MainHand
    OffHand
    Head
    Chest
    Legs
    Waist
    Wrist
    Hands
    Shoulder
    Feet
    Neck
    Back
    Finger1
    Finger2
    Trinket1
    Trinket2
```

### Calibration Command

The `/gc calibrate <slot>` command compares GearCrester's track/rank detection against Blizzard's official `C_Item.GetItemUpgradeInfo()` API for the specified equipped slot.

**Example:**

```
/gc calibrate head
```

**Output:**

```
[CALIBRATE] Head
  Bonus IDs: 6652, 13577, 12793
  GearCrester: track=HERO rank=1
  Blizzard:    track=HERO rank=1
  [OK] Match
```

Use this command to verify detection accuracy, especially for tier set items where bonus-ID mappings may differ from Blizzard's upgrade system.

## Crest Inventory

GearCrester now reads your actual crest inventory using Blizzard's `C_CurrencyInfo.GetCurrencyInfo()` API. When you run `/gc` without simulation, it shows upgrades you can afford with your current crests.

Use `/gc crests` to see your current inventory:

```
/gc crests
```

**Example Output:**

```
GearCrester: Current Crest Inventory
  Adventurer: 110
  Veteran:    400
  Champion:    55
  Hero:        85
  Myth:         0
```

## Crest Types

Valid crest types:

- `adventurer`
- `veteran`
- `champion`
- `hero`
- `myth`

## Examples

```text
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
/gc export                   -- Export upgradeable items
/gc export 40 champion       -- Export with crest simulation
/gc weight MainHand 1        -- Set "MainHand" to highest priority
/gc weight Back 20           -- Set "Back" to lowest priority
/gc weight list              -- Show all slot weights
/gc weight reset             -- Reset weights to default
/gc help                     -- Show help
```

---

# Export

- The export function is for future intreroperability with other addons/tools for gear selection/upgrade advice
- Export data is saved to `GearCrester.lua` in the section named `GearCresterExportDB`
- NB the export file is **only** written on logout to `WTF/Account/<ACCOUNT>/SavedVariables/GearCrester.lua`
- Export includes only upgradeable items with full details (slot, track, rank, ilvl, crest cost)
- You can export a simulated number of available crests

---

# Gold‑Only Upgrades

If you own two items of the **same track** and one has a **higher rank**:

- Upgrading the lower‑rank item up to the higher rank costs **zero crests**
- These are marked as `[GOLD‑ONLY]`
- Gold‑only upgrades do **not** consume crests

---

# Technical Details

## Inventory Scanning

- Scans equipped gear, bags, and bank
- Extracts item IDs, bonus IDs, and metadata
- Feeds results into the core data model

## Upgrade Evaluation

- Parses bonus IDs to determine track and rank
- Applies Midnight crest rules to compute:
    - current rank
    - maximum rank
    - crest cost per step
- Identifies gold‑only upgrades

## UI and Diagnostics

- Movable, scrollable UI frame
- `/gc test` validates scanner, advisor, crest tracker, UI, and export
- `/gc why` explains non‑upgradeable items

## Performance

- Modular, lose coupled, data‑driven architecture
- Scanner and advisor operate on snapshots
- Export writes once per session
- Typical RAM use \***\*insert value here\*\***

---

# Roadmap

For development progress and potential future functionality, see [docs/roadmap.md](https://github.com/ExponentiallyDigital/GearCrester/) on the GearCrester GitHub repo.

---

# Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with various gear and crest scenarios, see [docs/testplans](https://github.com/ExponentiallyDigital/GearCrester/) on the GearCrester GitHub repo.
5. Submit a pull request

Please follow Lua best practices and maintain compatibility with existing functionality.

---

## Bugs and new features

Found a bug or want to submit a feature request? [Open an issue here](https://github.com/ExponentiallyDigital/GearCrester/issues).

---

## Support

This tool is unsupported and may cause objects in mirrors to be closer than they appear etc. Batteries not included.

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

Copyright (C) 2026 ArcNineOhNine
