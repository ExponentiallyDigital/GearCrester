local addonName, GC = ...

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

frame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        GC:OnLoad()
    elseif event == "PLAYER_LOGIN" then
        GC.modules.InventoryScanner:ScanEquipped()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        GC.modules.InventoryScanner:ScanEquipped()
    elseif event == "BAG_UPDATE" then
        GC.modules.InventoryScanner:ScanBags()
    elseif event == "PLAYERBANKSLOTS_CHANGED" then
        GC.modules.InventoryScanner:ScanBank()
    end
end)
