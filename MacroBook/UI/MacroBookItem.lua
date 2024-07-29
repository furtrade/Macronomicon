local _, addon = ...

local MacroBookItemEvents = {"UPDATE_MACROS", "UPDATE_SHAPESHIFT_FORM", "SPELL_UPDATE_COOLDOWN", "PET_BAR_UPDATE",
                             "ACTIONBAR_SLOT_CHANGED", "CURSOR_CHANGED", "UPDATE_MACROS"}

MacroBookItemMixin = MacroBookItemMixin or {}

function MacroBookItemMixin:OnLoad()
    self.Backplate:SetAlpha(self.defaultBackplateAlpha);
    self.Button.IconHighlight:SetAlpha(self.iconHighlightHoverAlpha);
end

-- HACK: one of the shortfalls of trying to integrate with the blizz ui
function MacroBookItemMixin:UpdateSpellData(forceUpdate)
    return self:UpdateMacroData(forceUpdate)
end

-- Function to update the macro data
function MacroBookItemMixin:UpdateMacroData(forceUpdate)
    if not self.elementData then
        self:ClearMacroData()
        return
    end

    local macroBookItemInfo = addon.MacroBank:GetMacroInfoPlus(self.elementData.slotIndex)

    if not macroBookItemInfo then
        self:ClearMacroData()
        return
    end

    -- Avoid updating all data and visuals if it's not necessary
    if not forceUpdate and self.macroBookItemInfo and tCompare(macroBookItemInfo, self.macroBookItemInfo) then
        return
    end

    if macroBookItemInfo.isVirtual then
        local detail = addon:GetFirstItemNameForMacro(macroBookItemInfo.name)
        if detail then
            macroBookItemInfo.subName = detail.name
            macroBookItemInfo.description = detail.link
        end
    end

    self:ClearMacroData()

    self.macroBookItemInfo = macroBookItemInfo
    self.slotIndex = self.elementData.slotIndex

    self:UpdateVisuals()
end

-- Initialization function, called when the macro button is created
function MacroBookItemMixin:Init(elementData)
    self.elementData = elementData
    local forceUpdate = true
    self:UpdateMacroData(forceUpdate)
end

-- Function to clear the macro data
function MacroBookItemMixin:ClearMacroData()
    -- if self.cancelMacroLoadCallback then
    --     self.cancelMacroLoadCallback();
    -- end

    self.macroBookItemInfo = nil
    self.slotIndex = nil;
    self.macroGrabbed = nil;

    -- other props that may not matter
    self.isOffSpec = nil;
    self.spellBank = nil;
    self.isUnlearned = nil;
    self.activeGlyphCast = nil;
    self.inClickBindMode = nil;
    self.canClickBind = nil;
    self.isTrainable = nil;
end

function MacroBookItemMixin.Reset(framePool, self)
    Pool_HideAndClearAnchors(framePool, self);

    self:ClearMacroData();
    self.elementData = nil;
end

function MacroBookItemMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, MacroBookItemEvents);
    self:UpdateActionBarAnim();
    self:UpdateBorderAnim();
    -- self:UpdateTrainableFX();
end

function MacroBookItemMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, MacroBookItemEvents);
    self:UpdateActionBarAnim();
    self:UpdateBorderAnim();
    -- self:UpdateTrainableFX();
end

function MacroBookItemMixin:OnEvent(event, ...)
    if not self:HasValidData() then
        return;
    end

    if event == "UPDATE_SHAPESHIFT_FORM" then
        -- Attack icons change when shapeshift form changes
        self:UpdateIcon();
    elseif "UPDATE_MACROS" then
        self:UpdateIcon();
    elseif event == "UPDATE_MACROS" then
        self:UpdateIcon();
    elseif event == "ACTIONBAR_SLOT_CHANGED" then
        self:UpdateActionBarStatus();
    elseif event == "CURSOR_CHANGED" then
        -- Spell was being dragged from spellbook, update action bar status since we may have hidden visual during drag
        if self.macroGrabbed then
            self.macroGrabbed = false;
            self:UpdateActionBarStatus();
        end
    end
end

function MacroBookItemMixin:HasValidData()
    return self.elementData and self.macroBookItemInfo;
end

function MacroBookItemMixin:GetName()
    return self:HasValidData() and self.macroBookItemInfo.name;
end

function MacroBookItemMixin:GetTexture()
    return self:HasValidData() and self.Button.Icon:GetTexture();
end

-- function MacroBookItemMixin:IsFlyout()
--     return self:HasValidData() and self.macroBookItemInfo.itemType == Enum.MacroBookItemType.Flyout;
-- end

function MacroBookItemMixin:GetItemType()
    return self:HasValidData() and self.macroBookItemInfo.itemType;
end

function MacroBookItemMixin:GetDragTarget()
    return self.Button;
end

-- function MacroBookItemMixin:ToggleFlyout(reason)
--     if not self:IsFlyout() then
--         return;
--     end

--     local offSpecID = self.isOffSpec and self.elementData.specID or nil;
--     local distance, isActionBar, showFullTooltip = -2, false, true;
--     SpellFlyout:Toggle(self.macroBookItemInfo.actionID, self.Button, "RIGHT", distance, isActionBar, offSpecID,
--         showFullTooltip, reason);
--     SpellFlyout:SetBorderSize(42);

--     local rotation = SpellFlyout:IsShown() and 180 or 0;
--     SetClampedTextureRotation(self.Button.FlyoutArrow, rotation);
-- end

-- Function to update the visual elements
function MacroBookItemMixin:UpdateVisuals()
    self.Name:SetText(self.macroBookItemInfo.name);
    self.Button.Icon:SetTexture(self.macroBookItemInfo.iconID);

    if self.macroBookItemInfo.subName then
        self:UpdateSubName(self.macroBookItemInfo.subName);
    else
        self.SubName:SetText("");
        -- if self.macroBookItemInfo.spellID then
        --     local spell = Spell:CreateFromSpellID(spellID);
        --     self.cancelSpellLoadCallback = spell:ContinueWithCancelOnSpellLoad(function()
        --         local spellSubName = spell:GetSpellSubtext();
        --         self:UpdateSubName(spellSubName);
        --         self.cancelSpellLoadCallback = nil;
        --     end);
        -- end
    end

    -- Macros do not have itemType equivalent to Flyout in spells
    self.Button.FlyoutArrow:Hide();

    self:UpdateArtSet();
    if self.artSet.iconMask then
        self.Button.IconMask:SetAtlas(self.artSet.iconMask, TextureKitConstants.IgnoreAtlasSize);
        self.Button.IconMask:Show();
    else
        self.Button.IconMask:Hide();
    end

    self.Button.IconHighlight:SetAtlas(self.artSet.iconHighlight, TextureKitConstants.IgnoreAtlasSize);

    self.isUnlearned = false; -- Macros cannot be unlearned

    self.Button.Icon:SetDesaturated(self.isUnlearned);
    self.Button.FlyoutArrow:SetDesaturated(self.isUnlearned);

    self.isTrainable = false; -- Macros do not need to be trained

    self.Name:SetAlpha(1);
    self.SubName:SetAlpha(1);
    self.RequiredLevel:SetAlpha(1);

    self.Button.Icon:SetVertexColor(1, 1, 1);
    self.Button.Icon:SetAlpha(1);

    self.RequiredLevel:Hide();
    self.RequiredLevel:SetText("");

    local borderAtlas = self.artSet.activeBorder;
    local borderAnchors = self.artSet.activeBorderAnchors;
    self.Button.Border:SetAtlas(borderAtlas, TextureKitConstants.IgnoreAtlasSize);
    self.Button.Border:ClearAllPoints();
    for _, anchor in ipairs(borderAnchors) do
        local point, relativeTo, relativePoint, x, y = anchor:Get();
        relativeTo = relativeTo or self.Button;
        self.Button.Border:SetPoint(point, relativeTo, relativePoint, x, y);
    end

    self.Button.BorderSheenMask:SetAtlas(self.artSet.borderSheenMask, TextureKitConstants.UseAtlasSize);
    self.Button.BorderSheenMask:ClearAllPoints();
    for _, anchor in ipairs(self.artSet.borderSheenMaskAnchors) do
        local point, relativeTo, relativePoint, x, y = anchor:Get();
        relativeTo = relativeTo or self.Button.Border;
        self.Button.BorderSheenMask:SetPoint(point, relativeTo, relativePoint, x, y);
    end

    -- Macros do not have level link locks
    self.Button.LevelLinkLock:Hide();
    self.Button.LevelLinkIconCover:Hide();

    -- Macros do not have trainable state
    self.Button.TrainableShadow:Hide();
    self.Button.TrainableBackplate:Hide();

    self:UpdateActionBarStatus();
    self:UpdateCooldown();
    self:UpdateAutoCast();
    self:UpdateGlyphState();
    self:UpdateClickBindState();
    self:UpdateBorderAnim();

    -- If already being hovered, make sure to reset any on-hover state that needs to change
    if self.Button:IsMouseMotionFocus() then
        self:OnIconLeave();
        self:OnIconEnter();
    end
end

function MacroBookItemMixin:UpdateSubName(subNameText)
    -- If no subtext but it isPassive
    if subNameText == "" and self.macroBookItemInfo.isPassive then
        subNameText = SPELL_PASSIVE;
    end

    -- Truncate subNameText if it exceeds 14 characters and append ellipses
    if string.len(subNameText) > 14 then
        subNameText = string.sub(subNameText, 1, 14) .. "...";
    end

    self.macroBookItemInfo.subName = subNameText;
    self.SubName:SetText(subNameText);
end

function MacroBookItemMixin:UpdateIcon()
    if not self:HasValidData() then
        return;
    end

    -- Set the icon texture for the macro
    -- local _, iconID = GetMacroInfo(self.slotIndex)
    local macroIfo = addon.MacroBank:GetMacroInfoPlus(self.slotIndex)
    local iconID = macroIfo.iconID

    self.Button.Icon:SetTexture(iconID);
end

function MacroBookItemMixin:UpdateActionBarStatus()
    if not self:HasValidData() then
        return;
    end

    -- Avoid showing "missing from bar" visuals while in click bind mode, or macro is being dragged out of macro list
    if not self.macroGrabbed and not self.inClickBindMode and self.elementData.showActionBarStatus then
        -- self.actionBarStatus = MacroSearchUtil.GetActionbarStatusForMacroInfo(self.macroBookItemInfo);
    else
        self.actionBarStatus = ActionButtonUtil.ActionBarActionStatus.NotMissing;
    end

    self:UpdateActionBarAnim();
end

function MacroBookItemMixin:UpdateActionBarAnim()
    local shouldPlayHighlight = self:HasValidData() and self.actionBarStatus ==
                                    ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars and self:IsShown();
    self:UpdateSynchronizedAnimState(self.Button.ActionBarHighlight.Anim, shouldPlayHighlight);
end

function MacroBookItemMixin:UpdateBorderAnim()
    local shouldPlaySheen = self:HasValidData() and not self.isUnlearned and self:IsShown();
    self:UpdateSynchronizedAnimState(self.Button.BorderSheen.Anim, shouldPlaySheen);
end

function MacroBookItemMixin:UpdateSynchronizedAnimState(animGroup, shouldBePlaying)
    local isPlaying = animGroup:IsPlaying();
    if shouldBePlaying and not isPlaying then
        -- Ensure all looping anims stay synced with other SpellBookItems
        animGroup:PlaySynced();
    elseif not shouldBePlaying and isPlaying then
        animGroup:Stop();
    end
end

-- function MacroBookItemMixin:UpdateTrainableFX()
--     local shouldBePlaying = self.isTrainable and self:HasValidData() and self:IsShown();
--     if shouldBePlaying and not self.trainableFXController then
--         self.trainableFXController = self.Button.FxModelScene:AddEffect(TRAINABLE_FX_ID, self.Button, self.Button);
--     elseif not shouldBePlaying and self.trainableFXController then
--         self.trainableFXController:CancelEffect();
--         self.trainableFXController = nil;
--     end
-- end

-- HACK: 🤔This will require some hackery
function MacroBookItemMixin:UpdateCooldown()
    if not self:HasValidData() then
        return;
    end

    -- local cooldownInfo = 0 or C_SpellBook.GetSpellBookItemCooldown(self.slotIndex, self.spellBank);
    -- if cooldownInfo and cooldownInfo.isEnabled then
    --     self.Button.Cooldown:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.modRate);
    -- else
    self.Button.Cooldown:Clear();
    -- end
end

-- TODO: 🤗Might be cool to show autocast anims for special macros
function MacroBookItemMixin:UpdateAutoCast()
    if not self:HasValidData() then
        return;
    end

    local autoCastAllowed, autoCastEnabled = false, false;

    if not self.isOffSpec then
        autoCastAllowed, autoCastEnabled = false, false -- C_SpellBook.GetSpellBookItemAutoCast(self.slotIndex, self.spellBank);
    end

    self.Button.AutoCastOverlay:SetShown(autoCastAllowed);
    self.Button.AutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled);
end

-- TODO: Think of a reason to use this
function MacroBookItemMixin:ShowGlyphActivation()
    if not self:HasValidData() then
        return;
    end

    -- Cache that a glyph is being applied/removed on this item
    -- So that we can show the right glyph state while the cast is still ongoing
    self.activeGlyphCast = {
        isRemoval = IsPendingGlyphRemoval()
    };

    local isActivationStart = true;
    self:UpdateGlyphState(isActivationStart);
end

function MacroBookItemMixin:UpdateGlyphState(isActivationStart)
    if not self:HasValidData() then
        return;
    end

    local hasGlyph = false;
    local isValidForPendingGlyph = false;

    -- On the frame that activeGlyphCast is set, IsCastingGlyph is not yet true,
    -- so important to also check if we only just now set activeGlyphCast before clearing it out as stale
    if self.activeGlyphCast and not (isActivationStart or IsCastingGlyph()) then
        self.activeGlyphCast = nil;
    end

    -- Glyph application/removal is actively being cast on this item, so predict glyph state based on cached info
    if self.activeGlyphCast then
        hasGlyph = not self.activeGlyphCast.isRemoval;
        -- Otherwise get current glyph state normally
    elseif self.macroBookItemInfo.itemType == Enum.SpellBookItemType.Spell and not self.isOffSpec then
        hasGlyph = false -- HasAttachedGlyph(self.macroBookItemInfo.spellID);
        isValidForPendingGlyph = false -- IsSpellValidForPendingGlyph(self.macroBookItemInfo.spellID);
    end

    self.Button.GlyphIcon:SetShown(hasGlyph);

    if isValidForPendingGlyph and not self.GlyphHighlightAnim:IsPlaying() then
        self.GlyphHighlightAnim:Restart();
    elseif not isValidForPendingGlyph and self.GlyphHighlightAnim:IsPlaying() then
        self.GlyphHighlightAnim:Stop();
    end

    if isActivationStart then
        self.Button.GlyphActivateHighlight:Show();
        self.Button.GlyphActiveIcon:Show();
        self.GlyphActivateAnim:Restart();
    else
        self.GlyphActivateAnim:Stop();
        self.Button.GlyphActivateHighlight:Hide();
        self.Button.GlyphActiveIcon:Hide();
    end
end

-- I dont really care about clickBinding
function MacroBookItemMixin:UpdateClickBindState()
    if not self:HasValidData() then
        return;
    end

    local wasInClickBindMode = self.inClickBindMode;
    self.inClickBindMode = InClickBindingMode();
    self.canClickBind = false;

    if self.inClickBindMode and self.macroBookItemInfo.spellID and not self.isUnlearned then
        self.canClickBind = C_ClickBindings.CanSpellBeClickBound(self.macroBookItemInfo.spellID);
    end

    self.Button.ClickBindingHighlight:SetShown(self.canClickBind and ClickBindingFrame:HasEmptySlot());
    self.Button.ClickBindingIconCover:SetShown(self.inClickBindMode and not self.canClickBind);

    -- Update saturation, except on unlearned items as they already have their own desaturated state
    if not self.isUnlearned then
        -- Desaturate if binding active and can't click bind, otherwise restore saturation
        local saturation = (self.inClickBindMode and not self.canClickBind) and 0.75 or 0;
        self.Button.Icon:SetDesaturation(saturation);
    end

    if self.inClickBindMode ~= wasInClickBindMode then
        -- Update action bar status as its highlight is disabled while in clickbind mode
        self:UpdateActionBarStatus();
    end
end

-- Event handlers for interaction
function MacroBookItemMixin:OnIconEnter()
    if not self:HasValidData() then
        return;
    end

    local tooltip = GameTooltip;
    tooltip:SetOwner(self.Button, "ANCHOR_RIGHT");

    if self.inClickBindMode and not self.canClickBind then
        GameTooltip_AddErrorLine(tooltip, CLICK_BINDING_NOT_AVAILABLE);
        tooltip:Show();
        return;
    end

    self.Button.IconHighlight:Show();
    self.Backplate:SetAlpha(self.hoverBackplateAlpha);

    tooltip:SetText(self.macroBookItemInfo.name);
    tooltip:AddLine(self.macroBookItemInfo.description or self.macroBookItemInfo.subName or "", 1, 1, 1);

    local actionBarStatusToolTip = nil -- self.actionBarStatus and MacroSearchUtil.GetTooltipForActionBarStatus(self.actionBarStatus);
    if actionBarStatusToolTip then
        GameTooltip_AddColoredLine(tooltip, actionBarStatusToolTip, LIGHTBLUE_FONT_COLOR);
    end

    tooltip:Show();

    ClearOnBarHighlightMarks();

    -- local macroID = self.macroBookItemInfo.macroID;
    -- if self.macroBookItemInfo.isCharacterMacro then
    --     UpdateOnBarHighlightMarksByMacro(macroID);
    -- else
    --     UpdateOnBarHighlightMarksByGlobalMacro(macroID);
    -- end

    ActionBarController_UpdateAllSpellHighlights();
end

function MacroBookItemMixin:OnIconLeave()
    if not self:HasValidData() then
        return;
    end

    self.Button.IconHighlight:Hide();
    self.Button.IconHighlight:SetAlpha(self.iconHighlightHoverAlpha);
    self.Backplate:SetAlpha(self.defaultBackplateAlpha);

    ClearOnBarHighlightMarks();

    -- Update action bar highlights
    ActionBarController_UpdateAllSpellHighlights();
    GameTooltip:Hide();
end

function MacroBookItemMixin:OnIconClick(button)
    -- if not self:HasValidData() then
    --     return;
    -- end

    -- local macroID = self.slotIndex;
    -- local actionID = self.slotIndex;

    -- -- **Handle Click Bind Mode**
    -- if self.inClickBindMode then
    --     if self.canClickBind and actionID and ClickBindingFrame:HasNewSlot() then
    --         ClickBindingFrame:AddNewAction(Enum.ClickBindingType.Macro, actionID);
    --     end
    --     -- **Handle Macro Execution**
    -- elseif button == "LeftButton" then
    --     RunMacro(macroID);
    -- end
end

function MacroBookItemMixin:OnModifiedIconClick(button)
    if not self:HasValidData() then
        return;
    end

    EventRegistry:TriggerEvent("MacroBookItemMixin.OnModifiedClick", self, button);

    if IsModifiedClick("CHATLINK") then
        if MacroFrameText and MacroFrameText:HasFocus() then
            -- Macro frame is open, so chat link inserts macro name into macro text
            local macroName = self.macroBookItemInfo.name;
            ChatEdit_InsertLink(macroName);
        else
            -- Insert macro name as a chat link
            local macroLink = GetMacroLink(self.macroBookItemInfo.index);
            ChatEdit_InsertLink(macroLink);
        end
    elseif IsModifiedClick("PICKUPACTION") then
        PickupMacro(self.macroBookItemInfo.index);
    end
end

function MacroBookItemMixin:OnIconDragStart()
    if not self:HasValidData() then
        return;
    end

    local macroInfo = addon.MacroBank:GetMacroInfoPlus(self.slotIndex);
    local macroData = addon.MacroBank:GetMacroDataByName(macroInfo.name);

    -- Create the macro if it doesn't exist
    if not macroInfo.macroID then
        macroInfo.macroID = addon:CreateMacro(macroInfo.name, macroData)
    end

    PickupMacro(macroInfo.macroID);
    self.macroGrabbed = true;
    self:UpdateActionBarStatus();
end

function MacroBookItemMixin:OnIconMouseDown()
    if not self:HasValidData() then
        return;
    end

    self.Button.IconHighlight:SetAlpha(self.iconHighlightPressAlpha);
end

function MacroBookItemMixin:OnIconMouseUp()
    if not self:HasValidData() then
        return;
    end

    self.Button.IconHighlight:SetAlpha(self.iconHighlightHoverAlpha);
end

function MacroBookItemMixin:OnGlyphActivateAnimFinished()
    self:UpdateGlyphState();
end

MacroBookItemMixin.ArtSet = {
    Square = {
        iconMask = "spellbook-item-spellicon-mask",
        iconHighlight = "spellbook-item-iconframe-hover",
        activeBorder = "spellbook-item-iconframe",
        activeBorderAnchors = {CreateAnchor("TOPLEFT", nil, "TOPLEFT", -11, 1),
                               CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 1, -7)},
        inactiveBorder = "spellbook-item-iconframe-inactive",
        inactiveBorderAnchors = {CreateAnchor("TOPLEFT", nil, "TOPLEFT", -10, 1),
                                 CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 2, -5)},
        borderSheenMask = "spellbook-item-iconframe-sheen-mask",
        borderSheenMaskAnchors = {CreateAnchor("TOPLEFT"), CreateAnchor("BOTTOMRIGHT")},
        trainableBackplate = "spellbook-item-needtrainer-iconframe-backplate"
    },
    Circle = {
        iconMask = "talents-node-circle-mask",
        iconHighlight = "spellbook-item-iconframe-passive-hover",
        activeBorder = "talents-node-circle-gray",
        activeBorderAnchors = {CreateAnchor("TOPLEFT", nil, "TOPLEFT", 0, 0),
                               CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, 0)},
        inactiveBorder = "spellbook-item-iconframe-passive-inactive",
        inactiveBorderAnchors = {CreateAnchor("TOPLEFT", nil, "TOPLEFT", 0, 0),
                                 CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, 0)},
        borderSheenMask = "talents-node-circle-sheenmask",
        borderSheenMaskAnchors = {CreateAnchor("CENTER")},
        trainableBackplate = "spellbook-item-needtrainer-passive-backplate"
    }
}

function MacroBookItemMixin:UpdateArtSet()
    if not self:HasValidData() then
        self.artSet = nil;
    elseif self.macroBookItemInfo.isPassive then
        self.artSet = MacroBookItemMixin.ArtSet.Circle;
    else
        self.artSet = MacroBookItemMixin.ArtSet.Square;
    end
end

MacroBookItemButtonMixin = MacroBookItemButtonMixin or {};

function MacroBookItemButtonMixin:OnLoad()
    self:RegisterForDrag("LeftButton");
    -- self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function MacroBookItemButtonMixin:OnClick(button)
    if IsModifiedClick() then
        self:GetParent():OnModifiedIconClick(button);
    else
        self:GetParent():OnIconClick(button);
    end
end

function MacroBookItemButtonMixin:OnEnter()
    self:GetParent():OnIconEnter();
end

function MacroBookItemButtonMixin:OnLeave()
    self:GetParent():OnIconLeave();
end

function MacroBookItemButtonMixin:OnDragStart()
    self:GetParent():OnIconDragStart();
end

function MacroBookItemButtonMixin:OnMouseDown()
    self:GetParent():OnIconMouseDown();
end

function MacroBookItemButtonMixin:OnMouseUp()
    self:GetParent():OnIconMouseUp();
end
