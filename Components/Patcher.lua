local addonName, addon = ...

-- TODO: this belongs in Macros.lua
--=============================================================================
function addon:getCustomMacrosFromDB()
    -- Initialize an empty table for the custom macros
    local customMacros = {}

    -- Iterate over all the keys in the profile
    for macroKey, macroValue in pairs(self.db.profile) do
        -- Check if the key is a custom macro
        if macroKey:find("CUSTOM_") == 1 then
            -- If it is, add it to the customMacros table
            customMacros[macroKey] = macroValue
        end
    end

    return customMacros
end

function addon:loadCustomMacros()
    -- Get the custom macros from the addon's database
    local customMacros = self:getCustomMacrosFromDB()

    -- Add the custom macros to the macroData.CUSTOM table
    self.macroData.CUSTOM = customMacros
end

function addon:updateMacro(macroName, macroInfo)
    local macroString
    if macroInfo.type == "custom" then
        -- If it's a custom macro, get the string from the super macro
        macroString = self:patchMacro(macroInfo.superMacro)
    else
        -- Otherwise, build the macro string as normal
        macroString = self:buildMacroString(macroInfo)
    end
    EditMacro(macroName, macroName, macroInfo.icon, macroString)
end

function addon:ProcessMacros(macroTables)
    self:loadCustomMacros()

    macroTables = macroTables or addon.macroData

    for macroType, macroTypeData in pairs(macroTables) do
        for _, macroInfo in pairs(macroTypeData) do
            if self:isMacroEnabled(macroInfo.enabled) then
                self:createOrUpdateMacro(macroType, macroInfo)
            end
        end
    end
end

--=============================================================================

function addon:PatchMacros()
    local customMacros = addon.customMacros

    for _, macroInfo in pairs(customMacros) do
        if self:isMacroEnabled(macroInfo.enabled) then
            self:createOrUpdateMacro(macroType, macroInfo)
        end
    end
end

addon.rules = {
    -- Define a rule for the "known" condition
    known = {
        condition = "known:",
        onMatch = function(line)
            -- Perform some manipulations on the line and return the new line
            -- This is just a placeholder. Replace it with your actual implementation.
        end
    },

    -- Define more rules as needed...
}

function addon:patchMacro(superMacro)
    local macroLines = {}

    -- Split the super macro into lines
    local superMacroLines = self:split(superMacro, "\n")

    -- Process each line in the super macro
    for _, line in ipairs(superMacroLines) do
        -- Search for special conditions
        for ruleName, rule in pairs(self.rules) do
            if line:find(rule.condition) then
                -- If a special condition is found, run the corresponding function
                line = rule.onMatch(line)
                break
            end
        end

        table.insert(macroLines, line)
    end

    return table.concat(macroLines, "\n")
end
