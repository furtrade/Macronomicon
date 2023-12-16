-- scan bags for items we can use
local addonName, addon = ...

-- Create an item object from a bag or inventory slot.
local function itemizer(dollOrBagIndex, slotIndex)
	local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex)
		or GetInventoryItemLink("player", dollOrBagIndex)

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
				itemInfo.spellName = itemSpell
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

-- helper function to sort items by type, e.g. health pots, mana pots, food, etc.
local function sortTableByLevel(items)
	table.sort(items, function(a, b)
		if a.level and b.level then
			return a.level > b.level
		elseif a.level then
			return true
		elseif b.level then
			return false
		else
			return false
		end
	end)
end

-- Process items and update macroData
local function processItems()
	-- send items to the macros tables
	if addon.itemCache then
		for _, v in pairs(addon.macroData) do
			if v.items then
				-- sort items by level.
				sortTableByLevel(v.items)
				-- search itemCache for keyword matches from macroData
				-- if match found, add to v.items
				addon:matchMaker(addon.itemCache, v.items, v.keywords)
			end
		end
	end
end

-- Scans bags and inventory for items we want to use
-- and adds them to our itemCache.
function addon:updateItemCache()
	addon.itemCache = {}
	addon.resetMacroData()

	-- inventory
	for bagOrSlotIndex = 1, 19 do
		local itemInfo = itemizer(bagOrSlotIndex)

		if itemInfo then
			table.insert(addon.itemCache, itemInfo)
		end
	end

	-- bags
	local numBags = Constants.InventoryConstants.NumBagSlots
	for bagOrSlotIndex = 0, numBags do
		local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex)
		if numSlots > 0 then
			for slotIndex = 1, numSlots do
				local itemInfo = itemizer(bagOrSlotIndex, slotIndex)

				if itemInfo then
					table.insert(addon.itemCache, itemInfo)
				end
			end
		end
	end

	-- call the processItems function
	processItems()
end
