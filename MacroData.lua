-- macroData.lua
-- Contains data for macros and some related functions.
local _, addon = ...

addon.macroData = {
    HP = {
        name = "Heal Pot",
        icon = "Interface\\Icons\\inv_potion_167",
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
        icon = "Interface\\Icons\\inv_potion_168",
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
        icon = "Interface\\Icons\\inv_misc_food_64",
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
        icon = "Interface\\Icons\\inv_drink_17",
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
        icon = "Interface\\Icons\\inv_misc_bandage_12",
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
        icon = "Interface\\Icons\\inv_stone_04",
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
        icon = "Interface\\Icons\\inv_misc_bomb_04",
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
