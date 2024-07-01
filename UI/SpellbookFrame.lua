local addonName, addon = ...

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

    local spells = {6603, 312411, 368896, 312425, 312724, 125439, 309819, 312411, 34091, 233368, 59752, 69041, 20594,
                    20549, 58984, 20572, 7744, 20577, 26297, 20589}

    -- Filter out invalid spell IDs
    local validSpells = {}
    for _, spellID in ipairs(spells) do
        local spellName = GetSpellInfo(spellID)
        if spellName then
            table.insert(validSpells, spellID)
        end
    end

    table.sort(validSpells, function(a, b)
        local nameA = GetSpellInfo(a)
        local nameB = GetSpellInfo(b)
        return nameA > nameB
    end)

    local frameWidth = frame:GetWidth()
    local frameHeight = frame:GetHeight()
    local startX1 = frameWidth * positionOptions.startX1
    local startX2 = frameWidth * positionOptions.startX2
    local margin = frameHeight * positionOptions.margin
    local usableHeight = frameHeight - (2 * margin)
    local paddingY = (usableHeight - (positionOptions.maxRows * positionOptions.iconSize)) /
                         (positionOptions.maxRows - 1)

    addon.spellButtons = {}

    for i, spellID in ipairs(validSpells) do
        local buttonName = "MacrobialSpellButton" .. i
        local button = addon.CreateDraggableButton(buttonName, frame, "spell", spellID, positionOptions.iconSize)
        local column = math.floor((i - 1) % positionOptions.buttonsPerPage / positionOptions.maxRows)
        local row = (i - 1) % positionOptions.maxRows
        local xOffset = column == 0 and startX1 or startX2
        local yOffset = -margin - (row * (positionOptions.iconSize + paddingY)) + frame:GetHeight() * 0.01
        button:SetPoint("TOPLEFT", frame, "TOPLEFT", xOffset, yOffset)
        table.insert(addon.spellButtons, button)
    end

    -- Load custom buttons
    addon:LoadCustomButtons()

    -- Create page navigation buttons
    addon.CreatePaginationButtons(frame, math.ceil(#validSpells / positionOptions.buttonsPerPage))

    MacrobialSpellbookFrame = frame
    frame:Hide()

    -- Show the first page initially
    addon.UpdateSpellbookPage(0)
end

addon.CreateMacrobialSpellbookFrame = CreateMacrobialSpellbookFrame
