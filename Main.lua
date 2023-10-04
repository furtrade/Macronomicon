--@class addon
local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon("addon", "AceEvent-3.0", "AceConsole-3.0", "AceHook-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local _G = _G

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
addon.title = GetAddOnMetadata(addonName, "Title")

addon.player = {
    localeClass = select(1, UnitClass("player")),
    class = select(2, UnitClass("player")),
    race = select(2, UnitRace("player")),
    faction = select(1,UnitFactionGroup("player"))
}

addon.itemsAvailable = {}
local activeItems = addon.itemsAvailable






function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addon.title .. "DB", self.defaults)
    
    AceConfig:RegisterOptionsTable(addon.title .. "_Options", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .. "_Options", addon.title)
    
    -- AceConfig:RegisterOptionsTable(addon.title .."_paperDoll", self.paperDoll)
    -- AceConfigDialog:AddToBlizOptions(addon.title .."_paperDoll", "Paper Doll", "addon")
    
    -- self:GetCharacterInfo()
    
    self:RegisterChatCommand(addon.title, "SlashCommand")
    self:RegisterChatCommand("mbl", "SlashCommand")

end

function addon:OnEnable()
    -- self:RegisterEvent("PLAYER_STARTED_MOVING")
    -- self:RegisterEvent("CHAT_MSG_CHANNEL")
end

function addon:SlashCommand(input, editbox)
    -- input is everything after the slash command
    -- input = input:trim()
    if input == "run" then
        self:Print("Running...")
        self:doTheThing()
    elseif input == "enable" then
        self:Enable()
        self:Print("Enabled.")
    elseif input == "disable" then
        -- unregisters all events and calls addon:OnDisable() if you defined that
        self:Disable()
        self:Print("Disabled.")
    elseif input == "message" then
        print("this is our saved message:", self.db.profile.someInput)
    else
        -- self:Print("Some useful help message.")
        -- https://github.com/Stanzilla/WoWUIBugs/issues/89
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        
    end
end

-- macro engine to create macros
function addon.macros:makeMacro(macroName, icon, items)
    local prefix = ">" -- add an option to change this later
    local macroName = prefix .. macroName
    local macroExists = GetMacroInfo(macroName)
    if not macroExists then CreateMacro(macroName, icon) end
    
    local tip = "#showtooltip "
    local cast = "\n/cast "
    
    local macro = tip
    -- for _, item in ipairs(items) do
    --     macro = macro .. cast .. item.name
    -- end
    if items[1] then  -- Check if the first element exists
        macro = macro .. cast .. items[1].name
    end
    
    
    EditMacro(macroName, macroName, icon, macro)
end

-- check which macros are enabled and create them.
function addon.macros:processMacros(table)
    if not table then table = addon.macros end
    
    -- which macros are enabled? e.g. "HealPotMacro"
    for _, macroInfo in ipairs(table) do
        if macroInfo.enabled then
            -- Go through the macroList and create the macros
            local name = macroInfo.name
            local icon = macroInfo.icon
            local items = macroInfo.items
            
            addon.macros:makeMacro(name, icon, items)
        end
    end
end


-- helper function for scanning bags
local function itemizer(dollOrBagIndex, slotIndex)
    local itemLink = slotIndex and C_Container.GetContainerItemLink(dollOrBagIndex, slotIndex) or GetInventoryItemLink("player", dollOrBagIndex)
    
    if itemLink then
        -- Check if the item can be used
        local itemID =  tonumber(string.match(itemLink, "item:(%d+):"))
        if itemID then
            local canUse = C_PlayerInfo.CanUseItem(itemID)
            
            -- Get item type and subtype and equipSlotLocation
            local itemLevel, _, itemType, itemSubType, _, equipLoc = select(4, GetItemInfo(itemID))
            
            -- does the item have a spell associated with it?
            local itemSpell, itemSpellId = GetItemSpell(itemID)
            
            --Bundle the item info for the activeItems table.
            if canUse then
                local itemInfo = {}
                itemInfo.id = itemID
                itemInfo.link = itemLink
                itemInfo.name = C_Item.GetItemNameByID(itemID)
                itemInfo.equipLoc = equipLoc
                local count = GetItemCount(itemID)
                itemInfo.count = count
                itemInfo.type = itemType
                itemInfo.subType = itemSubType
                itemInfo.spellName = itemSpell
                itemInfo.spellId = itemSpellId
                itemInfo.level = itemLevel
                
                return itemInfo
            end
        end
    end
end

-- helper function to sort items by type, e.g. health pots, mana pots, food, etc.
local function sortTableByLevel(items)
    table.sort(items, function(a, b)
        if a.level and b.level then
            return a.level > b.level
        elseif a.level then
            return true
        elseif b.level then
            return false
        else
            return false
        end
    end)
end

-- We need to categorise items in activeItems[itemType] eg "Consumables" 
-- into desired categories such as health pots, mana pots, food, drink, devices, etc.
local function matchMaker(table1, table2, keywords)
    for _, keyword in ipairs(keywords) do
        for _, item in ipairs(table1) do
            for match in string.gmatch(item.spellName:lower(), keyword:lower()) do
                if match then
                    table.insert(table2, item)
                    -- break  -- exit inner loop after first match
                end
            end
        end
    end
end

-- loop through activeItems and sort them into categories
--[[ function addon.items:moveToMacros(itemsTable)
-- push activeItems into addon.macros.
for _, macroInfo in pairs(addon.macros) do
    matchMaker(itemsTable, macroInfo.items, macroInfo.keywords)
end
end ]]

-- scan bags for items we can use
function addon.items:refreshActiveItems()
    activeItems = {}
    
    -- inventory 
    for bagOrSlotIndex = 1, 19 do
        local itemInfo = itemizer(bagOrSlotIndex);
        
        if itemInfo then
            local itemType = itemInfo.type
            local spellName = itemInfo.spellName
            if itemType and spellName then
                if not activeItems[itemType] then
                    activeItems[itemType] = {}
                end
                table.insert(activeItems[itemType], itemInfo);
            end
        end
    end
    
    -- bags
    for bagOrSlotIndex = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bagOrSlotIndex);
        if numSlots > 0 then
            for slotIndex = 1, numSlots do
                local itemInfo = itemizer(bagOrSlotIndex, slotIndex)
                
                if itemInfo then
                    local itemType = itemInfo.type
                    -- local slotEnabled = itemInfo.slotEnabled
                    if itemType then
                        if not activeItems[itemType] then
                            activeItems[itemType] = {}
                        end
                        table.insert(activeItems[itemType], itemInfo);
                    end
                end
            end
        end
    end
    
    -- send items to the macros tables
    for _, macroInfo in pairs(addon.macros) do
        if activeItems then
            matchMaker(activeItems, macroInfo.items, macroInfo.keywords)
        end
    end
    for _, macroInfo in pairs(addon.macros) do
        if macroInfo.items then
            sortTableByLevel(macroInfo.items)
        end
    end
    -- now we need to prune the macro items to be usable.
end

-- function to run the addon and create the macros
function addon:doTheThing()
    self:Print("Refreshing Active Items...")
    addon.items:refreshActiveItems()
    print("\nRefreshed active items... \nProcessing Macros")
    addon.macros:processMacros()
end