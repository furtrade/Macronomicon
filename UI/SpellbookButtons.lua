-- SpellbookButtons.lua
local _, addon = ...

function addon:CreateButtons()
    self.spellButtons = self.spellButtons or {}
    print("Entering addon:CreateButtons...")

    for macroHeader, macroInfo in pairs(self.macroData) do
        local buttonName = macroInfo.name
        local button = self:FindButtonByName(buttonName)
        if not button then
            local icon = self:GetMacroIcon(macroInfo, buttonName)
            button = self:CreateDraggableButton(buttonName, self.MacrobialSpellbookFrame, "custom", macroInfo, icon,
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

function addon:GetMacroIcon(macroInfo, name)
    local macroID = self:getMacroIDByName(name)
    if macroID then
        local _, icon = GetMacroInfo(macroID)
        return icon
    else
        return macroInfo.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    end
end

function addon:CreateDraggableButton(name, parentFrame, actionType, actionData, icon, iconSize)
    local button = CreateFrame("Button", name, parentFrame, "SecureActionButtonTemplate, ActionButtonTemplate")
    button:SetSize(iconSize, iconSize)
    button.icon = _G[name .. "Icon"]
    button.icon:SetTexture(icon)

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
        setButtonScripts(PickupSpell, PlaceAction)
    elseif actionType == "macro" then
        setButtonAttributes("macro", actionData)
        setButtonScripts(PickupMacro, PlaceAction)
    elseif actionType == "custom" then
        button:SetScript("OnDragStart", function(self)
            local macroName = addon:getMacroName(name)
            local macroID = addon:getMacroIDByName(name)

            if not macroID then
                macroID = addon:createMacro(actionData)
                print("created macro with id ", macroID, " called ", macroName)
            end
            macroID = addon:updateMacro(actionData, macroID)
            print("updated macro with id ", macroID, " called ", macroName)

            PickupMacro(macroID)
        end)
        button:SetScript("OnReceiveDrag", function(self)
            local _, _, _, id = GetCursorInfo()
            if id then
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

function addon:getMacroIDByName(name)
    for i = 1, MAX_ACCOUNT_MACROS + MAX_CHARACTER_MACROS do
        local macroName, _, icon = GetMacroInfo(i)
        if macroName == self:getMacroName(name) or macroName == name then
            return i, icon
        end
    end
    return nil
end

function addon:getMacroName(name)
    return "!" .. name -- Prefix is configurable if needed
end

function addon:createMacro(info)
    local perCharacter = false
    return CreateMacro(self:getMacroName(info.name), info.icon or "INV_Misc_QuestionMark", info.macroText, perCharacter)
end

function addon:updateMacro(info, macroID)
    local macroString = self:buildMacroString(info)
    EditMacro(macroID, self:getMacroName(info.name), info.icon, macroString)
    return macroID
end

function addon:buildMacroString(info)
    local lines = {"#showtooltip"}

    local item = self:getBestItem(info.items)
    if item then
        local condition = info.condition and " [" .. info.condition .. "]" or ""
        table.insert(lines, "/cast" .. condition .. " " .. item.name)
    end

    if info.nuance and type(info.nuance) == "function" then
        info.nuance(lines)
    end

    return self:formatMacro(table.concat(lines, "\n"))
end

function addon:formatMacro(macro)
    local formattedMacro = macro
    repeat
        macro = formattedMacro
        formattedMacro = formattedMacro:gsub(",;", ";"):gsub(";,", ";"):gsub(";+", ";"):gsub("%s%s+", " "):gsub(",%s+",
            ","):gsub("%s+$", ""):gsub("%][ \t]+", "]"):gsub("%[%s+", "["):gsub(",%]", "]"):gsub(";+$", ""):gsub(
            "([/#]%w+%s[;,])", function(match)
                return match:sub(1, -2)
            end):lower()
    until formattedMacro == macro
    return formattedMacro
end
