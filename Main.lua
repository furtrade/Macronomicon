local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local _G = _G

addon.spellbook = {}
addon.itemCache = {}

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addonName .. "DB", self.defaults)
    --[[ -- 🤗Disabled Options Frame temporarily
    AceConfig:RegisterOptionsTable(addon.title .. "_Options", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .. "_Options", addon.title)
    ]]
    self:RegisterChatCommand(addon.title, "SlashCommand")
    self:RegisterChatCommand("mcn", "SlashCommand")

    self.gui = LibStub("AceGUI-3.0")

    -- Generate the macro groups
    self:LoadCustomMutations()
    self:generateMacroGroups()
end

function addon:OnEnable()
    local sendIt = "OnEventThrottle"
    self:RegisterEvent("PLAYER_LEVEL_UP", sendIt)
    self:RegisterEvent("QUEST_TURNED_IN", sendIt)
    self:RegisterEvent("LOOT_CLOSED", sendIt)
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", sendIt)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", sendIt)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", sendIt)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", sendIt)
    self:RegisterEvent("BAG_UPDATE", sendIt)
    self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", sendIt)
    self:RegisterEvent("BANKFRAME_CLOSED", sendIt)
    self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED", sendIt)
    self:RegisterEvent("ITEM_LOCK_CHANGED", sendIt)
    self:RegisterEvent("PLAYER_MONEY", sendIt)
    self:RegisterEvent("SPELLS_CHANGED", sendIt)
    self:RegisterEvent("LEARNED_SPELL_IN_TAB", sendIt)
    self:RegisterEvent("SKILL_LINES_CHANGED", sendIt)

    -- Custom event handlers from file 1
    self:RegisterEvent("ADDON_LOADED", "OnPlayerSpellsLoaded")
    -- self:RegisterEvent("PLAYER_LOGIN", "OnPlayerSpellsLoaded")
end

-- Setting up MacroBook UI
function addon:OnPlayerSpellsLoaded(event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddonName = ...
        if loadedAddonName == "Blizzard_PlayerSpells" then
            if PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame then
                addon.SetupCategory() -- Initialize mixin
                addon.SetupFrame() -- Initialize mixin
                addon.CreateAndInitCustomCategory()
            end
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        addon.InitializePlayerSpellsUtil()
        -- elseif event == "PLAYER_LOGIN" then
        --     addon.startNewSession()
    end
end

function addon:SlashCommand(input, editbox)
    input = input:trim()
    if input == "run" then
        self:Print("Running...")
        self:ProcessAll()
    else
        -- Settings.OpenToCategory(self.optionsFrame.name)
    end
end

-- Expose the addon globally for debugging
_G["Macronomicon"] = addon
