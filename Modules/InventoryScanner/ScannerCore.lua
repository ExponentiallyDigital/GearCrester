local addonName, GC = ...

GC.modules.InventoryScanner = {}

local Scanner = GC.modules.InventoryScanner

function Scanner:ScanEquipped()
    GC.DataModel.equipped = {}
    for slotID, slotName in pairs(GC.SLOTS) do
        local itemLink = GetInventoryItemLink("player", slotID)
        if itemLink then
            GC.DataModel.equipped[slotID] = {
                link = itemLink,
                slot = slotName,
            }
        end
    end
end

function Scanner:ScanBags()
    -- stub for later
end

function Scanner:ScanBank()
    -- stub for later
end
