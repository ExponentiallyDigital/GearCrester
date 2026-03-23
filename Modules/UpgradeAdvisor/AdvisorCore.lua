local addonName, GC = ...

GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
local Core = {}
GC.modules.UpgradeAdvisor.Core = Core

function Core:GetRecommendedUpgrades(simulatedCrests)
    GC.modules.InventoryScanner.ScannerEquipped:Scan()

    local equipped = GC.DataModel.equipped
    local Logic = GC.modules.UpgradeAdvisor.Logic

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] GetRecommendedUpgrades called|r")
        print(string.format("|cff00ff98[DEBUG] Equipped table size: %d|r", equipped and #equipped or 0))
    end

    local results = Logic:Evaluate(equipped, simulatedCrests)

    return results
end

function Core:PrintResults(results, title)
    if not results or #results == 0 then
        GC:Print("No upgrades available for equipped gear.")
        return
    end

    if title then
        print(title)
    else
        print("|cff00ff98GearCrester Upgrade Recommendations:|r")
    end

    for _, entry in ipairs(results) do
        local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
        local line = string.format(
            "%s: %d -> %d (%s%s x%d|r)",
            entry.slotName,
            entry.currentIlvl,
            entry.nextIlvl,
            affordColor,
            entry.crestType,
            entry.crestCost
        )
        print(line)
    end
end

return Core
