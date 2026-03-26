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

        -- Initialize SavedVariables if file didn't exist (first login after install/delete)
        -- WoW auto-creates the file on logout, but we need safe defaults on login
        GearCresterDB = GearCresterDB or {}
        GearCresterDB.slotWeights = GearCresterDB.slotWeights or {}
        GearCresterDB.slotCaps = GearCresterDB.slotCaps or {}
        GearCresterDB.session = GearCresterDB.session or {}

        GearCresterExportDB = GearCresterExportDB or {}
        GearCresterExportDB.exportItems = GearCresterExportDB.exportItems or {}

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
