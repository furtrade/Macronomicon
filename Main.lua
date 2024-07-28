local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local _G = _G

addon.spellbook = {}
addon.itemCache = {}

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addonName .. "DB", self.defaults)
    AceConfig:RegisterOptionsTable(addon.title .. "_Options", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .. "_Options", addon.title)
    self:RegisterChatCommand(addon.title, "SlashCommand")
    self:RegisterChatCommand("mbl", "SlashCommand")

    self.gui = LibStub("AceGUI-3.0")

    -- Generate the macro groups
    self:loadCustomMacros()
    self:generateMacroGroups()

    -- Initialize from file 1
    -- addon.SetupCategory() -- Initialize mixin
    -- addon.SetupFrame() -- Initialize mixin
    -- addon.CreateAndInitCustomCategory()
end

function addon:OnEnable()
    local sendIt = "autoTrigger"
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
    elseif input == "enable" then
        self:Enable()
        self:Print("Enabled.")
    elseif input == "disable" then
        self:Disable()
        self:Print("Disabled.")
    elseif input == "message" then
        print("this is our saved message:", self.db.profile.someInput)
    else
        Settings.OpenToCategory(self.optionsFrame.name)
    end
end

local lastTrigger = 0
local threshold = 5
local retryPending = false

function addon:autoTrigger(event)
    if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
        return
    end

    local currentTime = GetTime()
    if currentTime - lastTrigger > threshold then
        self:tryAction()
    elseif not retryPending then
        local timeToAct = threshold - (currentTime - lastTrigger)
        retryPending = true
        C_Timer.After(timeToAct, function()
            retryPending = false
            self:tryAction()
        end)
    end
end

function addon:tryAction()
    if InCombatLockdown() then
        return
    end

    local success = self:ProcessAll()
    if success then
        lastTrigger = GetTime()
    end
end

function addon:ProcessAll()
    if InCombatLockdown() then
        return false
    else
        self:UpdateItemCache()
        self:updateMacroData()
        self:processMacros()
        return true
    end
end

-- Expose the addon globally for debugging
_G.Macrobial = addon
_G["a_reverse_engine"] = addon -- From file 1
