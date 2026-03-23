local addonName, GC = ...

GC.name = addonName
GC.modules = {}
GC.db = {}

function GC:OnLoad()
    GC.db = GearCresterDB or {}
    GC.db.debug = GC.db.debug or false

    SlashCmdList["GEARCRESTER"] = function(msg)
        local args = msg:trim()

        if args and #args > 0 then
            if args:lower() == "debug=on" then
                GC.db.debug = true
                GC:Print("Debug mode enabled.")
                return
            elseif args:lower() == "debug=off" then
                GC.db.debug = false
                GC:Print("Debug mode disabled.")
                return
            end

            local countStr, crestType = args:match("^(%d+)%s+(%w+)$")

            if countStr and crestType then
                local count = tonumber(countStr)
                local crestTypeUpper = crestType:upper()

                local validTypes = {
                    ADVENTURER = true,
                    VETERAN = true,
                    CHAMPION = true,
                    HERO = true,
                    MYTH = true,
                }

                if validTypes[crestTypeUpper] then
                    local AdvisorCore = GC.modules.UpgradeAdvisor.Core
                    local simulatedCrests = GC.modules.CrestTracker.CrestData:SimulateCrests(crestTypeUpper, count)
                    local results = AdvisorCore:GetRecommendedUpgrades(simulatedCrests)
                    AdvisorCore:PrintResults(results, string.format("|cff00ff98GearCrester Upgrade Recommendations (Simulated: %d %s):|r", count, crestTypeUpper))
                else
                    GC:Print("Invalid crest type. Valid types: ADVENTURER, VETERAN, CHAMPION, HERO, MYTH")
                end
            else
                GC:Print("Usage: /gc <count> <crestType>")
                GC:Print("Example: /gc 40 champion")
                GC:Print("Use /gc debug=on to enable debug output")
            end
        else
            local AdvisorCore = GC.modules.UpgradeAdvisor.Core
            local results = AdvisorCore:GetRecommendedUpgrades()
            AdvisorCore:PrintResults(results)
        end
    end
    SLASH_GEARCRESTER1 = "/gc"

    self:Print("GearCrester loaded. /gc to view upgrade recommendations.")
end

function GC:Print(msg)
    print("|cff00ff98GearCrester:|r " .. msg)
end

return GC
