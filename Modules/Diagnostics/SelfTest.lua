local addonName, GC = ...

local SelfTest = {}
GC.modules.Diagnostics = GC.modules.Diagnostics or {}
GC.modules.Diagnostics.SelfTest = SelfTest

local testResults = {}

local function pass(testName)
    table.insert(testResults, { name = testName, success = true })
end

local function fail(testName, reason)
    table.insert(testResults, { name = testName, success = false, reason = reason })
end

function SelfTest:RunAllTests()
    testResults = {}

    print("|cff00ff98GearCrester Self-Diagnostics|r")
    print("================================")

    self:TestBonusIDParsing()
    self:TestTrackDetection()
    self:TestRankDetection()
    self:TestUpgradeEvaluation()
    self:TestSlashCommandRegistration()
    self:TestUIFrameAvailability()
    self:TestCrestDataModule()
    self:TestScannerModules()

    print("")
    print("|cff00ff98Summary|r")
    print("--------------------------------")

    local passCount = 0
    local failCount = 0

    for _, result in ipairs(testResults) do
        if result.success then
            print("|cff00ff00[OK] " .. result.name .. "|r")
            passCount = passCount + 1
        else
            print("|cffff0000[FAIL] " .. result.name .. "|r")
            if result.reason then
                print("  Reason: " .. result.reason)
            end
            failCount = failCount + 1
        end
    end

    print("")
    print(string.format("Passed: %d/%d", passCount, passCount + failCount))

    if failCount > 0 then
        print("|cffff0000Some tests failed. Please report this issue.|r")
    else
        print("|cff00ff00All tests passed.|r")
    end
end

function SelfTest:TestBonusIDParsing()
    local Logic = GC.modules.UpgradeAdvisor.Logic

    if not Logic or not Logic.ParseBonusIDs then
        fail("Bonus ID Parsing", "Logic.ParseBonusIDs function not found")
        return
    end

    local testLink = "item:123456:0:0:0:0:0:0:0:0:0:0:0:0:0:0:5:6652:13577:12699:12785:13439"
    local bonusIDs = Logic.ParseBonusIDs(testLink)

    if #bonusIDs > 0 then
        pass("Bonus ID Parsing")
    else
        fail("Bonus ID Parsing", "No bonus IDs extracted from test link")
    end
end

function SelfTest:TestTrackDetection()
    local Logic = GC.modules.UpgradeAdvisor.Logic
    local Data = GC.modules.UpgradeAdvisor.Data

    if not Data or not Data.TRACK_BONUS_IDS then
        fail("Track Detection", "TRACK_BONUS_IDS table not found")
        return
    end

    local championIDs = Data.TRACK_BONUS_IDS.CHAMPION
    if championIDs and #championIDs > 0 then
        pass("Track Detection")
    else
        fail("Track Detection", "CHAMPION track bonus IDs not configured")
    end
end

function SelfTest:TestRankDetection()
    local Data = GC.modules.UpgradeAdvisor.Data

    if not Data or not Data.RANK_BONUS_IDS then
        fail("Rank Detection", "RANK_BONUS_IDS table not found")
        return
    end

    local championRanks = Data.RANK_BONUS_IDS.CHAMPION
    if championRanks and championRanks[6] then
        pass("Rank Detection")
    else
        fail("Rank Detection", "CHAMPION rank 6 bonus ID not configured")
    end
end

function SelfTest:TestUpgradeEvaluation()
    local AdvisorCore = GC.modules.UpgradeAdvisor.Core

    if not AdvisorCore or not AdvisorCore.GetRecommendedUpgrades then
        fail("Upgrade Evaluation", "AdvisorCore.GetRecommendedUpgrades function not found")
        return
    end

    local results = AdvisorCore.GetRecommendedUpgrades(AdvisorCore, nil)

    if type(results) == "table" then
        pass("Upgrade Evaluation")
    else
        fail("Upgrade Evaluation", "GetRecommendedUpgrades did not return a table")
    end
end

function SelfTest:TestSlashCommandRegistration()
    if SlashCmdList and SlashCmdList["GEARCRESTER"] then
        pass("Slash Command Registration")
    else
        fail("Slash Command Registration", "GEARCRESTER slash command not registered")
    end
end

function SelfTest:TestUIFrameAvailability()
    if GC.modules.UI and GC.modules.UI.MainFrame then
        pass("UI Frame Availability")
    else
        fail("UI Frame Availability", "MainFrame module not found")
    end
end

function SelfTest:TestCrestDataModule()
    local CrestData = GC.modules.CrestTracker.CrestData

    if not CrestData then
        fail("Crest Data Module", "CrestData module not found")
        return
    end

    if not CrestData.SimulateCrests then
        fail("Crest Data Module", "SimulateCrests function not found")
        return
    end

    pass("Crest Data Module")
end

function SelfTest:TestScannerModules()
    local ScannerEquipped = GC.modules.InventoryScanner.ScannerEquipped
    local ScannerBags = GC.modules.InventoryScanner.ScannerBags
    local ScannerBank = GC.modules.InventoryScanner.ScannerBank

    if not ScannerEquipped then
        fail("Scanner Modules", "ScannerEquipped module not found")
        return
    end

    if not ScannerBags then
        fail("Scanner Modules", "ScannerBags module not found")
        return
    end

    if not ScannerBank then
        fail("Scanner Modules", "ScannerBank module not found")
        return
    end

    pass("Scanner Modules")
end

return SelfTest
