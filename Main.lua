local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local _G = _G

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
addon.title = GetAddOnMetadata(addonName, "Title")

-- addon.items = {}
-- addon.spellBook = {}
--addon.macroData = {}
addon.player = {
	localeClass = select(1, UnitClass("player")),
	class = select(2, UnitClass("player")),
	race = select(2, UnitRace("player")),
	faction = select(1, UnitFactionGroup("player")),
}

addon.spellbook = {}
addon.itemCache = {}

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(addon.title .. "DB", self.defaults)
	AceConfig:RegisterOptionsTable(addon.title .. "_Options", self.options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .. "_Options", addon.title)
	-- AceConfig:RegisterOptionsTable(addon.title .."_paperDoll", self.paperDoll)
	-- AceConfigDialog:AddToBlizOptions(addon.title .."_paperDoll", "Paper Doll", "addon")
	-- self:GetCharacterInfo()
	self:RegisterChatCommand(addon.title, "SlashCommand")
	self:RegisterChatCommand("mbl", "SlashCommand")

	-- Update the options for the selected macro
	local selectedMacro = self.db.profile.selectedMacro
	if selectedMacro then
		self:UpdateOptions(selectedMacro)
	end
end

function addon:OnEnable()
	-- function to callback when an event is triggered
	local sendIt = "autoTrigger"
	--triggers
	self:RegisterEvent("PLAYER_LEVEL_UP", sendIt)
	self:RegisterEvent("QUEST_TURNED_IN", sendIt)
	self:RegisterEvent("LOOT_CLOSED", sendIt)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", sendIt)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", sendIt)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", sendIt)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", sendIt)
	self:RegisterEvent("BAG_UPDATE", sendIt)
	self:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", sendIt)
	-- self:RegisterEvent("BANKFRAME_OPENED", sendIt)
	self:RegisterEvent("BANKFRAME_CLOSED", sendIt)
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED", sendIt)
	self:RegisterEvent("ITEM_LOCK_CHANGED", sendIt)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", sendIt)
	self:RegisterEvent("PLAYER_MONEY", sendIt)
end

local lastTrigger = 0
local threshold = 5        -- seconds
local retryPending = false -- Tracks pending retry

function addon:autoTrigger(event)
	-- Check for combat state
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		return
	end

	local currentTime = GetTime()
	if currentTime - lastTrigger > threshold then
		self:tryAction()
	elseif not retryPending then
		-- Time until next possible action
		local timeToAct = threshold - (currentTime - lastTrigger)
		retryPending = true
		C_Timer.After(timeToAct, function()
			retryPending = false
			self:tryAction()
		end)
	end
end

function addon:tryAction()
	if InCombatLockdown() then -- Check combat state again
		return
	end

	local success = self:doTheThing()
	if success then
		lastTrigger = GetTime()
	end
end

function addon:SlashCommand(input, editbox)
	-- input is everything after the slash command
	input = input:trim()
	if input == "run" then
		self:Print("Running...") -- debugging
		self:doTheThing()
	elseif input == "enable" then
		self:Enable()
		self:Print("Enabled.")
	elseif input == "disable" then
		-- unregisters all events and calls addon:OnDisable() if you defined that
		self:Disable()
		self:Print("Disabled.")
	elseif input == "message" then
		print("this is our saved message:", self.db.profile.someInput)
	else
		-- https://github.com/Stanzilla/WoWUIBugs/issues/89
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
	end
end

-- function to run the addon and create the macros
function addon:doTheThing()
	if InCombatLockdown() then
		return false
	else
		addon:UpdateItemCache()
		addon:UpdateSpellbook()
		addon:UpdateMacroData()
		addon:ProcessMacros()
		--addon:PrintAllItemLinks()
		return true
	end
end
