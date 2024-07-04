local _, addon = ...

addon.positionOptions = {
    startX1 = 0.18, -- Column 1 X position as a percentage of frame width
    startX2 = 0.58, -- Column 2 X position as a percentage of frame width
    margin = 0.14, -- Top and bottom margin as a percentage of frame height
    iconSize = 45, -- Size of the button's icon
    maxRows = 6, -- Maximum number of rows per column
    buttonsPerPage = 12 -- Number of buttons per page (2 columns * 6 rows)
}

local function CalculateButtonPosition(index, frameWidth, frameHeight)
    local opt = addon.positionOptions
    local column = math.floor((index - 1) / opt.maxRows) % 2
    local row = (index - 1) % opt.maxRows

    local marginX = frameWidth * (column == 0 and opt.startX1 or opt.startX2)
    local marginY = frameHeight * opt.margin
    local paddingY = (frameHeight - 2 * marginY - opt.maxRows * opt.iconSize) / (opt.maxRows - 1)

    local xOffset = marginX
    local yOffset = -marginY - row * (opt.iconSize + paddingY)

    return xOffset, yOffset
end

local function SortButtonsAlphabetically()
    table.sort(addon.spellButtons, function(a, b)
        return a:GetName() < b:GetName()
    end)
end

function addon.PositionButtonsInGrid()
    local frameWidth = addon.spellbookWidth
    local frameHeight = addon.spellbookHeight

    SortButtonsAlphabetically() -- Sort buttons before positioning them

    for i, button in ipairs(addon.spellButtons) do
        local xOffset, yOffset = CalculateButtonPosition(i, frameWidth, frameHeight)
        button:SetPoint("TOPLEFT", addon.MacrobialSpellbookFrame, "TOPLEFT", xOffset, yOffset)
        button:Hide()
    end
end
