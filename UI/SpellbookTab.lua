local _, addon = ...

-- Create a new tab in the spellbook
function CreateSpellbookTab()
    -- Determine the number of existing tabs
    local numTabs = 0
    while _G["SpellBookSkillLineTab" .. (numTabs + 1)] do
        numTabs = numTabs + 1
    end

    local tab = CreateFrame("Button", "MacrobialSpellbookTab", SpellBookFrame, "SpellBookSkillLineTabTemplate")
    tab:SetPoint("TOPLEFT", _G["SpellBookSkillLineTab" .. numTabs], "BOTTOMLEFT", 0, -17)
    tab:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    tab.tooltip = "Macrobial"

    tab:SetScript("OnClick", function(self)
        if not MacrobialSpellbookFrame then
            addon.CreateMacrobialSpellbookFrame()
        end
        MacrobialSpellbookFrame:Show()
    end)

    tab:Show()
    return tab
end

addon.CreateSpellbookTab = CreateSpellbookTab
