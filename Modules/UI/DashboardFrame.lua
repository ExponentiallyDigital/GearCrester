local addonName, GC = ...

local Dashboard = {}
GC.modules.UI = GC.modules.UI or {}
GC.modules.UI.Dashboard = Dashboard

local UIUtils = GC.modules.UI.Utils
local frameWidth = 650  -- Increased from 600 for better content fit
local frameHeight = 520  -- Increased from 450 to prevent content overlap at bottom

function Dashboard:Create()
    if self.frame then return self.frame end

    local frame = CreateFrame("Frame", "GearCresterDashboard", UIParent, "BackdropTemplate")
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
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(unpack(UIUtils.COLORS.bg))

    -- Addon icon (top-left corner)
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\AddOns\\GearCrester\\media\\GearCrester-icon.png")
    icon:SetSize(36, 36)
    icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -6)
    frame.icon = icon

    -- Title bar (centered, below icon)
    local titleBar = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleBar:SetPoint("TOP", frame, "TOP", 0, -5)
    titleBar:SetText("|cff00ff98GearCrester|r")
    frame.titleBar = titleBar

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    frame.closeBtn = closeBtn

    -- Tab bar (positioned below icon)
    local tabContainer = CreateFrame("Frame", nil, frame)
    tabContainer:SetSize(frameWidth - 20, 30)
    tabContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -47)  -- Moved down 5px more to -47
    frame.tabContainer = tabContainer

    local tabWidth = (frameWidth - 20) / 3 - 5
    local upgradesTab = UIUtils:CreateTabButton(tabContainer, "Upgrades", tabWidth, function() self:ShowTab("upgrades") end)
    upgradesTab:SetPoint("TOPLEFT", tabContainer, "TOPLEFT", 0, 0)
    self.upgradesTab = upgradesTab

    local crestsTab = UIUtils:CreateTabButton(tabContainer, "Crests", tabWidth, function() self:ShowTab("crests") end)
    crestsTab:SetPoint("TOPLEFT", upgradesTab, "TOPRIGHT", 5, 0)
    self.crestsTab = crestsTab

    local inventoryTab = UIUtils:CreateTabButton(tabContainer, "Equipped", tabWidth, function() self:ShowTab("equipped") end)
    inventoryTab:SetPoint("TOPLEFT", crestsTab, "TOPRIGHT", 5, 0)
    self.inventoryTab = inventoryTab

    -- Content area (moved down 14px to avoid overlap with tabs)
    local contentArea = UIUtils:CreatePanel(frame, nil, frameWidth - 20, frameHeight - 70)
    contentArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -74)  -- Moved down from -60 to -74
    frame.contentArea = contentArea

    -- Create panels for each tab
    self:CreateUpgradesPanel(contentArea)
    self:CreateCrestsPanel(contentArea)
    self:CreateInventoryPanel(contentArea)

    frame:Hide()
    self.frame = frame
    return frame
end

function Dashboard:CreateUpgradesPanel(parent)
    local panel = UIUtils:CreatePanel(parent, "Upgrade Recommendations", parent:GetWidth() - 20, parent:GetHeight() - 20)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    panel:Hide()
    self.upgradesPanel = panel

    -- Scroll frame for upgrade list
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -25)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    panel.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(scroll:GetWidth(), 400)
    scroll:SetScrollChild(content)
    panel.content = content

    -- Store list items for easy clearing
    panel.items = {}
end

function Dashboard:CreateCrestsPanel(parent)
    local panel = UIUtils:CreatePanel(parent, "Crest Inventory", parent:GetWidth() - 20, parent:GetHeight() - 20)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    panel:Hide()
    self.crestsPanel = panel

    -- Crest progress bars will be added dynamically
    panel.bars = {}
end

function Dashboard:CreateInventoryPanel(parent)
    local panel = UIUtils:CreatePanel(parent, "Inventory Overview", parent:GetWidth() - 20, parent:GetHeight() - 20)
    panel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -10)
    panel:Hide()
    self.inventoryPanel = panel

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -25)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 10)
    panel.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(scroll:GetWidth(), 400)
    scroll:SetScrollChild(content)
    panel.content = content
end

function Dashboard:ShowTab(tabName)
    if not self.frame then self:Create() end

    -- Update tab states
    if self.upgradesTab then self.upgradesTab:SetActive(tabName == "upgrades") end
    if self.crestsTab then self.crestsTab:SetActive(tabName == "crests") end
    if self.inventoryTab then self.inventoryTab:SetActive(tabName == "equipped") end

    -- Ensure panels exist
    if not self.upgradesPanel then self:CreateUpgradesPanel(self.frame.contentArea) end
    if not self.crestsPanel then self:CreateCrestsPanel(self.frame.contentArea) end
    if not self.inventoryPanel then self:CreateInventoryPanel(self.frame.contentArea) end

    -- Show/hide panels
    self.upgradesPanel:Show()
    self.crestsPanel:Show()
    self.inventoryPanel:Show()

    if tabName == "upgrades" then
        self.upgradesPanel:Show()
        self.crestsPanel:Hide()
        self.inventoryPanel:Hide()
        self:UpdateUpgradesPanel()  -- Populate with default /gc results
    elseif tabName == "crests" then
        self.upgradesPanel:Hide()
        self.crestsPanel:Show()
        self.inventoryPanel:Hide()
        self:UpdateCrestsPanel()
    else
        self.upgradesPanel:Hide()
        self.crestsPanel:Hide()
        self.inventoryPanel:Show()
        self:UpdateInventoryPanel()
    end
end

function Dashboard:ShowWithData(results, title)
    if not self.frame then self:Create() end

    -- Ensure tabs and panels are created
    if not self.upgradesTab then self:Create() end
    if not self.upgradesPanel then self:CreateUpgradesPanel(self.frame.contentArea) end

    self:ShowTab("upgrades")
    self:UpdateUpgradesPanel(results, title)
    self.frame:Show()
end

function Dashboard:UpdateUpgradesPanel(results, title)
    local panel = self.upgradesPanel
    local content = panel.content
    local scroll = panel.scroll

    -- Clear ALL existing content (including buttons which are frames, not regions)
    if panel.items then
        for _, btn in ipairs(panel.items) do
            if btn then
                btn:Hide()
                btn:SetParent(nil)
            end
        end
    end
    panel.items = {}

    -- Clear title if exists
    if panel.titleLabel then
        panel.titleLabel:Hide()
        panel.titleLabel:SetParent(nil)
        panel.titleLabel = nil
    end

    content:SetHeight(400)

    -- Default: show all upgrades if no results provided (same as /gc command)
    if not results then
        local Core = GC.modules.UpgradeAdvisor.Core
        results = Core:GetRecommendedUpgrades(nil, true, true)
    end

    -- Add title
    local titleLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    titleLabel:SetText(title or "|cff00ff98Upgrade Recommendations|r")
    titleLabel:SetJustifyH("LEFT")
    panel.titleLabel = titleLabel

    -- Add upgrade entries
    local yOffset = -25
    if results and #results > 0 then
        for i, entry in ipairs(results) do
            -- Create a button widget for clickable item links
            local btn = CreateFrame("Button", nil, content)
            btn:SetSize(content:GetWidth() - 10, 18)
            btn:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
            table.insert(panel.items, btn)  -- Track for later clearing

            local affordColor = entry.canAfford and "|cff00ff00" or "|cffff0000"
            local location = entry.location and (" [" .. entry.location .. "]") or ""
            local totalCost = entry.totalCrestCost or entry.crestCostPerStep or 0
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

            local lineText = string.format("• %s%s: %d -> %d %s",
                entry.slotName or entry.location, location,
                entry.currentIlvl, entry.nextIlvl, costText)

            if entry.itemLink then
                lineText = lineText .. " " .. entry.itemLink
            end

            -- Create fontstring for the text
            local line = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            line:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
            line:SetJustifyH("LEFT")
            line:SetText(lineText)

            -- Button click handler for item links
            btn:SetScript("OnClick", function(self, button)
                if entry.itemLink and IsModifiedClick() then
                    HandleModifiedItemClick(entry.itemLink)
                end
            end)

            -- Button hover handler for tooltips
            btn:SetScript("OnEnter", function(self)
                if entry.itemLink then
                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink(entry.itemLink)
                    GameTooltip:Show()
                end
            end)

            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            yOffset = yOffset - 18
        end
    else
        local noDataLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        noDataLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
        noDataLabel:SetText("No upgrades available.")
    end

    content:SetHeight(math.max(400, -yOffset + 10))
    scroll:SetVerticalScroll(0)
end

function Dashboard:UpdateCrestsPanel()
    local panel = self.crestsPanel
    local content = panel.content or panel

    -- Clear existing bars
    for _, bar in ipairs(panel.bars or {}) do
        bar:Hide()
    end
    panel.bars = {}

    local counts = GC.modules.CrestTracker.CrestData:GetAllCrestCounts()
    local yOffset = -30  -- Increased from -10 to -30 to avoid overlapping heading

    for _, trackName in ipairs({"ADVENTURER", "VETERAN", "CHAMPION", "HERO", "MYTH"}) do
        local count = counts[trackName] or 0
        local label = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
        label:SetText(GC.ColorTrack(trackName) .. ": " .. count)
        label:SetJustifyH("LEFT")
        yOffset = yOffset - 25
    end

    content:SetHeight(math.max(300, -yOffset + 10))
end

function Dashboard:UpdateInventoryPanel()
    local panel = self.inventoryPanel
    local content = panel.content

    -- Clear existing content by resetting height and removing regions
    content:SetHeight(300)
    for i = content:GetNumRegions(), 1, -1 do
        local region = select(i, content:GetRegions())
        if region then
            region:Hide()
            region:SetParent(nil)
        end
    end

    local yOffset = -5
    local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    label:SetText("|cff00ff98Equipped Items|r")
    yOffset = yOffset - 20

    if GC.DataModel and GC.DataModel.equipped then
        for slotID, itemData in pairs(GC.DataModel.equipped) do
            if itemData and itemData.itemLink then
                -- Create a button widget for clickable item links
                local btn = CreateFrame("Button", nil, content)
                btn:SetSize(content:GetWidth() - 10, 18)
                btn:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)

                local lineText = "• " .. (GC.SLOTS[slotID] or "Unknown") .. ": " .. itemData.itemLink

                -- Create fontstring for the text
                local line = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                line:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
                line:SetJustifyH("LEFT")
                line:SetText(lineText)

                -- Button click handler for item links
                btn:SetScript("OnClick", function(self, button)
                    if IsModifiedClick() then
                        HandleModifiedItemClick(itemData.itemLink)
                    end
                end)

                -- Button hover handler for tooltips
                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink(itemData.itemLink)
                    GameTooltip:Show()
                end)

                btn:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)

                yOffset = yOffset - 18
            end
        end
    end

    content:SetHeight(math.max(300, -yOffset + 10))
end

function Dashboard:Toggle()
    if not self.frame then self:Create() end
    if self.frame and self.frame:IsShown() then
        self.frame:Hide()
    else
        -- Ensure tabs are created before showing
        if not self.upgradesTab then self:Create() end
        self:ShowTab("upgrades")
        self.frame:Show()
    end
end

return Dashboard
