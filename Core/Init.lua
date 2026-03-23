local addonName, GC = ...

GC.name = addonName
GC.modules = {}
GC.db = {}

function GC:OnLoad()
    GC.db = GearCresterDB or {}
    GC:Print("GearCrester loaded. /gc to open.")
end

function GC:Print(msg)
    print("|cff00ff98GearCrester:|r " .. msg)
end
