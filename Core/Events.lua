local addonName, GC = ...

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then
            return
        end

        -- Validate and sanitize SavedVariables before use
        -- This prevents errors from corrupted or malformed saved data
        if type(GearCresterDB) ~= "table" then
            GearCresterDB = {}
            print("|cff00ff98GearCrester:|r SavedVariables corrupted - resetting to defaults")
        end
        if type(GearCresterDB.slotWeights) ~= "table" then
            GearCresterDB.slotWeights = {}
        end
        if type(GearCresterDB.slotCaps) ~= "table" then
            GearCresterDB.slotCaps = {}
        end
        if type(GearCresterDB.session) ~= "table" then
            GearCresterDB.session = {}
        end

        if type(GearCresterExportDB) ~= "table" then
            GearCresterExportDB = {}
        end
        if type(GearCresterExportDB.exportItems) ~= "table" then
            GearCresterExportDB.exportItems = {}
        end

        GC:OnLoad()
    elseif event == "PLAYER_LOGIN" then
        -- Scan equipped items on login
        GC.modules.InventoryScanner.ScannerEquipped:Scan()

        -- Scan bags once per session
        if not GearCresterDB.session.bagsScanned then
            GC.modules.InventoryScanner.ScannerBags:Scan()
            GearCresterDB.session.bagsScanned = true
        end

        -- Do NOT scan bank on login - wait for bank to be opened
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        GC.modules.InventoryScanner.ScannerEquipped:Scan()
    elseif event == "BAG_UPDATE" then
        -- Do NOT scan on bag-open events (performance)
        -- Only scan when explicitly requested via /gc scan
    elseif event == "PLAYERBANKSLOTS_CHANGED" then
        -- Scan bank once when bank is opened
        if not GearCresterDB.session.bankScanned then
            GC.modules.InventoryScanner.ScannerBank:Scan()
            GearCresterDB.session.bankScanned = true
        end
    end
end)
