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

    -- Use ScrollingMessageFrame for hyperlink support
    local scrollFrame = CreateFrame("ScrollingMessageFrame", "GearCresterScrollFrame", frame)
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
    scrollFrame:SetFading(false)
    scrollFrame:SetMaxLines(100)
    scrollFrame:SetJustifyH("LEFT")
    scrollFrame:SetHyperlinksEnabled(true)

    -- Enable hyperlink interactions
    scrollFrame:SetScript("OnHyperlinkEnter", function(self, linkData, link)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)

    scrollFrame:SetScript("OnHyperlinkLeave", function(self)
        GameTooltip:Hide()
    end)

    scrollFrame:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
        if IsModifiedClick() then
            HandleModifiedItemClick(link)
        else
            ChatEdit_InsertLink(link)
        end
    end)

    frame.scrollFrame = scrollFrame

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
        self.frame.scrollFrame:Clear()
        self.frame.scrollFrame:AddMessage("No upgrades available for equipped gear, bags, or bank.")
        return
    end

    self.frame.scrollFrame:Clear()
    self.frame.scrollFrame:AddMessage("|cff00ff98GearCrester: upgrade recommendations|r")
    self.frame.scrollFrame:AddMessage("")

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
        local itemName = entry.itemLink and (" " .. entry.itemLink) or ""
        local line = string.format("%s%s: %d -> %d %s%s",
            entry.slotName or entry.location,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            costText,
            itemName)
        self.frame.scrollFrame:AddMessage(line)
    end
end

function MainFrame:ShowResults(text)
    if not self.frame then
        self:Create()
    end

    self.frame.scrollFrame:Clear()

    -- Split text by newlines and add each line
    for line in text:gmatch("[^\n]+") do
        self.frame.scrollFrame:AddMessage(line)
    end

    self.frame:Show()
end

return MainFrame
