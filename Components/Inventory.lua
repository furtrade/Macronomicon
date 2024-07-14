-- addon.lua
local _, addon = ...

-- Centralized storage for items
addon.itemCache = addon.itemCache or {}
addon.itemLookup = addon.itemLookup or {}

-- Helper function to create or update the lookup table
local function updateLookupTable(item)
    addon.itemLookup[item.name] = item
end

-- Helper function to add or update an item in a table
local function addOrUpdateItem(tbl, item)
    updateLookupTable(item)
    for i, existingItem in ipairs(tbl) do
        if existingItem.name == item.name then
            tbl[i] = item
            return
        end
    end
    table.insert(tbl, item)
end

-- Helper function to set the count of items not present in the lookup to 0
local function setUnmatchedItemsToZero(tbl, matchedItems)
    for _, item in ipairs(tbl) do
        if not matchedItems[item.name] then
            item.count = 0
        end
    end
end

-- Function to get item link
local function getItemLink(bagOrSlotIndex, slotIndex)
    return slotIndex and C_Container.GetContainerItemLink(bagOrSlotIndex, slotIndex) or
               GetInventoryItemLink("player", bagOrSlotIndex)
end

-- Function to extract item information
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
        rank = addon.gameVersion < 4000 and C_Spell.GetSpellSubtext(itemSpellId),
        count = C_Item.GetItemCount(itemID, false, true, false),
        found = true
    }
end

-- Processes items for the given macro
local scoreCache = {}
local function getScore(self, entry, macroInfo)
    local key = entry.name
    if scoreCache[key] then
        return scoreCache[key]
    end
    local score = self:scoreEntry(entry, "item", macroInfo)
    scoreCache[key] = score
    return score
end

local function processEntries(self, macroKey, macroInfo)
    local keywords = macroInfo.keywords or {}
    local matchedEntries = {}

    local entries = self.itemCache
    local macroEntriesKey = "items"

    if not macroInfo[macroEntriesKey] then
        macroInfo[macroEntriesKey] = {}
    end
    local macroEntries = macroInfo[macroEntriesKey]

    for _, entry in ipairs(entries or {}) do
        for _, keyword in ipairs(keywords) do
            if entry.name:match(keyword) then
                if not matchedEntries[entry.name] then
                    matchedEntries[entry.name] = true
                    entry.score = getScore(self, entry, macroInfo)
                    addOrUpdateItem(macroEntries, entry)
                end
                break
            end
        end
    end

    -- Set unmatched items to zero
    setUnmatchedItemsToZero(macroEntries, matchedEntries)
end

-- Updates the item cache
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

    -- Set the count of items not found to 0
    setUnmatchedItemsToZero(cache, foundItems)

    -- Update macros to reflect the current state of the item cache
    self:updateMacroData()
end

-- Function to update macro data
function addon:updateMacroData()
    for macroKey, macroInfo in pairs(self.macroData) do
        processEntries(self, macroKey, macroInfo)
    end
end

