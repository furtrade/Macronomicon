-- SpellbookButtons.lua
local _, addon = ...

function addon:CreateButtons()
    self.spellButtons = self.spellButtons or {}
    print("Entering addon:CreateButtons...")

    for macroHeader, macroData in pairs(self.macroData) do
        local buttonName = macroData.name
        local button = self:FindButtonByName(buttonName)
        if not button then
            print("Creating button:", buttonName)
            button = self:CreateDraggableButton(buttonName, self.MacrobialSpellbookFrame, "custom", macroData,
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
            if not addon:macroExists(name) then
                addon:createOrUpdateMacro(actionData)
            end
            PickupMacro(addon:getMacroIDByName(name))
        end)
        button:SetScript("OnReceiveDrag", function(self)
            local _, _, _, id = GetCursorInfo()
            if id then
                -- actionData.macroID = id
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
