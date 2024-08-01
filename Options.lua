local _, addon = ...

addon.defaults = {
    profile = {
        ["macroS"] = {
            ["*"] = {
                toggleOption = true
            }
        },
        customButtons = {}
    }
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
                    func = "CreateCustomMacro"
                }
            }
        },
        macroS = {
            type = "group",
            name = "Macros",
            order = 2,
            inline = false,
            args = {
                -- Options for the selected macro
                -- These options will be dynamically updated based on the selected macro
            }
        }
    }
}

function addon:GetMacroNames()
    local macroNames = {}
    for macroName, _ in pairs(self.macroData) do
        macroNames[macroName] = macroName
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
                    get = function()
                        return addon.db.profile.macroS[macroName].toggleOption
                    end,
                    set = function(_, value)
                        addon.db.profile.macroS[macroName].toggleOption = value
                    end
                },
                ["delete" .. macroName] = {
                    type = "execute",
                    order = 2,
                    name = "Delete",
                    desc = "Delete this macro",
                    func = function()
                        addon:DeleteCustomMacro(macroName)
                    end,
                    confirm = true,
                    confirmText = "Are you sure you want to delete this macro?",
                    hidden = not addon.db.profile.macroS[macroName].isCustom -- Hide if the macro is not custom
                },
                spacer1 = {
                    type = "description",
                    order = 3,
                    name = ""
                },
                itemLinks = {
                    type = "description",
                    order = 4,
                    name = function()
                        return addon:GetItemLinksForMacro(macroName)
                    end,
                    fontSize = "medium"
                }
            }
        }

        -- If the macro is custom, add additional options
        if addon.db.profile.macroS[macroName].isCustom then
            addon.options.args.macroS.args[macroName].args.superMacro = {
                type = "input",
                name = "Macro String",
                desc = "Edit the macro string",
                width = "full",
                multiline = 10,
                set = function(info, val)
                    addon.db.profile.macroS[macroName].superMacro = val
                end,
                get = function(info)
                    return addon.db.profile.macroS[macroName].superMacro
                end,
                order = 7
            }
        end

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
        local macroName = addon:standardizeName(text)

        -- Check if the macroName is not empty
        if macroName and macroName ~= "" then
            -- Create a new macroInfo table for the custom macro
            local macroInfo = {
                name = macroName,
                isCustom = true,
                icon = "INV_Misc_QuestionMark"
            }
            -- Save the new custom macro to the database
            addon.db.profile.macroS[macroName] = macroInfo
            addon.db.profile.macroS[macroName].superMacro = ""
            addon.db.profile.macroS[macroName].parameters = ""
            addon.db.profile.macroS[macroName].toggleOption = true

            -- Update the macroData table
            addon:LoadCustomMutations()
            addon:generateMacroGroups()
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
    if addon.db.profile.macroS[macroName] then -- Corrected path
        -- Remove from db and macroData tables
        addon.db.profile.macroS[macroName] = nil
        addon.macroData[macroName] = nil

        -- Delete the actual macro
        addon:deleteMacro(macroName)

        addon:LoadCustomMutations()
        addon:generateMacroGroups()
        LibStub("AceConfigRegistry-3.0"):NotifyChange(addon.title .. "_options")
    else
        print("Macro does not exist: " .. macroName)
    end
end

function addon:GetItemLinksForMacro(macroName)
    -- Initialize the item links string as empty
    local itemLinksString = ""

    for header, macroInfo in pairs(addon.macroData) do
        -- Use the forEachMacro function to apply the callback to each macro
        -- addon:forEachMacro(callback)
        if header == macroName and macroInfo.items then
            -- Initialize an empty table to hold the item links
            local itemLinks = {}

            -- Extract the link from each item and add it to the itemLinks table
            for i = 1, #macroInfo.items do
                local item = macroInfo.items[i]
                if item.link then
                    table.insert(itemLinks, item.link)
                end
            end

            -- Convert the itemLinks table to a string
            itemLinksString = table.concat(itemLinks, "\n")
        end
    end
    return itemLinksString
end
