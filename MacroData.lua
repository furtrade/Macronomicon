-- macroData.lua
-- Contains data for macros. And some related functions.
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
            -- add a healthstone to our heal pot macro
            local healthstone = addon:playerHasItem("HS")
            if healthstone then
                local healthstoneLine = "/use " .. healthstone
                table.insert(macroLines, 2, healthstoneLine)
            end
        end,
        -- condition = "",
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

-- Helper function to check if any element in a table satisfies a condition
local function any(t, condition)
    for _, v in ipairs(t) do
        if condition(v) then
            return true
        end
    end
    return false
end

-- Score an item or spell
function addon:scoreItemOrSpell(itemOrSpell, isItem, macroInfo)
    if not itemOrSpell.id or type(itemOrSpell.id) ~= "number" then
        return 0
    end

    local tooltip = self:GetTooltipByType(itemOrSpell.id, isItem)
    if not tooltip then
        return 0
    end

    local content = self:TableOfContents(tooltip)
    local combinedText = content.onLeftSide .. " " .. content.onRightSide

    local zoneName = FindAndExtractZoneName(combinedText)
    if zoneName and not IsPlayerInZone(zoneName) then
        return 0
    end

    local values = {}
    for _, pattern in ipairs(macroInfo.valuation) do
        for value in string.gmatch(combinedText, pattern) do
            local numValue = tonumber(value)
            if numValue then
                table.insert(values, numValue)
            end
        end
    end

    local total = 0
    for _, value in ipairs(values) do
        total = total + value
    end
    return #values > 0 and total / #values or 0
end

local function processItemsOrSpells(self, macroKey, macroData)
    local keywords = macroData.keywords or {}
    local matchedItems = {}

    for _, entryType in ipairs({"item", "spell"}) do
        local entries = entryType == "item" and self.itemCache or self.spellbook

        for _, entry in ipairs(entries or {}) do
            if any(keywords, function(keyword)
                return string.match(entry.name, keyword)
            end) then
                if not matchedItems[entry.name] then
                    matchedItems[entry.name] = true
                    entry.score = self:scoreItemOrSpell(entry, entryType == "item", macroData)
                    table.insert(macroData[entryType == "item" and "items" or "spells"], entry)
                end
            end
        end
    end
end

-- Update macro data
function addon:updateMacroData()
    for macroKey, macroData in pairs(self.macroData) do
        processItemsOrSpells(self, macroKey, macroData)
    end
    addon:sortMacroData("level")
end

-- Sort items and spells within macros
function addon:sortMacroData(attribute)
    if attribute ~= "score" and attribute ~= "level" then
        return
    end

    for _, macroData in pairs(self.macroData) do
        for _, itemsOrSpells in pairs({"items", "spells"}) do
            if macroData[itemsOrSpells] then
                table.sort(macroData[itemsOrSpells], function(a, b)
                    return a[attribute] < b[attribute]
                end)
            end
        end
    end
end

-- Player has item
function addon:playerHasItem(macroHeader)
    local highestItem, highestScore, highestLevel = nil, -1, -1

    if self.macroData[macroHeader] then
        for _, item in pairs(self.macroData[macroHeader].items) do
            if item.score > highestScore or (item.score == highestScore and item.level > highestLevel) then
                highestItem = item.name
                highestScore = item.score
                highestLevel = item.level
            end
        end
    end

    return highestItem
end
