local _, addon = ...

addon.itemCache = addon.itemCache or {}

-- Function to get the best item based on score
function addon:getBestItem(items)
    local best, highScore = nil, -math.huge
    for _, item in ipairs(items) do
        if item.score and item.score > highScore and (not item.count or item.count ~= 0) then
            best, highScore = item, item.score
        end
    end
    return best
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
    local itemSpell, itemSpellId = GetItemSpell(itemID)
    if not (canUse and itemSpell) then
        return nil
    end

    local itemLevel, _, itemType, itemSubType, _, equipLoc = select(4, GetItemInfo(itemID))

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
        rank = GetSpellSubtext(itemSpellId),
        count = GetItemCount(itemID),
        found = true
    }
end

local function addItemToCache(bagOrSlotIndex, slotIndex)
    local itemLink = getItemLink(bagOrSlotIndex, slotIndex)
    if not itemLink then
        return
    end

    local cache = addon.itemCache
    for i = 1, #cache do
        local cachedItem = cache[i]
        if cachedItem.link == itemLink then
            cachedItem.count = GetItemCount(cachedItem.id)
            cachedItem.found = true
            return
        end
    end

    local itemInfo = itemizer(bagOrSlotIndex, slotIndex)
    if itemInfo then
        table.insert(cache, itemInfo)
    end
end

function addon:UpdateItemCache()
    local cache = addon.itemCache

    -- Mark all items in the cache as not found
    for i = 1, #cache do
        cache[i].found = false
    end

    -- Update equipped items
    for bagOrSlotIndex = 1, 19 do
        addItemToCache(bagOrSlotIndex)
    end

    -- Update bag items
    local GetContainerNumSlots = C_Container.GetContainerNumSlots
    for bagOrSlotIndex = 0, Constants.InventoryConstants.NumBagSlots do
        local numSlots = GetContainerNumSlots(bagOrSlotIndex)
        for slotIndex = 1, numSlots do
            addItemToCache(bagOrSlotIndex, slotIndex)
        end
    end

    -- Remove items from the cache that were not found
    for i = #cache, 1, -1 do
        if not cache[i].found then
            table.remove(cache, i)
        end
    end
end
