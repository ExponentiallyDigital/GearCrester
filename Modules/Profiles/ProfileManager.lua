local addonName, GC = ...

GC.ProfileManager = {}

function GC.ProfileManager:GetProfile()
    return GC.db.profile or "Default"
end
