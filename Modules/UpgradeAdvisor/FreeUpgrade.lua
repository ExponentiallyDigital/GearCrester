local addonName, GC = ...

local FreeUpgrade = {}
GC.modules.UpgradeAdvisor = GC.modules.UpgradeAdvisor or {}
GC.modules.UpgradeAdvisor.FreeUpgrade = FreeUpgrade

function FreeUpgrade:ApplyGoldOnlyDetection(results, simulatedCrests)
    if not results or #results == 0 then
        return
    end

    -- Do NOT apply gold-only detection when using simulated crests
    -- Gold-only only applies to real inventory comparisons
    if simulatedCrests then
        return
    end

    -- First pass: find highest OWNED rank per track (from items at max rank)
    -- An item at max rank means we own that rank
    local trackHighestOwnedRank = {}
    for _, entry in ipairs(results) do
        if entry.trackName and entry.currentRank == entry.maxRank then
            -- This item is at its max affordable rank, which means we own up to this rank
            if not trackHighestOwnedRank[entry.trackName] or entry.maxRank > trackHighestOwnedRank[entry.trackName] then
                trackHighestOwnedRank[entry.trackName] = entry.maxRank
            end
        end
    end

    -- Second pass: mark gold-only upgrades
    -- An upgrade is gold-only if we own a higher rank item of the same track
    for _, entry in ipairs(results) do
        if entry.trackName then
            local highestOwned = trackHighestOwnedRank[entry.trackName]
            if highestOwned and entry.currentRank < highestOwned then
                -- We own a higher rank, so upgrading to that rank is free (gold-only)
                entry.isGoldOnly = true
                entry.goldOnlyTargetRank = highestOwned
            end
        end
    end
end

return FreeUpgrade
