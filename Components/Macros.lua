local addonName, addon = ...

-- Entry point for processing macros (1st to execute)
-- Iterates over macro data and processes each macro
--[[ function addon:ProcessMacros(macroTables)
	macroTables = macroTables or addon.macroData

	for macroType, macroTypeData in pairs(macroTables) do
		for _, macroInfo in pairs(macroTypeData) do
			if self:isMacroEnabled(macroInfo.enabled) then
				self:createOrUpdateMacro(macroType, macroInfo)
			end
		end
	end
end ]]

-- Checks if a macro is enabled in the addon's settings (2nd to execute)
function addon:isMacroEnabled(macroKey)
	-- Check if the database is initialized
	if not self.db then
		print("Error: Database is not initialized")
		return false
	end

	-- Check if the macroKey exists in the profile
	if self.db.profile.macroS[macroKey] == nil then
		print("Error: Macro key '" .. macroKey .. "' does not exist in the profile")
		return false
	end

	-- Return the value of the toggleOption for the macroKey
	return self.db.profile.macroS[macroKey].toggleOption
end

-- Handles creation or update of a macro (3rd to execute)
function addon:createOrUpdateMacro(macroType, macroInfo)
	local macroName = self:getMacroName(macroInfo.name)
	if not self:macroExists(macroName) then
		self:createMacro(macroType, macroName)
	end
	self:updateMacro(macroName, macroInfo)
end

-- Constructs the full macro name with a prefix (4th to execute)
function addon:getMacroName(name)
	local prefix = "!" -- Make this configurable if needed
	return prefix .. name
end

function addon:standardizedName(text)
	-- Remove white space
	local formattedText = text:gsub("%s+", "")

	-- Keep only the first 9 characters
	formattedText = formattedText:sub(1, 9)

	return formattedText
end

-- Checks if a macro already exists (5th to execute)
function addon:macroExists(name)
	return GetMacroInfo(name) ~= nil
end

-- Creates a new macro in the game (6th to execute)
function addon:createMacro(macroType, name)
	local numGeneralMacros, numCharacterMacros = GetNumMacros()
	local perCharacter = macroType ~= "GENERAL" and numCharacterMacros < MAX_CHARACTER_MACROS
	CreateMacro(name, "INV_Misc_QuestionMark", nil, perCharacter)
end

function addon:DeleteGameMacro(macroName)
	-- Get the index of the macro
	local macroD = self:getMacroName(macroName)

	-- If the macro exists, delete it
	if macroD then
		DeleteMacro(macroD)
	end
end

-- Updates an existing macro with new content (7th to execute)
--[[ function addon:updateMacro(macroName, macroInfo)
	local macroString = self:buildMacroString(macroInfo)
	EditMacro(macroName, macroName, macroInfo.icon, macroString)
end ]]

function addon:selectElement(t)
	local selectedElement = nil
	local highestScore = -math.huge -- Initialize to lowest possible value

	-- Iterate over the elements
	for _, element in ipairs(t) do
		-- Debug: print element and its score
		-- print("Element: ", element)
		-- print("Score: ", element.score)

		-- Check if the score field is present and numeric
		if element.score then
			-- print("Score field is present.")

			if type(element.score) == "number" then
				-- print("Score field is a number.")

				-- Check if the element's score is higher than the current highest score
				if element.score > highestScore then
					highestScore = element.score
					selectedElement = element

					-- Debug: print new highest score and selected element
					-- print("New highest score: ", highestScore)
					-- print("Selected element: ", selectedElement)
				end
			else
				-- print("Score field is not a number.")
			end
		else
			-- print("Score field is not present.")
		end
	end

	-- Debug: print selected element before returning
	-- print("Final selected element: ", selectedElement)

	return selectedElement
end

-- Builds the macro string from the provided macro information (8th to execute)
function addon:buildMacroString(macroDef)
	local macroLines = { "#showtooltip" }

	-- Get the favored (highest scoring) item
	local favoredItem = self:selectElement(macroDef.items)

	-- Building the macro line for the favored item
	if favoredItem then
		-- print(favoredItem.name)
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
