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
		toggleMain = {
			type = "toggle",
			order = 0,
			name = "Main",
			desc = "Primary spammable attack macro",
			get = "GetValue",
			set = "SetValue",
		},
		toggleHP = {
			type = "toggle",
			order = 1,
			name = "Health Potion",
			desc = "Manage health potions macro",
			get = "GetValue",
			set = "SetValue",
			-- inline getter/setter example
			-- get = function(info) return addon.db.profile.toggleHP end,
			-- set = function(info, value) addon.db.profile.toggleHP = value end,
		},
		toggleMP = {
			type = "toggle",
			order = 1.2,
			name = "Mana Potion",
			desc = "Manage mana potions macro",
			-- inline getter/setter example
			get = "GetValue",
			set = "SetValue",
		},
		toggleFood = {
			type = "toggle",
			order = 1.4,
			name = "Food",
			desc = "Manage food macro",
			-- inline getter/setter example
			get = "GetValue",
			set = "SetValue",
		},
		toggleDrink = {
			type = "toggle",
			order = 1.6,
			name = "Drink",
			desc = "Manage drink macro",
			-- inline getter/setter example
			get = "GetValue",
			set = "SetValue",
		},
		toggleBandage = {
			type = "toggle",
			order = 1.8,
			name = "Bandage",
			desc = "Manage bandage macro",
			-- inline getter/setter example
			get = "GetValue",
			set = "SetValue",
		},
		toggleHS = {
			type = "toggle",
			order = 2,
			name = "Healthstone",
			desc = "Manage healthstone macro",
			-- inline getter/setter example
			get = "GetValue",
			set = "SetValue",
		},
		toggleBang = {
			type = "toggle",
			order = 2.2,
			name = "Bang",
			desc = "Manage bang macro",
			-- inline getter/setter example
			get = "GetValue",
			set = "SetValue",
		},
	},
}

function addon:GetValue(info)
	return self.db.profile[info[#info]]
end

function addon:SetValue(info, value)
	self.db.profile[info[#info]] = value
end
