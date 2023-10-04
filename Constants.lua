local addon = LibStub("AceAddon-3.0"):GetAddon("addon")

addon.macros = {
    hp = {
        enabled = addon.db.profile.toggleHP,
        name = "Heal Pot",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Healing Potion"},
        items = {},
        spells = addon:getSpells(addon.spellBook.heals)
    },
    mp = {
        enabled = addon.db.profile.toggleMP,
        name = "Mana Pot",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Mana Potion"},
        items = {},
        spells = {}
    },
    food = {
        enabled = addon.db.profile.toggleFood,
        name = "Food",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Food"},
        items = {},
        spells = {}
    },
    drink = {
        enabled = addon.db.profile.toggleDrink,
        name = "Drink",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Drink"},
        items = {},
        spells = {}
    },
    bandage = {
        enabled = addon.db.profile.toggleBandage,
        name = "Bandage",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Bandage"},
        items = {},
        spells = {}
    },
    healthstone = {
        enabled = addon.db.profile.toggleHS,
        name = "Healthstone",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Healthstone"},
        items = {},
        spells = {}
    },
    bang = {
        enabled = addon.db.profile.toggleBang,
        name = "Bang",
        icone = "INV_Misc_QuestionMark",
        keywords = {"Explosive", "Bomb", "Grenade", "Dynamite", "Sapper", "Rocket", "Charge"},
        items = {},
        spells = {}
    },
}



addon.spellBook.heals = {
    ["Crimson Vial"] = 185311, --Rogue
    ["Renewal"] = 108238, --Druid
    ["Exhilaration"] = 109304, --Hunter
    ["Fortitude of the Bear"] = 272679, --Hunter
    ["Bitter Immunity"] = 383762, --Warrior
    ["Desperate Prayer"] = 19236, --Priest
    ["Expel Harm"] = 322101, --Monk
    ["Healing Elixir"] = 122281 --Monk
}

function addon:getSpells(spellBook);
    local spellKnown = {}
    -- iterate through addon.spellList and check if spell is known.
    -- if spell is known, add it to spellKnown table.
    for spellName, spellId in pairs(spellBook) do
        if IsSpellKnown(spellId) then
            table.insert(spellKnown, spellName);
        end
    end
    return spellKnown
end

