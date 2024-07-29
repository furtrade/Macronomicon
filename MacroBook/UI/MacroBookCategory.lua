local _, addon = ...
function addon.SetupCategory()

    --[[
	Mixins for each of the categories (sub-tabs) in the SpellBook

	Each category contains one or more spell groups, each spell group contains a range of slot indices, and each slot index maps to a specific spellbook item.
	Which spell book item is in a specific slot index will change as spells/talents are learned and unlearned.
	These category mixins primarily track & maintain spell group index data, and corresponding specific spell book items are determined on demand for display.
]] --------------------------- Base Mixin --------------------------------
    SpellBookMacrobialCategory = {};
    -- SpellBookMacrobialCategory = CreateFromMixins(BaseSpellBookCategoryMixin)

    function SpellBookMacrobialCategory:Init(macroBookFrame)
        self.macroBookFrame = macroBookFrame;
        self:UpdateSpellGroups();
    end

    function SpellBookMacrobialCategory:SetTabID(tabID)
        self.tabID = tabID;
    end

    function SpellBookMacrobialCategory:GetTabID()
        return self.tabID;
    end

    function SpellBookMacrobialCategory:GetName()
        return self.displayName;
    end

    function SpellBookMacrobialCategory:GetMacroBank()
        return self.macroBank;
    end

    function SpellBookMacrobialCategory:GetCategoryEnum()
        return self.categoryEnum;
    end

    function SpellBookMacrobialCategory:GetSpellGroupForSlotIndex(slotIndex)
        for _, spellGroup in ipairs(self.spellGroups) do
            if spellGroup.spellBookItemSlotIndices and spellGroup.spellBookItemSlotIndices[slotIndex] then
                return spellGroup;
            end
        end
        return nil;
    end

    function SpellBookMacrobialCategory:ContainsSlot(slotIndex, spellBank)
        if not self.spellGroups then
            return false;
        end

        if self.spellBank ~= spellBank then
            return false;
        end

        local containingSpellGroup = self:GetSpellGroupForSlotIndex(slotIndex);
        return containingSpellGroup ~= nil;
    end

    -- Creates a data for use with a PagedContent frame
    -- byDataGroup: [bool] - See Blizzard_PagedContentFrame.lua -> SetDataProvider for details on expected group data format
    -- itemFilterFunc: [func<bool>(slotIndex, spellBank)] - OPTIONAL - filter function that returns true if the passed SpellBookItem should be included in the data
    -- tableToAppendTo: [table] OPTIONAL - Existing table that data tables should be appended to (rather than a newly created table)
    function SpellBookMacrobialCategory:GetSpellBookItemData(byDataGroup, itemFilterFunc, tableToAppendTo)
        if not self.spellGroups then
            return nil;
        end

        local returnData = tableToAppendTo or {};
        for _, spellGroup in ipairs(self.spellGroups) do
            local dataGroup = byDataGroup and {
                elements = {}
            } or nil;
            if byDataGroup and spellGroup.displayName then
                dataGroup.header = {
                    templateKey = "HEADER",
                    text = spellGroup.displayName,
                    spellGroup = spellGroup
                };
            end
            for _, slotIndex in pairs(spellGroup.orderedSpellBookItemSlotIndices) do
                if not itemFilterFunc or itemFilterFunc(slotIndex, self.spellBank) then
                    local itemEntry = self:GetElementDataForItem(slotIndex, self.spellBank, spellGroup);

                    if byDataGroup then
                        table.insert(dataGroup.elements, itemEntry);
                    else
                        table.insert(returnData, itemEntry);
                    end
                end
            end
            if byDataGroup then
                table.insert(returnData, dataGroup);
            end
        end

        return returnData;
    end

    function SpellBookMacrobialCategory:GetElementDataForItem(slotIndex, spellBank, spellGroup)
        if not spellGroup then
            spellGroup = self:GetSpellGroupForSlotIndex(slotIndex);
        end
        if not spellGroup then
            return nil;
        end

        return {
            templateKey = "MACRO",
            slotIndex = slotIndex,
            spellBank = spellBank,
            specID = spellGroup.specID,
            isOffSpec = spellGroup.isOffSpec or false,
            showActionBarStatus = spellGroup.showActionBarStatuses
        };
    end

    -- Returns true if any of the groups or index ranges within them changed between the old and new collection of groups
    function SpellBookMacrobialCategory:DidSpellGroupsChange(oldSpellGroups, newSpellGroups, compareSpellIndicies)
        if oldSpellGroups == nil and newSpellGroups == nil then
            return false;
        elseif oldSpellGroups == nil or newSpellGroups == nil then
            return true;
        end

        local compareDepth = compareSpellIndicies and 3 or 2;
        local anyNonIndicesChanges = not tCompare(oldSpellGroups, newSpellGroups, compareDepth);

        return anyNonIndicesChanges;
    end

    -- Use to populate spell groups with contiguous spell book item indices based on a defined offset and count
    function SpellBookMacrobialCategory:PopulateSpellGroupsIndiciesByRange()
        if not self.spellGroups then
            return;
        end

        for _, spellGroup in ipairs(self.spellGroups) do
            if spellGroup.numSpellBookItems and spellGroup.slotIndexOffset then
                spellGroup.spellBookItemSlotIndices = {}; -- Used for constant-time lookup of what indices the group contains
                spellGroup.orderedSpellBookItemSlotIndices = {}; -- Used for iterating over the indices in consistent order
                for i = 1, spellGroup.numSpellBookItems do
                    local slotIndex = spellGroup.slotIndexOffset + i;
                    spellGroup.spellBookItemSlotIndices[slotIndex] = true;
                    spellGroup.orderedSpellBookItemSlotIndices[i] = slotIndex;
                end
            end
        end
    end

    function SpellBookMacrobialCategory:Init(macroBookFrame)
        self.displayName = "Macrobial"
        self.spellBank = Enum.SpellBookSpellBank.Player -- Assuming Custom spells are player-specific
        self.categoryEnum = PlayerSpellsUtil.SpellBookCategories.Macrobial

        -- BaseSpellBookCategoryMixin.Init(self, macroBookFrame)
        self.macroBookFrame = macroBookFrame;
        self:UpdateSpellGroups();
    end

    function SpellBookMacrobialCategory:UpdateSpellGroups()
        addon.MacroBank:MergeMacros()

        local newSpellGroups = {}

        -- Creating spellgroup for Curated Macros
        -- local numMacros = addon.MacroBank:GetMacroCount() or 0;
        local macrosCurated = K_MacroBook.GetSpellBookSkillLineInfo(1)
        local curatedMacros = {
            displayName = "Curated",
            slotIndexOffset = macrosCurated.itemIndexOffset, -- Adjust as needed
            numSpellBookItems = macrosCurated.numSpellBookItems, -- Adjust as needed
            showActionBarStatuses = false,
            spellBookItemSlotIndices = {}, -- Handled by PopulateSpellGroupsIndiciesByRange
            orderedSpellBookItemSlotIndices = {} -- Handled by PopulateSpellGroupsIndiciesByRange
        }
        table.insert(newSpellGroups, curatedMacros);

        local macrosMisc = K_MacroBook.GetSpellBookSkillLineInfo(2)
        local miscMacros = {
            displayName = "Misc",
            slotIndexOffset = macrosMisc.itemIndexOffset, -- Adjust as needed
            numSpellBookItems = macrosMisc.numSpellBookItems, -- Adjust as needed
            showActionBarStatuses = false,
            spellBookItemSlotIndices = {}, -- Handled by PopulateSpellGroupsIndiciesByRange
            orderedSpellBookItemSlotIndices = {} -- Handled by PopulateSpellGroupsIndiciesByRange
        }
        table.insert(newSpellGroups, miscMacros);

        local compareSpellIndicies = false
        local anyChanges = self:DidSpellGroupsChange(self.spellGroups, newSpellGroups, compareSpellIndicies)

        if anyChanges then
            self.spellGroups = newSpellGroups
            self:PopulateSpellGroupsIndiciesByRange()
        end

        return anyChanges
    end

    function SpellBookMacrobialCategory:IsAvailable()
        return true
    end

    function SpellBookMacrobialCategory:ContainsSkillLine(skillLineIndex)
        -- if not self.spellGroups then
        --     return false
        -- end

        -- for _, spellGroup in ipairs(self.spellGroups) do
        --     if spellGroup.skillLineIndex == skillLineIndex then
        --         return true
        --     end
        -- end
        return false
    end

    -- end of SetupCategory (╯°□°）╯︵ ┻━┻
end

function addon.InitializePlayerSpellsUtil()
    -- addon.logMsg("Init PlayerSpellsUtil.")
    if PlayerSpellsUtil and PlayerSpellsUtil.SpellBookCategories then
        PlayerSpellsUtil.SpellBookCategories.Macrobial = 4
        -- addon.logMsg("Custom category added.")
        addon.customCategoryInitialized = true
    else
        -- addon.logMsg("PlayerSpellsUtil.SpellBookCategories missing.")
    end
end

-- Function to nudge a frame by xOffset and yOffset
local function NudgeFrame(frame, xOffset, yOffset)
    if frame and frame.GetPoint then
        -- Get the current point of the frame
        local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
        if point then
            -- Calculate the new offsets
            local newXOffset = (xOfs or 0) + xOffset
            local newYOffset = (yOfs or 0) + yOffset

            -- Set the new point with the new offsets
            frame:ClearAllPoints()
            frame:SetPoint(point, relativeTo, relativePoint, newXOffset, newYOffset)

            -- Print the new position for debugging
            -- print("frame moved to new position: " .. newXOffset .. ", " .. newYOffset)
        else
            print("Unable to retrieve the current position of the frame.")
        end
    else
        print("Invalid frame or frame does not support GetPoint.")
    end
end

local function OnClickBtnXT()
    -- Function to extend the OnClick handler of a frame
    local function OnClickXT(frame, xt)
        if frame and frame.HookScript then
            -- Hook into the OnClick script of the frame
            frame:HookScript("OnClick", function(...)
                print("trying")
                -- Call the new function
                xt(...)
            end)
        else
            print("Invalid frame or frame does not support HookScript.")
        end
    end

    -- Some localized Blizzard frames
    local blizz = PlayerSpellsFrame.SpellBookFrame
    local blizzTabSystem = PlayerSpellsFrame.SpellBookFrame.CategoryTabSystem

    local function OnClickSpellBookTab(self, button, down)
        MacroBookFrame.CategoryTabSystem:SetTabVisuallySelected(0)
        MacroBookFrame.PagedSpellsFrame:Hide()
        blizz.PagedSpellsFrame:Show()
    end

    for i, button in ipairs(blizzTabSystem.tabs) do
        -- print("Initializing button in blizzTabSystem: ", button.tabText) -- Debugging
        OnClickXT(button, OnClickSpellBookTab)
    end

    local function OnClickMacroBookTab(self, button, down)
        blizzTabSystem:SetTabVisuallySelected(0)
        blizz.PagedSpellsFrame:Hide()
        MacroBookFrame.PagedSpellsFrame:Show()
    end

    for i, button in ipairs(MacroBookFrame.CategoryTabSystem.tabs) do
        -- print("Initializing button in MacroBookFrame: ", button.tabText) -- Debugging
        OnClickXT(button, OnClickMacroBookTab)
    end
end

-- Function to create and initialize the custom category
function addon.CreateAndInitCustomCategory()
    local blizz = PlayerSpellsFrame.SpellBookFrame

    MacroBookFrame = CreateFrame("Frame", "MacroBookFrame", PlayerSpellsFrame, "MacroBookFrameTemplate")
    MacroBookFrame.PagedSpellsFrame:Hide()
    MacroBookFrame:SetPoint("TOPLEFT", blizz, "TOPLEFT")
    MacroBookFrame:SetPoint("BOTTOMRIGHT", blizz, "BOTTOMRIGHT")

    MacroBookFrame:SetFrameLevel(blizz:GetFrameLevel() + 1)
    -- 🤗This might require some more effort
    NudgeFrame(MacroBookFrame.CategoryTabSystem, 200, 0)
    MacroBookFrame.CategoryTabSystem:SetTabVisuallySelected(0)

    MacroBookFrame.isMinimzed = blizz.isMinimized
    MacroBookFrame.lastActiveTabID = blizz.lastActiveTabID
    MacroBookFrame.maximizedWidth = blizz.maximizedWidth
    MacroBookFrame.maximizedWidth = blizz.maximizedWidth
    MacroBookFrame.view1MaaximizedXOffset = blizz.view1MaaximizedXOffset
    MacroBookFrame.view1MinimizedXOffset = blizz.view1MinimizedXOffset
    MacroBookFrame.view1YOffset = blizz.view1YOffset

    MacroBookFrame:SetMinimized(blizz.isMinimized)

    OnClickBtnXT()
end
