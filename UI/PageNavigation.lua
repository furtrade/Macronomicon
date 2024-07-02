local _, addon = ...

-- Helper function to create navigation buttons
local function createButton(name, parent, texture, point, offsetX, offsetY, onClick)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    button:SetSize(32, 32)
    button:SetPoint(point, parent, point, offsetX, offsetY)
    button:SetNormalTexture(texture)
    button:SetPushedTexture(texture .. "-Down")
    button:SetDisabledTexture(texture .. "-Disabled")
    button:SetHighlightTexture(texture .. "-Highlight")
    button:SetScript("OnClick", onClick)
    return button
end

-- Function to create pagination buttons
function addon:CreatePaginationButtons(frame, maxPages)
    local nextButton = createButton("MacrobialSpellbookNextPageButton", frame,
        "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "BOTTOMRIGHT", -50, 15, function()
            addon.UpdateSpellbookPage(1)
        end)

    local prevButton = createButton("MacrobialSpellbookPrevPageButton", frame,
        "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "BOTTOMRIGHT", -87, -- Adjusted to align next to nextButton
        15, function()
            addon.UpdateSpellbookPage(-1)
        end)

    frame.prevButton = prevButton
    frame.nextButton = nextButton
    frame.maxPages = maxPages

    addon.UpdateSpellbookPage(0)
end

local currentPage = 1

function addon.UpdateSpellbookPage(direction)
    currentPage = currentPage + direction
    local maxPages = addon.MacrobialSpellbookFrame.maxPages

    if currentPage <= 1 then
        currentPage = 1
        addon.MacrobialSpellbookFrame.prevButton:Disable()
    else
        addon.MacrobialSpellbookFrame.prevButton:Enable()
    end

    if currentPage >= maxPages then
        currentPage = maxPages
        addon.MacrobialSpellbookFrame.nextButton:Disable()
    else
        addon.MacrobialSpellbookFrame.nextButton:Enable()
    end

    local startIndex = (currentPage - 1) * addon.positionOptions.buttonsPerPage + 1
    local endIndex = startIndex + addon.positionOptions.buttonsPerPage - 1

    for i, button in ipairs(addon.spellButtons) do
        if i >= startIndex and i <= endIndex then
            button:Show()
        else
            button:Hide()
        end
    end
end
