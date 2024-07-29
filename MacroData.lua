-- macroData.lua
-- Contains data for macros and related functions.
local _, addon = ...

-- Grabs the first item from the table.
function addon:GetFirstItemLinkForMacro(macroName)
    -- Iterate through each header and macroInfo in the macroData
    for header, macroInfo in pairs(addon.macroData) do
        -- Check if the macro name matches and if it has items
        if macroInfo.name == macroName and macroInfo.items then
            -- Loop through the items and return the first item link found
            for i = 1, #macroInfo.items do
                local item = macroInfo.items[i]
                if item.name then
                    return item.name
                end
            end
        end
    end
    -- Return nil if no matching item link is found
    return nil
end

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
        icon = 134795,
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
        icon = 134796,
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
        icon = 134020,
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
        icon = 132804,
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
        icon = 133682,
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
        icon = 135230,
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
        icon = 133712,
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
