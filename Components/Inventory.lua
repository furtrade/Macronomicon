local _, addon = ...

addon.itemCache = addon.itemCache or {}

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
