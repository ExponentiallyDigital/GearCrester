local addonName, GC = ...

GC.name = addonName
GC.modules = {}
GC.db = {}

-- for supression of calibration text when "/gc test" is run
GC.suppressCalibrationOutput = false

-- Valid crest types (shared constant)
GC.VALID_CREST_TYPES = {
    ADVENTURER = true,
    VETERAN = true,
    CHAMPION = true,
    HERO = true,
    MYTH = true,
}

function GC:OnLoad()
    GC.db = GearCresterDB
    local version = C_AddOns and C_AddOns.GetAddOnMetadata(addonName, "Version") or "unknown"
    GC.version = version
    GC.modules.Commands:Register()
    GC:Print("v" .. version .. " loaded. Use /gc or /gc help.")
end

function GC:Print(msg)
    print("|cff00ff98GearCrester:|r " .. msg)
end

-- Helper: slot name to ID lookup
function GC:SlotNameToID(slotName)
    if not slotName then return nil end
    return GC.SLOT_NAME_TO_ID[slotName:lower()]
end

return GC
