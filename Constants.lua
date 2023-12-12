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
		--sequence = false,
		nuance = function(macroLines)
            -- Example: Add an additional check or line based on a specific condition
            --if SomeConditionIsMet() then
                --table.insert(macroLines, "/say Activating Heal Pot")
            --end
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

function addon.resetMacroData()
	for k, v in pairs(addon.macroData) do
		if type(v) == "table" then
			v.items, v.spells = {}, {}
		end
	end
end

-- Usage:
-- addon.resetMacroData()

-- Search for item in a specific category by name or ID
function addon:findItemInCategoryByNameOrId(category, name, id)
    for _, item in ipairs(addon.macroData[category].items) do
        if (name and item.name == name) or (id and item.id == id) then
            return item
        end
    end
    return false
end

-- Search for the first item in a specific category, or by ID
function addon:findItemInCategory(category, id)
    if id then
        for _, item in ipairs(addon.macroData[category].items) do
            if item.id == id then
                return item
            end
        end
    else
        return addon.macroData[category].items[1]
    end
    return false
end

-- Search for item by name or ID across all categories
function addon:findItemByNameOrId(name, id)
    for _, categoryData in pairs(addon.macroData) do
        for _, item in ipairs(categoryData.items) do
            if (name and item.name == name) or (id and item.id == id) then
                return item
            end
        end
    end
    return false
end

function addon:playerHasItem(...)
    local id, category, spellOrItemName = nil, nil, nil

    for _, arg in ipairs({...}) do
        if type(arg) == "number" then
            id = arg
        elseif type(arg) == "string" then
            if self:isCategory(arg) then
                category = arg
            else
                spellOrItemName = arg
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

    return false
end
