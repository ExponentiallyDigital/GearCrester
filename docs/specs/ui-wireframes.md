# GearCrester UI Wireframes

This document describes the current UI implementation in GearCrester.

---

## Dashboard UI (Current Implementation)

**Location:** `Modules/UI/DashboardFrame.lua`

**Frame:** `GearCresterDashboard` (650x520 pixels, centered, movable)

### Layout

```
┌─────────────────────────────────────────────────────────────┐
│  [Icon]  GearCrester v0.0.4                    [Close]      │
├─────────────────────────────────────────────────────────────┤
│  [Upgrades] [Crests] [Equipped] [Help]  ← Tabs              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                                                     │   │
│  │  Tab Content Area (scrollable)                      │   │
│  │                                                     │   │
│  │  Upgrades Tab:                                      │   │
│  │  • Head: 489 -> 493 (CHAMPION x8) [item link]      │   │
│  │  • MainHand: 476 -> 480 (HERO x40) [item link]     │   │
│  │                                                     │   │
│  │  Crests Tab:                                        │   │
│  │  ADVENTURER: 110                                    │   │
│  │  VETERAN:    400                                    │   │
│  │  CHAMPION:    55                                    │   │
│  │  HERO:        85                                    │   │
│  │  MYTH:         0                                    │   │
│  │                                                     │   │
│  │  Equipped Tab:                                      │   │
│  │  Head: [item link]                                  │   │
│  │  Neck: [item link]                                  │   │
│  │  ...                                                │   │
│  │                                                     │   │
│  │  Help Tab:                                          │   │
│  │  /gc - Show recommendations                         │   │
│  │  /gc <count> <crestType> - Simulate                 │   │
│  │  ...                                                │   │
│  │                                                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Tab Behavior

- **Upgrades:** Shows upgrade recommendations from `UpgradeAdvisor.Core:GetRecommendedUpgrades()`
- **Crests:** Shows current crest inventory from `CrestTracker.CrestData:GetAllCrestCounts()`
- **Equipped:** Shows all equipped items with their links
- **Help:** Shows slash command reference

### Item Link Interaction

All item links are:

- **Clickable:** Shift-click to chat, Ctrl-click to open in dressup frame, etc.
- **Hoverable:** Shows GameTooltip with item details

### Color Coding

- Track names use `GC.TRACK_COLORS` (ADVENTURER=Yellow, VETERAN=Green, CHAMPION=Purple, HERO=Pink, MYTH=Red)
- Affordance: Green = can afford, Red = cannot afford
- FREE upgrades marked with `[FREE]` tag

---

## Legacy MainFrame

**Location:** `Modules/UI/MainFrame.lua`

A simpler text-based UI frame for backward compatibility. Shows upgrade recommendations in HTML format.

---

## Stub UI Modules (Not Implemented)

The following UI modules exist as stubs for future implementation:

- `Heatmap.lua` - Visual upgrade matrix
- `SlotList.lua` - Simple list UI
- `TooltipExtensions.lua` - Crest info in item tooltips

---

## UI Utilities

**Location:** `Modules/UI/UIUtils.lua`

Reusable UI components:

- `CreatePanel()` - Styled panel with backdrop
- `CreateProgressBar()` - Progress bar widget
- `CreateTabButton()` - Tab button with active/inactive states

**Color Palette:**

- Background: Dark navy
- Accent: Green/cyan
- Text: White/light gray
- Border: Tooltip border style
