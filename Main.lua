local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local _G = _G

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
addon.title = GetAddOnMetadata(addonName, "Title")

-- Table lookup for game versions
local gameVersionLookup = {
    [110000] = "RETAIL",
    [100000] = "DRAGONFLIGHT",
    [90000] = "SHADOWLANDS",
    [80000] = "BFA",
    [70000] = "LEGION",
    [60000] = "WOD",
    [50000] = "MOP",
    [40000] = "CATA",
    [30000] = "WOTLK",
    [20000] = "TBC"
}
local gameVersion = select(4, GetBuildInfo())
addon.gameVersion = gameVersion
-- Find the appropriate game version
for version, name in pairs(gameVersionLookup) do
    if gameVersion >= version then
        addon.game = name
        break
    end
end

addon.player = {
    localeClass = select(1, UnitClass("player")),
    class = select(2, UnitClass("player")),
    race = select(2, UnitRace("player")),
    faction = select(1, UnitFactionGroup("player"))
}

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

function addon:ProcessAll()
    if InCombatLockdown() then
        return false
    else
        self:UpdateItemCache()
        -- self:UpdateSpellbook()
        self:updateMacroData()
        self:processMacros()
        return true
    end
end

-- Expose the addon globally for debugging
_G.Macrobial = addon
