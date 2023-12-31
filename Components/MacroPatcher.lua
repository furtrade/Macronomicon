local addonName, addon = ...

addon.rules = {
    -- Define a rule for the "known" condition
    known = {
        condition = "[Kk][Nn][Oo][Ww][Nn]:",
        onMatch = function(line)
            -- Check if "noknown" is the condition
            local isNoKnown = line:match("[Nn][Oo][Kk][Nn][Oo][Ww][Nn]:")
            local condition = isNoKnown and "[Nn][Oo][Kk][Nn][Oo][Ww][Nn]:" or "[Kk][Nn][Oo][Ww][Nn]:"

            -- Extract the spell name from the line
            local spellToCheck = line:match(condition .. "([^,%]]+)")
            -- Trim leading and trailing whitespace
            spellToCheck = spellToCheck:match("^%s*(.-)%s*$"):lower()

            -- Check if the spell name is in addon.spellbook
            for _, spell in ipairs(addon.spellbook) do
                if spell.name:lower() == spellToCheck then
                    if isNoKnown then
                        -- If "no" precedes "known" and the spell name is found, remove the entire condition block
                        local alteredLine = line:gsub("%[[^%]]-" .. condition .. "[^;]*;", "")
                        return alteredLine
                    else
                        -- If "no" does not precede "known" and the spell name is found, remove only the condition and the spell name
                        local alteredLine = line:gsub(",?%s*" .. condition .. "%s*" .. spellToCheck .. "%s*,?", ",")
                        return alteredLine
                    end
                end
            end

            -- If the spell name is not found and "no" precedes "known", remove only the condition
            if isNoKnown then
                local alteredLine = line:gsub(",?%s*" .. condition .. "%s*" .. spellToCheck .. "%s*,?", ",")
                return alteredLine
            end

            -- If the spell name is not found and "no" does not precede "known", remove the entire condition block
            local alteredLine = line:gsub("%[[^%]]-" .. condition .. "[^;]*;", "")
            return alteredLine
        end
    },

    -- Define more rules as needed...
}

function addon:split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function addon:patchMacro(macroInfo)
    if macroInfo.isCustom ~= true then
        print("Error: macroInfo is not a custom macro")
        return
    end

    local superMacro = self.db.profile.macroS[macroInfo.name].superMacro
    local macroLines = {}

    -- Split the super macro into lines
    local superMacroLines = self:split(superMacro, "\n")

    -- Process each line in the super macro
    for _, line in ipairs(superMacroLines) do
        -- Search for special conditions
        for ruleName, rule in pairs(self.rules) do
            if line:lower():find(rule.condition:lower()) then
                -- If a special condition is found, run the corresponding function
                line = rule.onMatch(line)
                break
            end
        end

        table.insert(macroLines, line)
    end

    return addon:formatMacro(table.concat(macroLines, "\n"))
end
