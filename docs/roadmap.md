# GearCrester Roadmap

This document tracks development progress, module status, and upcoming work.
It is the primary reference for what to build next.

---

## Phase 1 — MVP (Equipped‑Only Upgrade Advisor) ✅ COMPLETE

### Core

- [x] Init.lua basic bootstrap
- [x] Event routing for equipment changes

### Inventory Scanner

- [x] ScannerEquipped: read equipped items into DataModel
- [x] ScannerBags: read bag items into DataModel
- [x] ScannerBank: read bank items into DataModel

### Crest Tracker

- [x] CrestData: read crest currency counts

### Upgrade Advisor

- [x] AdvisorData: slot priorities + crest cost tables
- [x] AdvisorLogic: evaluate upgradeability
- [x] AdvisorCore: expose GetRecommendedUpgrades()
- [x] Slash command `/gc` to print upgrade list

### Output

- [x] Chat‑based upgrade recommendations

---

## Phase 2 — Crest System Expansion (Backlog)

- [ ] Weekly cap detection
- [ ] Seasonal cap detection
- [ ] Reset timer (region‑based)
- [ ] Tier rollover logic (5->1)
- [ ] Crest efficiency score (CES)

---

## Phase 3 — Inventory Expansion ✅ COMPLETE

- [x] ScannerBags: detect upgradeable items in bags
- [x] ScannerBank: detect upgradeable items in bank
- [x] Gold‑only upgrade detection

---

## Phase 4 — UI Framework (Partial)

- [x] DashboardFrame: movable dashboard with tabs
- [x] MainFrame: legacy text-based frame
- [ ] SlotList: simple list UI (stub)
- [ ] Heatmap: visual upgrade matrix (stub)
- [ ] TooltipExtensions: crest info in tooltips (stub)

---

## Phase 5 — Profiles & Customisation (Partial)

- [x] ProfileManager: basic profile reading
- [x] Weighting system for slot importance (1-20)
- [ ] Drag‑and‑drop slot priority (future)

---

## Phase 6 — Advanced Features (Backlog)

- [ ] Crest forecasting (weekly + seasonal)
- [x] Upgrade simulation mode
- [ ] Crest waste prevention warnings
- [ ] Alt support (read alt data via SavedVariables)
- [ ] Role‑aware slot priority presets

---

## Phase 7 — Polish & Release (Partial)

- [x] Documentation pass
- [x] Self-diagnostics test suite
- [x] Export functionality
- [ ] Performance audit
- [ ] Icon + branding
- [ ] Release packaging
