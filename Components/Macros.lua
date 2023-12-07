local addonName, addon = ...

-- macro engine to create macros
function addon:makeMacro(name, icon, items)
	local prefix = "!" -- add an option to change this later
	local macroName = prefix .. name

	-- check if the macro exists already
	local macroExists = GetMacroInfo(macroName)
	if not macroExists then
		CreateMacro(macroName, "INV_Misc_QuestionMark")
	end

	-- build the macro string
	local tip = "#showtooltip "
	local cast = "\n/cast "

	local macro = tip
	-- for _, item in ipairs(items) do
	--     macro = macro .. cast .. item.name
	-- end
	if items[1] then -- Check if the first element exists
		macro = macro .. cast .. items[1].name
	end

	EditMacro(macroName, macroName, icon, macro)
	-- self:Print("Done!")
end

-- check which macros are enabled and create them.
function addon:processMacros(macroTables)
	if not macroTables then
		macroTables = addon.macroData
	end
	-- which macros are enabled? e.g. "HealPotMacro"
	for _, macroInfo in pairs(macroTables) do
		-- check if the macro is enabled
		if addon.db.profile[macroInfo.enabled] then
			-- get macro info
			local name = macroInfo.name
			local icon = macroInfo.icon
			local items = macroInfo.items

			addon:makeMacro(name, icon, items)
		end
	end
end
