-- Score.lua
-- Handles logic for scoring items and spells for use in macros
local _, addon = ...

-- Extracts the zone name from the given text
local function extractZoneName(text)
    text = text:lower()
    local pattern = "usable only inside%s+([^%.]+)%."
    return text:match(pattern)
end

-- Checks if the player is in the specified zone
local function isPlayerInZone(zoneName)
    return zoneName:lower() == GetZoneText():lower()
end

-- Helper function to check if any element in a table satisfies a condition
local function any(tbl, condition)
    for _, value in ipairs(tbl) do
        if condition(value) then
            return true
        end
    end
    return false
end

-- Scores an item or spell based on its tooltip and macro information
function addon:scoreEntry(entry, isItem, macroInfo)
    if not entry.id or type(entry.id) ~= "number" then
        return 0
    end

    local tooltip = self:GetTooltipByType(entry.id, isItem)
    if not tooltip then
        return 0
    end

    local content = self:TableOfContents(tooltip)
    local combinedText = content.onLeftSide .. " " .. content.onRightSide

    local zone = extractZoneName(combinedText)
    if zone and not isPlayerInZone(zone) then
        return 0
    end

    local values = {}
    for _, pattern in ipairs(macroInfo.valuation) do
        for value in combinedText:gmatch(pattern) do
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

-- Processes items or spells for the given macro
local function processEntries(self, macroKey, macroInfo)
    local keywords = macroInfo.keywords or {}
    local matchedEntries = {}

    for _, entryType in ipairs({"item", "spell"}) do
        local entries = entryType == "item" and self.itemCache or self.spellbook

        for _, entry in ipairs(entries or {}) do
            if any(keywords, function(keyword)
                return entry.name:match(keyword)
            end) then
                if not matchedEntries[entry.name] then
                    matchedEntries[entry.name] = true
                    entry.score = self:scoreEntry(entry, entryType == "item", macroInfo)
                    table.insert(macroInfo[entryType == "item" and "items" or "spells"], entry)
                end
            end
        end
    end
end

-- Updates the macro data by processing items and spells
function addon:updateMacroData()
    for macroKey, macroInfo in pairs(self.macroData) do
        processEntries(self, macroKey, macroInfo)
    end
    self:sortMacroData("level")
end

-- Sorts items and spells within macros based on the specified attribute
function addon:sortMacroData(attribute)
    if attribute ~= "score" and attribute ~= "level" then
        return
    end

    for _, macroInfo in pairs(self.macroData) do
        for _, entryType in pairs({"items", "spells"}) do
            if macroInfo[entryType] then
                table.sort(macroInfo[entryType], function(a, b)
                    return a[attribute] < b[attribute]
                end)
            end
        end
    end
end

-- Checks if the player has the best item for the specified macro
function addon:getBestItemForMacro(macroKey)
    local bestItem, bestScore, bestLevel = nil, -1, -1

    if self.macroData[macroKey] then
        for _, item in pairs(self.macroData[macroKey].items) do
            if item.score > bestScore or (item.score == bestScore and item.level > bestLevel) then
                bestItem = item.name
                bestScore = item.score
                bestLevel = item.level
            end
        end
    end

    return bestItem
end
