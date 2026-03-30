local addonName, GC = ...

local CrestData = {}
GC.modules.CrestTracker = GC.modules.CrestTracker or {}
GC.modules.CrestTracker.CrestData = CrestData

function CrestData:ReadCrests()
    GC.DataModel.crests = {}

    for crestName, crestID in pairs(GC.CREST_IDS) do
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(crestID)
        if currencyInfo then
            GC.DataModel.crests[crestName] = {
                id = crestID,
                count = currencyInfo.quantity,
                name = currencyInfo.name,
            }
        end
    end
end

function CrestData:GetCrestCount(crestName)
    if GC.DataModel.crests[crestName] then
        return GC.DataModel.crests[crestName].count
    end
    return 0
end

function CrestData:GetAllCrestCounts()
    -- Ensure we have fresh data from Blizzard's API
    self:ReadCrests()

    return {
        ADVENTURER = self:GetCrestCount("ADVENTURER"),
        VETERAN = self:GetCrestCount("VETERAN"),
        CHAMPION = self:GetCrestCount("CHAMPION"),
        HERO = self:GetCrestCount("HERO"),
        MYTH = self:GetCrestCount("MYTH"),
    }
end

function CrestData:SimulateCrests(crestType, count)
    local simulated = {}

    for _, typeName in ipairs(GC.CREST_TYPES) do
        if typeName == crestType then
            simulated[typeName] = count
        else
            simulated[typeName] = 0
        end
    end

    return simulated
end

return CrestData
