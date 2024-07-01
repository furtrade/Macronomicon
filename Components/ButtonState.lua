-- ButtonState.lua
-- Description:
-- This file handles the version tracking and state management of custom buttons. 
-- It ensures that each button is up-to-date with the latest script version and manages 
-- the creation and update process of the buttons based on their scripts. It also interacts 
-- with the database to store and retrieve button information.
local addonName, addon = ...

-- Function to check if a custom button already exists
function addon:customButtonExists(name)
    return self.db.profile.customButtons[name] ~= nil
end

-- Function to create a new custom button
function addon:createCustomButton(name, script, icon)
    self.db.profile.customButtons[name] = {
        script = script,
        icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    }
    self.customButtons[name] = self.db.profile.customButtons[name]
end

-- Function to update an existing custom button
function addon:updateCustomButton(name, script, icon)
    if self:customButtonExists(name) then
        self.db.profile.customButtons[name].script = script
        if icon then
            self.db.profile.customButtons[name].icon = icon
        end
        self.customButtons[name] = self.db.profile.customButtons[name]
    end
end

-- Function to manage the state of custom buttons
function addon:manageButtonState(name, scriptDef, icon)
    local scriptText = self:generateScriptText(scriptDef)
    if not self:customButtonExists(name) then
        self:createCustomButton(name, scriptText, icon)
    else
        self:updateCustomButton(name, scriptText, icon)
    end
end
