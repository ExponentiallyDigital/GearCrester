local addonName, GC = ...

local Data = {}
GC.modules.UpgradeAdvisor.Data = Data

Data.SLOT_PRIORITY = {
    [16] = 1, -- MainHand
    [17] = 2, -- OffHand
    [1]  = 3, -- Head
    [5]  = 4, -- Chest
    [7]  = 5, -- Legs
    [6]  = 6, -- Waist
    [9]  = 7, -- Wrist
    [10] = 8, -- Hands
    [11] = 9, -- Ring1
    [12] = 10, -- Ring2
    [13] = 11, -- Trinket1
    [14] = 12, -- Trinket2
}

function Data:GetSlotPriority(slotID)
    return self.SLOT_PRIORITY[slotID] or 99
end

function Data:GetItemUpgradeInfo(itemLink)
    -- stub: return crest type, cost, next ilvl, etc.
    return {
        canUpgrade = false,
    }
end
