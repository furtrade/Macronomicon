local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local _G = _G

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
addon.title = GetAddOnMetadata(addonName, "Title")

-- addon.items = {}
-- addon.spellBook = {}
addon.macroData = {}
addon.player = {
	localeClass = select(1, UnitClass("player")),
	class = select(2, UnitClass("player")),
	race = select(2, UnitRace("player")),
	faction = select(1, UnitFactionGroup("player")),
}

addon.itemCache = {}
-- local cachedItems = addon.itemCache

function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New(addon.title .. "DB", self.defaults)
	AceConfig:RegisterOptionsTable(addon.title .. "_Options", self.options)
	self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .. "_Options", addon.title)
	-- AceConfig:RegisterOptionsTable(addon.title .."_paperDoll", self.paperDoll)
	-- AceConfigDialog:AddToBlizOptions(addon.title .."_paperDoll", "Paper Doll", "addon")
	-- self:GetCharacterInfo()
	self:RegisterChatCommand(addon.title, "SlashCommand")
	self:RegisterChatCommand("mbl", "SlashCommand")
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
end

local lastEventTime = {}
local timeThreshold = 7 -- in seconds

-- Event handler to automate the AdornSet() function.
function addon:autoTrigger(event)
	-- check if the player is in combat, if so return.
	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		return
	end

	local currentTime = GetTime()
	if not lastEventTime[event] or (currentTime - lastEventTime[event] > timeThreshold) then
		local success = self:doTheThing()
		if success then
			lastEventTime[event] = currentTime
		end
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

-- macro engine to create macros
function addon:makeMacro(macroName, icon, items)
	local prefix = "!" -- add an option to change this later
	local macroName = prefix .. macroName

	-- check if the macro exists already
	local macroExists = GetMacroInfo(macroName)
	if not macroExists then
		CreateMacro(macroName, "INV_Misc_QuestionMark")
	end

	-- build the macro string
	local tip = "#showtooltip "
	local cast = "\n/cast "

	local macro = tip
	-- for _, item in ipairs(items) do
	--     macro = macro .. cast .. item.name
	-- end
	if items[1] then -- Check if the first element exists
		macro = macro .. cast .. items[1].name
	end

	EditMacro(macroName, macroName, icon, macro)
	-- self:Print("Done!")
end

-- check which macros are enabled and create them.
function addon:processMacros(macroTables)
	if not macroTables then
		macroTables = addon.macroData
	end
	-- which macros are enabled? e.g. "HealPotMacro"
	for _, macroInfo in pairs(macroTables) do
		-- check if the macro is enabled
		if addon.db.profile[macroInfo.enabled] then
			-- get macro info
			local name = macroInfo.name
			local icon = macroInfo.icon
			local items = macroInfo.items

			addon:makeMacro(name, icon, items)
		end
	end
end

-- helper function for scanning bags
local function itemizer(dollOrBagIndex, slotIndex)
	local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex)
		or GetInventoryItemLink("player", dollOrBagIndex)

	if itemLink then
		-- Check if the item can be used
		local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
		if itemID then
			local canUse = C_PlayerInfo.CanUseItem(itemID)

			-- Get item type and subtype and equipSlotLocation
			local itemLevel, _, itemType, itemSubType, _, equipLoc = select(4, GetItemInfo(itemID))

			-- does the item have a spell associated with it?
			local itemSpell, itemSpellId = GetItemSpell(itemID)

			--Bundle the item info
			if canUse and itemSpell then
				local itemInfo = {}
				-- usual stuff
				itemInfo.id = itemID
				itemInfo.link = itemLink
				itemInfo.name = C_Item.GetItemNameByID(itemID)
				itemInfo.level = itemLevel
				itemInfo.type = itemType
				itemInfo.subType = itemSubType
				itemInfo.equipLoc = equipLoc
				itemInfo.spellName = itemSpell
				itemInfo.spellId = itemSpellId
				local count = GetItemCount(itemID)
				itemInfo.count = count

				return itemInfo
			end
		end
	end
end

-- helper function to sort items by type, e.g. health pots, mana pots, food, etc.
local function sortTableByLevel(items)
	table.sort(items, function(a, b)
		if a.level and b.level then
			return a.level > b.level
		elseif a.level then
			return true
		elseif b.level then
			return false
		else
			return false
		end
	end)
end

local function matchMaker(cache, macroItems, keywords)
	for _, keyword in pairs(keywords) do
		for _, item in pairs(cache) do
			for match in string.gmatch(item.spellName:lower(), keyword:lower()) do
				if match then
					table.insert(macroItems, item)
					-- break  -- exit inner loop after first match
				end
			end
		end
	end
	-- still need to prune these items
end

-- scan bags for items we can use
function addon:refreshcachedItems()
	addon.itemCache = {}
	addon.resetMacroData()

	-- inventory
	for bagOrSlotIndex = 1, 19 do
		local itemInfo = itemizer(bagOrSlotIndex)

		if itemInfo then
			table.insert(addon.itemCache, itemInfo)
		end
	end

	-- bags
	local numBags = Constants.InventoryConstants.NumBagSlots
	for bagOrSlotIndex = 0, numBags do
		local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex)
		if numSlots > 0 then
			for slotIndex = 1, numSlots do
				local itemInfo = itemizer(bagOrSlotIndex, slotIndex)

				if itemInfo then
					table.insert(addon.itemCache, itemInfo)
				end
			end
		end
	end

	-- send items to the macros tables
	if addon.itemCache then
		for _, v in pairs(addon.macroData) do
			if v.items then
				-- search itemCache for keyword matches from macroData
				-- if match found, add to v.items
				matchMaker(addon.itemCache, v.items, v.keywords)
			end
		end
	end
	-- sort items from best to worst.
	for _, v in pairs(addon.macroData) do
		if v.items then
			sortTableByLevel(v.items)
		end
	end
	-- now we need to select items for a macro.
end

-- function to run the addon and create the macros
function addon:doTheThing()
	if InCombatLockdown() then
		return false
	else
		self:Print("Refreshing Active Items...") -- debugging
		addon:refreshcachedItems()
		self:Print("\nRefreshed active items") -- debugging
		addon:processMacros()
		self:Print("Done.") -- debugging
		return true
	end
end
