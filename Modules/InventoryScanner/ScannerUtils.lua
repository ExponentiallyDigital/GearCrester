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

-- Get equip location slot name from an item link (uses InventoryType for Midnight compatibility)
function ScannerUtils:GetSlotName(itemLink, bagID, slotIndex)
    -- Try to get slot name from container item info (Midnight API)
    if bagID and slotIndex then
        local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bagID, slotIndex)
        if info and info.itemID then
            local invType = C_Item and C_Item.GetItemInventoryTypeByID and C_Item.GetItemInventoryTypeByID(info.itemID)
            if invType then
                return GC.INVENTORYTYPE_TO_SLOT[invType] or "Unknown"
            end
        end
    end

    -- Fallback to old API if available
    if itemLink then
        local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
        return GC.EQUIPLOC_TO_SLOT[itemEquipLoc] or itemEquipLoc or "Unknown"
    end

    return "Unknown"
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
                        -- Pass bagID and slotIndex for InventoryType-based slot detection
                        local slotName = self:GetSlotName(itemLink, bagID, slotIndex)
                        local itemKey = string.format("%s%d_slot%d", keyPrefix, bagID, slotIndex)

                        -- Detect crafted track using itemLink (TradeSkillUI API)
                        local craftedTrack = GC.GetCraftedTrackName(itemLink)

                        items[itemKey] = {
                            itemLink = itemLink,
                            slotName = slotName,
                            bagID = bagID,
                            slotIndex = slotIndex,
                            location = string.format("%s %d, slot %d", keyPrefix == "bag" and "bag" or "bank", keyPrefix == "bag" and bagID or (bagID - 5), slotIndex),
                            craftedTrack = craftedTrack,  -- Store crafted track if applicable
                        }

                        if GC.db and GC.db.debug then
                            print("|cff00ff98[SCAN DEBUG] key=" .. itemKey .. " location=" .. items[itemKey].location)
                        end
                    end
                end
            end
        end
    end

    return items
end

return ScannerUtils
