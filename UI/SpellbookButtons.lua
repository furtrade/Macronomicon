local addonName, addon = ...

local function CreateDraggableButton(name, parentFrame, spellID, iconSize)
    local button = CreateFrame("Button", name, parentFrame, "SecureActionButtonTemplate, ActionButtonTemplate")
    button:SetSize(iconSize, iconSize)
    button:SetAttribute("type", "spell")
    button:SetAttribute("spell", spellID)
    button.icon = _G[name .. "Icon"]
    button.icon:SetTexture(GetSpellTexture(spellID))

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(spellID)
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    button:SetScript("OnDragStart", function(self)
        PickupSpell(spellID)
    end)

    button:SetScript("OnReceiveDrag", function(self)
        PlaceAction(GetCursorInfo())
        ClearCursor()
    end)

    button:RegisterForDrag("LeftButton")
    return button
end

addon.CreateDraggableButton = CreateDraggableButton
