# GearCrester Test Plan — MainFrame UI

This test plan validates the MainFrame UI module, which displays upgrade recommendations in a scrollable frame with hyperlinks.

---

## 1. Enable Debug Mode

/gc debug on

Expected:

- Debug mode enabled message.

---

## 2. Open UI Frame

/gc ui

Expected:

- MainFrame window appears with upgrade recommendations.
- Content is sorted: equipped items first, then bag items sorted by bag number then slot number.
- Item links are clickable and show tooltips on hover.
- Shift+click inserts link into chat.
- Scrollbar appears if content exceeds frame height.

---

## 3. Validate Content Structure

The UI should display:

- Header: "GearCrester: upgrade recommendations"
- Blank line
- Each upgrade: "SlotName [location]: currentILvl -> nextILvl (TRACK x totalCost) [itemLink]"
- For gold-only: "(TRACK FREE to rank X)"
- Items sorted by bag/slot when applicable
- **Track names displayed in color**: ADVENTURER (yellow), VETERAN (green), CHAMPION (purple), HERO (pink), MYTH (red)
- Item links clickable with tooltip on hover, Shift+click to insert into chat
- Regular text (non-title) in non-bold font

**Note:** Display shows `TotalCrestCost` (total for upgrade path), not per-step cost.

---

## 4. Test Simulated Crests

/gc ui 50 hero

Expected:

- MainFrame shows recommendations assuming 50 HERO crests available.
- Header includes "(simulated: 50 HERO)"
- Same sorting and hyperlink behavior as /gc ui

---

## 5. Hyperlink Functionality

- Hover over item links: tooltip appears.
- Shift+click item links: link inserted into chat edit box.
- Regular click: no action (preserves standard behavior).

---

## 6. Scrolling

- If content fits: no scrollbar visible.
- If content exceeds height: scrollbar appears and functions properly.
- Mouse wheel scrolls the content.

---

## 5. Validate Item Data Structure

Each item entry must include:

- correct sort sequence (equipped, then by bag then slot number, bank nags and slots last)
- Slot
- slotID
- ItemLink
- Track
- Rank
- CurrentILvl
- UpgradeSteps
- CrestCostPerStep (cost per individual step, always 20)
- TotalCrestCost (UPGRADE STEPS \* 20 — this is what should be displayed to users)
- isGoldOnly aka "free" (only costs gfold and not crests)

**Note:** UI display should show `TotalCrestCost`, not `CrestCostPerStep`.

---

## 8. Regression Checks

- No Lua errors when opening/closing frame.
- Frame is movable by dragging title bar.
- Close button hides the frame.
- /gc ui toggles frame visibility.
- Content updates when inventory changes (after rescanning).

---

# End of Test Plan
