local addonName, addon = ...


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

--[[ local function getSpells(spellBook)
    local spellKnown = {}
    -- iterate through addon.spellList and check if spell is known.
    -- if spell is known, add it to spellKnown table.
    for spellName, spellId in pairs(spellBook) do
        if IsSpellKnown(spellId) then
            table.insert(spellKnown, spellName);
        end
    end
    return spellKnown
end ]]


addon.macroData = {
    HP = {
        enabled = "toggleHP",
        name = "Heal Pot",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Healing Potion"},
        items = {},
        -- spells = getSpells(addon.spellBook.heals)
    },
    MP = {
        enabled = "toggleMP",
        name = "Mana Pot",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Mana Potion"},
        items = {},
        spells = {}
    },
    Food = {
        enabled = "toggleFood",
        name = "Food",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Food"},
        items = {},
        spells = {}
    },
    Drink = {
        enabled = "toggleDrink",
        name = "Drink",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Drink"},
        items = {},
        spells = {}
    },
    Bandage = {
        enabled = "toggleBandage",
        name = "Bandage",
        icone = "INV_Misc_QuestionMark",
        keywords = {"First Aid","Bandage"},
        items = {},
        spells = {}
    },
    HS = {
        enabled = "toggleHS",
        name = "Healthstone",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Healthstone"},
        items = {},
        spells = {}
    },
    Bang = {
        enabled = "toggleBang",
        name = "Bang",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Explosive", "Bomb", "Grenade", "Dynamite", "Sapper", "Rocket", "Charge"},
        items = {},
        spells = {}
    },
}