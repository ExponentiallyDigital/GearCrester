local addonName, GC = ...

local UpgradeOrder = {}
GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
GC.modules.UpgradeAdvisor.UpgradeOrder = UpgradeOrder

local Data = GC.modules.UpgradeAdvisor.Data

function UpgradeOrder:GetDefaultPriority(slotID)
    if Data and Data.SLOT_PRIORITY then
        return Data.SLOT_PRIORITY[slotID] or 99
    end
    return 99
end

function UpgradeOrder:GetEffectivePriority(slotID)
    -- Check if user has defined a custom weight for this slot
    if GearCresterDB and GearCresterDB.slotWeights then
        local userWeight = GearCresterDB.slotWeights[slotID]
        if userWeight and type(userWeight) == "number" and userWeight >= 1 and userWeight <= 20 then
            return userWeight
        end
    end
    
    -- Fall back to default priority
    return self:GetDefaultPriority(slotID)
end

function UpgradeOrder:SetSlotWeight(slotID, weight)
    if not GearCresterDB.slotWeights then
        GearCresterDB.slotWeights = {}
    end
    
    if weight >= 1 and weight <= 20 then
        GearCresterDB.slotWeights[slotID] = weight
        return true
    end
    
    return false
end

function UpgradeOrder:ResetSlotWeights()
    GearCresterDB.slotWeights = {}
end

function UpgradeOrder:GetAllWeights()
    local weights = {}
    
    -- Get all default priorities
    for slotID, defaultPriority in pairs(Data.SLOT_PRIORITY) do
        weights[slotID] = {
            default = defaultPriority,
            effective = self:GetEffectivePriority(slotID),
            isCustom = GearCresterDB.slotWeights and GearCresterDB.slotWeights[slotID] ~= nil,
        }
    end
    
    return weights
end

return UpgradeOrder
