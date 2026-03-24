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

    -- Step 1: Check canonical TRACK_BONUS_IDS (unchanged)
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

    -- Step 2: Fallback - count rank-bonus matches across all tracks
    -- This handles items that have rank bonus IDs but omit canonical track markers
    local trackMatchCounts = {}
    for _, trackName in ipairs(Data.TRACKS) do
        local rankBonusIDs = Data.RANK_BONUS_IDS[trackName]
        if rankBonusIDs then
            local matchCount = 0
            for rank = 1, Data.MAX_RANK do
                local rankIDs = rankBonusIDs[rank]
                if rankIDs then
                    for _, bonusID in ipairs(bonusIDs) do
                        for _, rankBonusID in ipairs(rankIDs) do
                            if bonusID == rankBonusID then
                                matchCount = matchCount + 1
                            end
                        end
                    end
                end
            end
            trackMatchCounts[trackName] = matchCount
        end
    end

    -- Find track with highest match count
    local bestTrack = nil
    local bestCount = 0
    for trackName, count in pairs(trackMatchCounts) do
        if count > bestCount then
            bestCount = count
            bestTrack = trackName
        end
    end

    if bestTrack and bestCount > 0 then
        if GC.db and GC.db.debug then
            print(string.format("|cff00ff00[DEBUG] FALLBACK: Inferred %s track from %d rank bonus ID(s)|r", bestTrack, bestCount))
        end
        return bestTrack
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

    -- Step 1: Try canonical track detection
    local trackName = DetermineTrack(bonusIDs)

    if trackName then
        -- Canonical track found, try to get rank
        local rank = DetermineRank(trackName, bonusIDs)

        if rank then
            -- Both track and rank found canonically
            if GC.db and GC.db.debug then
                print(string.format("|cff00ff00[DEBUG] Canonical: %s track rank %d|r", trackName, rank))
            end
            return trackName, rank
        end

        -- Track found but rank missing - attempt rank-id inference fallback
        if GC.db and GC.db.debug then
            print(string.format("|cff00ff00[DEBUG] Track=%s found but rank missing - running rank-id fallback|r", trackName))
        end
    else
        -- No canonical track - will attempt full inference below
        if GC.db and GC.db.debug then
            print("|cff00ff00[DEBUG] No canonical track - running full inference|r")
        end
    end

    -- Step 2: Rank-ID inference fallback
    -- Scan all tracks' RANK_BONUS_IDS to find matching rank bonus IDs
    local bestTrack = nil
    local bestRank = 0  -- Initialize to 0 to avoid nil comparison
    local bestMatchCount = 0
    local matchedBonusIDs = {}

    for _, candidateTrack in ipairs(Data.TRACKS) do
        local rankBonusIDs = Data.RANK_BONUS_IDS[candidateTrack]
        if rankBonusIDs then
            for rank = 1, Data.MAX_RANK do
                local rankIDs = rankBonusIDs[rank]
                if rankIDs and #rankIDs > 0 then
                    local matchCount = 0
                    local currentMatches = {}
                    for _, bonusID in ipairs(bonusIDs) do
                        for _, rankBonusID in ipairs(rankIDs) do
                            if bonusID == rankBonusID then
                                matchCount = matchCount + 1
                                table.insert(currentMatches, bonusID)
                            end
                        end
                    end

                    -- Prefer higher match count; if tied, prefer higher rank (tie-breaker)
                    if matchCount > bestMatchCount or (matchCount == bestMatchCount and rank > bestRank) then
                        bestTrack = candidateTrack
                        bestRank = rank
                        bestMatchCount = matchCount
                        matchedBonusIDs = currentMatches
                    end
                end
            end
        end
    end

    if bestTrack and bestRank > 0 and bestMatchCount > 0 then
        if GC.db and GC.db.debug then
            print(string.format("|cff00ff00[DEBUG] FALLBACK: Inferred %s track rank %d from %d rank bonus ID(s): %s|r",
                bestTrack, bestRank, bestMatchCount, table.concat(matchedBonusIDs, ", ")))
        end
        return bestTrack, bestRank
    end

    -- No inference possible
    if GC.db and GC.db.debug then
        print("|cffff0000[DEBUG] No track/rank could be inferred from bonus IDs|r")
    end
    return nil, nil
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

function Logic:GetRecommendedUpgrades(simulatedCrests, includeBags, includeBank)
    local results = {}

    if GC.db and GC.db.debug then
        print("|cff00ff98[DEBUG] Starting upgrade evaluation...|r")
    end

    -- Helper function to evaluate items from a source
    local function EvaluateItems(items, sourceName)
        if not items then
            return
        end

        for slotID, itemData in pairs(items) do
            local itemLink = itemData.itemLink
            local slotName = itemData.slotName or itemData.location

            if not itemLink then
                if GC.db and GC.db.debug then
                    print(string.format("|cffff0000[DEBUG] %s: No item link, skipping|r", slotName or "Unknown"))
                end
            else
                local currentIlvl = GetItemIlvl(itemLink)
                local trackName, currentRank = GetItemUpgradeInfo(itemLink)

                if GC.db and GC.db.debug then
                    print(string.format("|cff00ff98[DEBUG] %s=%s ilvl=%d track=%s rank=%d|r",
                        sourceName, slotName or "Unknown", currentIlvl, trackName or "nil", currentRank or 0))
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
                    local crestCostPerStep = Data:GetCrestCost()

                    local crestCount
                    if simulatedCrests then
                        crestCount = simulatedCrests[crestType] or 0
                    else
                        crestCount = GC.modules.CrestTracker.CrestData:GetCrestCount(crestType)
                    end

                    -- Calculate max affordable rank with proper remaining crests tracking
                    local maxRank = currentRank
                    local remaining = crestCount
                    local upgradeSteps = 0

                    for r = currentRank, Data.MAX_RANK - 1 do
                        if remaining >= crestCostPerStep then
                            remaining = remaining - crestCostPerStep
                            upgradeSteps = upgradeSteps + 1
                            maxRank = r + 1
                        else
                            break
                        end
                    end

                    if upgradeSteps > 0 then
                        -- Get FINAL ilvl at maxRank
                        local finalIlvl = Data.TRACK_ILVLS[trackName][maxRank]
                        local totalCrestCost = upgradeSteps * crestCostPerStep

                        -- Check if we can afford the FULL upgrade path
                        local canAfford = crestCount >= totalCrestCost

                        table.insert(results, {
                            slotName = slotName,
                            slotID = slotID,
                            itemLink = itemLink,
                            currentIlvl = currentIlvl,
                            nextIlvl = finalIlvl,
                            trackName = trackName,
                            currentRank = currentRank,
                            maxRank = maxRank,
                            crestType = crestType,
                            crestCostPerStep = crestCostPerStep,
                            totalCrestCost = totalCrestCost,
                            upgradeSteps = upgradeSteps,
                            isGoldOnly = false,
                            goldOnlyTargetRank = nil,
                            canAfford = canAfford,
                            priority = Data:GetSlotPriority(slotID) or 99,
                            location = itemData.location,
                        })
                    end
                end
            end
        end
    end

    -- Evaluate all sources
    EvaluateItems(GC.DataModel.equipped, "Equipped")

    if includeBags then
        EvaluateItems(GC.DataModel.bags, "Bag")
    end

    if includeBank then
        EvaluateItems(GC.DataModel.bank, "Bank")
    end

    if GC.db and GC.db.debug then
        print(string.format("|cff00ff98[DEBUG] Total upgrades found: %d|r", #results))
    end

    return results
end

function Logic:DumpAllItems()
    print("|cff00ff98GearCrester Bonus ID Dump:|r")

    GC.modules.InventoryScanner.ScannerEquipped:Scan()

    for slotID, itemData in pairs(GC.DataModel.equipped) do
        local itemLink = itemData.itemLink
        local slotName = itemData.slotName

        if itemLink then
            local bonusIDs = ParseBonusIDs(itemLink)
            local trackName, currentRank = GetItemUpgradeInfo(itemLink)
            local ilvl = GetItemIlvl(itemLink)

            print(string.format("%s: ilvl=%d track=%s rank=%s bonusIDs=[%s]",
                slotName or "Unknown",
                ilvl,
                trackName or "nil",
                currentRank or "nil",
                table.concat(bonusIDs, ", ") or "none"))
        end
    end
end

function Logic:GetItemDiagnostics(itemLink)
    local result = {
        itemLink = itemLink,
        bonusIDs = {},
        trackName = nil,
        currentRank = nil,
        reason = nil,
    }

    if not itemLink then
        result.reason = "No item link provided"
        return result
    end

    result.bonusIDs = ParseBonusIDs(itemLink)

    if #result.bonusIDs == 0 then
        result.reason = "No bonus IDs found on this item"
        return result
    end

    result.trackName, result.currentRank = GetItemUpgradeInfo(itemLink)

    if not result.trackName then
        result.reason = "Track not detected - bonus IDs do not match any known upgrade track"
        return result
    end

    if not result.currentRank then
        result.reason = "Rank not detected - bonus IDs do not match any known rank for " .. result.trackName
        return result
    end

    if result.currentRank >= Data.MAX_RANK then
        result.reason = "Already at max rank (" .. result.currentRank .. "/" .. Data.MAX_RANK .. ")"
        return result
    end

    result.reason = "Item is upgradeable"
    return result
end

function Logic:PrintWhyDiagnostics()
    print("|cff00ff98GearCrester Upgrade Diagnostics:|r")

    GC.modules.InventoryScanner.ScannerEquipped:Scan()

    for slotID, itemData in pairs(GC.DataModel.equipped) do
        local itemLink = itemData.itemLink
        local slotName = itemData.slotName

        if itemLink then
            local diagnostics = self:GetItemDiagnostics(itemLink)
            print(string.format("%s: %s", slotName or "Unknown", diagnostics.reason))
            if #diagnostics.bonusIDs > 0 then
                print(string.format("  Bonus IDs: %s", table.concat(diagnostics.bonusIDs, ", ")))
            end
        else
            print(string.format("%s: No item equipped", slotName or "Unknown"))
        end
    end
end

return Logic
