local addonName, GC = ...

GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
local Core = {}
GC.modules.UpgradeAdvisor.Core = Core

function Core:GetRecommendedUpgrades(simulatedCrests, includeBags, includeBank)
    GC.modules.InventoryScanner.ScannerEquipped:Scan()

    if includeBags then
        GC.modules.InventoryScanner.ScannerBags:Scan()
    end

    if includeBank then
        GC.modules.InventoryScanner.ScannerBank:Scan()
    end

    local Logic = GC.modules.UpgradeAdvisor.Logic
    local UpgradeOrder = GC.modules.UpgradeAdvisor.UpgradeOrder
    local FreeUpgrade = GC.modules.UpgradeAdvisor.FreeUpgrade

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] GetRecommendedUpgrades called|r")
        print(string.format("|cff00ff98[DEBUG] Scanning: equipped=%s bags=%s bank=%s|r",
            "yes", includeBags and "yes" or "no", includeBank and "yes" or "no"))
    end

    local results = Logic:GetRecommendedUpgrades(simulatedCrests, includeBags, includeBank)

    -- Sort using UpgradeOrder priorities
    if UpgradeOrder then
        table.sort(results, function(a, b)
            local priorityA = UpgradeOrder:GetEffectivePriority(a.slotID)
            local priorityB = UpgradeOrder:GetEffectivePriority(b.slotID)

            if priorityA ~= priorityB then
                return priorityA < priorityB
            end
            return a.nextIlvl > b.nextIlvl
        end)
    end

    return results
end

function Core:PrintResults(results, title)
    if not results or #results == 0 then
        GC:Print("No upgrades available.")
        return
    end

    if title then
        print(title)
    else
        print("|cff00ff98GearCrester: upgrade recommendations|r")
    end

    -- Split results into non-bag and bag entries
    local nonBag = {}
    local bagEntries = {}

    for _, entry in ipairs(results) do
        local isBag = entry.location and entry.location:match("^bag (%d+), slot (%d+)")
        if isBag then
            table.insert(bagEntries, entry)
        else
            table.insert(nonBag, entry)
        end
    end

    -- Sort ONLY bag entries by bag then slot
    table.sort(bagEntries, function(a, b)
        local aBag, aSlot = a.location:match("bag (%d+), slot (%d+)")
        local bBag, bSlot = b.location:match("bag (%d+), slot (%d+)")

        aBag, aSlot = tonumber(aBag), tonumber(aSlot)
        bBag, bSlot = tonumber(bBag), tonumber(bSlot)

        if aBag ~= bBag then
            return aBag < bBag
        end
        return aSlot < bSlot
    end)

    -- Print non-bag entries first (equipped, etc.)
    for _, entry in ipairs(nonBag) do
        local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
        local location = entry.location and (" [" .. entry.location .. "]") or ""
        local totalCost = entry.totalCrestCost or entry.crestCostPerStep or entry.crestCost or 0
        local track = GC.ColorTrack(entry.trackName or entry.crestType or "UNKNOWN")
        local costText
        local goldOnlyText = ""
        if entry.isGoldOnly then
            if entry.goldOnlyTargetRank then
                costText = string.format("(%s FREE to rank %d)", track, entry.goldOnlyTargetRank)
            else
                costText = string.format("(%s FREE)", track)
            end
        else
            costText = string.format("(%s%s x%d|r)", affordColor, track, totalCost)
            goldOnlyText = entry.isGoldOnly and " [FREE]" or ""
        end
        local itemName = entry.itemLink and (" " .. entry.itemLink) or ""
        local rankText = (not entry.isGoldOnly and entry.goldOnlyTargetRank) and string.format(" (to rank %d)", entry.goldOnlyTargetRank) or ""

        print(string.format(
            "%s%s: %d -> %d %s%s%s%s",
            entry.slotName,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            costText,
            goldOnlyText,
            rankText,
            itemName
        ))
    end

    -- Print sorted bag entries
    for _, entry in ipairs(bagEntries) do
        local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
        local location = entry.location and (" [" .. entry.location .. "]") or ""
        local totalCost = entry.totalCrestCost or entry.crestCostPerStep or entry.crestCost or 0
        local track = GC.ColorTrack(entry.trackName or entry.crestType or "UNKNOWN")
        local costText
        local goldOnlyText = ""
        if entry.isGoldOnly then
            if entry.goldOnlyTargetRank then
                costText = string.format("(%s FREE to rank %d)", track, entry.goldOnlyTargetRank)
            else
                costText = string.format("(%s FREE)", track)
            end
        else
            costText = string.format("(%s%s x%d|r)", affordColor, track, totalCost)
            goldOnlyText = entry.isGoldOnly and " [FREE]" or ""
        end
        local itemName = entry.itemLink and (" " .. entry.itemLink) or ""
        local rankText = (not entry.isGoldOnly and entry.goldOnlyTargetRank) and string.format(" (to rank %d)", entry.goldOnlyTargetRank) or ""

        print(string.format(
            "%s%s: %d -> %d %s%s%s%s",
            entry.slotName,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            costText,
            goldOnlyText,
            rankText,
            itemName
        ))
    end
end

function Core:GetFreeUpgrades()
    -- Get all upgrades and filter for free ones only
    local allResults = self:GetRecommendedUpgrades(nil, true, true)
    local freeResults = {}

    for _, entry in ipairs(allResults) do
        if entry.isGoldOnly and entry.totalCrestCost == 0 then
            table.insert(freeResults, entry)
        end
    end

    return freeResults
end

function Core:PrintFreeUpgrades()
    local results = self:GetFreeUpgrades()

    if not results or #results == 0 then
        GC:Print("No free upgrades available.")
        return
    end

    print("|cff00ff98GearCrester: free upgrade opportunities|r")
    print("--------------------------------")

    for _, entry in ipairs(results) do
        local location = ""
        if entry.location then
            location = " [" .. entry.location .. "]"
        end
        local itemName = ""
        if entry.itemLink then
            itemName = " " .. entry.itemLink
        end
        local line = string.format(
            "%s%s: %d -> %d [FREE]%s",
            entry.slotName,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            itemName
        )
        print(line)
    end
end

return Core
