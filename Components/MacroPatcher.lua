local addonName, addon = ...

-- TODO: this belongs in Macros.lua
--=============================================================================
function addon:getCustomMacrosFromDB()
    -- print("starting up getCustomMacrosFromDB")
    -- Initialize an empty table for the custom macros
    local customMacros = {}

    -- Iterate over all the keys in the profile
    for macroKey, macroValue in pairs(self.db.profile.macroS) do
        -- Check if the key is a macro
        if type(macroValue) == "table" and macroValue.isCustom == true then
            -- If it is, add it to the customMacros table
            -- print("getting macroKey: ", macroKey)
            customMacros[macroKey] = macroValue
        end
    end

    -- print("handing keys to loadCustomMacros function")
    return customMacros
end

function addon:loadCustomMacros()
    -- Get the custom macros from the addon's database
    local customMacros = self:getCustomMacrosFromDB()

    -- Add the custom macros to the macroData.CUSTOM table
    self.macroData.CUSTOM = customMacros
end

function addon:updateMacro(macroInfo)
    local macroString
    if macroInfo.isCustom == true then
        -- If it's a custom macro, get the string from the super macro
        macroString = self:patchMacro(macroInfo)
    else
        -- Otherwise, build the macro string as normal
        macroString = self:buildMacroString(macroInfo)
    end

    local macroName = self:getMacroName(macroInfo.name)
    EditMacro(macroName, macroName, macroInfo.icon, macroString)
end

function addon:ProcessMacros(macroTables)
    self:loadCustomMacros()

    macroTables = macroTables or addon.macroData

    for macroType, macroTypeData in pairs(macroTables) do
        for macroKey, macroInfo in pairs(macroTypeData) do
            -- print("macroKey: ", macroKey)
            if self:isMacroEnabled(macroKey) then
                self:createOrUpdateMacro(macroType, macroInfo)
            end
        end
    end
end

--=============================================================================

--[[ function addon:PatchMacros()
    local customMacros = addon.customMacros

    for macroKey, macroInfo in pairs(customMacros) do
        if self:isMacroEnabled(macroKey) then
            self:createOrUpdateMacro(macroType, macroInfo)
        end
    end
end ]]

addon.rules = {
    -- Define a rule for the "known" condition
    known = {
        condition = "[Kk][Nn][Oo][Ww][Nn]:",
        onMatch = function(line)
            -- Extract the spell name from the line
            local spellToCheck = line:match("[Kk][Nn][Oo][Ww][Nn]:([^,%]]+)")
            -- Trim leading and trailing whitespace
            spellToCheck = spellToCheck:match("^%s*(.-)%s*$"):lower()

            -- Check if the spell name is in addon.spellbook
            for _, spell in ipairs(addon.spellbook) do
                if spell.name:lower() == spellToCheck then
                    -- If the spell name is found, remove only the condition and the spell name
                    local alteredLine = line:gsub(",?%s*[Kk][Nn][Oo][Ww][Nn]:%s*" .. spellToCheck .. "%s*,?", ",")
                    return alteredLine
                end
            end

            -- If the spell name is not found, remove the entire condition block
            local alteredLine = line:gsub("%[[^%]]-[Kk][Nn][Oo][Ww][Nn]:[^;]*;", "")
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
