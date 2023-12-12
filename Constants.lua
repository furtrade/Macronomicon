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
