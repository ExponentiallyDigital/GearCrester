local addonName, GC = ...

local Commands = {}
GC.modules.Commands = Commands

-- Dispatch table for slash commands
local handlers = {}

function Commands:Register()
    SlashCmdList["GEARCRESTER"] = function(msg)
        local args = (msg or ""):trim()

        if args == "" then
            -- Default: show upgrade recommendations
            local Core = GC.modules.UpgradeAdvisor.Core
            local results = Core:GetRecommendedUpgrades(nil, true, true)
            Core:PrintResults(results)
            return
        end

        local cmd, param = args:match("^(%w+)%s*(.*)$")
        cmd = cmd and cmd:lower() or ""
        param = param or ""

        local handler = handlers[cmd]
        if handler then
            handler(param)
        else
            -- Try <count> <crestType> pattern
            local countStr, crestType = args:match("^(%d+)%s+(%w+)$")
            if countStr and crestType then
                Commands:SimulateUpgrades(tonumber(countStr), crestType:upper())
            else
                GC:Print("Unknown command. Use /gc help.")
            end
        end
    end
    SLASH_GEARCRESTER1 = "/gc"
end

function Commands:SimulateUpgrades(count, crestTypeUpper)
    if not GC.VALID_CREST_TYPES[crestTypeUpper] then
        GC:Print("Invalid crest type. Valid: ADVENTURER, VETERAN, CHAMPION, HERO, MYTH")
        return
    end
    local Core = GC.modules.UpgradeAdvisor.Core
    local sim = GC.modules.CrestTracker.CrestData:SimulateCrests(crestTypeUpper, count)
    local results = Core:GetRecommendedUpgrades(sim, true, true)
    Core:PrintResults(results, string.format(
        "|cff00ff98GearCrester: upgrade recommendations (simulated: %d %s)|r",
        count, GC.ColorTrack(crestTypeUpper)))
end

handlers["help"] = function()
    print("|cff00ff98GearCrester: help|r")
    print("--------------------------------")
    print("/gc - Show upgrade recommendations")
    print("/gc <count> <crestType> - Simulate upgrades")
    print("/gc debug on|off - Toggle debug output")
    print("/gc why - Show why items are not upgradeable")
    print("/gc crests - Show crest inventory")
    print("/gc free - Show free upgrade opportunities")
    print("/gc calibrate npc - Scan at upgrader NPC")
    print("/gc calibrate <slot> - Compare GC vs Blizzard data")
    print("/gc scan - Rescan inventory and bank")
    print("/gc slotcaps - View stored slot caps")
    print("/gc dump - Dump items with bonus IDs")
    print("/gc test - Run self-diagnostics")
    print("/gc export [count crestType] - Export items")
    print("/gc ui [count crestType] - Toggle dashboard UI")
    print("/gc weight <slot> <value> - Set priority (1-20)")
    print("/gc weight reset|list - Manage weights")
end

handlers["debug"] = function(param)
    local state = param:lower()
    if state == "on" then
        GC.db.debug = true
        GC:Print("Debug mode enabled.")
    elseif state == "off" then
        GC.db.debug = false
        GC:Print("Debug mode disabled.")
    else
        GC:Print("Usage: /gc debug on|off")
    end
end

handlers["dump"] = function()
    GC.modules.UpgradeAdvisor.Logic:DumpAllItems()
end

handlers["why"] = function()
    GC.modules.UpgradeAdvisor.Logic:PrintWhyDiagnostics()
end

handlers["crests"] = function()
    local counts = GC.modules.CrestTracker.CrestData:GetAllCrestCounts()
    print("|cff00ff98GearCrester: crest inventory|r")
    for _, name in ipairs({"ADVENTURER","VETERAN","CHAMPION","HERO","MYTH"}) do
        print(string.format("  %s: %d", GC.ColorTrack(name), counts[name] or 0))
    end
end

handlers["free"] = function()
    GC.modules.UpgradeAdvisor.Core:PrintFreeUpgrades()
end

handlers["scan"] = function()
    GearCresterDB.session.bagsScanned = false
    GearCresterDB.session.bankScanned = false
    GC.modules.InventoryScanner.ScannerEquipped:Scan()
    GC.modules.InventoryScanner.ScannerBags:Scan()
    GearCresterDB.session.bagsScanned = true
    if BankFrame and BankFrame:IsShown() then
        GC.modules.InventoryScanner.ScannerBank:Scan()
        GearCresterDB.session.bankScanned = true
    end
    GC:Print("Full scan complete. Type /gc to see upgrades.")
end

handlers["slotcaps"] = function()
    print("|cff00ff98GearCrester: slot caps|r")
    print("--------------------------------")
    local hasCaps = false
    local maxRank = GC.modules.UpgradeAdvisor.Data.MAX_RANK or 6
    for slotID, cap in pairs(GearCresterDB.slotCaps or {}) do
        hasCaps = true
        print(string.format("%s: %s %d/%d",
            GC.SLOTS[slotID] or "Unknown", GC.ColorTrack(cap.track), cap.currUpgrade, maxRank))
    end
    if not hasCaps then print("(no data yet)") end
end

handlers["test"] = function()
    local st = GC.modules.Diagnostics and GC.modules.Diagnostics.SelfTest
    if st then st:RunAllTests() else GC:Print("SelfTest module not found.") end
end

handlers["calibrate"] = function(param)
    local sub = param:lower():trim()
    if sub == "npc" then
        local US = GC.modules.UpgradeAdvisor.UpgraderScanner
        if not US then GC:Print("UpgraderScanner not found."); return end
        if not US:IsUpgraderOpen() then
            GC:Print("Open the Item Upgrade NPC window first.")
            return
        end
        GC:Print("Scanning equipped items at upgrader NPC...")
        US:ScanEquippedAtUpgrader()
        return
    end
    local slotName = sub ~= "" and sub or "head"
    local slotID = GC:SlotNameToID(slotName)
    if not slotID then
        GC:Print("Unknown slot: " .. slotName)
        return
    end
    GC.modules.InventoryScanner.ScannerEquipped:Scan()
    local itemData = GC.DataModel.equipped[slotID]
    if itemData and itemData.itemLink then
        GC.modules.UpgradeAdvisor.Logic:CalibrateItemUpgradeInfo(itemData.itemLink, itemData.slotName)
    else
        GC:Print("No item equipped in " .. slotName)
    end
end

handlers["weight"] = function(param)
    if not param or #param == 0 then
        GC:Print("Usage: /gc weight <slotName> <value> | reset | list")
        return
    end
    local subCmd = param:match("^(%w+)")
    if not subCmd then return end

    if subCmd:lower() == "reset" then
        GC.modules.UpgradeAdvisor.UpgradeOrder:ResetSlotWeights()
        GC:Print("All slot weights reset to default.")
    elseif subCmd:lower() == "list" then
        print("|cff00ff98GearCrester: slot weights (lower = higher priority)|r")
        print("--------------------------------")
        local weights = GC.modules.UpgradeAdvisor.UpgradeOrder:GetAllWeights()
        local sorted = {}
        for slotID, w in pairs(weights) do
            table.insert(sorted, { name = GC.SLOTS[slotID] or "Unknown", effective = w.effective, isCustom = w.isCustom })
        end
        table.sort(sorted, function(a, b) return a.effective < b.effective end)
        for _, e in ipairs(sorted) do
            local tag = e.isCustom and "|cffff0000(custom)|r" or "|cff00ff00(default)|r"
            print(string.format("%s: %d %s", e.name, e.effective, tag))
        end
    else
        local slotName, valueStr = param:match("^(%w+)%s+(%d+)$")
        if slotName and valueStr then
            local value = tonumber(valueStr)
            if value < 1 or value > 20 then GC:Print("Weight must be 1-20."); return end
            local slotID = GC:SlotNameToID(slotName)
            if slotID then
                GC.modules.UpgradeAdvisor.UpgradeOrder:SetSlotWeight(slotID, value)
                GC:Print(string.format("Set %s weight to %d.", slotName, value))
            else
                GC:Print("Unknown slot. Valid: Head, Neck, Shoulder, Chest, Waist, Legs, Feet, Wrist, Hands, Finger1, Finger2, Trinket1, Trinket2, Back, MainHand, OffHand")
            end
        else
            GC:Print("Usage: /gc weight <slotName> <value>")
        end
    end
end

handlers["ui"] = function(param)
    if param and #param > 0 then
        local countStr, crestType = param:match("^(%d+)%s+(%w+)$")
        if countStr and crestType then
            local crestTypeUpper = crestType:upper()
            if GC.VALID_CREST_TYPES[crestTypeUpper] then
                local sim = GC.modules.CrestTracker.CrestData:SimulateCrests(crestTypeUpper, tonumber(countStr))
                local results = GC.modules.UpgradeAdvisor.Core:GetRecommendedUpgrades(sim, true, true)
                GC.modules.UI.Dashboard:ShowWithData(results, string.format("Simulated: %d %s", tonumber(countStr), crestTypeUpper))
            else
                GC:Print("Invalid crest type.")
            end
        else
            GC:Print("Usage: /gc ui [count crestType]")
        end
    else
        if GC.modules.UI and GC.modules.UI.Dashboard then
            GC.modules.UI.Dashboard:Toggle()
        else
            GC:Print("UI not available.")
        end
    end
end

handlers["export"] = function(param)
    if param and #param > 0 then
        local countStr, crestType = param:match("^(%d+)%s+(%w+)$")
        if countStr and crestType then
            local crestTypeUpper = crestType:upper()
            if GC.VALID_CREST_TYPES[crestTypeUpper] then
                local sim = GC.modules.CrestTracker.CrestData:SimulateCrests(crestTypeUpper, tonumber(countStr))
                GC.modules.Export.Export:RunExport(sim)
            else
                GC:Print("Invalid crest type.")
            end
        else
            GC:Print("Usage: /gc export <count> <crestType>")
        end
    else
        if GC.modules.Export and GC.modules.Export.Export then
            GC.modules.Export.Export:PrintExport()
        else
            GC:Print("Export module not found.")
        end
    end
end

return Commands
