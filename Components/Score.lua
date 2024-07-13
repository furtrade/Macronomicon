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

-- Scores an item or spell based on its tooltip and macro information
function addon:scoreEntry(entry, byType, macroInfo)
    if not entry.id or type(entry.id) ~= "number" then
        return 0
    end

    local tooltip = self:GetTooltipByType(entry.id, byType)
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

-- Function to get the best item based on score
function addon:getBestItem(t)
    if not t then
        print("Error: items is nil")
        return nil
    end

    local selectedElement = nil
    local highestScore = -math.huge -- Initialize to lowest possible value

    -- Iterate over the elements
    for _, element in ipairs(t) do
        -- Check if the score field is present and numeric
        if element.score and type(element.score) == "number" then
            -- Check if the element's score is higher than the current highest score
            -- and if the count is not present or not equal to 0
            if element.score > highestScore and (not element.count or element.count ~= 0) then
                highestScore = element.score
                selectedElement = element
            end
        end
    end
    return selectedElement
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
