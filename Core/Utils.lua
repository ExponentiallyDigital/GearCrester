local addonName, GC = ...

-- String trim function (not available in WoW Lua by default)
if not string.trim then
    string.trim = function(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end
end

function GC:SafeCall(func, ...)
    if type(func) == "function" then
        return pcall(func, ...)
    end
end

function GC:Round(num, places)
    local mult = 10^(places or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Normalize track name strings (e.g., "MYTHIC" -> "MYTH")
function GC.NormalizeTrackName(trackName)
    if not trackName then
        return nil
    end
    if trackName == "MYTHIC" then
        return "MYTH"
    end
    return trackName
end

-- Determine track name for crafted items using TradeSkillUI API + item level
-- Requires itemLink (NOT itemLocation)
-- Returns: "CRAFTED", "CRAFTED-HERO", or "CRAFTED-MYTHIC" if item is crafted, nil otherwise
-- Note: Crafting quality (1-5) only tells us if item is crafted, not the track.
--       Track is determined by final item level (crest infusion).
function GC.GetCraftedTrackName(itemLink)
    if not itemLink then
        return nil
    end

    -- Step 1: Check if item is crafted using TradeSkillUI API
    local craftedQuality = C_TradeSkillUI and C_TradeSkillUI.GetItemCraftedQualityByItemInfo and C_TradeSkillUI.GetItemCraftedQualityByItemInfo(itemLink)

    if not craftedQuality or craftedQuality == 0 then
        -- Not a crafted item
        return nil
    end

    -- Step 2: Item is crafted - determine track by final item level
    local ilvl = GetDetailedItemLevelInfo(itemLink)

    if not ilvl or ilvl == 0 then
        -- Fallback to base crafted if ilvl unavailable
        return "CRAFTED"
    end

    -- Map ilvl to crafted track (Midnight Season 1 crafted gear)
    -- CRAFTED:       base crafted (ilvl ~252)
    -- CRAFTED-HERO:  HERO infusion (ilvl ~272)
    -- CRAFTED-MYTHIC: MYTHIC infusion (ilvl ~285)
    if ilvl >= 285 then
        return "CRAFTED-MYTHIC"
    elseif ilvl >= 272 then
        return "CRAFTED-HERO"
    else
        return "CRAFTED"
    end
end

-- Returns true if the item can be worn in one of the GC.SLOTS equipment slots
function GC.CanBeEquipped(itemLink)
    if not itemLink then return false end
    -- Try to get equip location
    local _, _, _, _, _, _, _, _, equipSlot = GetItemInfo(itemLink)
    if not equipSlot then
        -- Item not cached yet; request load and assume not equipable for now
        return false
    end
    -- Check against known equip locations
    return GC.EQUIPLOC_TO_SLOT[equipSlot] ~= nil
end

-- Safe, deterministic sorting for all GearCrester result types
-- Sort order: 1) Location (equipped < bags < bank), 2) Tier (CRAFTED-MYTHIC > MYTH > CRAFTED-HERO > HERO > CRAFTED > CHAMPION > VETERAN > ADVENTURER), 3) Slot priority, 4) Bag/slot
function GC.SortUpgradeResults(results)
    if not results or type(results) ~= "table" then
        return results
    end

    -- Remove nil entries defensively and normalize to canonical schema
    local cleaned = {}
    for _, v in ipairs(results) do
        if v ~= nil then
            table.insert(cleaned, GC.NormalizeUpgradeEntry(v))
        end
    end
    results = cleaned

    -- Use global tier priority from Constants.lua
    local tierPriority = GC.TIER_PRIORITY or {}

    local function getTierPriority(entry)
        if not entry or not entry.trackName then
            return 999 -- No/unknown track = lowest priority
        end
        return tierPriority[entry.trackName] or 999
    end

    local function getSlotPriority(entry)
        if not entry then return 999 end

        -- For /gc results, priority is already computed (Data:GetSlotPriority)
        if entry.priority then
            return entry.priority
        end

        -- Fallback: derive from slotID / slotName
        local Data = GC.modules
            and GC.modules.UpgradeAdvisor
            and GC.modules.UpgradeAdvisor.Data

        if not Data or not Data.SLOT_PRIORITY then
            return 999
        end

        -- Equipped items: use slotID directly
        if not entry.location and entry.slotID then
            return Data.SLOT_PRIORITY[entry.slotID] or 999
        end

        -- Bag/bank items: use slotName -> slotID -> priority
        local slotName = entry.slotName
        if not slotName and entry.itemLink then
            local _, _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(entry.itemLink)
            if equipLoc and GC.EQUIPLOC_TO_SLOT then
                slotName = GC.EQUIPLOC_TO_SLOT[equipLoc]
            end
        end

        if slotName and GC.SLOTS then
            for slotID, name in pairs(GC.SLOTS) do
                if name == slotName then
                    return Data.SLOT_PRIORITY[slotID] or 999
                end
            end
        end

        return 999
    end

    local function getLocationPriority(entry)
        if not entry then return 999 end
        if not entry.location then
            return 1 -- Equipped
        end
        if entry.location:match("^bag") then
            return 2 -- Bags
        end
        if entry.location:match("^bank") then
            return 3 -- Bank
        end
        return 999
    end

    local function getBagSlot(entry)
        if not entry or not entry.location then
            return 99, 99
        end

        local b1, s1 = entry.location:match("bag (%d+), slot (%d+)")
        if b1 and s1 then
            return tonumber(b1), tonumber(s1)
        end

        local b2, s2 = entry.location:match("bank (%d+), slot (%d+)")
        if b2 and s2 then
            -- bank after bags
            return tonumber(b2) + 50, tonumber(s2)
        end

        return 99, 99
    end

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG SORT] Incoming entries for sorting:|r")
        for i, e in ipairs(results) do
            local tierPri = getTierPriority(e)
            local slotPri = getSlotPriority(e)
            print(string.format(
                "  #%d loc=%s track=%s tierPri=%s slotName=%s slotPri=%s bagSlot=%s",
                i,
                tostring(e.location),
                tostring(e.trackName),
                tostring(tierPri),
                tostring(e.slotName),
                tostring(slotPri),
                tostring(e.location)
            ))
        end
    end

    table.sort(results, function(a, b)
        if a == nil then return false end
        if b == nil then return true end

        -- 🔥 DEBUG: show exactly what the comparator is comparing
        if GC.db and GC.db.debug then
            local aTierPri = getTierPriority(a)
            local bTierPri = getTierPriority(b)
            local aSlotPri = getSlotPriority(a)
            local bSlotPri = getSlotPriority(b)
            print(string.format(
                "[DEBUG COMPARE]\n  A: loc=%s track=%s tierPri=%s slotName=%s slotPri=%s\n  B: loc=%s track=%s tierPri=%s slotName=%s slotPri=%s",
                tostring(a.location),
                tostring(a.trackName),
                tostring(aTierPri),
                tostring(a.slotName),
                tostring(aSlotPri),
                tostring(b.location),
                tostring(b.trackName),
                tostring(bTierPri),
                tostring(b.slotName),
                tostring(bSlotPri)
            ))
        end

        -- 1. Location: equipped < bags < bank
        local aLocPri = getLocationPriority(a)
        local bLocPri = getLocationPriority(b)
        if aLocPri ~= bLocPri then
            return aLocPri < bLocPri
        end

        -- 2. Track tier (via GC.TIER_PRIORITY)
        local aTier = getTierPriority(a)
        local bTier = getTierPriority(b)
        if aTier ~= bTier then
            return aTier < bTier
        end

        -- 3. Slot weighting
        local aSlotPri = getSlotPriority(a)
        local bSlotPri = getSlotPriority(b)
        if aSlotPri ~= bSlotPri then
            return aSlotPri < bSlotPri
        end

        -- 4. Bag/bank number and slot
        local aBag, aSlot = getBagSlot(a)
        local bBag, bSlot = getBagSlot(b)
        if aBag ~= bBag then
            return aBag < bBag
        end
        if aSlot ~= bSlot then
            return aSlot < bSlot
        end

        -- 5. Final fallback: alphabetical by slotName
        return (a.slotName or "") < (b.slotName or "")
    end)

    return results
end

-- Maps slotName ("Wrist") → numeric slotID (9)
function GC.ResolveSlotID(slotName)
    if not slotName then return nil end
    local nameLower = tostring(slotName):lower()

    -- Direct lookup first
    if GC.SLOT_NAME_TO_ID then
        local slotID = GC.SLOT_NAME_TO_ID[nameLower]
        if slotID then
            return slotID
        end
    end

    -- Handle generic slot names (for bag/bank items)
    if nameLower == "finger" or nameLower == "finger1" then
        return GC.SLOT_NAME_TO_ID and GC.SLOT_NAME_TO_ID["finger1"] or 11
    end
    if nameLower == "finger2" then
        return GC.SLOT_NAME_TO_ID and GC.SLOT_NAME_TO_ID["finger2"] or 12
    end
    if nameLower == "trinket" or nameLower == "trinket1" then
        return GC.SLOT_NAME_TO_ID and GC.SLOT_NAME_TO_ID["trinket1"] or 13
    end
    if nameLower == "trinket2" then
        return GC.SLOT_NAME_TO_ID and GC.SLOT_NAME_TO_ID["trinket2"] or 14
    end

    -- Fallback: try to match against GC.SLOTS values
    if GC.SLOTS then
        for id, name in pairs(GC.SLOTS) do
            if tostring(name):lower() == nameLower then
                return id
            end
        end
    end

    return nil
end

function GC.NormalizeUpgradeEntry(entry)
    entry = entry or {}

    -- Canonical schema defaults
    entry.slotName = entry.slotName or "Unknown"
    entry.slotID = tonumber(entry.slotID) or nil
    entry.itemLink = entry.itemLink or nil
    entry.itemName = entry.itemName or nil
    entry.currentIlvl = tonumber(entry.currentIlvl) or 0
    entry.nextIlvl = tonumber(entry.nextIlvl) or 0
    entry.trackName = entry.trackName or nil
    entry.currentRank = tonumber(entry.currentRank) or nil
    entry.maxRank = tonumber(entry.maxRank) or nil
    entry.crestType = entry.crestType or nil
    entry.crestCostPerStep = tonumber(entry.crestCostPerStep) or 0
    entry.totalCrestCost = tonumber(entry.totalCrestCost) or 0
    entry.upgradeSteps = tonumber(entry.upgradeSteps) or 0
    entry.isGoldOnly = entry.isGoldOnly == true
    entry.goldOnlyTargetRank = tonumber(entry.goldOnlyTargetRank) or nil
    entry.canAfford = entry.canAfford == true

    if entry.priority == nil then
        local Data = GC.modules and GC.modules.UpgradeAdvisor and GC.modules.UpgradeAdvisor.Data
        entry.priority = Data and Data:GetSlotPriority(entry.slotID) or 999
    else
        entry.priority = tonumber(entry.priority) or 999
    end

    entry.location = entry.location or nil
    entry.bonusIDs = entry.bonusIDs or {}

    -- Ensure item has normalized slotID from slotName as fallback
    if not entry.slotID and entry.slotName then
        entry.slotID = GC.ResolveSlotID(entry.slotName)
    end

    return entry
end

function GC.FormatUpgradeLine(entry, mode)
    entry = GC.NormalizeUpgradeEntry(entry)

    local location = entry.location and (" [" .. entry.location .. "]") or ""
    local trackText = GC.ColorTrack(entry.trackName or entry.crestType or "UNKNOWN")
    local itemRef = entry.itemLink or entry.itemName or ""

    if mode == "free" then
        return string.format("%s%s: %d -> %d [FREE] (%s)%s",
            entry.slotName,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            trackText,
            itemRef ~= "" and " " .. itemRef or "")
    elseif mode == "dump" then
        return string.format("%s%s: %s - ilvl=%d track=%s rank=%s bonusIDs=[%s]",
            entry.slotName,
            location,
            itemRef ~= "" and itemRef or "Unknown",
            entry.currentIlvl,
            trackText,
            tostring(entry.currentRank or "nil"),
            table.concat(entry.bonusIDs or {}, ", "))
    elseif mode == "why" then
        local reason = entry.reason or "No reason"
        return string.format("%s%s: %s (%s) %s",
            entry.slotName,
            location,
            itemRef ~= "" and itemRef or "Unknown",
            reason,
            trackText)
    else
        -- default formatting
        local totalCost = tonumber(entry.totalCrestCost) or 0
        local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
        local costText

        if entry.isGoldOnly then
            if entry.goldOnlyTargetRank then
                costText = string.format("(%s FREE to rank %d)", trackText, entry.goldOnlyTargetRank)
            else
                costText = string.format("(%s FREE)", trackText)
            end
        else
            costText = string.format("(%s%s x%d|r)", affordColor, trackText, totalCost)
        end

        local rankText = (not entry.isGoldOnly and entry.goldOnlyTargetRank) and string.format(" (to rank %d)", entry.goldOnlyTargetRank) or ""

        return string.format("%s%s: %d -> %d %s%s%s",
            entry.slotName,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            costText,
            rankText,
            itemRef ~= "" and " " .. itemRef or "")
    end
end
