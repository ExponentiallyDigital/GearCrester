local addonName, GC = ...

GC.SLOTS = {
    [1] = "Head",
    [2] = "Neck",
    [3] = "Shoulder",
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [8] = "Feet",
    [9] = "Wrist",
    [10] = "Hands",
    [11] = "Finger1",
    [12] = "Finger2",
    [13] = "Trinket1",
    [14] = "Trinket2",
    [15] = "Back",
    [16] = "MainHand",
    [17] = "OffHand",
}

-- Map equip location strings to slot names
GC.EQUIPLOC_TO_SLOT = {
    INVTYPE_HEAD = "Head",
    INVTYPE_NECK = "Neck",
    INVTYPE_SHOULDER = "Shoulder",
    INVTYPE_CHEST = "Chest",
    INVTYPE_ROBE = "Chest",
    INVTYPE_WAIST = "Waist",
    INVTYPE_LEGS = "Legs",
    INVTYPE_FEET = "Feet",
    INVTYPE_WRIST = "Wrist",
    INVTYPE_HAND = "Hands",
    INVTYPE_FINGER = "Finger",
    INVTYPE_TRINKET = "Trinket",
    INVTYPE_CLOAK = "Back",
    INVTYPE_WEAPON = "MainHand",
    INVTYPE_2HWEAPON = "MainHand",
    INVTYPE_WEAPONMAINHAND = "MainHand",
    INVTYPE_WEAPONOFFHAND = "OffHand",
    INVTYPE_SHIELD = "OffHand",
    INVTYPE_HOLDABLE = "OffHand",
}

-- Map InventoryType enum to slot names (Midnight API - used for bag/bank items)
GC.INVENTORYTYPE_TO_SLOT = {
    [1]  = "Head",
    [2]  = "Neck",
    [3]  = "Shoulder",
    [4]  = "Shirt",
    [5]  = "Chest",
    [6]  = "Waist",
    [7]  = "Legs",
    [8]  = "Feet",
    [9]  = "Wrist",
    [10] = "Hands",
    [11] = "Finger",
    [12] = "Trinket",
    [13] = "MainHand",
    [14] = "OffHand",
    [15] = "Ranged",
    [16] = "Back",
    [17] = "MainHand",  -- 2H weapon
    [18] = "Bag",
    [19] = "Tabard",
    [20] = "Chest",     -- Robe
    [21] = "MainHand",  -- Weapon (1H)
    [22] = "OffHand",   -- Holdable
    [23] = "Ranged",    -- Ranged (bow/wand)
    [24] = "Quiver",
    [25] = "Profession",
    [26] = "MainHand",  -- 2H weapon (alternate)
}

-- Track colour codes for printed output
GC.TRACK_COLORS = {
    ADVENTURER      = "|cffffff00",  -- Yellow
    VETERAN         = "|cff00ff00",  -- Green
    CHAMPION        = "|cffb04bff",  -- Purple
    CRAFTED         = "|cff00ffff",  -- Cyan (base crafted)
    HERO            = "|cffff66ff",  -- Pink
    ["CRAFTED-HERO"] = "|cffff9966",  -- Orange-Pink (crafted HERO)
    MYTH            = "|cffff0000",  -- Red
    ["CRAFTED-MYTHIC"] = "|cff990000",  -- Dark Red (crafted MYTHIC)
}

function GC.ColorTrack(track)
    local c = GC.TRACK_COLORS[track]
    if not c then return track end
    return c .. track .. "|r"
end

-- Reverse lookup: slot name -> slot ID
GC.SLOT_NAME_TO_ID = {}
for id, name in pairs(GC.SLOTS) do
    GC.SLOT_NAME_TO_ID[name:lower()] = id
end

-- Track names for parsing upgrade strings (from UpgraderScanner)
GC.TRACK_NAMES = {
    ["Adventurer"] = "ADVENTURER",
    ["Veteran"]    = "VETERAN",
    ["Champion"]   = "CHAMPION",
    ["Hero"]       = "HERO",
    ["Myth"]       = "MYTH",
}

-- Crest currency IDs (from CrestData)
GC.CREST_IDS = {
    ADVENTURER = 3383,
    VETERAN = 3341,
    CHAMPION = 3343,
    HERO = 3345,
    MYTH = 3347,
}

-- Crest types list (from CrestData)
GC.CREST_TYPES = {
    "ADVENTURER",
    "VETERAN",
    "CHAMPION",
    "HERO",
    "MYTH",
}

-- Valid crest types lookup (from Init)
GC.VALID_CREST_TYPES = {
    ADVENTURER = true,
    VETERAN = true,
    CHAMPION = true,
    HERO = true,
    MYTH = true,
}

-- Tier ordering for sorting (highest priority first, index = priority)
-- CRAFTED-MYTHIC > MYTH > CRAFTED-HERO > HERO > CRAFTED > CHAMPION > VETERAN > ADVENTURER
GC.TIER_PRIORITY = {
    ["CRAFTED-MYTHIC"] = 1,
    MYTH = 2,
    ["CRAFTED-HERO"] = 3,
    HERO = 4,
    CRAFTED = 5,
    CHAMPION = 6,
    VETERAN = 7,
    ADVENTURER = 8,
}
