local addonName, GC = ...

local FreeUpgrade = {}
GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
GC.modules.UpgradeAdvisor.FreeUpgrade = FreeUpgrade

function FreeUpgrade:IsGoldOnlyUpgrade(itemData, allItems)
    if not itemData or not itemData.trackName or not itemData.currentRank then
        return false, nil
    end
    
    local trackName = itemData.trackName
    local currentRank = itemData.currentRank
    local slotName = itemData.slotName
    
    -- Find the highest rank item of the same track
    local highestRank = currentRank
    
    if allItems then
        for _, otherItem in ipairs(allItems) do
            if otherItem.trackName == trackName and otherItem.currentRank > highestRank then
                highestRank = otherItem.currentRank
            end
        end
    end
    
    -- If we found a higher rank item of the same track
    if highestRank > currentRank then
        return true, highestRank
    end
    
    return false, nil
end

function FreeUpgrade:ApplyGoldOnlyDetection(results)
    if not results or #results == 0 then
        return
    end
    
    -- First pass: find highest rank per track
    local trackMaxRank = {}
    for _, entry in ipairs(results) do
        if entry.trackName then
            if not trackMaxRank[entry.trackName] or entry.currentRank > trackMaxRank[entry.trackName] then
                trackMaxRank[entry.trackName] = entry.currentRank
            end
        end
    end
    
    -- Second pass: mark gold-only upgrades
    for _, entry in ipairs(results) do
        if entry.trackName and entry.currentRank < trackMaxRank[entry.trackName] then
            entry.isGoldOnly = true
            entry.goldOnlyTargetRank = trackMaxRank[entry.trackName]
            entry.goldOnlySteps = trackMaxRank[entry.trackName] - entry.currentRank
        end
    end
end

return FreeUpgrade
