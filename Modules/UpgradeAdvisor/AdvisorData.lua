local addonName, GC = ...

GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
local Data = {}
GC.modules.UpgradeAdvisor.Data = Data

Data.SLOT_PRIORITY = {
    [16] = 1, -- MainHand
    [17] = 2, -- OffHand
    [1]  = 3, -- Head
    [5]  = 4, -- Chest
    [7]  = 5, -- Legs
    [6]  = 6, -- Waist
    [9]  = 7, -- Wrist
    [10] = 8, -- Hands
    [3]  = 9, -- Shoulder
    [8]  = 10, -- Feet
    [2]  = 11, -- Neck
    [15] = 12, -- Back
    [11] = 13, -- Finger1
    [12] = 14, -- Finger2
    [13] = 15, -- Trinket1
    [14] = 16, -- Trinket2
}

Data.TRACKS = {
    "ADVENTURER",
    "VETERAN",
    "CHAMPION",
    "HERO",
    "MYTH",
}

Data.TRACK_ILVLS = {
    ADVENTURER = {
        [1] = 220,
        [2] = 224,
        [3] = 227,
        [4] = 230,
        [5] = 233,
        [6] = 237,
    },
    VETERAN = {
        [1] = 233,
        [2] = 237,
        [3] = 240,
        [4] = 243,
        [5] = 246,
        [6] = 250,
    },
    CHAMPION = {
        [1] = 246,
        [2] = 250,
        [3] = 253,
        [4] = 256,
        [5] = 259,
        [6] = 263,
    },
    HERO = {
        [1] = 259,
        [2] = 263,
        [3] = 266,
        [4] = 269,
        [5] = 272,
        [6] = 276,
    },
    MYTH = {
        [1] = 272,
        [2] = 272,
        [3] = 279,
        [4] = 282,
        [5] = 285,
        [6] = 289,
    },
}

Data.CREST_TYPE = {
    ADVENTURER = "ADVENTURER",
    VETERAN = "VETERAN",
    CHAMPION = "CHAMPION",
    HERO = "HERO",
    MYTH = "MYTH",
}

Data.CREST_COST = 20

Data.MAX_RANK = 6

-- Bonus IDs that identify upgrade track (last bonus ID in the sequence)
Data.TRACK_BONUS_IDS = {
    ADVENTURER = { 12697 },
    VETERAN = { 12698 },
    CHAMPION = { 6652, 13577, 12699, 13439, 12787 },
    HERO = { 12700 },
    MYTH = { 12701 },
}

-- Bonus IDs that identify rank within each track
Data.RANK_BONUS_IDS = {
    ADVENTURER = {
        [1] = { 12773 },
        [2] = { 12774 },
        [3] = { 12775 },
        [4] = { 12776 },
        [5] = { 12777 },
        [6] = { 12778 },
    },
    VETERAN = {
        [1] = { 12779 },
        [2] = { 12780 },
        [3] = { 12781 },
        [4] = { 12782 },
        [5] = { 12783 },
        [6] = { 12784 },
    },
    CHAMPION = {
        [1] = { 12785 },
        [2] = { 12786 },
        [3] = { 12787 },
        [4] = { 12788, 13333 },
        [5] = { 12789 },
        [6] = { 12790 },
    },
    HERO = {
        [1] = { 12791 },
        [2] = { 12792 },
        [3] = { 12793 },
        [4] = { 12794 },
        [5] = { 12795 },
        [6] = { 12796 },
    },
    MYTH = {
        [1] = { 12797 },
        [2] = { 12798 },
        [3] = { 12799 },
        [4] = { 12800 },
        [5] = { 12801 },
        [6] = { 12802 },
    },
}

function Data:GetSlotPriority(slotID)
    return self.SLOT_PRIORITY[slotID] or 99
end

function Data:GetCrestType(trackName)
    return self.CREST_TYPE[trackName]
end

function Data:GetCrestCost()
    return self.CREST_COST
end

function Data:GetNextIlvl(trackName, currentRank)
    local nextRank = currentRank + 1
    if nextRank > self.MAX_RANK then
        return nil
    end
    local trackIlvls = self.TRACK_ILVLS[trackName]
    if not trackIlvls then
        return nil
    end
    return trackIlvls[nextRank]
end

function Data:GetTrackIndex(trackName)
    for i, name in ipairs(self.TRACKS) do
        if name == trackName then
            return i
        end
    end
    return nil
end

function Data:GetNextTrack(currentTrackName)
    local currentIndex = self:GetTrackIndex(currentTrackName)
    if not currentIndex or currentIndex >= #self.TRACKS then
        return nil
    end
    return self.TRACKS[currentIndex + 1]
end

return Data
