local addonName, GC = ...

GC.modules.InventoryScanner = GC.modules.InventoryScanner or {}
local ScannerUtils = {}
GC.modules.InventoryScanner.Utils = ScannerUtils

-- Shared hidden tooltip for scanning item text
local scanTooltip = CreateFrame("GameTooltip", "GearCresterScanTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

-- Check if an item should be skipped (BoE or Warbound)
function ScannerUtils:ShouldSkipItem(itemLink)
    local _, _, _, _, _, _, _, _, _, _, _, _, _, bindType = GetItemInfo(itemLink)

    -- Skip BoE items
    if bindType == 2 then return true end

    -- Scan tooltip for "Warbound"
    scanTooltip:ClearLines()
    scanTooltip:SetHyperlink(itemLink)
    for i = 1, scanTooltip:NumLines() do
        local line = _G["GearCresterScanTooltipTextLeft" .. i]:GetText()
        if line and line:find("Warbound") then
            return true
        end
    end

    return false
end

-- Get equip location slot name from an item link
function ScannerUtils:GetSlotName(itemLink)
    local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
    return GC.EQUIPLOC_TO_SLOT[itemEquipLoc] or "Unknown"
end

-- Scan a container range and return items table
function ScannerUtils:ScanContainerRange(bagStart, bagEnd, keyPrefix)
    local items = {}

    for bagID = bagStart, bagEnd do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        if numSlots and numSlots > 0 then
            for slotIndex = 1, numSlots do
                local info = C_Container.GetContainerItemInfo(bagID, slotIndex)
                if info and info.hyperlink then
                    local itemLink = info.hyperlink
                    if not self:ShouldSkipItem(itemLink) then
                        local slotName = self:GetSlotName(itemLink)
                        local itemKey = string.format("%s%d_slot%d", keyPrefix, bagID, slotIndex)
                        items[itemKey] = {
                            itemLink = itemLink,
                            slotName = slotName,
                            bagID = bagID,
                            slotIndex = slotIndex,
                            location = string.format("%s %d, slot %d", keyPrefix == "bag" and "bag" or "bank", keyPrefix == "bag" and bagID or (bagID - 5), slotIndex),
                        }
                    end
                end
            end
        end
    end

    return items
end

return ScannerUtils
