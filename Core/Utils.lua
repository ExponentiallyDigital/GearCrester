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
-- Sort order: 1) Tier (MYTH > HERO > CHAMPION > VETERAN > ADVENTURER), 2) Slot priority, 3) Location (equipped < bags < bank), 4) Bag/slot
function GC.SortUpgradeResults(results)
    if not results or type(results) ~= "table" then
        return results
    end

    -- Remove nil entries defensively
    local cleaned = {}
    for _, v in ipairs(results) do
        if v ~= nil then
            table.insert(cleaned, v)
        end
    end
    results = cleaned

    local Data = GC.modules.UpgradeAdvisor and GC.modules.UpgradeAdvisor.Data

    -- Build tier priority map (lower = higher priority, so MYTH=1, HERO=2, etc.)
    local tierPriority = {}
    if Data and Data.TRACKS then
        for i, track in ipairs(Data.TRACKS) do
            -- Reverse order: last track (MYTH) gets priority 1
            tierPriority[track] = #Data.TRACKS - i + 1
        end
    else
        -- Fallback if Data not available yet
        tierPriority["MYTH"] = 1
        tierPriority["HERO"] = 2
        tierPriority["CHAMPION"] = 3
        tierPriority["VETERAN"] = 4
        tierPriority["ADVENTURER"] = 5
    end

    local function getTierPriority(entry)
        if not entry or not entry.trackName then
            return 999  -- No track = lowest priority
        end
        local priority = tierPriority[entry.trackName]
        return priority or 999  -- Unknown track = lowest priority
    end

    local function getSlotPriority(entry)
        if not entry then return 999 end
        -- Use slot priority for all items (equipped and bag/bank)
        if Data and Data.SLOT_PRIORITY then
            local slotName = nil

            -- For equipped items, use slotID directly
            if not entry.location and entry.slotID then
                return Data.SLOT_PRIORITY[entry.slotID] or 999
            end

            -- For bag/bank items, get slot name from entry or item info
            if entry.location then
                slotName = entry.slotName
                if not slotName and entry.itemLink then
                    -- Try to extract from item info
                    local _, _, _, _, _, _, _, _, _, equipLoc = GetItemInfo(entry.itemLink)
                    if equipLoc then
                        slotName = GC.EQUIPLOC_TO_SLOT[equipLoc]
                    end
                end
            end

            -- Find slotID from slotName and return priority
            if slotName then
                for slotID, name in pairs(GC.SLOTS) do
                    if name == slotName then
                        return Data.SLOT_PRIORITY[slotID] or 999
                    end
                end
            end
        end
        return 999
    end

    local function getLocationPriority(entry)
        if not entry then return 999 end
        if not entry.location then
            return 1  -- Equipped items first
        end
        -- Bag/bank items
        if entry.location:match("^bag") then
            return 2
        elseif entry.location:match("^bank") then
            return 3
        end
        return 999
    end

    local function getBagSlot(entry)
        if not entry or not entry.location then
            return 99, 99
        end

        -- bag X, slot Y
        local b1, s1 = entry.location:match("bag (%d+), slot (%d+)")
        if b1 and s1 then
            return tonumber(b1), tonumber(s1)
        end

        -- bank X, slot Y
        local b2, s2 = entry.location:match("bank (%d+), slot (%d+)")
        if b2 and s2 then
            -- bank bags sort after normal bags
            return tonumber(b2) + 50, tonumber(s2)
        end

        return 99, 99
    end

    table.sort(results, function(a, b)
        -- Handle nils
        if a == nil then return false end
        if b == nil then return true end

        -- 1. Tier priority (MYTH > HERO > CHAMPION > VETERAN > ADVENTURER)
        local aTier = getTierPriority(a)
        local bTier = getTierPriority(b)
        if aTier ~= bTier then
            return aTier < bTier  -- Lower tier priority = higher priority
        end

        -- 2. Slot priority
        local aSlotPri = getSlotPriority(a)
        local bSlotPri = getSlotPriority(b)
        if aSlotPri ~= bSlotPri then
            return aSlotPri < bSlotPri
        end

        -- 3. Location priority (equipped < bags < bank)
        local aLocPri = getLocationPriority(a)
        local bLocPri = getLocationPriority(b)
        if aLocPri ~= bLocPri then
            return aLocPri < bLocPri
        end

        -- 4. Bag/bank sorting
        local aBag, aSlot = getBagSlot(a)
        local bBag, bSlot = getBagSlot(b)

        if aBag ~= bBag then
            return aBag < bBag
        end
        if aSlot ~= bSlot then
            return aSlot < bSlot
        end

        -- Final fallback: alphabetical by slotName
        return (a.slotName or "") < (b.slotName or "")
    end)

    return results
end

