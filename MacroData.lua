-- macroData.lua
-- Contains data for macros and related functions.
local _, addon = ...

-- Function to get items for a given macro from the centralized item cache
local function getItemsForMacro(macroKey)
    local macroInfo = addon.macroData[macroKey]
    local items = addon.itemCache
    local matchedItems = {}

    for _, entry in ipairs(items) do
        for _, keyword in ipairs(macroInfo.keywords) do
            if entry.name:match(keyword) then
                matchedItems[entry.name] = entry
                entry.score = addon:scoreEntry(entry, "item", macroInfo)
            end
        end
    end

    local sortedItems = {}
    for _, item in pairs(matchedItems) do
        table.insert(sortedItems, item)
    end

    table.sort(sortedItems, function(a, b)
        return a.score > b.score
    end)

    return sortedItems
end

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
            local healthstone = addon:getBestItemForMacro("HS")
            if healthstone then
                local healthstoneLine = "/use " .. healthstone
                table.insert(macroLines, 2, healthstoneLine)
            end
        end,
        getItems = function()
            return getItemsForMacro("HP")
        end
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
        getItems = function()
            return getItemsForMacro("MP")
        end
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
        getItems = function()
            return getItemsForMacro("Food")
        end
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
        getItems = function()
            return getItemsForMacro("Drink")
        end
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
        getItems = function()
            return getItemsForMacro("Bandage")
        end
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
        getItems = function()
            return getItemsForMacro("HS")
        end
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
        getItems = function()
            return getItemsForMacro("Bang")
        end
    }
}
