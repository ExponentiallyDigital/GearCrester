# GearCrester

GearCrester is a modular World of Warcraft addon for Midnight that helps players understand and plan their crest‑based gear upgrades.

_This is a proof of concept release to ensure that logic and data are correct, most functionality is via slash commands, this will be replaced by a full GUI in a later release._

## Why use this?

<strong><span style="color:#ba372a">TL;DR</strong></span> <span style="color:#2dc26b">Clear visibility of your gear's crest upgrade options.</span>

## Core Principles

- Pure crest upgrade visibility to help plan crest spend
- No performance simulation or stat weighting decisioning (AMR and SimC handle that really well!)
- Modular architecture
- Clean minimalistic UI
- Command line driven for simplicity and speed (a full graphical user interface is being planned for)

## Key Features

- **Upgrade Advisor** – evaluates upgradeability and provides clear recommendations
- **Crest‑aware planning** – understands track and rank via bonus IDs and crest rules
- **Gold‑only upgrades** – detects upgrades that cost gold only and marks them as `[FREE]`
- **Inventory scanning** – scans equipped gear, bags, and bank
- **Export system** – writes upgradeable items to SavedVariables for analysis/manipulation by external tools (think potrential AMR/Simc integration)
- **Self‑diagnostics** – `/gc test` runs a full subsystem health check
- **Configurable slot weights** – prioritize slots (1–20, lower = higher priority)
- **UI frame** – movable, scrollable UI for recommendations and simulations

---

# Installation

1. Move/copy the `GearCrester` folder to your `_retail_/Interface/AddOns/` directory
2. Restart World of Warcraft or logout and login

---

# Configuration

1. Open your bank and bags so GearCrester can see what gear you have available
    - run /gc scan
2. Head over to the upgrade NPC and open their dialogue box then
   run `/gc calibrate npc` to scan the higest level you've obtained for your gear, this is used by the crest "free" (requiring gold only) upgrade scanner
3. GearCrester works out of the box with default "weights" or priority values for gear slot upgrade sequencing. The order can be modified via `/gc weight <slot <value>` slash commands, see below. Any changes you make to weights are saved, and can be listed or reset via the below commands.

---

# Slash Commands

| Command                          | Description                                                                             |
| -------------------------------- | --------------------------------------------------------------------------------------- |
| `/gc`                            | Show upgrade recommendations for equipped gear, bags, and bank                          |
| `/gc <count> <crestType>`        | Simulate upgrades with specified crest count                                            |
| `/gc ui`                         | Toggle the UI frame                                                                     |
| `/gc ui <count> <crestType>`     | Show simulated results in the UI frame                                                  |
| `/gc export`                     | Export upgradeable items to SavedVariables                                              |
| `/gc export <count> <crestType>` | Export upgradeable items with crest simulation                                          |
| `/gc weight <slot> <value>`      | Set slot priority weight (1–20), lower values = higher priority, see "Slot names" below |
| `/gc weight reset`               | Reset all slot weights                                                                  |
| `/gc weight list`                | Show all slot weights                                                                   |
| `/gc help`                       | Show all commands                                                                       |
| `/gc calibrate npc`              | Scan all equipped items at the Item Upgrade NPC (must have NPC window open)             |

<br>
Several commands are available for verification purposes, none are needed during normal use:

| Development Commands   | Description                                                                              |
| ---------------------- | ---------------------------------------------------------------------------------------- |
| `/gc debug on\|off`    | Enable/disable debug output                                                              |
| `/gc calibrate <slot>` | Compare GearCrester's upgrade detection against Blizzard's C_Item.GetItemUpgradeInfo API |
| `/gc dump`             | Dump all equipped items with bonus IDs, track, and rank                                  |
| `/gc why`              | Explain why items are or are not upgradeable                                             |
| `/gc test`             | Run subsystem diagnostics                                                                |

## Examples

```text
/gc                          -- Show real upgrade recommendations
/gc 40 champion              -- Simulate with 40 Champion crests
/gc 80 hero                  -- Simulate with 80 Hero crests
/gc ui                       -- Open/close the UI frame
/gc ui 40 champion           -- Show simulated results in UI frame
/gc ui 60 myth               -- Show 60 Myth crest simulation in UI frame
/gc export                   -- Export upgradeable items
/gc export 40 champion       -- Export with crest simulation
/gc weight MainHand 1        -- Set "MainHand" to highest priority
/gc weight Back 20           -- Set "Back" to lowest priority
/gc weight list              -- Show all slot weights
/gc weight reset             -- Reset weights to default
/gc help                     -- Show help
```

## Slot Caps (Important)

GearCrester needs to see your items once to learn your upgrade caps.
Blizzard does not expose slot caps through the API, so GearCrester reconstructs them.

**To populate slot caps:**

1. Open your **bags** once after installing the addon.
2. Visit your **bank** once per character per season.

GearCrester will automatically scan your items and store the highest track/rank
you have ever achieved for each slot.
You do **not** need to keep the items — once scanned, your gear's highest level is saved

**Commands:**

- `/gc slotcaps` — view stored slot caps
- `/gc scan` — manually rescan inventory/bank
- `/gc free` — list free upgrades

---

# Gold‑Only Upgrades

If you own two items of the **same track** and one has a **higher rank**:

- Upgrading the lower‑rank item up to the higher rank costs **zero crests**
- These are marked as `[free]`
- Gold‑only upgrades do **not** consume crests

## Free Upgrades (Track-Cap Inheritance)

GearCrester automatically detects free upgrade opportunities through track-cap inheritance. If you have a higher-track item at max rank (e.g., Champion 6/6 Neck), lower-track items of the same slot (e.g., Veteran 1/6 Neck) can be upgraded to their max rank (Veteran 6/6) for FREE using gold only.

Free upgrades are marked with `[FREE]` in the output.

Use `/gc free` to see only free upgrade opportunities:

```
/gc free
```

**Example Output:**

```
GearCrester Free Upgrade Opportunities
--------------------------------
Neck [Equipped]: 233 -> 250 (FREE)
```

## Crest Inventory

GearCrester reads your actual crest inventory using Blizzard's published API. When you run `/gc` without simulation, it shows upgrades you can afford with your current crests.

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

### Slot names

Item slot names and default priority sequence from highest to lowest:

```text
    1. MainHand
    2. OffHand
    3. Head
    4. Chest
    5. Legs
    6. Waist
    7. Wrist
    8. Hands
    9. Shoulder
    10. Feet
    11. Neck
    12. Back
    13. Finger1
    14. Finger2
    15. Trinket1
    16. Trinket2
```

---

# Export

- The export function is for future intreroperability with other addons/tools for gear selection/upgrade advice
- Export data is saved to `GearCrester.lua` in the section named `GearCresterExportDB`
- NB the export file is **only** written on logout to `WTF/Account/<ACCOUNT>/SavedVariables/GearCrester.lua`
- Export includes only upgradeable items with full details (slot, track, rank, ilvl, crest cost)
- You can also export a simulated number of available crests

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
- Identifies gold‑only (crest "free") upgrades

## Performance

- Modular, lose coupled, data‑driven architecture
- Scanner and advisor operate on snapshots
- Export writes once per session
- Typical RAM use: ~800KB (varies with inventory size)

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
