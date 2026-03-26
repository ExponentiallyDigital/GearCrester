local addonName, GC = ...

local ScannerBank = {}
GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
GC.modules.InventoryScanner.ScannerBank = ScannerBank

-- Hidden tooltip for scanning item text
local scanTooltip = CreateFrame("GameTooltip", "GearCresterScanTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

function ScannerBank:Scan()
    GC.DataModel.bank = {}

    for bagID = 5, 11 do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        if numSlots and numSlots > 0 then
            for slotIndex = 1, numSlots do
                local info = C_Container.GetContainerItemInfo(bagID, slotIndex)
                if info and info.hyperlink then
                    local itemLink = info.hyperlink

                    -- Get bind type and equip location
                    local _, _, _, _, _, _, _, _, itemEquipLoc, _, _, _, _, bindType = GetItemInfo(itemLink)

                    -- Determine if item should be skipped
                    local shouldSkip = false

                    -- Skip BoE items (bindType == 2)
                    if bindType == 2 then
                        shouldSkip = true
                    end

                    -- Scan tooltip for "Warbound until equipped"
                    if not shouldSkip then
                        scanTooltip:ClearLines()
                        scanTooltip:SetHyperlink(itemLink)
                        local isWarbound = false
                        for i = 1, scanTooltip:NumLines() do
                            local line = _G["GearCresterScanTooltipTextLeft" .. i]:GetText()
                            if line and line:find("Warbound") then
                                isWarbound = true
                                break
                            end
                        end

                        if isWarbound then
                            shouldSkip = true
                        end
                    end

                    -- Only insert item if not skipped
                    if not shouldSkip then
                        -- Map equip location to slot name
                        local slotName = GC.EQUIPLOC_TO_SLOT[itemEquipLoc] or "Unknown"
                        local itemKey = string.format("bank_bag%d_slot%d", bagID, slotIndex)

                        GC.DataModel.bank[itemKey] = {
                            itemLink = itemLink,
                            slotName = slotName,
                            bagID = bagID,
                            slotIndex = slotIndex,
                            location = string.format("bank %d, slot %d", bagID - 5, slotIndex),
                        }
                    end
                end
            end
        end
    end

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] Bank scanned|r")
    end
end

return ScannerBank
