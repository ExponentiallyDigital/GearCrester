local addonName, GC = ...

local MainFrame = {}
GC.modules.UI = GC.modules.UI or {}
GC.modules.UI.MainFrame = MainFrame

local frameWidth = 500
local frameHeight = 400

function MainFrame:Create()
    if self.frame then
        return self.frame
    end

    local frame = CreateFrame("Frame", "GearCresterMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(frameWidth, frameHeight)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)

    local titleBar = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleBar:SetPoint("TOP", frame, "TOP", 0, -5)
    titleBar:SetText("GearCrester Upgrade Advisor")
    frame.titleBar = titleBar

    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)
    frame.closeButton = closeButton

    local scrollFrame = CreateFrame("ScrollFrame", "GearCresterScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
    frame.scrollFrame = scrollFrame

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(frameWidth - 50, frameHeight - 50)
    scrollFrame:SetScrollChild(scrollChild)
    frame.scrollChild = scrollChild

    local output = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    output:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -5)
    output:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", -5, -5)
    output:SetJustifyH("LEFT")
    output:SetJustifyV("TOP")
    frame.output = output

    frame:Hide()
    self.frame = frame
    return frame
end

function MainFrame:Show()
    if not self.frame then
        self:Create()
    end
    self.frame:Show()
    self:Update()
end

function MainFrame:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function MainFrame:Toggle()
    if self.frame and self.frame:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function MainFrame:Update()
    if not self.frame then
        return
    end

    local results = GC.modules.UpgradeAdvisor.Core:GetRecommendedUpgrades(nil, true, true)

    if not results or #results == 0 then
        self.frame.output:SetText("No upgrades available for equipped gear, bags, or bank.")
        return
    end

    local lines = {}
    table.insert(lines, "|cff00ff98GearCrester: upgrade recommendations|r")
    table.insert(lines, "")

    for _, entry in ipairs(results) do
        local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
        local location = entry.location and string.format(" [%s]", entry.location) or ""
        local totalCost = entry.totalCrestCost or entry.crestCostPerStep or entry.crestCost or 0
        local track = GC.ColorTrack(entry.trackName or entry.crestType or "UNKNOWN")
        local costText
        if entry.isGoldOnly then
            if entry.goldOnlyTargetRank then
                costText = string.format("(%s FREE to rank %d)", track, entry.goldOnlyTargetRank)
            else
                costText = string.format("(%s FREE)", track)
            end
        else
            costText = string.format("(%s%s x%d|r)", affordColor, track, totalCost)
        end
        local line = string.format("%s%s: %d -> %d %s",
            entry.slotName or entry.location,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            costText)
        table.insert(lines, line)
    end

    self.frame.output:SetText(table.concat(lines, "\n"))
end

function MainFrame:ShowResults(text)
    if not self.frame then
        self:Create()
    end
    self.frame.output:SetText(text)
    self.frame:Show()
end

return MainFrame
