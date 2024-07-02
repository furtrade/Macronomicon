-- macroData.lua
-- Contains data for macros and some related functions.
local _, addon = ...

addon.macroData = {
    HP = {
        name = "Heal Pot",
        icon = "INV_Misc_QuestionMark",
        keywords = {"Healing Potion"},
        valuation = {"(%d+)%s+to%s+(%d+) health"},
        patterns = {{
            pattern = "(%d+)%s+to%s+(%d+) health",
            onMatch = function(match)
                -- print("Healing effect found:", match)
            end
        }},
        nuance = function(macroLines)
            -- Add a healthstone to our heal pot macro
            local healthstone = addon:playerHasItem("HS")
            if healthstone then
                local healthstoneLine = "/use " .. healthstone
                table.insert(macroLines, 2, healthstoneLine)
            end
        end,
        items = {}
    },
    MP = {
        name = "Mana Pot",
        icon = "INV_Misc_QuestionMark",
        keywords = {"Mana Potion", "Restore Mana"},
        valuation = {"(%d+)%s+to%s+(%d+) mana"},
        patterns = {{
            pattern = "(%d+)%s+to%s+(%d+) mana",
            onMatch = function(match)
                -- Handle the match
            end
        }},
        items = {},
        spells = {}
    },
    Food = {
        name = "Food",
        icon = "INV_Misc_QuestionMark",
        keywords = {"Food"},
        valuation = {"(%d+) health over %d+ sec"},
        patterns = {{
            pattern = "(%d+) health over %d+ sec",
            onMatch = function(match)
                -- Handle the match
            end
        }},
        items = {},
        spells = {}
    },
    Drink = {
        name = "Drink",
        icon = "INV_Misc_QuestionMark",
        keywords = {"Drink"},
        valuation = {"(%d+) mana over %d+ sec"},
        patterns = {{
            pattern = "(%d+) mana over %d+ sec",
            onMatch = function(match)
                -- Handle the match
            end
        }},
        items = {},
        spells = {}
    },
    Bandage = {
        name = "Bandage",
        icon = "INV_Misc_QuestionMark",
        keywords = {"First Aid", "Bandage"},
        valuation = {"Heals (%d+)"},
        patterns = {{
            pattern = "Heals (%d+)",
            onMatch = function(match)
                -- Handle the match
            end
        }},
        items = {},
        spells = {}
    },
    HS = {
        name = "Healthstone",
        icon = "INV_Misc_QuestionMark",
        keywords = {"Healthstone"},
        valuation = {"(%d+) life"},
        patterns = {{
            pattern = "(%d+) life",
            onMatch = function(match)
                -- Handle the match
            end
        }},
        items = {},
        spells = {}
    },
    Bang = {
        name = "Bang",
        icon = "INV_Misc_QuestionMark",
        keywords = {"Explosive", "Bomb", "Grenade", "Dynamite", "Sapper", "Rocket", "Charge"},
        valuation = {"(%d+)%s+to%s+(%d+)"},
        patterns = {{
            pattern = "(%d+)%s+to%s+(%d+)",
            onMatch = function(match)
                -- Handle the match
            end
        }},
        items = {},
        spells = {}
    }
}
