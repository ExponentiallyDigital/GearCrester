local addonName, GC = ...

GC.ResetTimer = {}

function GC.ResetTimer:GetTimeUntilReset()
    -- region-based static table
    return 0
end
