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
	-- TODO: Add ability to combine categories in a single macro. e.g. HP & HS
	HP = {
		enabled = "toggleHP",
		name = "Heal Pot",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Healing Potion" },
		patterns = { "(%d+)%s+to%s+(%d+) health" },
		onMatch = function(match)
			-- print("Healing effect found:", match)
		end,
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
		patterns = { "(%d+)%s+to%s+(%d+) mana" },
		items = {},
		spells = {},
	},
	Food = {
		enabled = "toggleFood",
		name = "Food",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Food" },
		patterns = { "(%d+) health over %d+ sec" },
		items = {},
		spells = {},
	},
	Drink = {
		enabled = "toggleDrink",
		name = "Drink",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Drink" },
		patterns = { "(%d+) mana over %d+ sec" },
		items = {},
		spells = {},
	},
	Bandage = {
		enabled = "toggleBandage",
		name = "Bandage",
		icone = "INV_Misc_QuestionMark",
		keywords = { "First Aid", "Bandage" },
		patterns = { "Heals (%d+)" },
		items = {},
		spells = {},
	},
	HS = {
		enabled = "toggleHS",
		name = "Healthstone",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Healthstone" },
		patterns = { "(%d+) life" },
		items = {},
		spells = {},
	},
	Bang = {
		enabled = "toggleBang",
		name = "Bang",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Explosive", "Bomb", "Grenade", "Dynamite", "Sapper", "Rocket", "Charge" },
		patterns = { "(%d+)%s+to%s+(%d+)" },
		items = {},
		spells = {},
	},
}

-- Function to score an item or spell
function addon:scoreItemOrSpell(itemOrSpell, isOfTypeItemOrSpell, patterns)
	-- print("scoreItemOrSpell function started") -- Debugging line

	-- Check if the item or spell ID is valid
	if not itemOrSpell.id or type(itemOrSpell.id) ~= "number" then
		-- print("Invalid item or spell ID") -- Debugging line
		return 0
	end

	-- Get the tooltip for the item or spell
	local myTooltip = self:GetTooltipByType(itemOrSpell.id, isOfTypeItemOrSpell)

	-- If the tooltip could not be retrieved, return 0
	if not myTooltip then
		-- print("Could not retrieve tooltip") -- Debugging line
		return 0
	end

	-- Extract the text from the tooltip
	local tooltipContentTable = self:TableOfContents(myTooltip)

	-- Concatenate the strings in the table into a single string
	local tooltipContent = tooltipContentTable.onLeftSide .. " " .. tooltipContentTable.onRightSide
	-- print("Tooltip content: " .. tooltipContent) -- Debugging line

	-- Extract the values from the tooltip text
	local values = {}
	if type(patterns) == "table" then
		for _, pattern in ipairs(patterns) do
			-- Use string.gsub as a workaround to iterate over all matches
			string.gsub(tooltipContent, pattern, function(...)
				-- The arguments to the function are the captures
				local captures = { ... }
				for _, value in ipairs(captures) do
					local numValue = tonumber(value)
					-- print("Converted value: ", numValue) -- Debugging line
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

	-- print(itemOrSpell.name, "Average:", average) -- debugging line.
	return average
end

-- Function to update macro data
function addon:UpdateMacroData()
	-- print("UpdateMacroData function started") -- Debugging line

	for macroName, macroData in pairs(self.macroData) do
		-- Iterate over itemCache
		for _, itemInfo in ipairs(self.itemCache or {}) do
			for _, keyword in ipairs(macroData.keywords or {}) do
				if string.match(itemInfo.spellName, keyword) then
					itemInfo.score = self:scoreItemOrSpell(itemInfo, "item", macroData.patterns)
					table.insert(macroData.items, itemInfo)
				end
			end
		end

		-- Iterate over spellbook
		for _, spellInfo in ipairs(self.spellbook or {}) do
			for _, keyword in ipairs(macroData.keywords or {}) do
				if string.match(spellInfo.name, keyword) then
					spellInfo.score = self:scoreItemOrSpell(spellInfo, "spell", macroData.patterns)
					table.insert(macroData.spells, spellInfo)
				end
			end
		end
	end
	-- print("UpdateMacroData function finished") -- Debugging line
end

-- Function to sort items and spells within macros
function addon:sortMacroData(attribute)
	-- Check if attribute is valid
	if attribute ~= "score" and attribute ~= "level" then
		-- print("Invalid attribute. Please use 'score' or 'level'.")
		return
	end

	-- Iterate over the macros
	for _, macro in ipairs(self.macroData) do
		-- Sort items if the table is not empty
		if macro.items and #macro.items > 0 then
			table.sort(macro.items, function(a, b)
				return a[attribute] < b[attribute]
			end)
		end

		-- Sort spells if the table is not empty
		if macro.spells and #macro.spells > 0 then
			table.sort(macro.spells, function(a, b)
				return a[attribute] < b[attribute]
			end)
		end
	end
end

-- This clears the entire table of items or spells respectively.
-- Probs better to just update the item count instead
function addon:resetMacroData(spellsOrItems)
	if self.macroData then
		for _, macroData in pairs(self.macroData) do
			if type(macroData) == "table" and macroData[spellsOrItems] then
				macroData[spellsOrItems] = {}
			end
		end
	end
end

function addon:findItemInCategory(category, id)
	if id then
		for _, item in ipairs(self.macroData[category].items) do
			if item.id == id then
				return item
			end
		end
	else
		return self.macroData[category].items[1]
	end
	return nil -- Return nil if no item is found
end

function addon:isCategory(category)
	return self.macroData[category] ~= nil
end

function addon:playerHasItem(...)
	local id, category, spellOrItemName = nil, nil, nil

	for _, arg in ipairs({ ... }) do
		if type(arg) == "number" then
			id = arg
		elseif type(arg) == "string" then
			if self:isCategory(arg) then
				category = arg
			else
				spellOrItemName = arg:lower() -- Convert to lower case for case-insensitive comparison
			end
		end
	end

	if category and spellOrItemName then
		return self:findItemInCategoryByNameOrId(category, spellOrItemName, id)
	elseif category then
		return self:findItemInCategory(category, id)
	elseif spellOrItemName or id then
		return self:findItemByNameOrId(spellOrItemName, id)
	end

	return nil
end

function addon:findItemInCategoryByNameOrId(category, name, id)
	for _, item in ipairs(self.macroData[category].items) do
		if (name and string.find(item.name:lower(), name)) or (id and item.id == id) then
			return item
		end
	end
	return nil
end

function addon:findItemByNameOrId(name, id)
	for _, categoryData in pairs(self.macroData) do
		for _, item in ipairs(categoryData.items) do
			if (name and string.find(item.name:lower(), name)) or (id and item.id == id) then
				return item
			end
		end
	end
	return nil
end
