local addonName, GC = ...

local UpgraderScanner = {}
GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
GC.modules.UpgradeAdvisor.UpgraderScanner = UpgraderScanner

-- Track names from customUpgradeString
local TRACK_NAMES = {
    ["Adventurer"] = "ADVENTURER",
    ["Veteran"] = "VETERAN",
    ["Champion"] = "CHAMPION",
    ["Hero"] = "HERO",
    ["Myth"] = "MYTH",
}

-- Check if the Item Upgrade NPC window is open
function UpgraderScanner:IsUpgraderOpen()
    return UpgradeFrame and UpgradeFrame:IsShown()
end

-- Get upgrade info for a specific equipment slot
function UpgraderScanner:GetUpgradeInfoForEquipmentSlot(slotID)
    if not slotID then
        return nil
    end
    
    local itemLocation = ItemLocation:CreateFromEquipmentSlot(slotID)
    if not itemLocation or not itemLocation:IsValid() then
        return nil
    end
    
    -- Get upgrade info from Blizzard's API
    local info = C_ItemUpgrade.GetItemUpgradeInfo(itemLocation)
    if not info then
        return nil
    end
    
    -- Parse track name from customUpgradeString (e.g., "Champion 3/6")
    local trackName = nil
    if info.customUpgradeString then
        for trackStr, trackKey in pairs(TRACK_NAMES) do
            if info.customUpgradeString:find(trackStr) then
                trackName = trackKey
                break
            end
        end
    end
    
    return {
        trackName = trackName,
        currUpgrade = info.currUpgrade,
        maxUpgrade = info.maxUpgrade,
        maxItemLevel = info.maxItemLevel,
        upgradeLevelInfos = info.upgradeLevelInfos,
    }
end

-- Scan all equipped items at the upgrader NPC
function UpgraderScanner:ScanEquippedAtUpgrader(onDone)
    if not self:IsUpgraderOpen() then
        if GC.db and GC.db.debug then
            print("|cffff0000[DEBUG] Upgrader window not open|r")
        end
        return
    end
    
    -- Fully replace slotCaps table
    GearCresterDB = GearCresterDB or {}
    GearCresterDB.slotCaps = {}
    
    -- Equipped slots to scan
    local slots = {1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17}
    local slotIndex = 1
    local scannedCount = 0
    
    local function scanNextSlot()
        if slotIndex > #slots then
            -- Scan complete
            if GC.db and GC.db.debug then
                print("|cff00ff00[DEBUG] Upgrader scan complete. Slot caps updated.|r")
            end
            GC:Print("Upgrader scan complete. Slot caps updated.")
            if onDone then
                onDone()
            end
            return
        end
        
        local slotID = slots[slotIndex]
        local info = UpgraderScanner:GetUpgradeInfoForEquipmentSlot(slotID)
        
        if info and info.trackName and info.currUpgrade and info.maxUpgrade then
            GearCresterDB.slotCaps[slotID] = {
                track = info.trackName,
                currUpgrade = info.currUpgrade,
                maxUpgrade = info.maxUpgrade,
                maxItemLevel = info.maxItemLevel,
            }
            scannedCount = scannedCount + 1
            
            if GC.db and GC.db.debug then
                local slotName = GC.SLOTS[slotID] or "Unknown"
                print(string.format("|cff00ff98[DEBUG] Scanned %s: %s %d/%d (max ilvl %d)|r",
                    slotName, info.trackName, info.currUpgrade, info.maxUpgrade, info.maxItemLevel))
            end
        end
        
        slotIndex = slotIndex + 1
        
        -- Use timer to avoid UI freeze
        C_Timer.After(0.05, scanNextSlot)
    end
    
    -- Start scanning
    scanNextSlot()
end

-- Get slot cap for a specific slotID
function UpgraderScanner:GetSlotCap(slotID)
    if not GearCresterDB or not GearCresterDB.slotCaps then
        return nil
    end
    return GearCresterDB.slotCaps[slotID]
end

-- Clear all slot caps (for testing/reset)
function UpgraderScanner:ClearSlotCaps()
    if GearCresterDB and GearCresterDB.slotCaps then
        GearCresterDB.slotCaps = {}
        GC:Print("Slot caps cleared.")
    end
end

return UpgraderScanner
