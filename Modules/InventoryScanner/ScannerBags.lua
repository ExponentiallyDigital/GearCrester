local addonName, GC = ...

local ScannerBags = {}
GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
GC.modules.InventoryScanner.ScannerBags = ScannerBags

function ScannerBags:Scan()
    GC.DataModel.bags = {}

    for bagID = 0, 4 do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        if numSlots and numSlots > 0 then
            for slotIndex = 1, numSlots do
                local info = C_Container.GetContainerItemInfo(bagID, slotIndex)
                if info and info.hyperlink then
                    local itemLink = info.hyperlink
                    local itemKey = string.format("bag%d_slot%d", bagID, slotIndex)
                    GC.DataModel.bags[itemKey] = {
                        itemLink = itemLink,
                        bagID = bagID,
                        slotIndex = slotIndex,
                        location = string.format("Bag %d, Slot %d", bagID, slotIndex),
                    }
                end
            end
        end
    end

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] Bags scanned|r")
    end
end

return ScannerBags
