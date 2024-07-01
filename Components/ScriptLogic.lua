local addonName, addon = ...

-- Table to store custom buttons temporarily
addon.customButtons = {}

-- Function to check if a custom button already exists
function addon:customButtonExists(name)
    return self.db and self.db.profile.customButtons[name] ~= nil
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
    if not self.db then
        return
    end
    self.db.profile.customButtons[name] = {
        script = script,
        icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    }
    self.customButtons[name] = self.db.profile.customButtons[name]
    -- Create the button
    addon.CreateDraggableButton(name, UIParent, "custom", name, addon.positionOptions.iconSize)
end

-- Function to update an existing custom button
function addon:updateCustomButton(name, script, icon)
    if not self.db then
        return
    end
    if self:customButtonExists(name) then
        self.db.profile.customButtons[name].script = script
        if icon then
            self.db.profile.customButtons[name].icon = icon
        end
        self.customButtons[name] = self.db.profile.customButtons[name]
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
    if not self.db then
        return
    end
    self.customButtons = self.db.profile.customButtons or {}
end

-- Function to process all custom buttons
function addon:processCustomButtons()
    self:loadCustomButtons()
    for name, buttonInfo in pairs(self.customButtons) do
        self:createOrUpdateCustomButton(name, buttonInfo.script, buttonInfo.icon)
    end
end
