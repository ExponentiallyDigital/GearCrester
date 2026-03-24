local addonName, GC = ...

GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
local Logic = {}
GC.modules.UpgradeAdvisor.Logic = Logic

local Data = GC.modules.UpgradeAdvisor.Data

local function ParseBonusIDs(itemLink)
    if not itemLink then
        return {}
    end

    local parts = { strsplit(":", itemLink) }
    local bonusIDs = {}

    for i = 1, #parts do
        local val = tonumber(parts[i])
        if val and val >= 1 and val <= 20 then
            local allNumeric = true
            local testIDs = {}
            for j = 1, val do
                local nextVal = tonumber(parts[i + j])
                if not nextVal then
                    allNumeric = false
                    break
                end
                table.insert(testIDs, nextVal)
            end
            if allNumeric and #testIDs == val then
                if GC.db and GC.db.debug then
                    print(string.format("|cff00ff98[DEBUG] Found bonus count %d at position %d|r", val, i))
                    print(string.format("|cff00ff98[DEBUG] Bonus IDs: %s|r", table.concat(testIDs, ", ")))
                end
                return testIDs
            end
        end
    end

    return {}
end

local function DetermineTrack(bonusIDs)
    if not bonusIDs or #bonusIDs == 0 then
        return nil
    end

    for _, trackName in ipairs(Data.TRACKS) do
        local trackBonusIDs = Data.TRACK_BONUS_IDS[trackName]
        if trackBonusIDs and #trackBonusIDs > 0 then
            for _, bonusID in ipairs(bonusIDs) do
                for _, trackBonusID in ipairs(trackBonusIDs) do
                    if bonusID == trackBonusID then
                        if GC.db and GC.db.debug then
                            print(string.format("|cff00ff00[DEBUG] MATCH! Bonus ID %d found in %s track|r", bonusID, trackName))
                        end
                        return trackName
                    end
                end
            end
        end
    end

    return nil
end

local function DetermineRank(trackName, bonusIDs)
    if not trackName or not bonusIDs or #bonusIDs == 0 then
        return nil
    end

    local rankBonusIDs = Data.RANK_BONUS_IDS[trackName]
    if not rankBonusIDs then
        return nil
    end

    for rank = 1, Data.MAX_RANK do
        local rankIDs = rankBonusIDs[rank]
        if rankIDs and #rankIDs > 0 then
            for _, bonusID in ipairs(bonusIDs) do
                for _, rankBonusID in ipairs(rankIDs) do
                    if bonusID == rankBonusID then
                        return rank
                    end
                end
            end
        end
    end

    return nil
end

local function GetItemUpgradeInfo(itemLink)
    if not itemLink then
        return nil, nil
    end

    local bonusIDs = ParseBonusIDs(itemLink)
    if #bonusIDs == 0 then
        return nil, nil
    end

    local trackName = DetermineTrack(bonusIDs)
    if not trackName then
        return nil, nil
    end

    local rank = DetermineRank(trackName, bonusIDs)
    if not rank then
        return nil, nil
    end

    return trackName, rank
end

local function GetItemIlvl(itemLink)
    if not itemLink then
        return 0
    end
    return GetDetailedItemLevelInfo(itemLink) or 0
end

Logic.GetItemUpgradeInfo = GetItemUpgradeInfo
Logic.GetItemIlvl = GetItemIlvl
Logic.ParseBonusIDs = ParseBonusIDs

function Logic:Evaluate(equipped, simulatedCrests)
    local results = {}

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] Starting upgrade evaluation...|r")
        local equippedCount = 0
        for _ in pairs(equipped) do
            equippedCount = equippedCount + 1
        end
        print(string.format("|cff00ff98[DEBUG] Equipped items: %d|r", equippedCount))
        print(string.format("|cff00ff98[DEBUG] Using simulated crests: %s|r", simulatedCrests and "YES" or "NO"))

        if simulatedCrests then
            for crestType, count in pairs(simulatedCrests) do
                print(string.format("|cff00ff98[DEBUG]   %s: %d|r", crestType, count))
            end
        end
    end

    for slotID, itemData in pairs(equipped) do
        local itemLink = itemData.itemLink
        local slotName = itemData.slotName

        if not itemLink then
            if GC.db and GC.db.debug then
                print(string.format("|cffff0000[DEBUG] Slot %s (%d): No item link, skipping|r", slotName or "Unknown", slotID))
            end
        else
            local currentIlvl = GetItemIlvl(itemLink)
            local trackName, currentRank = GetItemUpgradeInfo(itemLink)

            if GC.db and GC.db.debug then
                print(string.format("|cff00ff98[DEBUG] Slot=%s ilvl=%d track=%s rank=%d|r",
                    slotName or "Unknown", currentIlvl, trackName or "nil", currentRank or 0))
            end

            if not trackName then
                if GC.db and GC.db.debug then
                    print(string.format("|cffff0000[DEBUG]   Skipped: Could not determine track from bonus IDs|r"))
                end
            elseif not currentRank then
                if GC.db and GC.db.debug then
                    print(string.format("|cffff0000[DEBUG]   Skipped: Could not determine rank from bonus IDs|r"))
                end
            elseif currentRank >= Data.MAX_RANK then
                if GC.db and GC.db.debug then
                    print(string.format("|cffff0000[DEBUG]   Skipped: Already at max rank (%d/%d)|r", currentRank, Data.MAX_RANK))
                end
            else
                local crestType = Data:GetCrestType(trackName)
                local crestCost = Data:GetCrestCost()

                local crestCount
                if simulatedCrests then
                    crestCount = simulatedCrests[crestType] or 0
                else
                    crestCount = GC.modules.CrestTracker.CrestData:GetCrestCount(crestType)
                end

                local remainingCrests = crestCount

                for rank = currentRank, Data.MAX_RANK - 1 do
                    local nextRank = rank + 1
                    local nextIlvl = Data:GetNextIlvl(trackName, rank)

                    if not nextIlvl then
                        break
                    end

                    local canAfford = remainingCrests >= crestCost

                    if GC.db and GC.db.debug then
                        print(string.format("|cff00ff98[DEBUG]   Step %d->%d: %d->%d cost=%d canAfford=%s|r",
                            rank, nextRank, Data.TRACK_ILVLS[trackName][rank], nextIlvl, crestCost, canAfford and "true" or "false"))
                    end

                    if canAfford then
                        table.insert(results, {
                            slotName = slotName,
                            slotID = slotID,
                            itemLink = itemLink,
                            currentIlvl = Data.TRACK_ILVLS[trackName][rank],
                            nextIlvl = nextIlvl,
                            trackName = trackName,
                            currentRank = rank,
                            nextRank = nextRank,
                            crestType = crestType,
                            crestCost = crestCost,
                            canAfford = canAfford,
                            priority = Data:GetSlotPriority(slotID),
                        })
                        remainingCrests = remainingCrests - crestCost
                    else
                        if GC.db and GC.db.debug then
                            print(string.format("|cffff0000[DEBUG]   Cannot afford step %d->%d (need %d, have %d remaining)|r",
                                rank, nextRank, crestCost, remainingCrests))
                        end
                    end
                end
            end
        end
    end

    table.sort(results, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        end
        return a.nextIlvl > b.nextIlvl
    end)

    if GC.db and GC.db.debug then
        print(string.format("|cff00ff98[DEBUG] Total upgrades found: %d|r", #results))
    end

    return results
end

return Logic
