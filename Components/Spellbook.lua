local addonName, addon = ...

function addon:updateSpelldata()
	-- Initialize the spellbook table
	addon.spellbook = {}

	-- Loop through each spell tab
	for tab = 1, GetNumSpellTabs() do
		-- Retrieve information about the current tab
		local _, _, offset, numSlots = GetSpellTabInfo(tab)

		-- Loop through each slot in the tab
		for slot = offset + 1, offset + numSlots do
			-- Get the name, subtext, and ID of the spell in the current slot
			local spellName, spellSubText, spellID = GetSpellBookItemName(slot, BOOKTYPE_SPELL)

			-- Extract a numerical rank from the subtext, if present; otherwise, use the raw subtext
			local extractedRank = spellSubText:match("%d+")
			local rank = extractedRank and tonumber(extractedRank) or spellSubText

			-- Get the current spell data from the spellbook
			local currentSpell = addon.spellbook[spellName]

			-- Update the spellbook:
			-- If the spell is not already in the spellbook, or if the new rank is numerical and either
			-- replaces a non-numerical rank or is higher than the current numerical rank
			if
				not currentSpell
				or (type(rank) == "number" and (type(currentSpell.rank) ~= "number" or rank > currentSpell.rank))
			then
				addon.spellbook[spellName] = { rank = rank, spellID = spellID }
			end
		end
	end
end
