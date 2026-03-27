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
        -- Use maxRank as the final rank after upgrade (nextRank no longer exists)
        local nextRank = entry.maxRank
        local rankDiff = entry.maxRank - entry.currentRank

        table.insert(exportItems, {
            Slot = entry.slotName or "Unknown",
            Location = entry.location,
            ItemLink = entry.itemLink,
            CurrentILvl = entry.currentIlvl,
            CurrentRank = entry.currentRank,
            Track = entry.trackName,
            UpgradeSteps = entry.upgradeSteps or rankDiff,
            CrestCostPerStep = entry.crestCostPerStep or 0,
            TotalCrestCost = entry.totalCrestCost or 0,
        })
    end

    return exportItems
end

function Export:GenerateExportString(exportItems)
    if not exportItems or #exportItems == 0 then
        return "-- No upgradeable items found"
    end

    local lines = {}
    table.insert(lines, "\nGearCrester upgradeable items")
    table.insert(lines, "Generated: " .. (date and date("%Y-%m-%d %H:%M:%S") or "Unknown"))
    table.insert(lines, "")

    for _, item in ipairs(exportItems) do
        table.insert(lines, "[Item]")
        table.insert(lines, "Slot = " .. item.Slot)
        if item.Location then
            table.insert(lines, "Location = " .. item.Location)
        end
        table.insert(lines, "Item link = " .. (item.ItemLink or "nil"))
        table.insert(lines, "Current ilevel = " .. (item.CurrentILvl or "nil"))
        table.insert(lines, "Current rank = " .. (item.CurrentRank or "nil"))
        table.insert(lines, "Track = " .. GC.ColorTrack(item.Track or "nil"))
        table.insert(lines, "Upgrade steps = " .. item.UpgradeSteps)
        table.insert(lines, "Crest cost per step = " .. item.CrestCostPerStep)
        table.insert(lines, "Total crest cost = " .. item.TotalCrestCost)
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

    -- Ensure the data model is populated before exporting
    if GC.modules.InventoryScanner then
        GC.modules.InventoryScanner.ScannerEquipped:Scan()
        GC.modules.InventoryScanner.ScannerBags:Scan()
        GC.modules.InventoryScanner.ScannerBank:Scan()
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
    GearCresterExportDB.lastExportTime = date and date("%Y-%m-%d %H:%M:%S") or "Unknown"
    GearCresterExportDB.exportItems = exportItems

    print("|cff00ff98GearCrester:|r export complete. File will be written on |cffff0000**successful logout**|r.")
    print("|cff00ff98GearCrester:|r path: WTF/Account/<account_name>/SavedVariables/GearCrester.lua")
end

function Export:PrintExport()
    local Logic = GC.modules.UpgradeAdvisor.Logic

    if not Logic then
        print("|cffff0000GearCrester|r Export failed: UpgradeAdvisor.Logic module not available")
        return
    end

    -- Ensure the data model is populated before exporting
    if GC.modules.InventoryScanner then
        GC.modules.InventoryScanner.ScannerEquipped:Scan()
        GC.modules.InventoryScanner.ScannerBags:Scan()
        GC.modules.InventoryScanner.ScannerBank:Scan()
    end

    local results = Logic.GetRecommendedUpgrades(Logic, nil, true, true)

    if not results or #results == 0 then
        print("|cffff0000GearCrester|r No upgradeable items found to export.")
        return
    end

    local exportItems = self:GenerateExportData(results)
    local exportString = self:GenerateExportString(exportItems)

    -- Also write to SavedVariables (same as RunExport)
    if not GearCresterExportDB then
        GearCresterExportDB = {}
    end

    GearCresterExportDB.lastExport = exportString
    GearCresterExportDB.lastExportTime = date and date("%Y-%m-%d %H:%M:%S") or "Unknown"
    GearCresterExportDB.exportItems = exportItems

    print("|cff00ff98GearCrester: export|r")
    print(exportString)
end

return Export
