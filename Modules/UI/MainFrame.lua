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

    -- Create ScrollingMessageFrame for hyperlink support
    local msgFrame = CreateFrame("ScrollingMessageFrame", "GearCresterMessageFrame", frame)
    msgFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    msgFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
    msgFrame:SetFontObject("GameFontNormal")
    msgFrame:SetJustifyH("LEFT")
    msgFrame:SetFading(false)
    msgFrame:SetMaxLines(500)
    msgFrame:SetHyperlinksEnabled(true)

    -- Create scrollbar (manual sync, ScrollingMessageFrame does not support SetScrollBar)
    local scrollbar = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate")
    frame.scrollbar = scrollbar
    scrollbar:SetPoint("TOPLEFT", msgFrame, "TOPRIGHT", 4, -16)
    scrollbar:SetPoint("BOTTOMLEFT", msgFrame, "BOTTOMRIGHT", 4, 16)
    scrollbar:SetMinMaxValues(0, 0)
    scrollbar:SetValueStep(1)
    scrollbar:SetObeyStepOnDrag(true)

    -- When scrollbar moves → scroll the message frame
    scrollbar:SetScript("OnValueChanged", function(self, value)
        msgFrame:SetScrollOffset(value)
    end)

    -- When mouse wheel moves → update scrollbar
    msgFrame:EnableMouseWheel(true)
    msgFrame:SetScript("OnMouseWheel", function(self, delta)
        local min, max = scrollbar:GetMinMaxValues()
        local current = scrollbar:GetValue()
        local newValue = current - delta * 3
        newValue = math.max(min, math.min(max, newValue))
        scrollbar:SetValue(newValue)
    end)

    -- Update scrollbar range whenever new text is added
    hooksecurefunc(msgFrame, "AddMessage", function()
        local total = msgFrame:GetNumMessages()

        -- Calculate visible lines based on font height
        local _, fontHeight = msgFrame:GetFont()
        local visible = math.floor(msgFrame:GetHeight() / fontHeight)

        local maxOffset = total - visible
        if maxOffset < 0 then maxOffset = 0 end

        scrollbar:SetMinMaxValues(0, maxOffset)
    end)

    -- Enable hyperlink interactions
    msgFrame:SetScript("OnHyperlinkEnter", function(self, linkData, link)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)

    msgFrame:SetScript("OnHyperlinkLeave", function(self)
        GameTooltip:Hide()
    end)

    msgFrame:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
        if IsModifiedClick() then
            HandleModifiedItemClick(link)
        else
            ChatEdit_InsertLink(link)
        end
    end)

    frame.msgFrame = msgFrame

    -- When the frame is shown, force scroll to top
    frame:HookScript("OnShow", function()
        msgFrame:SetScrollOffset(0)
        if frame.scrollbar then
            frame.scrollbar:SetValue(0)
        end
    end)

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
        self.frame.msgFrame:Clear()
        self.frame.msgFrame:AddMessage("No upgrades available for equipped gear, bags, or bank.")
        return
    end

    self.frame.msgFrame:Clear()
    self.frame.msgFrame:AddMessage("|cff00ff98GearCrester: upgrade recommendations|r")
    self.frame.msgFrame:AddMessage("")

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
        self.frame.msgFrame:AddMessage(line)
    end
    -- Scroll to top on next frame (ScrollingMessageFrame always scrolls to bottom)
    C_Timer.After(0, function()
        self.frame.msgFrame:SetScrollOffset(0)
        if self.frame.scrollbar then
            self.frame.scrollbar:SetValue(0)
        end
    end)
end

function MainFrame:ShowResults(text)
    if not self.frame then
        self:Create()
    end

    self.frame.msgFrame:Clear()

    -- Split text by newlines and add each line
    for line in text:gmatch("[^\n]+") do
        self.frame.msgFrame:AddMessage(line)
    end

    self.frame:Show()
end

return MainFrame
