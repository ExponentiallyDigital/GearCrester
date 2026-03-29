local addonName, GC = ...

GC.modules.UI = GC.modules.UI or {}
local UIUtils = {}
GC.modules.UI.Utils = UIUtils

-- GearCrester color palette (WoW-native hex)
UIUtils.COLORS = {
    bg         = { 0.06, 0.06, 0.10, 0.95 },   -- Dark navy background
    bgPanel    = { 0.08, 0.08, 0.14, 0.90 },   -- Panel background
    bgHeader   = { 0.10, 0.10, 0.18, 1.00 },   -- Header strip
    accent     = { 0.00, 1.00, 0.60, 1.00 },    -- GearCrester green (#00ff98)
    accentDim  = { 0.00, 0.60, 0.36, 1.00 },    -- Dimmed accent
    text       = { 0.90, 0.90, 0.92, 1.00 },    -- Primary text
    textMuted  = { 0.55, 0.55, 0.60, 1.00 },    -- Muted text
    border     = { 0.20, 0.20, 0.28, 0.80 },    -- Border color
    borderHi   = { 0.00, 1.00, 0.60, 0.50 },    -- Highlighted border
    tabActive  = { 0.12, 0.12, 0.20, 1.00 },    -- Active tab
    tabInactive= { 0.06, 0.06, 0.10, 0.60 },    -- Inactive tab
    barBg      = { 0.15, 0.15, 0.20, 1.00 },    -- Progress bar bg
    free       = { 0.30, 1.00, 0.30, 1.00 },    -- Free upgrade green
    danger     = { 1.00, 0.30, 0.30, 1.00 },    -- Can't afford red
}

-- Track colors for progress bars
UIUtils.TRACK_BAR_COLORS = {
    ADVENTURER = { 1.00, 1.00, 0.00 },
    VETERAN    = { 0.00, 1.00, 0.00 },
    CHAMPION   = { 0.69, 0.29, 1.00 },
    HERO       = { 1.00, 0.40, 1.00 },
    MYTH       = { 1.00, 0.00, 0.00 },
}

-- Create a styled panel with optional title
function UIUtils:CreatePanel(parent, title, width, height)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetSize(width, height)
    panel:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(unpack(self.COLORS.bgPanel))
    panel:SetBackdropBorderColor(unpack(self.COLORS.border))

    if title then
        local label = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -6)
        label:SetText("|cff00ff98" .. title .. "|r")
        label:SetTextColor(unpack(self.COLORS.accent))
        panel.titleLabel = label
    end

    return panel
end

-- Create a progress bar
function UIUtils:CreateProgressBar(parent, width, height, r, g, b)
    local container = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    container:SetSize(width, height)
    container:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = nil,
    })
    container:SetBackdropColor(unpack(self.COLORS.barBg))

    local bar = container:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT", container, "TOPLEFT", 1, -1)
    bar:SetHeight(height - 2)
    bar:SetWidth(1)
    bar:SetColorTexture(r or 0, g or 1, b or 0.6, 0.8)

    local label = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER", container, "CENTER", 0, 0)

    container.bar = bar
    container.label = label
    container.maxWidth = width - 2

    function container:SetProgress(current, max, text)
        local pct = max > 0 and (current / max) or 0
        pct = math.min(pct, 1)
        self.bar:SetWidth(math.max(1, pct * self.maxWidth))
        self.label:SetText(text or string.format("%d / %d", current, max))
    end

    return container
end

-- Create a tab button
function UIUtils:CreateTabButton(parent, text, width, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 24)
    btn:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = nil,
    })
    btn:SetBackdropColor(unpack(self.COLORS.tabInactive))

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("CENTER")
    label:SetText(text)
    label:SetTextColor(unpack(self.COLORS.textMuted))
    btn.label = label

    btn:SetScript("OnClick", onClick)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.22, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        if not self.isActive then
            self:SetBackdropColor(unpack(UIUtils.COLORS.tabInactive))
        end
    end)

    function btn:SetActive(active)
        self.isActive = active
        if active then
            self:SetBackdropColor(unpack(UIUtils.COLORS.tabActive))
            self.label:SetTextColor(unpack(UIUtils.COLORS.accent))
        else
            self:SetBackdropColor(unpack(UIUtils.COLORS.tabInactive))
            self.label:SetTextColor(unpack(UIUtils.COLORS.textMuted))
        end
    end

    return btn
end

return UIUtils
