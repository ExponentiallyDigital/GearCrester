local addonName, GC = ...

local InventoryOverview = {}
GC.modules.UI = GC.modules.UI or {}
GC.modules.UI.InventoryOverview = InventoryOverview

function InventoryOverview:CollectAllItems()
    local result = {
        equipped = {},
        bags = {},
        bank = {},
        warbank = {},
    }
    
    -- Collect equipped items
    if GC.DataModel and GC.DataModel.equipped then
        for slotID, itemData in pairs(GC.DataModel.equipped) do
            if itemData and itemData.itemLink then
                local Logic = GC.modules.UpgradeAdvisor.Logic
                if Logic then
                    local trackName, currentRank = Logic.GetItemUpgradeInfo(itemData.itemLink)
                    local currentIlvl = Logic.GetItemIlvl(itemData.itemLink)
                    
                    table.insert(result.equipped, {
                        slot = itemData.slotName,
                        slotID = slotID,
                        itemLink = itemData.itemLink,
                        track = trackName,
                        rank = currentRank,
                        currentIlvl = currentIlvl,
                        location = "Equipped",
                    })
                end
            end
        end
    end
    
    -- Collect bag items (stub - may be empty)
    if GC.DataModel and GC.DataModel.bags then
        for itemKey, itemData in pairs(GC.DataModel.bags) do
            if itemData and itemData.itemLink then
                local Logic = GC.modules.UpgradeAdvisor.Logic
                if Logic then
                    local trackName, currentRank = Logic.GetItemUpgradeInfo(itemData.itemLink)
                    local currentIlvl = Logic.GetItemIlvl(itemData.itemLink)
                    
                    table.insert(result.bags, {
                        slot = itemData.location or itemKey,
                        slotID = nil,
                        itemLink = itemData.itemLink,
                        track = trackName,
                        rank = currentRank,
                        currentIlvl = currentIlvl,
                        location = itemData.location,
                    })
                end
            end
        end
    end
    
    -- Collect bank items (stub - may be empty)
    if GC.DataModel and GC.DataModel.bank then
        for itemKey, itemData in pairs(GC.DataModel.bank) do
            if itemData and itemData.itemLink then
                local Logic = GC.modules.UpgradeAdvisor.Logic
                if Logic then
                    local trackName, currentRank = Logic.GetItemUpgradeInfo(itemData.itemLink)
                    local currentIlvl = Logic.GetItemIlvl(itemData.itemLink)
                    
                    table.insert(result.bank, {
                        slot = itemData.location or itemKey,
                        slotID = nil,
                        itemLink = itemData.itemLink,
                        track = trackName,
                        rank = currentRank,
                        currentIlvl = currentIlvl,
                        location = itemData.location,
                    })
                end
            end
        end
    end
    
    -- Warbank not implemented yet
    -- result.warbank remains empty
    
    return result
end

function InventoryOverview:GetUpgradeInfo(itemData, simulatedCrests)
    if not itemData or not itemData.track or not itemData.rank then
        return nil
    end
    
    local Data = GC.modules.UpgradeAdvisor.Data
    if not Data then
        return nil
    end
    
    local trackName = itemData.track
    local currentRank = itemData.rank
    
    if currentRank >= Data.MAX_RANK then
        return nil
    end
    
    local nextRank = currentRank + 1
    local nextIlvl = Data:GetNextIlvl(trackName, currentRank)
    
    if not nextIlvl then
        return nil
    end
    
    local crestType = Data:GetCrestType(trackName)
    local crestCost = Data:GetCrestCost()
    
    -- Calculate crest count
    local crestCount = 0
    if simulatedCrests then
        crestCount = simulatedCrests[crestType] or 0
    elseif GC.modules.CrestTracker and GC.modules.CrestTracker.CrestData then
        crestCount = GC.modules.CrestTracker.CrestData:GetCrestCount(crestType)
    end
    
    local upgradeSteps = Data.MAX_RANK - currentRank
    local totalCrestCost = upgradeSteps * crestCost
    
    return {
        slot = itemData.slot,
        slotID = itemData.slotID,
        itemLink = itemData.itemLink,
        track = trackName,
        currentRank = currentRank,
        currentIlvl = itemData.currentIlvl,
        nextIlvl = nextIlvl,
        crestType = crestType,
        crestCostPerStep = crestCost,
        upgradeSteps = upgradeSteps,
        totalCrestCost = totalCrestCost,
        canAfford = crestCount >= crestCost,
        location = itemData.location,
    }
end

return InventoryOverview
