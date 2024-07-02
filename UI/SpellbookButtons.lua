local _, addon = ...

function addon:CreateButtons()
    self.spellButtons = self.spellButtons or {}
    local customButtons = self.db.profile.customButtons or {}
    print("Entering addon:CreateButtons...")

    for i, custom in ipairs(customButtons) do
        local buttonName = custom.name or "unknown" .. i
        local button = self:FindButtonByName(buttonName)
        if not button then
            print("Creating button:", buttonName)
            button = self:CreateDraggableButton(buttonName, self.MacrobialSpellbookFrame, "custom", custom,
                addon.positionOptions.iconSize)
            table.insert(self.spellButtons, button)
        end
    end
end

function addon:FindButtonByName(name)
    for _, button in ipairs(self.spellButtons or {}) do
        if button:GetName() == name then
            return button
        end
    end
    return nil
end

-- Utility function to find a macro by name
local function FindMacroByName(name)
    for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        local macroName = GetMacroInfo(i)
        if macroName == name then
            return i
        end
    end
    return nil
end

function addon:CreateDraggableButton(name, parentFrame, actionType, actionData, iconSize)
    local button = CreateFrame("Button", name, parentFrame, "SecureActionButtonTemplate, ActionButtonTemplate")
    button:SetSize(iconSize, iconSize)
    button.icon = _G[name .. "Icon"]

    local function setButtonAttributes(type, data)
        button:SetAttribute("type", type)
        button:SetAttribute(type, data)
    end

    local function setButtonScripts(pickupFunc, placeFunc)
        button:SetScript("OnDragStart", function(self)
            pickupFunc(actionData)
        end)
        button:SetScript("OnReceiveDrag", function(self)
            placeFunc()
            ClearCursor()
        end)
    end

    if actionType == "spell" then
        setButtonAttributes("spell", actionData)
        button.icon:SetTexture(GetSpellTexture(actionData))
        setButtonScripts(PickupSpell, PlaceAction)
    elseif actionType == "macro" then
        setButtonAttributes("macro", actionData)
        button.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        setButtonScripts(PickupMacro, PlaceAction)
    elseif actionType == "custom" then
        button.icon:SetTexture(actionData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        button:SetScript("OnDragStart", function(self)
            if not actionData.macroID then
                local macroName = name
                local macroID = FindMacroByName(macroName)
                if not macroID then
                    macroID = CreateMacro(macroName, "INV_Misc_QuestionMark", actionData.macroText, true)
                    print("Created macro with ID:", macroID)
                else
                    EditMacro(macroID, macroName, "INV_Misc_QuestionMark", actionData.macroText)
                    print("Updated macro with ID:", macroID)
                end
                actionData.macroID = macroID
            end
            if actionData.macroID then
                PickupMacro(actionData.macroID)
            else
                print("Error: No macro ID for custom script")
            end
        end)
        button:SetScript("OnReceiveDrag", function(self)
            local _, _, _, id = GetCursorInfo()
            if id then
                actionData.macroID = id
                ClearCursor()
            end
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
    return button
end
