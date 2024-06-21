local addonName, addon = ...

-- addon.itemCache = addon.itemCache or {}

local function getItemLink(bagOrSlotIndex, slotIndex)
    return slotIndex and C_Container.GetContainerItemLink(bagOrSlotIndex, slotIndex)
           or GetInventoryItemLink("player", bagOrSlotIndex)
end

local function itemizer(bagOrSlotIndex, slotIndex)
    local itemLink = getItemLink(bagOrSlotIndex, slotIndex)
    if not itemLink then return nil end

    local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
    if not itemID then return nil end

    local canUse = C_PlayerInfo.CanUseItem(itemID)
    local itemSpell, itemSpellId = GetItemSpell(itemID)
    if not (canUse and itemSpell) then return nil end

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
        reviewed = true
    }
end

local function addItemToCache(bagOrSlotIndex, slotIndex)
    local itemLink = getItemLink(bagOrSlotIndex, slotIndex)
    if not itemLink then return end

    for _, cachedItem in ipairs(addon.itemCache) do
        if cachedItem.link == itemLink then
            cachedItem.count = GetItemCount(cachedItem.id)
            cachedItem.reviewed = true
            return
        end
    end

    local itemInfo = itemizer(bagOrSlotIndex, slotIndex)
    if itemInfo then
        table.insert(addon.itemCache, itemInfo)
    end
end

function addon:UpdateItemCache()
    for _, item in ipairs(addon.itemCache) do
        item.reviewed = false
    end

    for bagOrSlotIndex = 1, 19 do
        addItemToCache(bagOrSlotIndex)
    end

    for bagOrSlotIndex = 0, Constants.InventoryConstants.NumBagSlots do
        local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex)
        for slotIndex = 1, numSlots do
            addItemToCache(bagOrSlotIndex, slotIndex)
        end
    end

    for i = #addon.itemCache, 1, -1 do
        if not addon.itemCache[i].reviewed then
            table.remove(addon.itemCache, i)
        end
    end
end
