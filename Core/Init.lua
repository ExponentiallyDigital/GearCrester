local addonName, GC = ...

-- Initialize SavedVariables at module load time (before ADDON_LOADED)
-- This prevents errors when SavedVariables file is missing or empty
-- Use 'or {}' pattern to safely handle nil values from missing files
if type(GearCresterDB) ~= "table" then
    GearCresterDB = {}
end
if type(GearCresterDB.slotWeights) ~= "table" then
    GearCresterDB.slotWeights = {}
end
if type(GearCresterExportDB) ~= "table" then
    GearCresterExportDB = {}
end
if type(GearCresterExportDB.exportItems) ~= "table" then
    GearCresterExportDB.exportItems = {}
end

GC.name = addonName
GC.modules = {}
GC.db = {}

function GC:OnLoad()
    -- SavedVariables already initialized at top of file
    GC.db = GearCresterDB

    -- Get version from TOC using C_AddOns API
    local version = "0.0.1"
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local metaVersion = C_AddOns.GetAddOnMetadata(addonName, "Version")
        if metaVersion then
            version = metaVersion
        end
    end

    SlashCmdList["GEARCRESTER"] = function(msg)
        local args = msg:trim()

        if args and #args > 0 then
            local cmd, param = args:match("^(%w+)%s*(.*)$")
            cmd = cmd and cmd:lower()

            if cmd == "help" then
                print("|cff00ff98GearCrester Help|r")
                print("--------------------------------")
                print("/gc - Show upgrade recommendations")
                print("/gc <count> <crestType> - Simulate upgrades (e.g., /gc 40 champion)")
                print("/gc debug on|off - Enable/disable debug output")
                print("/gc why - Show why items are not upgradeable")
                print("/gc dump - Dump all items with bonus IDs")
                print("/gc test - Run self-diagnostics")
                print("/gc export - Export upgradeable items")
                print("/gc export <count> <crestType> - Export with crest simulation")
                print("/gc ui - Toggle UI frame")
                print("/gc ui <count> <crestType> - Show simulation in UI frame")
                print("/gc weight <slot> <value> - Set slot priority weight (1-20)")
                print("/gc weight reset - Reset all slot weights to default")
                print("/gc weight list - Show all slot weights")
                print("/gc help - Show this help")
                return
            elseif cmd == "weight" then
                if not param or #param == 0 then
                    GC:Print("Usage: /gc weight <slotName> <value> | reset | list")
                    return
                end

                local subCmd, subParam = param:match("^(%w+)%s*(.*)$")
                subCmd = subCmd and subCmd:lower()

                if subCmd == "reset" then
                    GC.modules.UpgradeAdvisor.UpgradeOrder:ResetSlotWeights()
                    GC:Print("All slot weights reset to default.")
                    return
                elseif subCmd == "list" then
                    print("|cff00ff98GearCrester Slot Weights|r")
                    print("--------------------------------")
                    local weights = GC.modules.UpgradeAdvisor.UpgradeOrder:GetAllWeights()
                    local slotNames = GC.SLOTS
                    for slotID, weightData in pairs(weights) do
                        local slotName = slotNames[slotID] or "Unknown"
                        local status = weightData.isCustom and "|cffff0000(custom)|r" or "|cff00ff00(default)|r"
                        print(string.format("%s: %d %s", slotName, weightData.effective, status))
                    end
                    return
                else
                    local slotName, valueStr = param:match("^(%w+)%s+(%d+)$")
                    if slotName and valueStr then
                        local value = tonumber(valueStr)
                        if value < 1 or value > 20 then
                            GC:Print("Weight must be between 1 and 20.")
                            return
                        end

                        -- Find slotID by name
                        local slotID = nil
                        for id, name in pairs(GC.SLOTS) do
                            if name:lower() == slotName:lower() then
                                slotID = id
                                break
                            end
                        end

                        if slotID then
                            GC.modules.UpgradeAdvisor.UpgradeOrder:SetSlotWeight(slotID, value)
                            GC:Print(string.format("Set %s weight to %d.", slotName, value))
                        else
                            GC:Print("Unknown slot name. Valid slots: Head, Neck, Shoulder, Chest, Waist, Legs, Feet, Wrist, Hands, Finger1, Finger2, Trinket1, Trinket2, Back, MainHand, OffHand")
                        end
                    else
                        GC:Print("Usage: /gc weight <slotName> <value>")
                        GC:Print("Example: /gc weight MainHand 1")
                    end
                    return
                end
            elseif cmd == "debug" then
                if param and param:lower() == "on" then
                    GC.db.debug = true
                    GC:Print("Debug mode enabled.")
                elseif param and param:lower() == "off" then
                    GC.db.debug = false
                    GC:Print("Debug mode disabled.")
                else
                    GC:Print("Usage: /gc debug on|off")
                end
                return
            elseif cmd == "dump" then
                GC.modules.UpgradeAdvisor.Logic:DumpAllItems()
                return
            elseif cmd == "why" then
                GC.modules.UpgradeAdvisor.Logic:PrintWhyDiagnostics()
                return
            elseif cmd == "test" then
                if GC.modules.Diagnostics and GC.modules.Diagnostics.SelfTest then
                    GC.modules.Diagnostics.SelfTest:RunAllTests()
                else
                    GC:Print("SelfTest module not found.")
                end
                return
            elseif cmd == "ui" then
                if param and #param > 0 then
                    local countStr, crestType = param:match("^(%d+)%s+(%w+)$")
                    if countStr and crestType then
                        local count = tonumber(countStr)
                        local crestTypeUpper = crestType:upper()

                        local validTypes = {
                            ADVENTURER = true,
                            VETERAN = true,
                            CHAMPION = true,
                            HERO = true,
                            MYTH = true,
                        }

                        if validTypes[crestTypeUpper] then
                            local AdvisorCore = GC.modules.UpgradeAdvisor.Core
                            local simulatedCrests = GC.modules.CrestTracker.CrestData:SimulateCrests(crestTypeUpper, count)
                            local results = AdvisorCore:GetRecommendedUpgrades(simulatedCrests, true, true)

                            if not results or #results == 0 then
                                GC.modules.UI.MainFrame:ShowResults("|cff00ff98GearCrester Upgrade Recommendations|r\n\nNo upgrades available for equipped gear, bags, or bank.")
                            else
                                local lines = {}
                                table.insert(lines, "|cff00ff98GearCrester Upgrade Recommendations (Simulated: " .. count .. " " .. crestTypeUpper .. ")|r")
                                table.insert(lines, "")

                                for _, entry in ipairs(results) do
                                    local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
                                    local location = entry.location and string.format(" [%s]", entry.location) or ""
                                    local line = string.format("%s%s: %d -> %d (%s%s x%d|r)",
                                        entry.slotName or entry.location,
                                        location,
                                        entry.currentIlvl,
                                        entry.nextIlvl,
                                        affordColor,
                                        entry.crestType,
                                        entry.crestCost)
                                    table.insert(lines, line)
                                end

                                GC.modules.UI.MainFrame:ShowResults(table.concat(lines, "\n"))
                            end
                        else
                            GC:Print("Invalid crest type. Valid types: ADVENTURER, VETERAN, CHAMPION, HERO, MYTH")
                        end
                    else
                        GC:Print("Usage: /gc ui <count> <crestType>")
                        GC:Print("Example: /gc ui 40 champion")
                    end
                else
                    if GC.modules.UI and GC.modules.UI.MainFrame then
                        GC.modules.UI.MainFrame:Toggle()
                    else
                        GC:Print("UI not implemented yet.")
                    end
                end
                return
            elseif cmd == "export" then
                if param and #param > 0 then
                    local countStr, crestType = param:match("^(%d+)%s+(%w+)$")
                    if countStr and crestType then
                        local count = tonumber(countStr)
                        local crestTypeUpper = crestType:upper()

                        local validTypes = {
                            ADVENTURER = true,
                            VETERAN = true,
                            CHAMPION = true,
                            HERO = true,
                            MYTH = true,
                        }

                        if validTypes[crestTypeUpper] then
                            local simulatedCrests = GC.modules.CrestTracker.CrestData:SimulateCrests(crestTypeUpper, count)
                            GC.modules.Export.Export:RunExport(simulatedCrests)
                        else
                            GC:Print("Invalid crest type. Valid types: ADVENTURER, VETERAN, CHAMPION, HERO, MYTH")
                        end
                    else
                        GC:Print("Usage: /gc export <count> <crestType>")
                        GC:Print("Example: /gc export 40 champion")
                    end
                else
                    if GC.modules.Export and GC.modules.Export.Export then
                        GC.modules.Export.Export:PrintExport()
                    else
                        GC:Print("Export module not found.")
                    end
                end
                return
            end

            local countStr, crestType = args:match("^(%d+)%s+(%w+)$")

            if countStr and crestType then
                local count = tonumber(countStr)
                local crestTypeUpper = crestType:upper()

                local validTypes = {
                    ADVENTURER = true,
                    VETERAN = true,
                    CHAMPION = true,
                    HERO = true,
                    MYTH = true,
                }

                if validTypes[crestTypeUpper] then
                    local AdvisorCore = GC.modules.UpgradeAdvisor.Core
                    local simulatedCrests = GC.modules.CrestTracker.CrestData:SimulateCrests(crestTypeUpper, count)
                    local results = AdvisorCore:GetRecommendedUpgrades(simulatedCrests, true, true)
                    AdvisorCore:PrintResults(results, string.format("|cff00ff98GearCrester Upgrade Recommendations (Simulated: %d %s):|r", count, crestTypeUpper))
                else
                    GC:Print("Invalid crest type. Valid types: ADVENTURER, VETERAN, CHAMPION, HERO, MYTH")
                end
            else
                GC:Print("Usage: /gc <count> <crestType>")
                GC:Print("Example: /gc 40 champion")
                GC:Print("Use /gc help for all commands")
            end
        else
            local AdvisorCore = GC.modules.UpgradeAdvisor.Core
            local results = AdvisorCore:GetRecommendedUpgrades(nil, true, true)
            AdvisorCore:PrintResults(results)
        end
    end
    SLASH_GEARCRESTER1 = "/gc"

    print("|cff00ff98GearCrester v" .. version .. ":|r GearCrester loaded, use \"/gc\" to view upgrade recommendations or \"/gc help\".")
end

function GC:Print(msg)
    print("|cff00ff98GearCrester:|r " .. msg)
end

return GC
