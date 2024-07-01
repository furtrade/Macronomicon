local _, addon = ...

-- Positioning options table
addon.positionOptions = {
    startX1 = 0.18, -- Column 1 X position as a percentage of frame width
    startX2 = 0.58, -- Column 2 X position as a percentage of frame width
    margin = 0.14, -- Top and bottom margin as a percentage of frame height
    iconSize = 45, -- Size of the button's icon
    maxRows = 6, -- Maximum number of rows per column
    buttonsPerPage = 12 -- Number of buttons per page (2 columns * 6 rows)
}
local positionOptions = addon.positionOptions

-- Function to create and position buttons
local function CreateButtons(frame, buttonsData, startX1, startX2, margin, paddingY, frameHeight)
    addon.spellButtons = {}

    for index, buttonData in ipairs(buttonsData) do
        local buttonName = "MacrobialCustomButton" .. index
        local button = addon.CreateDraggableButton(buttonName, frame, "custom", buttonData, positionOptions.iconSize)
        local column = math.floor((index - 1) % positionOptions.buttonsPerPage / positionOptions.maxRows)
        local row = (index - 1) % positionOptions.maxRows
        local xOffset = column == 0 and startX1 or startX2
        local yOffset = -margin - (row * (positionOptions.iconSize + paddingY)) + frameHeight * 0.01
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)
        table.insert(addon.spellButtons, button)
    end
end

-- Main function to create the spellbook frame
local function CreateMacrobialSpellbookFrame()
    local frame = CreateFrame("Frame", "MacrobialSpellbookFrame", SpellBookFrame, "BackdropTemplate")
    frame:SetPoint("TOPLEFT", SpellBookFrame, "TOPLEFT", 0, 0)
    frame:SetPoint("BOTTOMRIGHT", SpellBookFrame, "BOTTOMRIGHT", 0, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {
            left = 11,
            right = 12,
            top = 12,
            bottom = 11
        }
    })
    frame:SetBackdropColor(0, 0, 0, 1)
    frame:SetBackdropBorderColor(1, 1, 1, 1)
    frame:EnableMouse(true)
    frame:SetToplevel(true)
    frame:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 3)

    local frameWidth = frame:GetWidth()
    local frameHeight = frame:GetHeight()
    local startX1 = frameWidth * positionOptions.startX1
    local startX2 = frameWidth * positionOptions.startX2
    local margin = frameHeight * positionOptions.margin
    local usableHeight = frameHeight - (2 * margin)
    local paddingY = (usableHeight - (positionOptions.maxRows * positionOptions.iconSize)) /
                         (positionOptions.maxRows - 1)

    -- Load custom buttons from the database
    local customButtons = addon.db.profile.customButtons or {}

    -- Create the buttons with the pre-calculated dimensions
    CreateButtons(frame, customButtons, startX1, startX2, margin, paddingY, frameHeight)

    -- Create page navigation buttons
    addon.CreatePaginationButtons(frame, math.ceil(#customButtons / positionOptions.buttonsPerPage))

    MacrobialSpellbookFrame = frame
    frame:Hide()

    -- Show the first page initially
    addon.UpdateSpellbookPage(0)
end

addon.CreateMacrobialSpellbookFrame = CreateMacrobialSpellbookFrame
