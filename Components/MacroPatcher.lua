local addonName, addon = ...

addon.rules = {
    -- TODO: Add support for switching between shoot and throw in Classic
    known = {
        condition = "[Kk][Nn][Oo][Ww][Nn]:",
        onMatch = function(chunk)
            chunk = chunk:lower()
            local isNoKnown = chunk:lower():find("noknown:") ~= nil
            local condition = isNoKnown and "noknown:" or "known:"

            local spellToCheck = chunk:lower():match(condition .. "([^,%]]+)")
            spellToCheck = spellToCheck:match("^%s*(.-)%s*$")

            local conditionPattern = ",?%s*" .. condition .. "%s*" .. spellToCheck .. "%s*,?"
            local blockPattern = "%[.*" .. condition .. ".*$"

            for _, spell in ipairs(addon.spellbook) do
                if spell.name:lower() == spellToCheck then
                    local newChunk = chunk:gsub(isNoKnown and blockPattern or conditionPattern, ",")
                    return newChunk
                end
            end

            local newChunk = chunk:gsub(isNoKnown and conditionPattern or blockPattern, ",")
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
                    -- break
                end
            end
        end

        -- Reassemble the chunks into a line and insert it into macroLines
        table.insert(macroLines, table.concat(chunks, ";"))
    end

    return addon:formatMacro(table.concat(macroLines, "\n"))
end
