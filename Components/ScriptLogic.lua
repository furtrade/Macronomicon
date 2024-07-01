local _, addon = ...

-- Function to check if a button already exists
function addon:buttonExists(name)
    for _, button in ipairs(addon.spellButtons or {}) do
        if button:GetName() == name then
            return true
        end
    end
    return false
end

-- Function to create buttons and update state
function addon:processButtons(type, info)
    local name = info.name
    if not self:buttonExists(name) then
        self:createScriptButton(type, info)
    end
    -- The button exists, so we update state
    self:updateButtonState(info)
end

-- Function to create a script button
function addon:createScriptButton(type, info)
    local scriptText = self:buildText(info)
    local buttonData = {
        name = info.name,
        scriptText = scriptText,
        tooltip = info.tooltip or "Custom Script Button",
        icon = info.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    }
    table.insert(self.db.profile.customButtons, buttonData)
end

-- Function to update the button state
function addon:updateButtonState(info)
    local existingButton = self:getButtonByName(info.name)
    if existingButton then
        local newScriptText = self:buildText(info)
        if existingButton:GetAttribute("macrotext") ~= newScriptText then
            -- Update the button's script
            existingButton:SetAttribute("macrotext", newScriptText)
        end
    end
end

-- Function to build the text of a script for the button
function addon:buildText(info)
    local lines = {"#showtooltip"}
    local item = self:getBestItem(info.items)
    if item then
        table.insert(lines, "/cast" .. (info.condition and " [" .. info.condition .. "]" or "") .. " " .. item.name)
    end
    if info.nuance then
        info.nuance(lines)
    end
    return self:format(table.concat(lines, "\n"))
end

-- Function to format the macro text
function addon:format(macro)
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

    return formattedMacro
end

-- Function to get a button by its name
function addon:getButtonByName(name)
    for _, button in ipairs(addon.spellButtons or {}) do
        if button:GetName() == name then
            return button
        end
    end
    return nil
end

-- Initialize custom scripts
function addon:processCustomScripts()
    self.customButtons = self.db.profile.customButtons or {}

    for _, scriptInfo in pairs(self.customButtons) do
        self:processButtons("custom", scriptInfo)
    end
end

-- Load custom buttons and process scripts on addon load
function addon:LoadCustomButtonScripts()
    if not self.db then
        print("Error: Database is not initialized")
        return
    end
    self:processCustomScripts()
end

-- Call the load function to initialize
addon:LoadCustomButtonScripts()
