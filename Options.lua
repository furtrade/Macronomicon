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
					values = {
						["Main"] = "Main",
						["HP"] = "Health Potion",
						["MP"] = "Mana Potion",
						["Food"] = "Food",
						["Drink"] = "Drink",
						["Bandage"] = "Bandage",
						["HS"] = "Healthstone",
						["Bang"] = "Bang",
					},
					get = "GetSelectedMacro",
					set = "SetSelectedMacro",
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
		itemLinks = {
			type = "input",
			order = 1,
			name = "Item Links",
			desc = "The item links for the " .. macro .. " macro",
			multiline = 10,
			get = function() return self:GetItemLinksForMacro(macro) end,
			set = function() end, -- Read-only, so no set function
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
