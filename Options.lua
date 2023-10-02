--this line is needed for the Options to show up in the Interface Options window
local addon = LibStub("AceAddon-3.0"):GetAddon("addon")


addon.defaults = {
	profile = {
		someToggle = true,
		someRange = 7,
		someInput = "Hello World",
		someSelect = 2, -- Banana
	},
}

-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables
addon.options = {
	type = "group",
	name = addon.title .." (label 2)",
	handler = addon,
	args = {
		someToggle = {
			type = "toggle",
			order = 1,
			name = "a checkbox",
			desc = "some description",
			-- inline getter/setter example
			get = function(info) return addon.db.profile.someToggle end,
			set = function(info, value) addon.db.profile.someToggle = value end,
		},
		someRange = {
			type = "range",
			order = 2,
			name = "a slider",
			-- this will look for a getter/setter on our handler object
			get = "GetSomeRange",
			set = "SetSomeRange",
			min = 1, max = 10, step = 1,
		},
		someKeybinding = {
			type = "keybinding",
			order = 3,
			name = "a keybinding",
			get = "GetValue",
			set = "SetValue",
		},
		group1 = {
			type = "group",
			order = 4,
			name = "a group",
			inline = true,
			-- getters/setters can be inherited through the table tree
			get = "GetValue",
			set = "SetValue",
			args = {
				someInput = {
					type = "input",
					order = 1,
					name = "an input box",
					width = "double",
				},
				someDescription = {
					type = "description",
					order = 2,
					name = function() return format("The current time is: |cff71d5ff%s|r", date("%X")) end,
					fontSize = "large",
				},
				someSelect = {
					type = "select",
					order = 3,
					name = "a dropdown",
					values = {"Apple", "Banana", "Strawberry"},
				},
			},
		},
	},
}

function addon:GetSomeRange(info)
	return self.db.profile.someRange
end

function addon:SetSomeRange(info, value)
	self.db.profile.someRange = value
end

-- for documentation on the info table
-- https://www.wowace.com/projects/ace3/pages/ace-config-3-0-options-tables#title-4-1
function addon:GetValue(info)
	return self.db.profile[info[#info]]
end

function addon:SetValue(info, value)
	self.db.profile[info[#info]] = value
end