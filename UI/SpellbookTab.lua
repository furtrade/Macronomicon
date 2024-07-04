local _, addon = ...

-- Utility Functions
local function GetNumElements(prefix)
    local count = 0
    while _G[prefix .. (count + 1)] do
        count = count + 1
    end
    return count
end

local function GetNumSpellTabs()
    return GetNumElements("SpellBookSkillLineTab")
end

local function GetNumSpellbookPages()
    return GetNumElements("SpellBookFrameTabButton")
end

local function GetNumSpellbookButtons()
    return GetNumElements("SpellButton")
end

local function HideShowSpellbookContent(action)
    local numPages = GetNumSpellbookPages()
    local numButtons = GetNumSpellbookButtons()

    for i = 1, numPages do
        local tabButton = _G["SpellBookFrameTabButton" .. i]
        if tabButton then
            tabButton[action](tabButton)
        end
    end

    for i = 1, numButtons do
        local spellButton = _G["SpellButton" .. i]
        if spellButton then
            spellButton[action](spellButton)
        end
    end
end

local function HideDefaultSpellbookContent()
    HideShowSpellbookContent("Hide")
end

local function ShowDefaultSpellbookContent()
    HideShowSpellbookContent("Show")
end

-- Create a new tab in the spellbook
function CreateSpellbookTab()
    local numTabs = GetNumSpellTabs()
    local prevSelectedTab

    local tab = CreateFrame("CheckButton", "MacrobialSpellbookTab", SpellBookFrame, "SpellBookSkillLineTabTemplate")
    tab:SetPoint("TOPLEFT", _G["SpellBookSkillLineTab" .. numTabs], "BOTTOMLEFT", 0, -17)
    tab:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    tab.tooltip = "Macrobial"

    tab:SetScript("OnClick", function(self)
        prevSelectedTab = self
        SpellBookFrame.selectedTab = self
        HideDefaultSpellbookContent()

        for i = 1, numTabs do
            local defaultTab = _G["SpellBookSkillLineTab" .. i]
            if defaultTab then
                defaultTab:SetChecked(false)
            end
        end
        self:SetChecked(true)

        if not MacrobialSpellbookFrame then
            addon:CreateMacrobialSpellbookFrame()
        end
        MacrobialSpellbookFrame:Show()
    end)

    tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tab.tooltip or "", 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)

    tab:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    tab:Show()

    for i = 1, numTabs do
        local defaultTab = _G["SpellBookSkillLineTab" .. i]
        if defaultTab then
            defaultTab:HookScript("OnClick", function()
                MacrobialSpellbookTab:SetChecked(false)
                if MacrobialSpellbookFrame then
                    MacrobialSpellbookFrame:Hide()
                end
                ShowDefaultSpellbookContent()

                prevSelectedTab = defaultTab
                SpellBookFrame.selectedTab = defaultTab

                for j = 1, numTabs do
                    local otherTab = _G["SpellBookSkillLineTab" .. j]
                    if otherTab then
                        otherTab:SetChecked(otherTab == defaultTab)
                    end
                end
                GameTooltip:Hide()
            end)
        end
    end

    -- Hook into the SpellBookFrame OnShow event to manage content visibility and tab highlighting
    SpellBookFrame:HookScript("OnShow", function()
        if SpellBookFrame.selectedTab then
            if SpellBookFrame.selectedTab == MacrobialSpellbookTab then
                HideDefaultSpellbookContent()
                if not MacrobialSpellbookFrame then
                    addon:CreateMacrobialSpellbookFrame()
                end
                MacrobialSpellbookFrame:Show()
                MacrobialSpellbookTab:SetChecked(true)
                for i = 1, numTabs do
                    local defaultTab = _G["SpellBookSkillLineTab" .. i]
                    if defaultTab and defaultTab ~= MacrobialSpellbookTab then
                        defaultTab:SetChecked(false)
                    end
                end
            else
                ShowDefaultSpellbookContent()
                if MacrobialSpellbookFrame then
                    MacrobialSpellbookFrame:Hide()
                end
                for i = 1, numTabs do
                    local defaultTab = _G["SpellBookSkillLineTab" .. i]
                    if defaultTab then
                        defaultTab:SetChecked(defaultTab == SpellBookFrame.selectedTab)
                    end
                end
            end
        else
            ShowDefaultSpellbookContent()
            if MacrobialSpellbookFrame then
                MacrobialSpellbookFrame:Hide()
            end
            -- Ensure only one default tab is checked if no tab is remembered
            local defaultTabChecked = false
            for i = 1, numTabs do
                local defaultTab = _G["SpellBookSkillLineTab" .. i]
                if defaultTab then
                    if defaultTab:GetChecked() then
                        defaultTabChecked = true
                    end
                end
            end
            if not defaultTabChecked then
                local firstTab = _G["SpellBookSkillLineTab1"]
                if firstTab then
                    firstTab:SetChecked(true)
                end
            end
        end
    end)

    return tab
end

addon.CreateSpellbookTab = CreateSpellbookTab
