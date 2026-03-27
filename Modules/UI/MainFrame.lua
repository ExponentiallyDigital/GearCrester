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

    -- ScrollFrame with SimpleHTML for content display
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 10)

    local html = CreateFrame("SimpleHTML", nil, scrollFrame)
    html:SetWidth(scrollFrame:GetWidth())
    html:SetHeight(1)  -- Height will be set by content
    html:SetFontObject("p", "GameFontNormalSmall")
    html:SetHyperlinksEnabled(true)
    scrollFrame:SetScrollChild(html)

    -- Hyperlink handlers
    html:SetScript("OnHyperlinkEnter", function(self, linkData, link)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(link)
        GameTooltip:Show()
    end)
    html:SetScript("OnHyperlinkLeave", function(self)
        GameTooltip:Hide()
    end)
    html:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
        if IsModifiedClick() then
            HandleModifiedItemClick(link)
        else
            ChatEdit_InsertLink(link)
        end
    end)

    frame.html = html
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
        self.frame.html:SetText("<html><body><p>GearCrester: No upgrades available for equipped gear, bags, or bank.</p></body></html>")
        return
    end

    -- Sort results like PrintResults: non-bag first, then bag entries sorted by bag/slot
    local nonBag = {}
    local bagEntries = {}

    for _, entry in ipairs(results) do
        local isBag = entry.location and entry.location:match("^bag (%d+), slot (%d+)")
        if isBag then
            table.insert(bagEntries, entry)
        else
            table.insert(nonBag, entry)
        end
    end

    -- Sort bag entries by bag number then slot number
    table.sort(bagEntries, function(a, b)
        local aBag, aSlot = a.location:match("bag (%d+), slot (%d+)")
        local bBag, bSlot = b.location:match("bag (%d+), slot (%d+)")

        aBag, aSlot = tonumber(aBag), tonumber(aSlot)
        bBag, bSlot = tonumber(bBag), tonumber(bSlot)

        if aBag ~= bBag then
            return aBag < bBag
        end
        return aSlot < bSlot
    end)

    -- Combine sorted results
    local sortedResults = {}
    for _, entry in ipairs(nonBag) do
        table.insert(sortedResults, entry)
    end
    for _, entry in ipairs(bagEntries) do
        table.insert(sortedResults, entry)
    end

    local function htmlEscape(str)
        return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    end

    local function itemNameFromLink(itemLink)
        return itemLink:match("|h%[(.-)%]|h") or itemLink
    end

    -- Build HTML content
    local htmlContent = "<html><body>"
    htmlContent = htmlContent .. "<p>GearCrester: upgrade recommendations</p>"
    htmlContent = htmlContent .. "<p></p>"

    for _, entry in ipairs(sortedResults) do
        local location = entry.location and (" [" .. entry.location .. "]") or ""
        local totalCost = entry.totalCrestCost or entry.crestCostPerStep or entry.crestCost or 0
        local track = entry.trackName or entry.crestType or "UNKNOWN"
        local trackColored = GC.ColorTrack(track)
        local costText
        if entry.isGoldOnly then
            if entry.goldOnlyTargetRank then
                costText = string.format("(%s FREE to rank %d)", trackColored, entry.goldOnlyTargetRank)
            else
                costText = string.format("(%s FREE)", trackColored)
            end
        else
            costText = string.format("(%s x%d)", trackColored, totalCost)
        end

        local line = string.format("%s%s: %d -> %d %s",
            entry.slotName or entry.location,
            location,
            entry.currentIlvl,
            entry.nextIlvl,
            costText)

        if entry.itemLink then
            local name = itemNameFromLink(entry.itemLink)
            local href = htmlEscape(entry.itemLink)
            line = htmlEscape(line) .. " <a href=\"" .. href .. "\">" .. htmlEscape("[" .. name .. "]") .. "</a>"
        else
            line = htmlEscape(line)
        end

        htmlContent = htmlContent .. "<p>" .. line .. "</p>"
    end

    htmlContent = htmlContent .. "</body></html>"
    self.frame.html:SetText(htmlContent)

    -- Adjust height after setting content
    self.frame.html:SetHeight(self.frame.html:GetContentHeight())
end

function MainFrame:ShowResults(text)
    if not self.frame then
        self:Create()
    end

    local function htmlEscape(str)
        return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    end

    local function itemNameFromLink(itemLink)
        return itemLink:match("|h%[(.-)%]|h") or itemLink
    end

    -- Convert plain text to HTML
    local htmlContent = "<html><body>"
    for line in text:gmatch("[^\n]+") do
        local rawLine = line
        if line:find("|Hitem:") then
            local itemLink = line:match("(|Hitem:[^|]-|h%[[^%]]-%]|h)")
            if itemLink then
                local name = itemNameFromLink(itemLink)
                local safeHref = htmlEscape(itemLink)
                line = htmlEscape(line:gsub(itemLink, "")) .. " <a href=\"" .. safeHref .. "\">" .. htmlEscape("[" .. name .. "]") .. "</a>"
            else
                line = htmlEscape(rawLine)
            end
        else
            line = htmlEscape(rawLine)
        end
        htmlContent = htmlContent .. "<p>" .. line .. "</p>"
    end
    htmlContent = htmlContent .. "</body></html>"

    self.frame.html:SetText(htmlContent)
    self.frame.html:SetHeight(self.frame.html:GetContentHeight())
    self.frame:Show()
end

return MainFrame
