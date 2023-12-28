local addonName, addon = ...

addon.defaults = {
	profile = {
		["*"] = {
			toggleOption = true
		},
		selectedMacro = "",
	},
}

addon.options = {
	type = "group",
	name = addon.title,
	handler = addon,
	args = {
		mainGroup = {
			type = "group",
			name = "Macros",
			order = 1,
			inline = true,
			args = {
				macroSelect = {
					type = "select",
					order = 0,
					name = "Select Macro",
					desc = "Select a macro to manage",
					values = function() return addon:GetMacroNames() end, -- Use the function here
					get = "GetSelectedMacro",
					set = "SetSelectedMacro",
				},
				createCustomMacro = {
					type = "execute",
					order = 1,
					name = "Create Custom Macro",
					desc = "Create a new custom macro",
					func = "CreateCustomMacro",
				},
			},
		},
		optionsGroup = {
			type = "group",
			name = "Options",
			order = 2,
			inline = true,
			args = {
				-- Options for the selected macro
				-- These options will be dynamically updated based on the selected macro
			},
		},
	},
}

-- Define the function that returns a table of macro names
function addon:GetMacroNames()
	local macroNames = {}

	-- Iterate over all categories of macros
	for _, macroCategory in pairs(self.macroData) do
		-- Add the names of the macros in the current category
		for macroName, _ in pairs(macroCategory) do
			macroNames[macroName] = macroName
		end
	end

	return macroNames
end

function addon:GetSelectedMacro(info)
	return self.db.profile.selectedMacro
end

function addon:SetSelectedMacro(info, value)
	self.db.profile.selectedMacro = value
	-- Update the options for the selected macro
	self:UpdateOptions(value)
end

function addon:UpdateOptions(selectedMacro)
	-- Update the args of the optionsGroup based on the selected macro
	self.options.args.optionsGroup.args = self:GetOptionsForMacro(selectedMacro)
end

function addon:GetOptionsForMacro(macro)
	-- Return the options for the given macro
	local options = {
		["toggle" .. macro] = {
			type = "toggle",
			order = 0,
			name = "Toggle",
			desc = "Manage " .. macro .. " macro",
			get = "GetToggle",
			set = "SetToggle",
		},
		spacer1 = {
			type = "description",
			order = 1,
			name = "",
		},
		itemLinks = {
			type = "input",
			order = 2,
			name = "Audit",
			desc = "The items found for the " .. macro .. " macro",
			multiline = 10,
			get = function() return self:GetItemLinksForMacro(macro) end,
			set = function() end, -- Read-only, so no set function
		},
		spacer2 = {
			type = "description",
			order = 3,
			name = "",
		},
		customMacroHeader = {
			type = "header",
			order = 4,
			name = "Custom Macro",
		},
		customMacro = {
			name = "Toggle Custom Macro",
			desc = "This will replace the default macro, granting you direct control over the macro string",
			type = "toggle",
			set = function(info, val) addon.db.profile[macro].customMacroEnabled = val end,
			get = function(info) return addon.db.profile[macro].customMacroEnabled end,
			order = 5,
		},
		spacer3 = {
			type = "description",
			order = 6,
			name = "",
		},
		macroString = {
			type = "input",
			name = "Macro String",
			desc = "Edit the macro string",
			multiline = 10,
			set = function(info, val) addon.db.profile[macro].macroString = val end,
			get = function(info) return addon.db.profile[macro].macroString end,
			order = 7,
		},
		parameters = {
			type = "input",
			name = "Parameters",
			desc = "Add parameters separated by commas",
			multiline = 10,
			set = function(info, val) addon.db.profile[macro].parameters = val end,
			get = function(info) return addon.db.profile[macro].parameters end,
			order = 8,
		},
	}
	return options
end

function addon:GetItemLinksForMacro(macro)
	-- Initialize the item links string as empty
	local itemLinksString = ""

	-- Define the callback function
	local function callback(macroInfo)
		-- Check if the macroInfo is the selected macro
		if macroInfo.name == macro and macroInfo.items then
			-- Initialize an empty table to hold the item links
			local itemLinks = {}

			-- Extract the link from each item and add it to the itemLinks table
			for i = 1, #macroInfo.items do
				local item = macroInfo.items[i]
				if item.link then
					table.insert(itemLinks, item.link)
				end
			end

			-- Convert the itemLinks table to a string
			itemLinksString = table.concat(itemLinks, "\n")
		end
	end

	-- Use the forEachMacro function to apply the callback to each macro
	self:forEachMacro(callback)

	return itemLinksString
end

function addon:GetToggle(info)
	local macroKey = info[#info]
	return self.db.profile[macroKey].toggleOption
end

function addon:SetToggle(info, value)
	local macroKey = info[#info]
	if not self.db.profile[macroKey] then
		self.db.profile[macroKey] = {}
	end
	self.db.profile[macroKey].toggleOption = value
end

function addon:GetValue(info)
	return self.db.profile[info[#info]]
end

function addon:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
