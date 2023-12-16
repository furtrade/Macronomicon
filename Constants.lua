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
		onMatch = function(match)
			print("Healing effect found:", match)
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
		items = {},
		spells = {},
	},
	Food = {
		enabled = "toggleFood",
		name = "Food",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Food" },
		items = {},
		spells = {},
	},
	Drink = {
		enabled = "toggleDrink",
		name = "Drink",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Drink" },
		items = {},
		spells = {},
	},
	Bandage = {
		enabled = "toggleBandage",
		name = "Bandage",
		icone = "INV_Misc_QuestionMark",
		keywords = { "First Aid", "Bandage" },
		items = {},
		spells = {},
	},
	HS = {
		enabled = "toggleHS",
		name = "Healthstone",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Healthstone" },
		items = {},
		spells = {},
	},
	Bang = {
		enabled = "toggleBang",
		name = "Bang",
		icone = "INV_Misc_QuestionMark",
		keywords = { "Explosive", "Bomb", "Grenade", "Dynamite", "Sapper", "Rocket", "Charge" },
		items = {},
		spells = {},
	},
}

-- Find matches for items or spells that we want to use.
function addon:UpdateMacroData()
	for macroName, macroData in pairs(self.macroData) do
		-- Iterate over itemCache
		for _, itemInfo in ipairs(self.itemCache or {}) do
			for _, keyword in ipairs(macroData.keywords or {}) do
				if string.match(itemInfo.name, keyword) then
					table.insert(macroData.items, itemInfo)
				end
			end
		end

		-- Iterate over spellbook
		for _, spellInfo in ipairs(self.spellbook or {}) do
			for _, keyword in ipairs(macroData.keywords or {}) do
				if string.match(spellInfo.name, keyword) then
					table.insert(macroData.spells, spellInfo)
				end
			end
		end
	end
end

-- This clears the entire table of items or spells respectively.
-- Probs better to just update the item count instead
function addon:resetMacroData(spellsOrItems)
	for _, macroData in pairs(self.macroData) do
		if type(macroData) == "table" and macroData[spellsOrItems] then
			macroData[spellsOrItems] = {}
		end
	end
end

-- Usage:
-- addon.resetMacroData()

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
