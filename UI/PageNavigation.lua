local _, addon = ...

-- Ensure positionOptions and CalculateButtonPosition are available
if not addon.positionOptions or not addon.CalculateButtonPosition then
    error("positionOptions or CalculateButtonPosition is not defined. Ensure ButtonPosition.lua is loaded first.")
end

local function CreatePaginationButtons(frame, maxPages)
    local function createButton(name, point, relativeFrame, relativePoint, offsetX, offsetY, textureUp, textureDown,
        textureDisabled, onClick)
        local button = CreateFrame("Button", name, frame, "UIPanelButtonTemplate")
        button:SetSize(32, 32)
        button:SetPoint(point, relativeFrame, relativePoint, offsetX, offsetY)
        button:SetNormalTexture(textureUp)
        button:SetPushedTexture(textureDown)
        button:SetDisabledTexture(textureDisabled)
        button:SetScript("OnClick", onClick)
        return button
    end

    local nextButton = createButton("MacrobialSpellbookNextPageButton", "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -50, 15,
        "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down",
        "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled", function()
            addon.UpdateSpellbookPage(1)
        end)

    local prevButton = createButton("MacrobialSpellbookPrevPageButton", "BOTTOMRIGHT", nextButton, "BOTTOMLEFT", -5, 0,
        "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up", "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down",
        "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled", function()
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
    local maxPages = MacrobialSpellbookFrame.maxPages

    if currentPage <= 1 then
        currentPage = 1
        MacrobialSpellbookFrame.prevButton:Disable()
    else
        MacrobialSpellbookFrame.prevButton:Enable()
    end

    if currentPage >= maxPages then
        currentPage = maxPages
        MacrobialSpellbookFrame.nextButton:Disable()
    else
        MacrobialSpellbookFrame.nextButton:Enable()
    end

    local startIndex = (currentPage - 1) * addon.positionOptions.buttonsPerPage + 1
    local endIndex = startIndex + addon.positionOptions.buttonsPerPage - 1

    for i, button in ipairs(addon.spellButtons) do
        if i >= startIndex and i <= endIndex then
            local xOffset, yOffset = addon.CalculateButtonPosition(i - startIndex + 1, button:GetParent():GetWidth(),
                button:GetParent():GetHeight())
            button:SetPoint("TOPLEFT", button:GetParent(), "TOPLEFT", xOffset, yOffset)
            button:Show()
        else
            button:Hide()
        end
    end
end

addon.CreatePaginationButtons = CreatePaginationButtons
