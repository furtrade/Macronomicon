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
	}
	return options
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
