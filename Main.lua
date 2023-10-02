--@class addon
local addonName, addon = ...

addon = LibStub("AceAddon-3.0"):NewAddon("addon", "AceEvent-3.0", "AceConsole-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

addon.title = "Macrobial"

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(addon.title .."DB", self.defaults)
    
    AceConfig:RegisterOptionsTable(addon.title .."_Options", self.options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addon.title .."_Options", addon.title)
    
    -- AceConfig:RegisterOptionsTable(addon.title .."_paperDoll", self.paperDoll)
    -- AceConfigDialog:AddToBlizOptions(addon.title .."_paperDoll", "Paper Doll", "addon")
    
    self:GetCharacterInfo()
end

function addon:OnEnable()
    -- self:RegisterEvent("PLAYER_STARTED_MOVING")
    -- self:RegisterEvent("CHAT_MSG_CHANNEL")
end

--[[ function addon:PLAYER_STARTED_MOVING(event)
    print(event)
end ]]

--[[ function addon:CHAT_MSG_CHANNEL(event, text, ...)
    print(event, text, ...)
end ]]

function addon:GetCharacterInfo()
    -- stores character-specific data
    self.db.char.level = UnitLevel("player")
end

function addon:SlashCommand(input, editbox)

    -- input is everything after the slash command
    input = input:trim()
    if input == "enable" then
        self:Enable()
        self:Print("Enabled.")
    elseif input == "disable" then
        -- unregisters all events and calls addon:OnDisable() if you defined that
        self:Disable()
        self:Print("Disabled.")
    elseif input == "message" then
        print("this is our saved message:", self.db.profile.someInput)
    else
        self:Print("Some useful help message.")
        -- https://github.com/Stanzilla/WoWUIBugs/issues/89
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        
    end
end