local _, addon = ...

addon.MacroBank = addon.MacroBank or {}

-- Combine real and virtual macros
-- Prepare the data
function addon.MacroBank:GetRealMacros()
    local MacroBankData = {}
    local nameCount = {}

    -- Function to rename duplicate macros
    local function getUniqueName(name)
        if not nameCount[name] then
            nameCount[name] = 0
        end
        nameCount[name] = nameCount[name] + 1
        if nameCount[name] > 1 then
            return name .. "(" .. (nameCount[name] - 1) .. ")"
        else
            return name
        end
    end

    -- Get the number of account macros and character macros
    local numAccountMacros, numCharacterMacros = GetNumMacros()

    -- Iterate over account macros
    for i = 1, numAccountMacros do
        local name, iconTexture, body = GetMacroInfo(i)
        local uniqueName = getUniqueName(name)
        table.insert(MacroBankData, {
            macroType = "account",
            macroID = i,
            name = uniqueName,
            iconID = iconTexture,
            body = body,
            itemType = 1,
            subName = "macro",
            isOffSpec = false,
            isPassive = false
        })
    end

    -- Iterate over character macros
    for i = 121, 120 + numCharacterMacros do
        local name, iconTexture, body = GetMacroInfo(i)
        local uniqueName = getUniqueName(name)
        table.insert(MacroBankData, {
            macroType = "character",
            macroID = i,
            name = uniqueName,
            iconID = iconTexture,
            body = body,
            itemType = 1,
            subName = "macro",
            isOffSpec = false,
            isPassive = false
        })
    end

    return MacroBankData
end

-- Function to traverse addon.macroData and create new macro objects
function addon.MacroBank:GetVirtualMacros()
    local MacroBankData = {}

    for key, value in pairs(addon.macroData) do
        local name = value.name
        local iconID = value.icon
        table.insert(MacroBankData, {
            isVirtual = true,
            -- macroType = "", -- ⚡This should be grabbed from the corresponding real macro
            -- macroID = 0, -- ⚡This should be grabbed from the corresponding real macro
            name = name,
            iconID = iconID, -- 🌩️Preferred over corresponding real macro
            -- body = "", --⚡This should be grabbed from the corresponding real macro
            itemType = 1, -- 🌩️Preferred over corresponding real macro
            subName = "macro", -- 🌩️Preferred over corresponding real macro
            isOffSpec = false, -- 🌩️Preferred over corresponding real macro
            isPassive = false -- 🌩️Preferred over corresponding real macro
        })
    end

    return MacroBankData
end

-- Function to merge macros and store the result in a sorted, indexed table
function addon.MacroBank:MergeMacros()
    -- Get data from both functions
    local realMacros = self:GetRealMacros()
    local virtualMacros = self:GetVirtualMacros()

    -- Create a combined table to store merged macro data
    local combinedMacros = {}

    -- Create a lookup table for real macros by name for quick access
    local realMacroLookup = {}
    for _, realMacro in ipairs(realMacros) do
        realMacroLookup[realMacro.name] = realMacro
    end

    -- Add all virtual macros, merging with real macros if they exist
    for _, virtualMacro in ipairs(virtualMacros) do
        local realMacroName = "!" .. virtualMacro.name
        local realMacro = realMacroLookup[realMacroName]
        if realMacro then
            -- Apply special rules for the matched macro
            table.insert(combinedMacros, {
                isVirtual = true,
                macroType = realMacro.macroType,
                macroID = realMacro.macroID,
                name = virtualMacro.name,
                iconID = virtualMacro.iconID, -- Preferred over corresponding real macro
                body = realMacro.body,
                itemType = virtualMacro.itemType, -- Preferred over corresponding real macro
                subName = virtualMacro.subName, -- Preferred over corresponding real macro
                isOffSpec = virtualMacro.isOffSpec, -- Preferred over corresponding real macro
                isPassive = virtualMacro.isPassive -- Preferred over corresponding real macro
            })
            -- Remove the real macro from the lookup to prevent it from being added again
            realMacroLookup[realMacroName] = nil
        else
            -- Add virtual macro as is if no corresponding real macro
            table.insert(combinedMacros, virtualMacro)
        end
    end

    -- Add any remaining real macros that don't have a virtual counterpart
    for realMacroName, realMacro in pairs(realMacroLookup) do
        table.insert(combinedMacros, realMacro)
    end

    -- Sort the combined table first by isVirtual, then alphabetically by name
    table.sort(combinedMacros, function(a, b)
        if a.isVirtual ~= b.isVirtual then
            return a.isVirtual and not b.isVirtual
        end
        return a.name < b.name
    end)

    self.combinedMacroList = combinedMacros
end

-- Function to retrieve the macroID by index
function addon.MacroBank:GetMacroIDForSlot(slotIndex)
    if not self.combinedMacroList then
        self:MergeMacros()
    end

    local macro = self.combinedMacroList[slotIndex]
    if macro then
        return macro.macroID
    else
        return nil
    end
end

-- Function to retrieve the macro data by index
function addon.MacroBank:GetMacroInfoPlus(slotIndex)
    if not self.combinedMacroList then
        self:MergeMacros()
    end

    local macro = self.combinedMacroList[slotIndex]
    if macro then
        return macro
    else
        return nil
    end
end

-- Function to get the number of entries in the combined macro list
function addon.MacroBank:GetMacroCount()
    if not self.combinedMacroList then
        self:MergeMacros()
    end

    return #self.combinedMacroList
end
