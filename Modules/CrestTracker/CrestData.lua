local addonName, GC = ...

local CrestData = {}
GC.modules.CrestTracker = GC.modules.CrestTracker or {}
GC.modules.CrestTracker.CrestData = CrestData

CrestData.CREST_IDS = {
    ADVENTURER = 3000,
    VETERAN = 3001,
    CHAMPION = 3002,
    HERO = 3003,
    MYTH = 3004,
}

CrestData.CREST_TYPES = {
    "ADVENTURER",
    "VETERAN",
    "CHAMPION",
    "HERO",
    "MYTH",
}

function CrestData:ReadCrests()
    GC.DataModel.crests = {}

    for crestName, crestID in pairs(self.CREST_IDS) do
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

function CrestData:SimulateCrests(crestType, count)
    local simulated = {}

    for _, typeName in ipairs(self.CREST_TYPES) do
        if typeName == crestType then
            simulated[typeName] = count
        else
            simulated[typeName] = 0
        end
    end

    return simulated
end

return CrestData
