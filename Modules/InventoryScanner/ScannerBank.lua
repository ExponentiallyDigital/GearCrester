local addonName, GC = ...

local ScannerBank = {}
GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
GC.modules.InventoryScanner.ScannerBank = ScannerBank

function ScannerBank:Scan()
    GC.DataModel.bank = {}

    for bagID = 5, 11 do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        if numSlots and numSlots > 0 then
            for slotIndex = 1, numSlots do
                local info = C_Container.GetContainerItemInfo(bagID, slotIndex)
                if info and info.hyperlink then
                    local itemLink = info.hyperlink
                    local itemKey = string.format("bank_bag%d_slot%d", bagID, slotIndex)
                    GC.DataModel.bank[itemKey] = {
                        itemLink = itemLink,
                        bagID = bagID,
                        slotIndex = slotIndex,
                        location = string.format("Bank Bag %d, Slot %d", bagID - 5, slotIndex),
                    }
                end
            end
        end
    end

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] Bank scanned|r")
    end
end

return ScannerBank
