-- SpellbookButtons.lua
local _, addon = ...

-- Cache frequently used functions
local CreateFrame = CreateFrame
local GetMacroInfo = GetMacroInfo
local PickupSpell = PickupSpell
local PickupMacro = PickupMacro
local PlaceAction = PlaceAction
local ClearCursor = ClearCursor
local GetCursorInfo = GetCursorInfo

-- Constants
local DEFAULT_ICON = "Interface\\Icons\\INV_Misc_QuestionMark"

local function GetButtonIcon(macroInfo, name)
    local macroID = addon:getMacroIDByName(name)
    if macroID then
        local _, iconTexture = GetMacroInfo(macroID)
        if iconTexture then
            return iconTexture
        end
    end
    return macroInfo.icon or DEFAULT_ICON
end

local function CreateDraggableButton(name, parentFrame, macroInfo, iconSize)
    local button = CreateFrame("Button", name, parentFrame, "SecureActionButtonTemplate, ActionButtonTemplate")
    button:SetSize(iconSize, iconSize)
    button.icon = button:CreateTexture(nil, "BACKGROUND")
    button.icon:SetAllPoints(button)

    local icon = GetButtonIcon(macroInfo, name)
    button.icon:SetTexture(icon)

    local actionType = macroInfo.actionType or "custom"
    local actionData = macroInfo.actionData or macroInfo

    local function setButtonAttributes(attrType, data)
        button:SetAttribute("type", attrType)
        button:SetAttribute(attrType, data)
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
        setButtonAttributes("macro", actionData)
        button:SetScript("OnDragStart", function(self)
            local macroName = addon:prefixedMacroName(name)
            local macroID = addon:getMacroIDByName(name)

            if not macroID then
                macroID = addon:createMacro(actionData)
            end
            macroID = addon:updateMacro(actionData, macroID)

            PickupMacro(macroID)

            -- Update button icon after creating or updating macro
            local newIcon = GetButtonIcon(macroInfo, name)
            button.icon:SetTexture(newIcon)
        end)
        button:SetScript("OnReceiveDrag", function(self)
            local _, _, _, id = GetCursorInfo()
            if id then
                ClearCursor()
            end
        end)
    end

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
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

function addon:CreateButtons()
    self.spellButtons = self.spellButtons or {}
    local buttonCache = {}

    -- Pre-populate button cache
    for _, button in ipairs(self.spellButtons) do
        buttonCache[button:GetName()] = button
    end

    for macroHeader, macroInfo in pairs(self.macroData) do
        local buttonName = macroInfo.name
        local button = buttonCache[buttonName]

        if not button then
            button = CreateDraggableButton(buttonName, self.MacrobialSpellbookFrame, macroInfo,
                self.positionOptions.iconSize)
            table.insert(self.spellButtons, button)
        else
            -- Update existing button icon
            local icon = GetButtonIcon(macroInfo, buttonName)
            button.icon:SetTexture(icon)
        end
    end
end
