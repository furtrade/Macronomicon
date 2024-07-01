local _, addon = ...

addon.positionOptions = {
    startX1 = 0.18, -- Column 1 X position as a percentage of frame width
    startX2 = 0.58, -- Column 2 X position as a percentage of frame width
    margin = 0.14, -- Top and bottom margin as a percentage of frame height
    iconSize = 45, -- Size of the button's icon
    maxRows = 6, -- Maximum number of rows per column
    buttonsPerPage = 12 -- Number of buttons per page (2 columns * 6 rows)
}

function addon.CalculateButtonPosition(index, frameWidth, frameHeight)
    local positionOptions = addon.positionOptions
    local columns = 2
    local rows = positionOptions.maxRows
    local marginX1 = frameWidth * positionOptions.startX1
    local marginX2 = frameWidth * positionOptions.startX2
    local marginY = frameHeight * positionOptions.margin
    local iconSize = positionOptions.iconSize
    local paddingY = (frameHeight - 2 * marginY - rows * iconSize) / (rows - 1)

    local column = (index - 1) % columns
    local row = math.floor((index - 1) / columns)
    local xOffset = column == 0 and marginX1 or marginX2
    local yOffset = -marginY - row * (iconSize + paddingY)

    print(string.format("CalculateButtonPosition - Index: %d, Column: %d, Row: %d, XOffset: %f, YOffset: %f", index,
        column, row, xOffset, yOffset))

    return xOffset, yOffset
end
