# GearCrester Roadmap

This document tracks development progress, module status, and upcoming work.
It is the primary reference for what to build next.

---

## Phase 1 — MVP (Equipped‑Only Upgrade Advisor)

### Core

- [ ] Init.lua basic bootstrap
- [ ] Event routing for equipment changes

### Inventory Scanner

- [ ] ScannerEquipped: read equipped items into DataModel

### Crest Tracker

- [ ] CrestData: read crest currency counts

### Upgrade Advisor

- [ ] AdvisorData: slot priorities + crest cost tables
- [ ] AdvisorLogic: evaluate upgradeability
- [ ] AdvisorCore: expose GetRecommendedUpgrades()
- [ ] Slash command `/gc` to print upgrade list

### Output

- [ ] Chat‑based upgrade recommendations

---

## Phase 2 — Crest System Expansion

- [ ] Weekly cap detection
- [ ] Seasonal cap detection
- [ ] Reset timer (region‑based)
- [ ] Tier rollover logic (5→1)
- [ ] Crest efficiency score (CES)

---

## Phase 3 — Inventory Expansion

- [ ] ScannerBags: detect upgradeable items in bags
- [ ] ScannerBank: detect upgradeable items in bank
- [ ] Gold‑only upgrade detection

---

## Phase 4 — UI Framework

- [ ] MainFrame: base window
- [ ] SlotList: simple list UI
- [ ] Heatmap: visual upgrade matrix
- [ ] TooltipExtensions: crest info in tooltips

---

## Phase 5 — Profiles & Customisation

- [ ] ProfileManager: save/load profiles
- [ ] Drag‑and‑drop slot priority
- [ ] Weighting system for slot importance

---

## Phase 6 — Advanced Features

- [ ] Crest forecasting (weekly + seasonal)
- [ ] Upgrade simulation mode
- [ ] Crest waste prevention warnings
- [ ] Alt support (read alt data via SavedVariables)
- [ ] Role‑aware slot priority presets

---

## Phase 7 — Polish & Release

- [ ] Icon + branding
- [ ] Documentation pass
- [ ] Performance audit
- [ ] Release packaging
