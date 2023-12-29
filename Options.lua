local addonName, addon = ...

addon.defaults = {
    profile = {
        ["macroS"] = {
            ["*"] = {
                toggleOption = true
            },
        },
    },
}

addon.options = {
    type = "group",
    name = addon.title,
    handler = addon,
    args = {
        mainGroup = {
            type = "group",
            name = "Macros",
            order = 1,
            inline = true,
            args = {
                createCustomMacro = {
                    type = "execute",
                    order = 1,
                    name = "Create Custom Macro",
                    desc = "Create a new custom macro",
                    func = "CreateCustomMacro",
                },
            },
        },
        macroS = {
            type = "group",
            name = "Macros",
            order = 2,
            inline = false,
            args = {
                -- Options for the selected macro
                -- These options will be dynamically updated based on the selected macro
            },
        },
    },
}

function addon:GetMacroNames()
    local macroNames = {}

    -- Iterate over all categories of macros
    for _, macroCategory in pairs(self.macroData) do
        -- Add the names of the macros in the current category
        for macroName, _ in pairs(macroCategory) do
            macroNames[macroName] = macroName
        end
    end

    return macroNames
end

-- Dynamically generate the list of macros
function addon:generateMacroGroups()
    -- Clear the existing macro groups
    addon.options.args.macroS.args = {}

    -- Dynamically generate the list of macros
    local i = 1
    for macroName, _ in pairs(addon:GetMacroNames()) do
        addon.options.args.macroS.args[macroName] = {
            type = "group",
            name = macroName,
            order = i,
            inline = false,
            args = {
                ["toggle" .. macroName] = {
                    type = "toggle",
                    order = 0,
                    name = "Enable",
                    desc = "Enable or disable this macro",
                    get = function() return addon.db.profile.macroS[macroName].toggleOption end,
                    set = function(_, value) addon.db.profile.macroS[macroName].toggleOption = value end,
                },
                ["delete" .. macroName] = {
                    type = "execute",
                    order = 2,
                    name = "Delete",
                    desc = "Delete this macro",
                    func = function() addon:DeleteCustomMacro(macroName) end,
                    confirm = true,
                    confirmText = "Are you sure you want to delete this macro?",
                },
            }
        }
        i = i + 1
    end
end

function addon:CreateCustomMacro()
    -- Create a new frame
    local frame = self.gui:Create("Frame")
    frame:SetTitle("Enter Macro Name")
    frame:SetWidth(320)
    frame:SetHeight(200)
    -- Create an edit box
    local editBox = self.gui:Create("EditBox")
    editBox:SetLabel("Macro Name")
    editBox:SetWidth(300)
    frame:AddChild(editBox)

    -- Set the callback for the edit box
    editBox:SetCallback("OnEnterPressed", function(widget, event, text)
        local macroName = self:standardizedName(text)

        -- Check if the macroName is not empty
        if macroName and macroName ~= "" then
            -- Create a new macroInfo table for the custom macro
            local macroInfo = {
                name = macroName,
                isCustom = true,
                icon = "INV_Misc_QuestionMark",
                superMacro = "",
            }
            -- Save the new custom macro to the database
            local insertMacro = self.db.profile.macroS
            insertMacro[macroName] = macroInfo
            insertMacro[macroName].toggleOption = true

            -- Update the macroData table
            self:loadCustomMacros()
            self:generateMacroGroups()
            LibStub("AceConfigRegistry-3.0"):NotifyChange(addon.title .. "_options")
            -- Close the frame
            frame:Release()
        else
            print("Please enter a valid macro name.")
        end
    end)
end

function addon:DeleteCustomMacro(macroName)
    -- Check if the macro exists
    if self.db.profile.macroS[macroName] then -- Corrected path
        -- Remove from db and macroData tables
        self.db.profile.macroS[macroName] = nil
        self.macroData.CUSTOM[macroName] = nil

        -- Delete the actual macro
        self:DeleteGameMacro(macroName)

        self:loadCustomMacros()
        self:generateMacroGroups()
        LibStub("AceConfigRegistry-3.0"):NotifyChange(addon.title .. "_options")
    else
        print("Macro does not exist: " .. macroName)
    end
end
