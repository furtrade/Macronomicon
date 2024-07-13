local _, addon = ...

addon.itemCache = addon.itemCache or {}

-- Helper function to check if an item exists in a table by its name
local function itemExists(tbl, itemName)
    for _, item in ipairs(tbl) do
        if item.name == itemName then
            return true
        end
    end
    return false
end

-- Helper function to add an item to a table if it doesn't already exist
local function addItemIfNotExists(tbl, item)
    if not itemExists(tbl, item.name) then
        table.insert(tbl, item)
        return true
    end
    return false
end

-- Helper function to remove an item from a table by its name
local function removeItem(tbl, itemName)
    for i = #tbl, 1, -1 do
        if tbl[i].name == itemName then
            table.remove(tbl, i)
            return true
        end
    end
    return false
end

-- Processes items or spells for the given macro
local scoreCache = {}
local function getScore(self, entry, entryType, macroInfo)
    local key = entry.name .. entryType
    if scoreCache[key] then
        return scoreCache[key]
    end
    local score = self:scoreEntry(entry, entryType, macroInfo)
    scoreCache[key] = score
    return score
end

local function processEntries(self, macroKey, macroInfo)
    local keywords = macroInfo.keywords or {}
    local matchedEntries = {}

    for _, entryType in ipairs({"item", "spell"}) do
        local entries = entryType == "item" and self.itemCache or self.spellbook
        local macroEntriesKey = entryType == "item" and "items" or "spells"

        if not macroInfo[macroEntriesKey] then
            macroInfo[macroEntriesKey] = {}
        end
        local macroEntries = macroInfo[macroEntriesKey]

        for _, entry in ipairs(entries or {}) do
            for _, keyword in ipairs(keywords) do
                if entry.name:match(keyword) then
                    if not matchedEntries[entry.name] then
                        matchedEntries[entry.name] = true
                        entry.score = getScore(self, entry, entryType, macroInfo)
                        addItemIfNotExists(macroEntries, entry)
                    end
                    break
                end
            end
        end

        -- Remove items that are no longer matched
        for i = #macroEntries, 1, -1 do
            if not matchedEntries[macroEntries[i].name] then
                table.remove(macroEntries, i)
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
            local entries = macroInfo[entryType]
            if entries then
                table.sort(entries, function(a, b)
                    return a[attribute] < b[attribute]
                end)
            end
        end
    end
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

local function getItemLink(bagOrSlotIndex, slotIndex)
    return slotIndex and C_Container.GetContainerItemLink(bagOrSlotIndex, slotIndex) or
               GetInventoryItemLink("player", bagOrSlotIndex)
end

local function itemizer(bagOrSlotIndex, slotIndex)
    local itemLink = getItemLink(bagOrSlotIndex, slotIndex)
    if not itemLink then
        return nil
    end

    local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
    if not itemID then
        return nil
    end

    local canUse = C_PlayerInfo.CanUseItem(itemID)
    local itemSpell, itemSpellId = C_Item.GetItemSpell(itemID)
    if not (canUse and itemSpell) then
        return nil
    end

    local itemLevel, _, itemType, itemSubType, _, equipLoc = select(4, C_Item.GetItemInfo(itemID))

    return {
        id = itemID,
        link = itemLink,
        name = C_Item.GetItemNameByID(itemID),
        level = itemLevel,
        itemType = itemType,
        subType = itemSubType,
        equipLoc = equipLoc,
        spellName = itemSpell,
        spellId = itemSpellId,
        rank = C_Spell.GetSpellSubtext(itemSpellId),
        count = C_Item.GetItemCount(itemID, false, true, false),
        found = true
    }
end

local function addItemToCache(bagOrSlotIndex, slotIndex)
    local itemLink = getItemLink(bagOrSlotIndex, slotIndex)
    if not itemLink then
        return
    end

    local cache = addon.itemCache
    local itemInfo = itemizer(bagOrSlotIndex, slotIndex)
    if itemInfo then
        removeItem(cache, itemInfo.name) -- Remove the existing item first
        table.insert(cache, itemInfo)
    end
end

function addon:UpdateItemCache()
    local cache = addon.itemCache
    local foundItems = {}

    -- Update equipped items
    for bagOrSlotIndex = 1, 19 do
        local itemInfo = itemizer(bagOrSlotIndex)
        if itemInfo then
            foundItems[itemInfo.name] = true
            addItemToCache(bagOrSlotIndex)
        end
    end

    -- Update bag items
    for bagOrSlotIndex = 0, Constants.InventoryConstants.NumBagSlots do
        local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex)
        for slotIndex = 1, numSlots do
            local itemInfo = itemizer(bagOrSlotIndex, slotIndex)
            if itemInfo then
                foundItems[itemInfo.name] = true
                addItemToCache(bagOrSlotIndex, slotIndex)
            end
        end
    end

    -- Remove items from the cache that were not found
    for i = #cache, 1, -1 do
        if not foundItems[cache[i].name] then
            table.remove(cache, i)
        end
    end
end
