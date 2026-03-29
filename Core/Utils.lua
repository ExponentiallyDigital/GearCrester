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

-- Safe, deterministic sorting for all GearCrester result types
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

    local UpgradeOrder = GC.modules.UpgradeAdvisor
        and GC.modules.UpgradeAdvisor.UpgradeOrder

    local function getPriority(entry)
        if not entry then return 999 end
        if not entry.location then
            -- Equipped item
            if UpgradeOrder and entry.slotID then
                return UpgradeOrder:GetEffectivePriority(entry.slotID)
            end
            return 999
        end
        -- Bag/bank items get lower priority than equipped
        return 500
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

        -- Equipped before bags/bank
        local aEquipped = (a.location == nil)
        local bEquipped = (b.location == nil)

        if aEquipped ~= bEquipped then
            return aEquipped -- true means a comes first
        end

        -- Slot priority (equipped only)
        local aPri = getPriority(a)
        local bPri = getPriority(b)
        if aPri ~= bPri then
            return aPri < bPri
        end

        -- Bag/bank sorting
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

