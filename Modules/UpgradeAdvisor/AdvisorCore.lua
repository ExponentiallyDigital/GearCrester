local addonName, GC = ...

GC.modules.UpgradeAdvisor = {}

local Advisor = GC.modules.UpgradeAdvisor

function Advisor:GetRecommendedUpgrades()
    local equipped = GC.DataModel.equipped
    local crests = GC.DataModel.crests

    return GC.modules.UpgradeAdvisor.Logic:Evaluate(equipped, crests)
end
