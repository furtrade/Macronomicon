local addonName, addon = ...

-- Table to store custom buttons and their scripts
addon.customButtons = {}

-- Function to check if a custom button already exists
function addon:customButtonExists(name)
    return self.customButtons[name] ~= nil
end

-- Function to create or update a custom button
function addon:createOrUpdateCustomButton(name, script, icon)
    if not self:customButtonExists(name) then
        self:createCustomButton(name, script, icon)
    else
        self:updateCustomButton(name, script, icon)
    end
end

-- Function to create a new custom button
function addon:createCustomButton(name, script, icon)
    self.customButtons[name] = {
        script = script,
        icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    }
end

-- Function to update an existing custom button
function addon:updateCustomButton(name, script, icon)
    if self:customButtonExists(name) then
        self.customButtons[name].script = script
        if icon then
            self.customButtons[name].icon = icon
        end
    end
end

-- Function to build the custom button script
function addon:buildCustomButtonScript(scriptDef)
    local scriptLines = {scriptDef.header or ""}
    if scriptDef.body then
        table.insert(scriptLines, scriptDef.body)
    end
    return table.concat(scriptLines, "\n")
end

-- Function to load custom buttons from the database
function addon:loadCustomButtons()
    local customButtonsFromDB = self.db.profile.customButtons or {}
    for name, buttonInfo in pairs(customButtonsFromDB) do
        self:createOrUpdateCustomButton(name, buttonInfo.script, buttonInfo.icon)
    end
end

-- Function to process all custom buttons
function addon:processCustomButtons()
    self:loadCustomButtons()
    for name, buttonInfo in pairs(self.customButtons) do
        self:createOrUpdateCustomButton(name, buttonInfo.script, buttonInfo.icon)
    end
end
