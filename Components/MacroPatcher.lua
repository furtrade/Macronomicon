local addonName, addon = ...

addon.rules = {
    -- TODO: Add support for switching between shoot and throw in Classic
    known = {
        condition = "[Kk][Nn][Oo][Ww][Nn]:",
        onMatch = function(chunk)
            -- Example1: /cast [known:Throw] Throw
            -- Example2: /cast [noknown:Throw] Shoot
            -- Check if "noknown" is the condition
            local isNoKnown = chunk:match("[Nn][Oo][Kk][Nn][Oo][Ww][Nn]:")
            local condition = isNoKnown and "[Nn][Oo][Kk][Nn][Oo][Ww][Nn]:" or "[Kk][Nn][Oo][Ww][Nn]:"

            -- Extract the spell name from the line
            local spellToCheck = chunk:match(condition .. "([^,%]]+)")
            -- Trim leading and trailing whitespace
            spellToCheck = spellToCheck:match("^%s*(.-)%s*$"):lower()

            -- Check if the spell name is in addon.spellbook
            for _, spell in ipairs(addon.spellbook) do
                if spell.name:lower() == spellToCheck then
                    if isNoKnown then
                        -- If "noknown" and the spell is found, remove the entire condition block
                        -- Example1: /cast [known:Throw] Throw NOT APPLICABLE (INCORRECT CONDITION)
                        -- Example2: /cast [noknown:Throw] Shoot CHANGED TO /cast  REMOVED ENTIRE CONDITION BLOCK
                        local newChunk = chunk:gsub("%[.*" .. condition .. ".*$", "") -- ENTIRE BLOCK REMOVED
                        return newChunk
                    else
                        -- If "known" and the spell name is found, remove only the condition and the spell name
                        -- Example1: /cast [known:Throw] Throw CHANGED TO /cast Throw CONDITION REMOVED
                        -- Example2: /cast [noknown:Throw] Shoot NOT APPLICABLE (INCORRECT CONDITION)
                        local newChunk = chunk:gsub(",?%s*" .. condition .. "%s*" .. spellToCheck .. "%s*,?", ",") -- CONDITION REMOVED
                        return newChunk
                    end
                end
            end

            if isNoKnown then
                -- If "noknown" and the spell name is not found, remove only the condition
                -- Example1: /cast [known:Throw] Throw NOT APPLICABLE (INCORRECT CONDITION)
                -- Example2: /cast [noknown:Throw] Shoot CHANGED TO /cast Shoot CONDITION REMOVED
                local newChunk = chunk:gsub(",?%s*" .. condition .. "%s*" .. spellToCheck .. "%s*,?", ",") -- CONDITION REMOVED
                return newChunk
            end

            -- If "known" and the spell name is not found, remove the entire condition block
            -- Example1: /cast [known:Throw] Throw CHANGED TO /cast  REMOVED ENTIRE CONDITION BLOCK
            -- Example2: /cast [noknown:Throw] Shoot NOT APPLICABLE (INCORRECT CONDITION)
            local newChunk = chunk:gsub("%[.*" .. condition .. ".*$", "") -- ENTIRE BLOCK REMOVED
            return newChunk
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
        -- Split the line into chunks
        local chunks = self:split(line, ";")

        -- Process each chunk in the line
        for i, chunk in ipairs(chunks) do
            -- Search for special conditions
            for ruleName, rule in pairs(self.rules) do
                if chunk:lower():find(rule.condition:lower()) then
                    -- If a special condition is found, run the corresponding function
                    chunks[i] = rule.onMatch(chunk)
                    break
                end
            end
        end

        -- Reassemble the chunks into a line and insert it into macroLines
        table.insert(macroLines, table.concat(chunks, ";"))
    end

    return addon:formatMacro(table.concat(macroLines, "\n"))
end
