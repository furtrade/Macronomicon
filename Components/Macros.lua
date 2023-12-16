local addonName, addon = ...

-- Entry point for processing macros (1st to execute)
-- Iterates over macro data and processes each macro
function addon:processMacros(macroTables)
	macroTables = macroTables or addon.macroData

	for _, macroInfo in pairs(macroTables) do
		if self:isMacroEnabled(macroInfo.enabled) then
			self:createOrUpdateMacro(macroInfo)
		end
	end
end

-- Checks if a macro is enabled in the addon's settings (2nd to execute)
function addon:isMacroEnabled(macroKey)
	return addon.db.profile[macroKey]
end

-- Handles creation or update of a macro (3rd to execute)
function addon:createOrUpdateMacro(macroInfo)
	local macroName = self:getMacroName(macroInfo.name)
	if not self:macroExists(macroName) then
		self:createMacro(macroName)
	end
	self:updateMacro(macroName, macroInfo)
end

-- Constructs the full macro name with a prefix (4th to execute)
function addon:getMacroName(name)
	local prefix = "!" -- Make this configurable if needed
	return prefix .. name
end

-- Checks if a macro already exists (5th to execute)
function addon:macroExists(name)
	return GetMacroInfo(name) ~= nil
end

-- Creates a new macro in the game (6th to execute)
function addon:createMacro(name)
	CreateMacro(name, "INV_Misc_QuestionMark")
end

-- Updates an existing macro with new content (7th to execute)
function addon:updateMacro(macroName, macroInfo)
	local macroString = self:buildMacroString(macroInfo)
	EditMacro(macroName, macroName, macroInfo.icon, macroString)
end

-- TODO: Make sure to actually implement a scoring system in the main block.
function addon:getHighestScoringItem(items)
	-- Initialize variables to track the favored item and its highest score
	local favoredItem, highestScore = nil, -1

	-- Loop through the items to find the one with the highest score
	for _, item in ipairs(items) do
		-- Check if the item has a score and if it's the highest
		if item.score and item.score > highestScore then
			favoredItem = item
			highestScore = item.score
		end
	end

	-- Fallback: Select the first item if no scored item is found
	if not favoredItem and #items > 0 then
		favoredItem = items[1]
	end

	-- Return the item with the highest score or the first item as a fallback
	return favoredItem
end

-- Builds the macro string from the provided macro information (8th to execute)
function addon:buildMacroString(macroDef)
	local macroLines = { "#showtooltip" }

	-- Get the favored (highest scoring) item
	local favoredItem = self:getHighestScoringItem(macroDef.items)

	-- Building the macro line for the favored item
	if favoredItem then
		print(favoredItem.name)
		local conditionPart = macroDef.condition and " [" .. macroDef.condition .. "]" or ""
		local line = "/cast" .. conditionPart .. " " .. favoredItem.name
		table.insert(macroLines, line)
	end

	-- Process nuances for the macro definition
	if macroDef.nuance and type(macroDef.nuance) == "function" then
		macroDef.nuance(macroLines)
	end

	return table.concat(macroLines, "\n")
end
