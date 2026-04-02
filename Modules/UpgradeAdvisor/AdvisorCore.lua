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

    -- Sort using the reusable sorting function
    GC.SortUpgradeResults(results)

    return results
end

function Core:PrintResults(results, title)
    if not results or #results == 0 then
        GC:Print("No upgrades available.")
        return
    end

    -- Sort results using the reusable sorting function
    GC.SortUpgradeResults(results)

    if title then
        print(title)
    else
        print("|cff00ff98GearCrester: upgrade recommendations|r")
    end

    for _, entry in ipairs(results) do
        print(GC.FormatUpgradeLine(entry, "default"))
    end
end

function Core:GetFreeUpgrades()
    -- Get all upgrades and filter for free ones only
    local allResults = self:GetRecommendedUpgrades(nil, true, true)
    local freeResults = {}

    for _, entry in ipairs(allResults) do
        if entry.isGoldOnly and (tonumber(entry.totalCrestCost) or 0) == 0 then
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

    -- Sort results using the reusable sorting function
    GC.SortUpgradeResults(results)

    print("|cff00ff98GearCrester: free upgrade opportunities|r")
    print("--------------------------------")

    for _, entry in ipairs(results) do
        print(GC.FormatUpgradeLine(entry, "free"))
    end
end

return Core
