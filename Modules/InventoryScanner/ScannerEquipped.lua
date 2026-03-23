local addonName, GC = ...

local ScannerEquipped = {}
GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
GC.modules.InventoryScanner.ScannerEquipped = ScannerEquipped

local SLOT_IDS = GC.SLOTS

function ScannerEquipped:Scan()
    GC.DataModel.equipped = {}

    for slotID, slotName in pairs(SLOT_IDS) do
        local itemLink = GetInventoryItemLink("player", slotID)
        if itemLink then
            GC.DataModel.equipped[slotID] = {
                itemLink = itemLink,
                slotName = slotName,
                slotID = slotID,
            }
        end
    end
end

return ScannerEquipped
