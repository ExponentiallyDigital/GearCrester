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

    -- Apply gold-only detection (only for non-simulated results)
    if FreeUpgrade then
        FreeUpgrade:ApplyGoldOnlyDetection(results, simulatedCrests)
    end

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
        print("|cff00ff98GearCrester Upgrade Recommendations:|r")
    end

    for _, entry in ipairs(results) do
        local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
        local goldOnlyText = entry.isGoldOnly and " [FREE]" or ""
        local location = entry.location and string.format(" [%s]", entry.location) or ""
        -- Guardrail 1.1: Display total crest cost for upgrade path, not per-step cost
        local totalCost = entry.totalCrestCost or entry.crestCostPerStep or entry.crestCost or 0
        local line = string.format(
            "%s%s: %d -> %d (%s%s x%d|r)%s%s",
            entry.slotName or entry.location,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            affordColor,
            entry.crestType,
            totalCost,
            goldOnlyText,
            entry.goldOnlyTargetRank and string.format(" (to rank %d)", entry.goldOnlyTargetRank) or ""
        )
        print(line)
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

    print("|cff00ff98GearCrester Free Upgrade Opportunities|r")
    print("--------------------------------")

    for _, entry in ipairs(results) do
        local location = entry.location and string.format(" [%s]", entry.location) or ""
        local line = string.format(
            "%s%s: %d -> %d (FREE)",
            entry.slotName or entry.location,
            location,
            entry.currentIlvl,
            entry.nextIlvl
        )
        print(line)
    end
end

return Core
