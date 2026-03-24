local addonName, GC = ...

local Export = {}
GC.modules.Export = GC.modules.Export or {}
GC.modules.Export.Export = Export

function Export:GenerateExportData(results)
    if not results or #results == 0 then
        return {}
    end

    local exportItems = {}

    for _, entry in ipairs(results) do
        local upgradeSteps = entry.nextRank - entry.currentRank
        local totalCrestCost = upgradeSteps * entry.crestCost

        table.insert(exportItems, {
            Slot = entry.slotName or "Unknown",
            Location = entry.location,
            ItemLink = entry.itemLink,
            CurrentILvl = entry.currentIlvl,
            CurrentRank = entry.currentRank,
            Track = entry.trackName,
            UpgradeSteps = upgradeSteps,
            CrestCostPerStep = entry.crestCost,
            TotalCrestCost = totalCrestCost,
        })
    end

    return exportItems
end

function Export:GenerateExportString(exportItems)
    if not exportItems or #exportItems == 0 then
        return "-- No upgradeable items found"
    end

    local lines = {}
    table.insert(lines, "-- GearCrester Export")
    table.insert(lines, "-- Generated: " .. (os.date and os.date("%Y-%m-%d %H:%M:%S") or "Unknown"))
    table.insert(lines, "-- Upgradeable Items")
    table.insert(lines, "")

    for _, item in ipairs(exportItems) do
        table.insert(lines, "[Item]")
        table.insert(lines, "Slot = " .. item.Slot)
        if item.Location then
            table.insert(lines, "Location = " .. item.Location)
        end
        table.insert(lines, "ItemLink = " .. (item.ItemLink or "nil"))
        table.insert(lines, "CurrentILvl = " .. (item.CurrentILvl or "nil"))
        table.insert(lines, "CurrentRank = " .. (item.CurrentRank or "nil"))
        table.insert(lines, "Track = " .. (item.Track or "nil"))
        table.insert(lines, "UpgradeSteps = " .. item.UpgradeSteps)
        table.insert(lines, "CrestCostPerStep = " .. item.CrestCostPerStep)
        table.insert(lines, "TotalCrestCost = " .. item.TotalCrestCost)
        table.insert(lines, "")
    end

    return table.concat(lines, "\n")
end

function Export:RunExport(simulatedCrests)
    local Logic = GC.modules.UpgradeAdvisor.Logic

    if not Logic then
        print("|cffff0000GearCrester|r Export failed: UpgradeAdvisor.Logic module not available")
        return
    end

    local results = Logic.GetRecommendedUpgrades(Logic, simulatedCrests, true, true)

    if not results or #results == 0 then
        print("|cffff0000GearCrester|r No upgradeable items found to export.")
        return
    end

    local exportItems = self:GenerateExportData(results)
    local exportString = self:GenerateExportString(exportItems)

    if not GearCresterExportDB then
        GearCresterExportDB = {}
    end

    GearCresterExportDB.lastExport = exportString
    GearCresterExportDB.lastExportTime = os.date and os.date("%Y-%m-%d %H:%M:%S") or "Unknown"
    GearCresterExportDB.exportItems = exportItems

    print("|cff00ff98GearCrester:|r Export complete. File will be written on logout.")
    print("|cff00ff98GearCrester:|r Path: WTF/<account_name>/<character_name>/SavedVariables/GearCrester.lua")
end

function Export:PrintExport()
    local Logic = GC.modules.UpgradeAdvisor.Logic

    if not Logic then
        print("|cffff0000GearCrester|r Export failed: UpgradeAdvisor.Logic module not available")
        return
    end

    local results = Logic.GetRecommendedUpgrades(Logic, nil, true, true)

    if not results or #results == 0 then
        print("|cffff0000GearCrester|r No upgradeable items found to export.")
        return
    end

    local exportItems = self:GenerateExportData(results)
    local exportString = self:GenerateExportString(exportItems)
    print("|cff00ff98GearCrester Export|r")
    print("Copy the following lines:")
    print(exportString)
end

return Export
