-- ScriptLogic.lua
-- Description:
-- This file contains functions to generate the script text for custom buttons. 
-- It is responsible for constructing the script content that will be used by the 
-- SpellbookButtons.lua file to create draggable buttons.
local addonName, addon = ...

-- Function to generate script text for custom buttons
function addon:BuildScriptText(scriptDef)
    local scriptLines = {scriptDef.header or ""}
    if scriptDef.body then
        table.insert(scriptLines, scriptDef.body)
    end
    return table.concat(scriptLines, "\n")
end

-- Function to save or update a custom button script
function addon:SaveCustomButtonScript(name, scriptDef, icon)
    if not self.db then
        print("Error: Database is not initialized")
        return
    end

    local scriptText = self:BuildScriptText(scriptDef)
    local buttonData = {
        name = name,
        scriptText = scriptText,
        icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    }
    print("Saving Custom Button Script: ", name) -- Logging
    self.db.profile.customButtons[name] = buttonData
end

-- Function to load custom button scripts from the database
function addon:LoadCustomButtonScripts()
    if not self.db then
        print("Error: Database is not initialized")
        return
    end

    self.customButtons = self.db.profile.customButtons or {}
end

-- Function to save all custom button scripts
function addon:SaveAllCustomButtonScripts()
    self:LoadCustomButtonScripts()

    for scriptType, scriptTypeData in pairs(addon.macroData) do
        for scriptKey, scriptInfo in pairs(scriptTypeData) do
            self:SaveCustomButtonScript(scriptInfo.name, scriptInfo, scriptInfo.icon)
        end
    end
end

-- Initialize custom button scripts
-- if addon.SaveAllCustomButtonScripts then
--     addon:SaveAllCustomButtonScripts()
-- end
