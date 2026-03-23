local addonName, GC = ...

local DefaultProfiles = {}
GC.modules.Profiles = GC.modules.Profiles or {}
GC.modules.Profiles.DefaultProfiles = DefaultProfiles

DefaultProfiles.data = {}

function DefaultProfiles:GetDefault()
    return self.data
end

return DefaultProfiles
