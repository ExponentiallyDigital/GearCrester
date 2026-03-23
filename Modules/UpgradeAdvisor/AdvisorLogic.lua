local addonName, GC = ...

local Logic = {}
GC.modules.UpgradeAdvisor.Logic = Logic

function Logic:Evaluate(equipped, crests)
    local results = {}

    for slotID, item in pairs(equipped) do
        local data = GC.modules.UpgradeAdvisor.Data:GetItemUpgradeInfo(item.link)

        if data.canUpgrade then
            table.insert(results, {
                slot = item.slot,
                link = item.link,
                nextIlvl = data.nextIlvl,
                crestType = data.crestType,
                crestCost = data.crestCost,
                priority = GC.modules.UpgradeAdvisor.Data:GetSlotPriority(slotID),
            })
        end
    end

    table.sort(results, function(a, b)
        return a.priority < b.priority
    end)

    return results
end
