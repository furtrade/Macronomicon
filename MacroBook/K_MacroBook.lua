local _, addon = ...
-- Initialize K_MacroBook globally if it doesn't already exist
K_MacroBook = K_MacroBook or {}

-- ❄️C_SpellBook.IsSpellBookItemPassive(slotIndex, spellBank)
function K_MacroBook.IsSpellBookItemPassive(slotIndex)
    return false
end

function K_MacroBook.GetSpellBookSkillLineInfo(macroEnum)
    local name, numMacros, indexOffset, iconID = "", 0, 0, 0

    -- Ensure the combinedMacroList is populated
    if not addon.MacroBank.combinedMacroList then
        addon.MacroBank:MergeMacros()
    end

    local combinedMacroList = addon.MacroBank.combinedMacroList

    -- Define search criteria functions
    local searchCriteria
    if macroEnum == 1 then
        name = "Mutating"
        searchCriteria = function(macro)
            return macro.isVirtual
        end
        iconID = 12345 -- Example icon ID for Mutating
    elseif macroEnum == 2 then
        name = "Assorted"
        searchCriteria = function(macro)
            return not macro.isVirtual
        end
        iconID = 67890 -- Example icon ID for Misc
    else
        return nil -- Return nil if the macroEnum is invalid
    end

    -- Iterate through the combinedMacroList to find the indexOffset and count relevant macros
    for index, macro in ipairs(combinedMacroList) do
        if searchCriteria(macro) then
            if numMacros == 0 then
                indexOffset = index - 1 -- Set indexOffset to the first matching macro's index
            end
            numMacros = numMacros + 1
        end
    end

    local skillLineInfo = {
        name = name,
        numSpellBookItems = numMacros,
        itemIndexOffset = indexOffset,
        iconID = iconID,
        shouldHide = false,
        isGuild = false
    }

    return skillLineInfo
end

