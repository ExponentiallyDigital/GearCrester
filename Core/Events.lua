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

        -- Initialize SavedVariables ONLY after ADDON_LOADED for this addon
        GearCresterDB = GearCresterDB or {}
        GearCresterExportDB = GearCresterExportDB or {}

        GC:OnLoad()
    elseif event == "PLAYER_LOGIN" then
        GC.modules.InventoryScanner.ScannerEquipped:Scan()
        GC.modules.InventoryScanner.ScannerBags:Scan()
        GC.modules.InventoryScanner.ScannerBank:Scan()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        GC.modules.InventoryScanner.ScannerEquipped:Scan()
    elseif event == "BAG_UPDATE" then
        GC.modules.InventoryScanner.ScannerBags:Scan()
    elseif event == "PLAYERBANKSLOTS_CHANGED" then
        GC.modules.InventoryScanner.ScannerBank:Scan()
    end
end)
