local addonName, addon = ...

local function CreateDraggableButton(name, parentFrame, actionType, actionData, iconSize)
    local button = CreateFrame("Button", name, parentFrame, "SecureActionButtonTemplate, ActionButtonTemplate")
    button:SetSize(iconSize, iconSize)

    if actionType == "spell" then
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", actionData)
        button.icon = _G[name .. "Icon"]
        button.icon:SetTexture(GetSpellTexture(actionData))

        button:SetScript("OnDragStart", function(self)
            PickupSpell(actionData)
        end)

        button:SetScript("OnReceiveDrag", function(self)
            PlaceAction(GetCursorInfo())
            ClearCursor()
        end)
    elseif actionType == "macro" then
        button:SetAttribute("type", "macro")
        button:SetAttribute("macro", actionData)
        button.icon = _G[name .. "Icon"]
        button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark") -- Placeholder texture, replace as needed

        button:SetScript("OnDragStart", function(self)
            PickupMacro(actionData)
        end)

        button:SetScript("OnReceiveDrag", function(self)
            PlaceAction(GetCursorInfo())
            ClearCursor()
        end)
    elseif actionType == "custom" then
        local scriptInfo = addon:GetScriptInfo(actionData)
        button:SetAttribute("type", "macro")
        button:SetAttribute("macrotext", scriptInfo.script)
        button.icon = _G[name .. "Icon"]
        button.icon:SetTexture(scriptInfo.icon)

        button:SetScript("OnDragStart", function(self)
            PickupMacro(scriptInfo.script)
        end)

        button:SetScript("OnReceiveDrag", function(self)
            PlaceAction(GetCursorInfo())
            ClearCursor()
        end)
    end

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if actionType == "spell" then
            GameTooltip:SetSpellByID(actionData)
        elseif actionType == "macro" then
            GameTooltip:SetText("Macro")
        elseif actionType == "custom" then
            local scriptInfo = addon:GetScriptInfo(actionData)
            GameTooltip:SetText(scriptInfo.tooltip)
        end
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    button:RegisterForDrag("LeftButton")
    return button
end

addon.CreateDraggableButton = CreateDraggableButton

function addon:GetScriptInfo(name)
    return self.db.profile.customButtons[name]
end

function addon:CreateAndStoreCustomButton(name, script, iconSize, iconTexture, tooltip)
    -- Store button info in AceDB
    self.db.profile.customButtons[name] = {
        script = script,
        iconSize = iconSize,
        icon = iconTexture,
        tooltip = tooltip
    }

    -- Create the button
    self:CreateDraggableButton(name, UIParent, "custom", name, iconSize)
end

function addon:LoadCustomButtons()
    for name, buttonInfo in pairs(self.db.profile.customButtons) do
        self:CreateDraggableButton(name, UIParent, "custom", name, buttonInfo.iconSize)
    end
end
