local _, addon = ...

local positionOptions = addon.positionOptions

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
    frame:SetBackdropColor(0, 0, 0, 1)
    frame:SetBackdropBorderColor(1, 1, 1, 1)
    frame:EnableMouse(true)
    frame:SetToplevel(true)
    frame:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 3)

    frame:SetScript("OnShow", function()
        print("Frame shown, creating buttons...")
        addon:CreateButtons(frame)
    end)

    print("Creating Macrobial spellbook frame...")

    self.MacrobialSpellbookFrame = frame
    frame:Hide()
end
