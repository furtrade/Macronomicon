-- ScriptLogic.lua
local _, addon = ...

-- Function to check if a button already exists
function addon:buttonExists(name)
    -- print("Checking if button exists: ", name)
    for _, button in ipairs(addon.spellButtons or {}) do
        if button:GetName() == name then
            -- print("Button found: ", name)
            return true
        end
    end
    -- print("Button does not exist: ", name)
    return false
end

-- Function to create buttons and update state
function addon:processButtons(type, info)
    -- print("Processing button of type: ", type, " with info: ", info.name)
    local name = info.name
    if not self:buttonExists(name) then
        -- print("Button does not exist, creating new button: ", name)
        self:createScriptButton(type, info)
    else
        -- print("Button already exists, updating state: ", name)
    end
    self:updateButtonState(info)
end

-- Function to create a script button
function addon:createScriptButton(type, info)
    -- print("Creating script button of type: ", type, " with info: ", info.name)
    local scriptText = self:buildText(info)
    local buttonData = {
        name = info.name,
        scriptText = scriptText,
        tooltip = info.tooltip or info.name .. " Tooltip",
        icon = info.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    }
    table.insert(self.db.profile.customButtons, buttonData)
    -- print("Script button created: ", buttonData.name)
end

-- Function to update the button state
function addon:updateButtonState(info)
    -- print("Updating button state for: ", info.name)
    local existingButton = self:getButtonByName(info.name)
    if existingButton then
        local newScriptText = self:buildText(info)
        -- print("New script text for button: ", info.name, " is: ", newScriptText)
        if existingButton:GetAttribute("macrotext") ~= newScriptText then
            -- Update the button's script
            -- print("Updating script text for button: ", info.name)
            existingButton:SetAttribute("macrotext", newScriptText)
        end
    else
        -- print("Button not found: ", info.name)
    end
end

-- Function to build the text of a script for the button
function addon:buildText(info)
    -- print("Building text for: ", info.name)
    if not info.items then
        -- print("Error: info.items is nil for", info.name)
        return ""
    end

    local lines = {"#showtooltip"}
    local item = self:getBestItem(info.items)
    if item then
        table.insert(lines, "/cast" .. (info.condition and " [" .. info.condition .. "]" or "") .. " " .. item.name)
    end
    if info.nuance then
        info.nuance(lines)
    end
    local text = self:formatText(table.concat(lines, "\n"))
    -- print("Built text: ", text)
    return text
end

-- Function to format the macro text
function addon:formatText(macro)
    -- print("Formatting macro text")
    local formattedMacro = macro
    local previousMacro

    repeat
        previousMacro = formattedMacro
        formattedMacro = formattedMacro:gsub(",;", ";") -- Remove commas before semicolons
        :gsub(";,", ";") -- Remove commas after semicolons
        :gsub(";+", ";") -- Removes multiple semicolons
        :gsub("%s%s+", " ") -- Remove double spaces
        :gsub(",%s+", ",") -- Remove spaces directly after a comma
        :gsub("%s+$", "") -- Remove spaces at the end of a line
        :gsub("%][ \t]+", "]") -- Remove spaces and tabs after ']'
        :gsub("%[%s+", "[") -- Remove whitespace after '['
        :gsub(",%]", "]") -- Remove a comma immediately before a ']'
        :gsub(";+$", "") -- Remove semicolons at the end of a line
        :gsub("([/#]%w+%s[;,])", function(match)
            return match:sub(1, -2)
        end)
        formattedMacro = formattedMacro:lower() -- Convert to lowercase
    until formattedMacro == previousMacro

    -- print("Formatted macro text: ", formattedMacro)
    return formattedMacro
end

-- Function to get a button by its name
function addon:getButtonByName(name)
    -- print("Getting button by name: ", name)
    for _, button in ipairs(addon.spellButtons or {}) do
        if button:GetName() == name then
            -- print("Button found: ", name)
            return button
        end
    end
    -- print("Button not found: ", name)
    return nil
end

-- Initialize custom scripts
function addon:processCustomScripts()
    -- print("Processing custom scripts")
    for _, macroTypeInfo in pairs(self.macroData) do
        for _, scriptInfo in pairs(macroTypeInfo) do
            -- print("Processing script info: ", scriptInfo.name)
            self:processButtons("custom", scriptInfo)
        end
    end
end

-- Load custom buttons and process scripts on addon load
function addon:LoadCustomButtonScripts()
    -- print("Loading custom button scripts")
    if not self.db then
        -- print("Error: Database is not initialized")
        return
    end
    self:processCustomScripts()
end
