local addonName, addon = ...

function addon:CreatePaginationButtons(parentFrame, updatePageFunction)
    -- Create the previous page button
    addon.prevButton = CreateFrame("Button", "MacrobialPrevPageButton", parentFrame, "UIPanelButtonTemplate")
    addon.prevButton:SetSize(25, 25)
    addon.prevButton:SetPoint("BOTTOMLEFT", parentFrame, "BOTTOMLEFT", 10, 10)
    addon.prevButton:SetText("<")
    addon.prevButton:SetScript("OnClick", function()
        if addon.currentPage > 1 then
            addon.currentPage = addon.currentPage - 1
            updatePageFunction()
        end
    end)

    -- Create the next page button
    addon.nextButton = CreateFrame("Button", "MacrobialNextPageButton", parentFrame, "UIPanelButtonTemplate")
    addon.nextButton:SetSize(25, 25)
    addon.nextButton:SetPoint("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -10, 10)
    addon.nextButton:SetText(">")
    addon.nextButton:SetScript("OnClick", function()
        if addon.currentPage < addon.totalPages then
            addon.currentPage = addon.currentPage + 1
            updatePageFunction()
        end
    end)
end
