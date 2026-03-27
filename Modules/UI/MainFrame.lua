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

    -- ScrollFrame + EditBox approach (guaranteed top alignment)
    local scroll = CreateFrame("ScrollFrame", "GearCresterScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    scroll:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)
    frame.scroll = scroll

    local edit = CreateFrame("EditBox", "GearCresterEditBox", scroll)
    edit:SetMultiLine(true)
    edit:SetFontObject("GameFontNormal")
    edit:SetWidth(scroll:GetWidth())
    edit:SetAutoFocus(false)
    edit:EnableMouse(true)
    edit:SetScript("OnEscapePressed", function() frame:Hide() end)
    edit:SetScript("OnHyperlinkClick", function(self, link, text, button)
        if IsModifiedClick() then
            HandleModifiedItemClick(link)
        else
            ChatEdit_InsertLink(link)
        end
    end)
    edit:SetScript("OnHyperlinkEnter", function(self, link, text)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    edit:SetScript("OnHyperlinkLeave", function(self)
        GameTooltip:Hide()
    end)
    edit:SetText("") -- start empty
    edit:SetCursorPosition(0)
    edit:ClearFocus()
    edit:SetMaxLetters(0) -- no limit

    -- Make the edit read-only: intercept keyboard input
    edit:SetScript("OnKeyDown", function() end)
    edit:SetScript("OnChar", function() end)

    scroll:SetScrollChild(edit)

    -- Create a manual scrollbar (sync with scroll frame)
    local scrollbar = CreateFrame("Slider", nil, frame, "UIPanelScrollBarTemplate")
    frame.scrollbar = scrollbar
    scrollbar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 4, -16)
    scrollbar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 4, 16)
    scrollbar:SetMinMaxValues(0, 0)
    scrollbar:SetValueStep(1)
    scrollbar:SetObeyStepOnDrag(true)

    scrollbar:SetScript("OnValueChanged", function(self, value)
        scroll:SetVerticalScroll(value)
    end)

    -- Mouse wheel on scroll area
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local min, max = scrollbar:GetMinMaxValues()
        local current = scrollbar:GetValue()
        local newValue = current - delta * 20
        newValue = math.max(min, math.min(max, newValue))
        scrollbar:SetValue(newValue)
    end)

    -- Resize handler to update edit width and scrollbar range
    scroll:SetScript("OnSizeChanged", function()
        edit:SetWidth(scroll:GetWidth())
        -- update scrollbar range
        local _, fh = edit:GetFont()
        local totalHeight = edit:GetNumLines() * (fh or 14)
        local visible = scroll:GetHeight()
        local max = math.max(0, totalHeight - visible)
        scrollbar:SetMinMaxValues(0, max)
        scrollbar:SetValue(0)
        scroll:SetVerticalScroll(0)
    end)

    -- Helper to set content and reset scroll to top
    frame.SetContent = function(self, text)
        edit:SetText(text)
        edit:HighlightText(0,0) -- ensure no selection
        -- Force top
        scroll:SetVerticalScroll(0)
        if frame.scrollbar then
            frame.scrollbar:SetValue(0)
        end
        -- Update scrollbar range
        local _, fh = edit:GetFont()
        local totalLines = edit:GetNumLines()
        local totalHeight = totalLines * (fh or 14)
        local visible = scroll:GetHeight()
        local max = math.max(0, totalHeight - visible)
        frame.scrollbar:SetMinMaxValues(0, max)
    end

    frame.msgEdit = edit
    frame.msgScroll = scroll

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
        self.frame:SetContent("No upgrades available for equipped gear, bags, or bank.")
        return
    end

    -- Build the full text (preserve colors and item links)
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
        local itemName = entry.itemLink and (" " .. entry.itemLink) or ""
        local line = string.format("%s%s: %d -> %d %s%s",
            entry.slotName or entry.location,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            costText,
            itemName)
        table.insert(lines, line)
    end

    -- Join lines into a single string with newlines
    local text = table.concat(lines, "\n")

    -- Set content and force top alignment
    self.frame:SetContent(text)

    -- Show the frame
    self.frame:Show()
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
