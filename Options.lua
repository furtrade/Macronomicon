local addonName, addon = ...

addon.defaults = {
	profile = {
		["*"] = true,
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
						["toggleMain"] = "Main",
						["toggleHP"] = "Health Potion",
						["toggleMP"] = "Mana Potion",
						["toggleFood"] = "Food",
						["toggleDrink"] = "Drink",
						["toggleBandage"] = "Bandage",
						["toggleHS"] = "Healthstone",
						["toggleBang"] = "Bang",
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
		toggleOption = {
			type = "toggle",
			order = 0,
			name = macro,
			desc = "Manage " .. macro .. " macro",
			get = "GetValue",
			set = "SetValue",
		},
	}
	return options
end

function addon:GetValue(info)
	return self.db.profile[info[#info]]
end

function addon:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
