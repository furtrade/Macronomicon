-- scan bags for items we can use
local addonName, addon = ...

local function removeDuplicateItems()
	local seenNames = {}
	for i = #addon.itemCache, 1, -1 do
		local itemName = addon.itemCache[i].name
		if seenNames[itemName] then
			print("Removing ", addon.itemCache[i].link,
				" because it is a duplicate.")
			table.remove(addon.itemCache, i)
		else
			seenNames[itemName] = true
		end
	end
end

-- Create an item object from a bag or inventory slot.
local function getItemLink(bagOrSlotIndex, slotIndex)
	local itemLink = slotIndex and C_Container.GetContainerItemLink(bagOrSlotIndex, slotIndex)
		or GetInventoryItemLink("player", bagOrSlotIndex)
	return itemLink
end

local function itemizer(bagOrSlotIndex, slotIndex)
	local itemLink = getItemLink(bagOrSlotIndex, slotIndex)

	if itemLink then
		-- Check if the item can be used
		local itemID = tonumber(string.match(itemLink, "item:(%d+):"))
		if itemID then
			local canUse = C_PlayerInfo.CanUseItem(itemID)

			-- Get item type and subtype and equipSlotLocation
			local itemLevel, _, itemType, itemSubType, _, equipLoc = select(4, GetItemInfo(itemID))

			-- does the item have a spell associated with it?
			local itemSpell, itemSpellId = GetItemSpell(itemID)

			--Bundle the item info
			if canUse and itemSpell then
				local itemInfo = {}
				-- usual stuff
				itemInfo.id = itemID
				itemInfo.link = itemLink
				itemInfo.name = C_Item.GetItemNameByID(itemID)
				itemInfo.level = itemLevel
				itemInfo.type = itemType
				itemInfo.subType = itemSubType
				itemInfo.equipLoc = equipLoc
				itemInfo.spellName = itemSpell -- more reliable than the actual item name.
				itemInfo.spellId = itemSpellId
				itemInfo.rank = GetSpellSubtext(itemSpellId)
				local count = GetItemCount(itemID)
				itemInfo.count = count

				-- trying to get the rank of the spell of the item.
				-- I think "rank" is really just a feature of classic wow.
				-- Might not be a good idea to use this.
				-- TODO: figure out a better method of measuring the "bigness" of an item.
				if itemSpellId then
					local rank = GetSpellSubtext(itemSpellId)
					itemInfo.rank = rank and tonumber(rank:match("%d+")) or rank
				end

				return itemInfo
			end
		end
	end
end

function addon:UpdateItemCache()
	-- Mark all items in the cache as not reviewed
	for _, item in ipairs(addon.itemCache) do
		item.reviewed = false
	end

	local function addItemToCache(bagOrSlotIndex, slotIndex)
		local itemLink = getItemLink(bagOrSlotIndex, slotIndex)

		for _, cachedItem in ipairs(addon.itemCache) do
			-- if the item is cached already, update the count
			if cachedItem.link == itemLink then
				cachedItem.count = GetItemCount(cachedItem.id)
				cachedItem.reviewed = true
				return
			end
		end
		-- if the item is not cached, use itemizer to get the itemInfo.
		-- Once we have the itemInfo, we can mark it as reviewed and cache it.
		local itemInfo = itemizer(bagOrSlotIndex, slotIndex)

		if itemInfo then
			-- addItemToCache(itemInfo)
			itemInfo.reviewed = true
			table.insert(addon.itemCache, itemInfo)
		end
	end

	-- inventory
	for bagOrSlotIndex = 1, 19 do
		addItemToCache(bagOrSlotIndex)
	end

	-- bags
	local numBags = Constants.InventoryConstants.NumBagSlots
	for bagOrSlotIndex = 0, numBags do
		local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex)
		if numSlots > 0 then
			for slotIndex = 1, numSlots do
				addItemToCache(bagOrSlotIndex, slotIndex)
			end
		end
	end

	-- Remove items from the cache that were not reviewed
	removeDuplicateItems()
end
