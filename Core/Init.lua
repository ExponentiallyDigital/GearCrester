local addonName, GC = ...

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
                print("|cff00ff98GearCrester: help|r")
                print("--------------------------------")
                print("/gc - Show upgrade recommendations")
                print("/gc <count> <crestType> - Simulate upgrades (e.g., /gc 40 champion)")
                print("/gc debug on|off - Enable/disable debug output")
                print("/gc why - Show why items are not upgradeable")
                print("/gc crests - Show current crest inventory")
                print("/gc free - Show free upgrade opportunities (track-cap inheritance)")
                print("/gc calibrate npc - Scan equipped items at upgrader NPC (must have NPC window open)")
                print("/gc calibrate <slot> - Compare GC vs Blizzard upgrade data for slot")
                print("/gc scan - Manually rescan inventory and bank")
                print("/gc slotcaps - View stored slot caps")
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
                    print("|cff00ff98GearCrester: slot weights (lower = higher priority)|r")
                    print("--------------------------------")

                    local weights = GC.modules.UpgradeAdvisor.UpgradeOrder:GetAllWeights()
                    local slotNames = GC.SLOTS

                    -- Build sortable array
                    local sorted = {}
                    for slotID, weightData in pairs(weights) do
                        table.insert(sorted, {
                            slotID = slotID,
                            slotName = slotNames[slotID] or "Unknown",
                            effective = weightData.effective,
                            isCustom = weightData.isCustom
                        })
                    end

                    -- Sort by effective weight ascending
                    table.sort(sorted, function(a, b)
                        return a.effective < b.effective
                    end)

                    -- Print sorted list
                    for _, entry in ipairs(sorted) do
                        local status = entry.isCustom and "|cffff0000(custom)|r" or "|cff00ff00(default)|r"
                        print(string.format("%s: %d %s", entry.slotName, entry.effective, status))
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
            elseif cmd == "calibrate" then
                -- Check for NPC subcommand
                local sub = param and param:lower() or ""

                if sub == "npc" then
                    local UpgraderScanner = GC.modules.UpgradeAdvisor.UpgraderScanner
                    if not UpgraderScanner then
                        GC:Print("UpgraderScanner module not found.")
                        return
                    end

                    if not UpgraderScanner:IsUpgraderOpen() then
                        GC:Print("Open the Item Upgrade NPC window first, then run /gc calibrate npc again.")
                        return
                    end

                    GC:Print("Scanning equipped items at upgrader NPC...")
                    UpgraderScanner:ScanEquippedAtUpgrader()
                    return
                end

                -- Otherwise fall back to calibrate-slot logic
                local slotName = sub ~= "" and sub or "head"
                local slotID = nil

                for id, name in pairs(GC.SLOTS) do
                    if name:lower() == slotName then
                        slotID = id
                        break
                    end
                end

                if not slotID then
                    GC:Print("Unknown slot: " .. (sub or "head") .. ". Valid: Head, Neck, Shoulder, etc.")
                    return
                end

                GC.modules.InventoryScanner.ScannerEquipped:Scan()

                local itemData = GC.DataModel.equipped[slotID]
                if itemData and itemData.itemLink then
                    GC.modules.UpgradeAdvisor.Logic:CalibrateItemUpgradeInfo(itemData.itemLink, itemData.slotName)
                else
                    GC:Print("No item equipped in " .. (itemData and itemData.slotName or slotName))
                end
                return
            elseif cmd == "crests" then
                -- Display current crest inventory
                local counts = GC.modules.CrestTracker.CrestData:GetAllCrestCounts()
                print("|cff00ff98GearCrester: current crest inventory|r")
                print(string.format("  Adventurer: %d", counts.ADVENTURER or 0))
                print(string.format("  Veteran:    %d", counts.VETERAN or 0))
                print(string.format("  Champion:   %d", counts.CHAMPION or 0))
                print(string.format("  Hero:       %d", counts.HERO or 0))
                print(string.format("  Myth:       %d", counts.MYTH or 0))
                return
            elseif cmd == "free" then
                -- Display free upgrade opportunities
                GC.modules.UpgradeAdvisor.Core:PrintFreeUpgrades()
                return
            elseif cmd == "scan" then
                -- Manual full rescan
                if GC.db and GC.db.debug then
                    print("|cff00ff98[DEBUG] Running full scan (manual)|r")
                end

                -- Reset session flags to force rescan
                GearCresterDB.session.bagsScanned = false
                GearCresterDB.session.bankScanned = false

                -- Scan everything
                GC.modules.InventoryScanner.ScannerEquipped:Scan()
                GC.modules.InventoryScanner.ScannerBags:Scan()
                GearCresterDB.session.bagsScanned = true

                -- Only scan bank if bank is open
                if BankFrame and BankFrame:IsShown() then
                    GC.modules.InventoryScanner.ScannerBank:Scan()
                    GearCresterDB.session.bankScanned = true
                end

                GC:Print("Full inventory scan complete. Type /gc to see upgrades.")
                return
            elseif cmd == "slotcaps" then
                -- Display stored slot caps
                print("|cff00ff98GearCrester: slot caps|r")
                print("--------------------------------")

                local hasCaps = false
                for slotID, cap in pairs(GearCresterDB.slotCaps or {}) do
                    hasCaps = true
                    local slotName = GC.SLOTS[slotID] or "Unknown"
                    -- Show max rank as Data.MAX_RANK for consistency (always 6/6 for Midnight Season 1)
                    local maxRank = GC.modules.UpgradeAdvisor and GC.modules.UpgradeAdvisor.Data and GC.modules.UpgradeAdvisor.Data.MAX_RANK or 6
                    print(string.format("%s: %s %d/%d", slotName, cap.track, cap.currUpgrade, maxRank))
                end

                if not hasCaps then
                    print("(no data yet - equip items or open bags/bank)")
                end
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
                                GC.modules.UI.MainFrame:ShowResults("|cff00ff98GearCrester: upgrade recommendations|r\n\nNo upgrades available for equipped gear, bags, or bank.")
                            else
                                local lines = {}
                                table.insert(lines, "|cff00ff98GearCrester: upgrade recommendations (simulated: " .. count .. " " .. crestTypeUpper .. ")|r")
                                table.insert(lines, "")

                                for _, entry in ipairs(results) do
                                    local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
                                    local location = entry.location and string.format(" [%s]", entry.location) or ""
                                    -- Guardrail 1.1: Display total crest cost for upgrade path, not per-step cost
                                    local totalCost = entry.totalCrestCost or entry.crestCostPerStep or entry.crestCost or 0
                                    local line = string.format("%s%s: %d -> %d (%s%s x%d|r)",
                                        entry.slotName or entry.location,
                                        location,
                                        entry.currentIlvl,
                                        entry.nextIlvl,
                                        affordColor,
                                        entry.crestType,
                                        totalCost)
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
                    AdvisorCore:PrintResults(results, string.format("|cff00ff98GearCrester: upgrade recommendations (simulated: %d %s)|r", count, crestTypeUpper))
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
