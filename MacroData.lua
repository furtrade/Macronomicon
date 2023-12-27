local addonName, addon = ...

-- ===========================================
-- Normal Macros:
-- ===========================================
-- (sit) food
-- (sit) drink
-- HP potion
-- healthstone (special case)
-- MP potion
-- explosive
-- (sit) bandages
--  TODO:Combat potion
-- ===========================================
-- Buff Sequences:
-- ===========================================
-- TODO:(sit) item enhancements
-- TODO:(sit) Food Buff (special case)
-- TODO:elixir
-- TODO:scroll
-- ===========================================
-- Weapon Swaps
-- ===========================================
--  TODO:Defensive
--  TODO:Offensive

-- ===========================================
-- Spells:
-- ===========================================
--  TODO: Add Warlock "Create Healthstone" line to auto update creating healthstones.
--  TODO: Add Mage Food & Water macros
--[[ addon.spellBook.heals = {
    ["Crimson Vial"] = 185311, --Rogue
    ["Renewal"] = 108238, --Druid
    ["Exhilaration"] = 109304, --Hunter
    ["Fortitude of the Bear"] = 272679, --Hunter
    ["Bitter Immunity"] = 383762, --Warrior
    ["Desperate Prayer"] = 19236, --Priest
    ["Expel Harm"] = 322101, --Monk
    ["Healing Elixir"] = 122281 --Monk
} ]]

addon.macroData = {
	GENERAL = {
		-- TODO: Add ability to combine categories in a single macro. e.g. HP & HS
		HP = {
			enabled = "toggleHP",
			name = "Heal Pot",
			icone = "INV_Misc_QuestionMark",
			keywords = { "Healing Potion" },
			valuation = { "(%d+)%s+to%s+(%d+) health" },
			patterns = {
				{
					pattern = "(%d+)%s+to%s+(%d+) health",
					onMatch = function(match)
						-- print("Healing effect found:", match)
					end,
				},
			},
			nuance = function(macroLines)
				-- add a healthstone to our heal pot macro
				local healthstone = addon:playerHasItem("HS", "Healthstone")
				if healthstone then
					local healthstoneLine = "/use " .. healthstone.name
					table.insert(macroLines, 2, healthstoneLine)
				end
			end,
			--condition = "",
			items = {},
		},
		MP = {
			enabled = "toggleMP",
			name = "Mana Pot",
			icone = "INV_Misc_QuestionMark",
			keywords = { "Mana Potion", "Restore Mana" },
			valuation = { "(%d+)%s+to%s+(%d+) mana" },
			patterns = {
				{
					pattern = "(%d+)%s+to%s+(%d+) mana",
					onMatch = function(match)
						-- Handle the match
					end,
				},
			},
			items = {},
			spells = {},
		},
		Food = {
			enabled = "toggleFood",
			name = "Food",
			icone = "INV_Misc_QuestionMark",
			keywords = { "Food" },
			valuation = { "(%d+) health over %d+ sec" },
			patterns = {
				{
					pattern = "(%d+) health over %d+ sec",
					onMatch = function(match)
						-- Handle the match
					end,
				},
			},
			items = {},
			spells = {},
		},
		Drink = {
			enabled = "toggleDrink",
			name = "Drink",
			icone = "INV_Misc_QuestionMark",
			keywords = { "Drink" },
			valuation = { "(%d+) mana over %d+ sec" },
			patterns = {
				{
					pattern = "(%d+) mana over %d+ sec",
					onMatch = function(match)
						-- Handle the match
					end,
				},
			},
			items = {},
			spells = {},
		},
		Bandage = {
			enabled = "toggleBandage",
			name = "Bandage",
			icone = "INV_Misc_QuestionMark",
			keywords = { "First Aid", "Bandage" },
			valuation = { "Heals (%d+)" },
			patterns = {
				{
					pattern = "Heals (%d+)",
					onMatch = function(match)
						-- Handle the match
					end,
				},
			},
			items = {},
			spells = {},
		},
		HS = {
			enabled = "toggleHS",
			name = "Healthstone",
			icone = "INV_Misc_QuestionMark",
			keywords = { "Healthstone" },
			valuation = { "(%d+) life" },
			patterns = {
				{
					pattern = "(%d+) life",
					onMatch = function(match)
						-- Handle the match
					end,
				},
			},
			items = {},
			spells = {},
		},
		Bang = {
			enabled = "toggleBang",
			name = "Bang",
			icone = "INV_Misc_QuestionMark",
			keywords = { "Explosive", "Bomb", "Grenade", "Dynamite", "Sapper", "Rocket", "Charge" },
			valuation = { "(%d+)%s+to%s+(%d+)" },
			patterns = {
				{
					pattern = "(%d+)%s+to%s+(%d+)",
					onMatch = function(match)
						-- Handle the match
					end,
				},
			},
			items = {},
			spells = {},
		},
	},
	WARLOCK = {
		main = {
			enabled = "toggleMain",
			name = "Main",
			icone = "INV_Misc_QuestionMark",
			keywords = { "Master Channeler" },
			patterns = {
				{
					pattern = "(%d+)%s+to%s+(%d+)",
					onMatch = function(match)
						-- print("Healing effect found:", match)
					end,
				},
			},
			items = {},
			spells = {},
		},
	},
}

function addon:forEachMacro(callback)
	for macroType, macroTypeData in pairs(self.macroData) do
		for _, macroInfo in pairs(macroTypeData) do
			callback(macroInfo)
		end
	end
end

local function FindAndExtractZoneName(text)
	-- Convert the text to lower case for case insensitive matching
	text = string.lower(text)
	local pattern = "usable only inside%s+([^%.]+)%."
	local match
	for zone in string.gmatch(text, pattern) do
		-- print("Match: " .. zone)
		match = zone
	end
	if match then
		-- print("Zone name found: " .. match)
		return match
	end
	return nil
end

local function IsPlayerInZone(zoneName)
	local currentZone = string.lower(GetZoneText())
	-- print("Current zone: ", currentZone)
	if string.lower(zoneName) == currentZone then
		return true
	else
		return false
	end
end

-- Function to score an item or spell
function addon:scoreItemOrSpell(itemOrSpell, isOfTypeItemOrSpell, macroInfo)
	-- Check if the item or spell ID is valid
	if not itemOrSpell.id or type(itemOrSpell.id) ~= "number" then
		return 0
	end

	-- Get the tooltip for the item or spell
	local myTooltip = self:GetTooltipByType(itemOrSpell.id, isOfTypeItemOrSpell)

	-- If the tooltip could not be retrieved, return 0
	if not myTooltip then
		return 0
	end

	-- Extract the text from the tooltip
	local tooltipContentTable = self:TableOfContents(myTooltip)

	-- Concatenate the strings in the table into a single string
	local tooltipContent = tooltipContentTable.onLeftSide .. " " .. tooltipContentTable.onRightSide

	local zoneName = FindAndExtractZoneName(tooltipContent)
	if zoneName and not IsPlayerInZone(zoneName) then
		return 0
	end

	-- Extract the values from the tooltip text
	local values = {}
	if type(macroInfo.valuation) == "table" then
		for _, pattern in ipairs(macroInfo.valuation) do
			-- Use string.gsub as a workaround to iterate over all matches
			string.gsub(tooltipContent, pattern, function(...)
				-- The arguments to the function are the captures
				local captures = { ... }
				for _, value in ipairs(captures) do
					local numValue = tonumber(value)
					if numValue then
						table.insert(values, numValue)
					end
				end
			end)
		end
	end

	-- Calculate the average of the values
	local total = 0
	for _, value in ipairs(values) do
		total = total + value
	end
	local average = #values > 0 and total / #values or 0

	return average
end

local function processItemsOrSpells(self, categoryKey, macroKey, macroData)
	local keywords = macroData.keywords or {}
	local entryTypes = { "item", "spell" }

	-- Create a table to store the names of the items that have been matched
	local matchedItems = {}

	for _, entryType in ipairs(entryTypes) do
		local entries = entryType == "item" and self.itemCache or self.spellbook

		for _, entry in ipairs(entries or {}) do
			local name = entry.name
			local isMatch = any(keywords, function(keyword) return string.match(name, keyword) end)

			if isMatch then
				-- Check if the item has already been matched
				if not matchedItems[name] then
					-- If the item has not been matched, add it to the matchedItems table
					matchedItems[name] = true

					entry.score = self:scoreItemOrSpell(entry, entryType, macroData)
					if entryType == "item" then
						self:addItem(categoryKey, macroKey, entry)
					else
						self:addSpell(categoryKey, macroKey, entry)
					end
				end
			end
		end
	end
end

-- Helper function to check if any element in a table satisfies a condition
function any(t, condition)
	for _, v in ipairs(t) do
		if condition(v) then return true end
	end
	return false
end

-- Refactored UpdateMacroData function
function addon:UpdateMacroData()
	for categoryKey, categoryData in pairs(self.macroData) do
		for macroKey, macroData in pairs(categoryData) do
			processItemsOrSpells(self, categoryKey, macroKey, macroData)
		end
	end

	addon:sortMacroData("level")
end

-- Function to sort items and spells within macros
-- Helper function to handle common logic
local function sortItemsOrSpells(itemsOrSpells, attribute)
	if itemsOrSpells and #itemsOrSpells > 0 then
		table.sort(itemsOrSpells, function(a, b)
			return a[attribute] < b[attribute]
		end)
	end
end

-- Refactored sortMacroData function
function addon:sortMacroData(attribute)
	-- Check if attribute is valid
	if attribute ~= ("score" or "level") then
		return
	end

	-- Iterate over the macro types
	for categoryKey, categoryData in pairs(self.macroData) do
		-- Iterate over the macros
		for macroKey, macroData in pairs(categoryData) do
			sortItemsOrSpells(macroData.items, attribute)
			sortItemsOrSpells(macroData.spells, attribute)
		end
	end
end

-- This clears the entire table of items or spells respectively.
-- Probs better to just update the item count instead
-- Helper function to handle common logic
local function resetItemsOrSpells(macroData, spellsOrItems)
	if type(macroData) == "table" and macroData[spellsOrItems] then
		macroData[spellsOrItems] = {}
	end
end

-- Refactored resetMacroData function
function addon:resetMacroData(spellsOrItems)
	if self.macroData then
		for macroType, macroTypeData in pairs(self.macroData) do
			for _, macroData in pairs(macroTypeData) do
				resetItemsOrSpells(macroData, spellsOrItems)
			end
		end
	end
end

-- Helper function to handle common logic
local function findItemInCategoryItems(categoryData, id)
	for _, item in ipairs(categoryData.items) do
		if item.id == id then
			return item
		end
	end
	return categoryData.items[1]
end

-- Refactored findItemInCategory function
function addon:findItemInCategory(category, id)
	for macroType, macroTypeData in pairs(self.macroData) do
		if macroTypeData[category] then
			return findItemInCategoryItems(macroTypeData[category], id)
		end
	end
	return nil -- Return nil if no item is found
end

function addon:isCategory(category)
	for macroType, macroTypeData in pairs(self.macroData) do
		if macroTypeData[category] then
			return true
		end
	end
	return false
end

function addon:playerHasItem(...)
	-- ... same as before ...
end

function addon:findItemInCategoryByNameOrId(category, name, id)
	for macroType, macroTypeData in pairs(self.macroData) do
		if macroTypeData[category] then
			for _, item in ipairs(macroTypeData[category].items) do
				if (name and string.find(item.name:lower(), name)) or (id and item.id == id) then
					return item
				end
			end
		end
	end
	return nil
end

function addon:findItemByNameOrId(name, id)
	for macroType, macroTypeData in pairs(self.macroData) do
		for _, categoryData in pairs(macroTypeData) do
			for _, item in ipairs(categoryData.items) do
				if (name and string.find(item.name:lower(), name)) or (id and item.id == id) then
					return item
				end
			end
		end
	end
	return nil
end

function addon:itemsBy(category, type)
	return self.macroData[category][type].items
end

function addon:spellsBy(category, type)
	return self.macroData[category][type].spells
end

function addon:addItem(categoryKey, macroKey, item)
	-- Add a timestamp to the item
	item.timestamp = GetTime()

	-- Get the items for the given category and macroKey
	local items = self.macroData[categoryKey][macroKey].items

	-- Remove items with the same name
	for i = #items, 1, -1 do
		if items[i].name == item.name then
			table.remove(items, i)
		end
	end

	-- Insert the item into the table
	table.insert(items, item)
end

function addon:addSpell(categoryKey, macroKey, spell)
	-- Add a timestamp to the item
	spell.timestamp = GetTime()

	-- Get the items for the given category and macroKey
	local spells = self.macroData[categoryKey][macroKey].spells

	-- Remove items with the same name
	for i = #spells, 1, -1 do
		if spells[i].name == spell.name then
			table.remove(spells, i)
		end
	end

	-- Insert the item into the table
	table.insert(spells, spell)
end

function addon:PrintItemLinks(categoryKey, macroKey)
	-- Check if the items exist for the given categoryKey and macroKey
	if self.macroData[categoryKey] and self.macroData[categoryKey][macroKey] and self.macroData[categoryKey][macroKey].items then
		-- Print a header for the item links
		print(string.format("=== Item Links for %s - %s ===", categoryKey, macroKey))

		-- Iterate over the items
		for i, item in ipairs(self.macroData[categoryKey][macroKey].items) do
			-- Check if the item has a link and print it
			if item.link then
				print(string.format("Item %d: %s", i, item.link))
			end
		end

		-- Print a footer for the item links
		print("=== End of Item Links ===")
	else
		print(string.format("No items found for category: %s, macro: %s.", categoryKey, macroKey))
	end
end

function addon:PrintAllItemLinks()
	-- Check if macroData exists
	if self.macroData then
		-- Loop over the macroData table
		for categoryKey, categoryValue in pairs(self.macroData) do
			for macroKey, _ in pairs(categoryValue) do
				-- Call the PrintItemLinks function for each categoryKey and macroKey
				self:PrintItemLinks(categoryKey, macroKey)
			end
		end
	else
		print("No macro data found.")
	end
end
