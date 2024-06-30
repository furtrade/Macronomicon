local addonName, addon = ...

local positionOptions = addon.positionOptions

local function CreatePaginationButtons(frame, maxPages)
    local prevButton = CreateFrame("Button", "MacrobialSpellbookPrevPageButton", frame, "UIPanelButtonTemplate")
    prevButton:SetSize(32, 32)
    prevButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -50, 15)
    prevButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    prevButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    prevButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")

    local nextButton = CreateFrame("Button", "MacrobialSpellbookNextPageButton", frame, "UIPanelButtonTemplate")
    nextButton:SetSize(32, 32)
    nextButton:SetPoint("BOTTOMRIGHT", prevButton, "BOTTOMLEFT", -5, 0)
    nextButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    nextButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    nextButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")

    prevButton:SetScript("OnClick", function()
        addon.UpdateSpellbookPage(-1)
    end)
    nextButton:SetScript("OnClick", function()
        addon.UpdateSpellbookPage(1)
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

    local startIndex = (currentPage - 1) * positionOptions.buttonsPerPage + 1
    local endIndex = startIndex + positionOptions.buttonsPerPage - 1

    for i, button in ipairs(addon.spellButtons) do
        if i >= startIndex and i <= endIndex then
            button:Show()
        else
            button:Hide()
        end
    end
end

addon.CreatePaginationButtons = CreatePaginationButtons
