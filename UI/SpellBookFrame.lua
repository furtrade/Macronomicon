local _, addon = ...

addon.spellbookWidth, addon.spellbookHeight = nil, nil

function addon:CreateMacrobialSpellbookFrame()
    if self.MacrobialSpellbookFrame then
        return
    end

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
    -- Set the frame's background to be fully transparent
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(1, 1, 1, 1)
    frame:EnableMouse(true)
    frame:SetToplevel(true)
    frame:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 3)

    frame:SetScript("OnShow", function()
        addon.spellbookWidth = tonumber(frame:GetWidth())
        addon.spellbookHeight = tonumber(frame:GetHeight())

        print("Frame shown")
        addon:CreateButtons()
        addon:PositionButtonsInGrid()
        addon:CreatePaginationButtons(frame, math.ceil(#addon.spellButtons / addon.positionOptions.buttonsPerPage))
    end)

    frame:SetScript("OnHide", function()
        -- Clear any tooltips
        GameTooltip:Hide()
    end)

    print("Creating Macrobial spellbook frame...")

    self.MacrobialSpellbookFrame = frame
    frame:Hide()
end
