local addonName, GC = ...

-- UI modules create frames, widgets, and visual components.
-- They must not contain business logic or data processing.

local UI = {}
GC.modules.<ModuleName> = UI

-- Create the primary frame for this UI component
function UI:CreateFrame()
    local frame = CreateFrame("Frame", "<ModuleName>Frame", UIParent)
    frame:SetSize(400, 300)
    frame:SetPoint("CENTER")

    -- Additional UI setup goes here

    self.frame = frame
    return frame
end

-- Update the UI with new data
function UI:Update(data)
    if not self.frame then
        self:CreateFrame()
    end

    -- Render the data into the UI
end

return UI
