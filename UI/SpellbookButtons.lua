local _, addon = ...

addon.spellButtons = addon.spellButtons or {}

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
        button:SetAttribute("type", "macro")
        button:SetAttribute("macrotext", actionData.macroText)
        button.icon = _G[name .. "Icon"]
        button.icon:SetTexture(actionData.icon or "Interface\\Icons\\INV_Misc_QuestionMark") -- Placeholder texture, replace as needed

        button:SetScript("OnDragStart", function(self)
            PickupMacro(actionData.macroText)
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
        elseif actionType == "custom" and actionData.tooltip then
            GameTooltip:SetText(actionData.tooltip)
        end
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    button:RegisterForDrag("LeftButton")

    addon.spellButtons[name] = button
    return button
end

addon.CreateDraggableButton = CreateDraggableButton
