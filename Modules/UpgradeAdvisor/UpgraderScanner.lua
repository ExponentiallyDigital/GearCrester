local addonName, GC = ...

local UpgraderScanner = {}
GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
GC.modules.UpgradeAdvisor.UpgraderScanner = UpgraderScanner

-- Track names from customUpgradeString
local TRACK_NAMES = {
    ["Adventurer"] = "ADVENTURER",
    ["Veteran"]    = "VETERAN",
    ["Champion"]   = "CHAMPION",
    ["Hero"]       = "HERO",
    ["Myth"]       = "MYTH",
}

local function DebugPrint(msg)
    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] " .. msg .. "|r")
    end
end

-- Very loose "is upgrader usable" check: API present and NPC window presumably open
function UpgraderScanner:IsUpgraderOpen()
    return C_ItemUpgrade and C_ItemUpgrade.GetItemUpgradeItemInfo ~= nil
end

local function ClearUpgradeSelection()
    if C_ItemUpgrade and C_ItemUpgrade.ClearItemUpgrade then
        pcall(C_ItemUpgrade.ClearItemUpgrade)
    end
end

local function TryReadUpgradeInfoFromItemAPI(loc)
    if not C_Item or not C_Item.GetItemUpgradeItemInfo then
        return nil
    end
    local ok, info = pcall(C_Item.GetItemUpgradeItemInfo, loc)
    if ok and info then
        return info
    end
    return nil
end

local function TryReadInfoFromUpgradeAPI(loc)
    if not C_ItemUpgrade or not C_ItemUpgrade.GetItemUpgradeItemInfo then
        return nil
    end

    local info
    -- Try with location (if supported)
    local ok, result = pcall(C_ItemUpgrade.GetItemUpgradeItemInfo, loc)
    if ok and result then
        info = result
    end

    -- Fallback: try without arguments (current selection)
    if not info then
        ok, result = pcall(C_ItemUpgrade.GetItemUpgradeItemInfo)
        if ok and result then
            info = result
        end
    end

    return info
end

local function TrySelectWith(funcName, loc)
    if not C_ItemUpgrade or not C_ItemUpgrade[funcName] then
        return false
    end
    local ok = pcall(C_ItemUpgrade[funcName], loc)
    return ok
end

local function ValidateUpgradeInfo(slotID, inventoryLink, info)
    if not info then
        return false, "no-info"
    end

    -- Prefer direct inventory itemID
    local invID = GetInventoryItemID("player", slotID)
    if invID and info.itemID and invID == info.itemID then
        return true, "itemID-match"
    end

    -- Fallback: name comparison
    if inventoryLink then
        local name = GetItemInfo(inventoryLink)
        if name and info.name and name == info.name then
            return true, "name-match"
        end
    end

    return false, "mismatch"
end

local function ParseTrack(customUpgradeString)
    if not customUpgradeString then
        return nil
    end
    for trackStr, trackKey in pairs(TRACK_NAMES) do
        if customUpgradeString:find(trackStr) then
            return trackKey
        end
    end
    return nil
end

local function BuildResultFromInfo(info)
    local trackName = ParseTrack(info.customUpgradeString)
    if not trackName or not info.currUpgrade or not info.maxUpgrade then
        return nil
    end

    return {
        trackName         = trackName,
        currUpgrade       = info.currUpgrade,
        maxUpgrade        = info.maxUpgrade,
        maxItemLevel      = info.maxItemLevel,
        upgradeLevelInfos = info.upgradeLevelInfos,
    }
end

-- Core per-slot logic: now prefers C_Item API (works for max-rank items),
-- then falls back to the upgrader UI (C_ItemUpgrade) when needed.
function UpgraderScanner:GetUpgradeInfoForEquipmentSlot(slotID)
    if not slotID then
        return nil
    end

    local itemLink = GetInventoryItemLink("player", slotID)
    if not itemLink then
        DebugPrint(("No item link for slot %d"):format(slotID))
        return nil
    end

    ----------------------------------------------------------------
    -- STEP 1: Use Blizzard's authoritative API (always works)
    ----------------------------------------------------------------
    local info = C_Item and C_Item.GetItemUpgradeInfo and C_Item.GetItemUpgradeInfo(itemLink)

    if not info or type(info) ~= "table" or not info.currentLevel or not info.trackString then
        DebugPrint(("Slot %d: Blizzard API returned nil"):format(slotID))
        return nil
    end

    local trackName = info.trackString:upper()
    local rank = info.currentLevel
    local maxRank = info.maxLevel or rank
    local currentIlvl = info.currentItemLevel or 0
    -- fix for crafted gear not returning ilevel
    if currentIlvl == 0 then
        currentIlvl = (GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(itemLink))
                or select(4, GetItemInfo(itemLink))
                or 0
    end

    if trackName == "MYTHIC" then
        trackName = "MYTH"
    end

    DebugPrint(("Slot %d: Blizzard API succeeded (%s %d/%d)"):format(slotID, trackName, rank, maxRank))

    ----------------------------------------------------------------
    -- STEP 2: Determine max item level
    -- If the item is NOT max rank, we can load it into the upgrader UI.
    -- If it IS max rank, the upgrader UI refuses to load it.
    ----------------------------------------------------------------
    local maxItemLevel = currentIlvl

    if rank < maxRank then
        -- Try to load into upgrader UI to read max ilvl
        local loc = ItemLocation:CreateFromEquipmentSlot(slotID)
        if loc and loc:IsValid() then
            ClearUpgradeSelection()

            -- Try both selectors
            if TrySelectWith("SetItemUpgradeFromItemLocation", loc)
            or TrySelectWith("SetItemUpgradeFromLocation", loc) then

                local upInfo = TryReadInfoFromUpgradeAPI(loc)
                if upInfo and upInfo.maxItemLevel then
                    maxItemLevel = upInfo.maxItemLevel
                    DebugPrint(("Slot %d: max ilvl from upgrader UI = %d"):format(slotID, maxItemLevel))
                end
            end

            ClearUpgradeSelection()
        end
    else
        DebugPrint(("Slot %d: Item is max rank; using current ilvl as max ilvl"):format(slotID))
    end

    -- Fallback for crafted gear or items where maxItemLevel=0
    if maxItemLevel == 0 then
        maxItemLevel = (GetDetailedItemLevelInfo and GetDetailedItemLevelInfo(itemLink))
                    or select(4, GetItemInfo(itemLink))
                    or 0
    end

    return {
        trackName    = trackName,
        currUpgrade  = rank,
        maxUpgrade   = maxRank,
        maxItemLevel = maxItemLevel,
    }
end

-- Scan all equipped items at the upgrader NPC
function UpgraderScanner:ScanEquippedAtUpgrader(onDone)
    if not self:IsUpgraderOpen() then
        DebugPrint("Upgrader API not available or NPC window not open")
        return
    end

    GearCresterDB = GearCresterDB or {}
    GearCresterDB.slotCaps = {}

    -- Build slot list from GC.SLOTS
    local slots = {}
    for slotID in pairs(GC.SLOTS or {}) do
        table.insert(slots, slotID)
    end
    table.sort(slots)

    GC:Print("Scanning equipped items at upgrader NPC...")

    local slotIndex = 1
    local captured = 0
    local failed   = 0

    local function scanNextSlot()
        if slotIndex > #slots then
            DebugPrint(("Upgrader scan complete: %d slots captured, %d failed"):format(captured, failed))
            GC:Print("Upgrader scan complete. Slot caps updated.")
            if onDone then
                onDone()
            end
            return
        end

        local slotID = slots[slotIndex]
        local slotName = GC.SLOTS[slotID] or ("Slot" .. slotID)

        local info = UpgraderScanner:GetUpgradeInfoForEquipmentSlot(slotID)
        if info and info.trackName and info.currUpgrade and info.maxUpgrade then
            -- Add slot name for easier debugging and UI display
            GearCresterDB.slotCaps[slotID] = {
                slot         = GC.SLOTS[slotID],
                track        = info.trackName,
                currUpgrade  = info.currUpgrade,
                maxUpgrade   = info.maxUpgrade,
                maxItemLevel = info.maxItemLevel,
            }
            captured = captured + 1
            DebugPrint(("%s (%d): %s %d/%d (max ilvl %d)"):format(
                slotName, slotID, info.trackName, info.currUpgrade, info.maxUpgrade, info.maxItemLevel or 0
            ))
        else
            failed = failed + 1
            DebugPrint(("%s (%d): No valid upgrade info"):format(slotName, slotID))
        end

        slotIndex = slotIndex + 1
        C_Timer.After(0.05, scanNextSlot)
    end

    scanNextSlot()
end

function UpgraderScanner:GetSlotCap(slotID)
    if not GearCresterDB or not GearCresterDB.slotCaps then
        return nil
    end
    return GearCresterDB.slotCaps[slotID]
end

function UpgraderScanner:ClearSlotCaps()
    if GearCresterDB then
        GearCresterDB.slotCaps = {}
        GC:Print("Slot caps cleared.")
    end
end

return UpgraderScanner
