local _, addon = ...

addon.itemCache = addon.itemCache or {}

-- Helper function to create a lookup table for quick existence checks
local function createLookupTable(tbl)
    local lookup = {}
    for _, item in ipairs(tbl) do
        lookup[item.name] = item
    end
    return lookup
end

-- Helper function to add or update an item in a table
local function addOrUpdateItem(tbl, item)
    local lookup = createLookupTable(tbl)
    if lookup[item.name] then
        for i, existingItem in ipairs(tbl) do
            if existingItem.name == item.name then
                tbl[i] = item
                return
            end
        end
    else
        table.insert(tbl, item)
    end
end

-- Helper function to remove items not present in the lookup
local function removeUnmatchedItems(tbl, matchedItems)
    for i = #tbl, 1, -1 do
        if not matchedItems[tbl[i].name] then
            table.remove(tbl, i)
        end
    end
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
                        addOrUpdateItem(macroEntries, entry)
                    end
                    break
                end
            end
        end

        -- Remove items that are no longer matched
        removeUnmatchedItems(macroEntries, matchedEntries)
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

function addon:UpdateItemCache()
    local cache = addon.itemCache
    local foundItems = {}

    -- Update equipped items
    for bagOrSlotIndex = 1, 19 do
        local itemInfo = itemizer(bagOrSlotIndex)
        if itemInfo then
            foundItems[itemInfo.name] = true
            addOrUpdateItem(cache, itemInfo)
        end
    end

    -- Update bag items
    for bagOrSlotIndex = 0, Constants.InventoryConstants.NumBagSlots do
        local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex)
        for slotIndex = 1, numSlots do
            local itemInfo = itemizer(bagOrSlotIndex, slotIndex)
            if itemInfo then
                foundItems[itemInfo.name] = true
                addOrUpdateItem(cache, itemInfo)
            end
        end
    end

    -- Remove items from the cache that were not found
    removeUnmatchedItems(cache, foundItems)
end
