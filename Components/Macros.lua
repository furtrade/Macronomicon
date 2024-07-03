-- Macros.lua
-- A file for managing creation or updating of macros within the addon
local _, addon = ...

-- Checks if a macro is enabled in the addon's settings
function addon:isMacroEnabled(key)
    if not self.db then
        print("Error: Database is not initialized")
        return false
    end

    local setting = self.db.profile.macroS[key]
    if not setting or setting.toggleOption == nil then
        print("Error: Macro key does not exist in the profile")
        return false
    end

    return setting.toggleOption
end

-- Constructs the full macro name with a prefix
function addon:getMacroName(name)
    return "!" .. name -- Prefix is configurable if needed
end

-- Standardizes a given text by removing white spaces and limiting length
function addon:standardizeName(text)
    return text:gsub("%s+", ""):sub(1, 14)
end

-- Checks if a macro already exists by name
function addon:macroExists(name)
    return self:getMacroIDByName(name) ~= nil
end

-- Gets the macro ID by name
function addon:getMacroIDByName(name)
    print("searching for: ", name)
    local searchName = self:getMacroName(name)
    for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        local macroSearch = GetMacroInfo(i)
        if macroSearch == searchName or macroSearch == name then
            print("matched ", macroSearch, " with ", name, " at index: ", i)
            return i
        end
    end
    return nil
end

-- Creates a new macro in the game
function addon:createMacro(info)
    local perCharacter = false -- Always create in the general tab
    local id = CreateMacro(self:getMacroName(info.name), info.icon or "INV_Misc_QuestionMark", info.macroText,
        perCharacter)

    return id
end

-- Deletes a game macro by name
function addon:deleteMacro(name)
    local macroID = self:getMacroIDByName(name)
    if macroID then
        DeleteMacro(macroID)
    end
end

-- Formats a macro string for consistency
function addon:formatMacro(macro)
    local formatted = macro
    repeat
        macro = formatted
        formatted = formatted:gsub(",;", ";"):gsub(";,", ";"):gsub(";+", ";"):gsub("%s%s+", " "):gsub(",%s+", ","):gsub(
            "%s+$", ""):gsub("%][ \t]+", "]"):gsub("%[%s+", "["):gsub(",%]", "]"):gsub(";+$", ""):gsub(
            "([/#]%w+%s[;,])", function(match)
                return match:sub(1, -2)
            end):lower()
    until formatted == macro
    return formatted
end

-- Retrieves user-made macros from the database and inserts them into the existing macroData table
function addon:loadCustomMacros()
    for header, info in pairs(self.db.profile.macroS) do
        if type(info) == "table" and info.isCustom then
            self.macroData[header] = info
        end
    end
end

-- Updates a macro with new information
function addon:updateMacro(info, id)
    local macroID = id or self:getMacroIDByName(info.name)
    local macroString = info.isCustom and self:patchMacro(info) or self:buildMacroString(info)
    EditMacro(macroID, self:getMacroName(info.name), info.icon, macroString)

    return macroID
end

-- Processes macros from the provided macro tables
function addon:processMacros()
    self:loadCustomMacros()

    for header, info in pairs(self.macroData) do
        self:updateMacro(info)
    end
end

-- Builds the macro string from the provided macro information
function addon:buildMacroString(info)
    local lines = {"#showtooltip"}

    local item = self:getBestItem(info.items)
    if item then
        local condition = info.condition and " [" .. info.condition .. "]" or ""
        table.insert(lines, "/cast" .. condition .. " " .. item.name)
    end

    if info.nuance and type(info.nuance) == "function" then
        info.nuance(lines)
    end

    return self:formatMacro(table.concat(lines, "\n"))
end
