local _, addon = ...

-- Function to get the number of spellbook tabs
local function GetNumSpellTabs()
    local numTabs = 0
    while _G["SpellBookSkillLineTab" .. (numTabs + 1)] do
        numTabs = numTabs + 1
    end
    return numTabs
end

-- Create a new tab in the spellbook
function CreateSpellbookTab()
    -- Determine the number of existing tabs
    local numTabs = GetNumSpellTabs()

    local tab = CreateFrame("CheckButton", "MacrobialSpellbookTab", SpellBookFrame, "SpellBookSkillLineTabTemplate")
    tab:SetPoint("TOPLEFT", _G["SpellBookSkillLineTab" .. numTabs], "BOTTOMLEFT", 0, -17)
    tab:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    tab.tooltip = "Macrobial"

    tab:SetScript("OnClick", function(self)
        -- Hide default spellbook content
        for i = 1, numTabs do
            local defaultTab = _G["SpellBookSkillLineTab" .. i]
            if defaultTab then
                defaultTab:SetChecked(false)
            end
        end
        self:SetChecked(true)

        -- Show custom spellbook frame
        if not MacrobialSpellbookFrame then
            addon:CreateMacrobialSpellbookFrame()
        end
        MacrobialSpellbookFrame:Show()
    end)

    tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tab.tooltip or "", 1, 1, 1, 1, true) -- Ensure valid text
        GameTooltip:Show()
    end)

    tab:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    tab:Show()

    -- Hook tab clicks to hide the Macrobial frame and manage glow borders
    for i = 1, numTabs do
        local defaultTab = _G["SpellBookSkillLineTab" .. i]
        if defaultTab then
            defaultTab:HookScript("OnClick", function()
                MacrobialSpellbookTab:SetChecked(false)
                if MacrobialSpellbookFrame then
                    MacrobialSpellbookFrame:Hide()
                end
                -- Set checked state to the clicked tab
                for j = 1, numTabs do
                    local otherTab = _G["SpellBookSkillLineTab" .. j]
                    if otherTab then
                        otherTab:SetChecked(false)
                    end
                end
                defaultTab:SetChecked(true)
                -- Clear any tooltips
                GameTooltip:Hide()
            end)
        end
    end

    return tab
end

addon.CreateSpellbookTab = CreateSpellbookTab
