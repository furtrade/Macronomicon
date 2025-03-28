local _, addon = ...

function addon:UpdateSpellbook()
    addon.spellbook = {}

    -- Loop through each spell tab
    for tab = 1, GetNumSpellTabs() do
        local _, _, offset, numSlots = GetSpellTabInfo(tab)

        -- Loop through each slot in the tab
        for slot = offset + 1, offset + numSlots do
            local spellName, spellSubText, spellID = GetSpellBookItemName(slot, BOOKTYPE_SPELL)

            -- Check if spellSubText is not nil before trying to use it
            if spellSubText then
                -- Extract a numerical rank from the subtext, if present; otherwise, use the raw subtext
                local extractedRank = spellSubText:match("%d+")
                local rank = extractedRank and tonumber(extractedRank) or spellSubText
            else
                -- Handle the case where spellSubText is nil
                local rank = 0
            end

            -- Check if the spell already exists in the spellbook
            local spellExists = false
            for _, spell in ipairs(addon.spellbook) do
                if spell.spellID == spellID then
                    -- Update rank if the new rank is higher
                    if type(rank) == "number" and type(spell.rank) == "number" and rank > spell.rank then
                        spell.rank = rank
                    end
                    spellExists = true
                    break
                end
            end

            -- Add new spell if it doesn't exist
            if not spellExists then
                table.insert(addon.spellbook, {
                    name = spellName,
                    rank = rank,
                    spellID = spellID
                })
            end
        end
    end
end
