local addonName, addon = ...

-- local itemID = 864
-- Function to extract text from a tooltip (both left and right sides)
local function TableOfContents(typFrame)
	if typFrame and typFrame:IsShown() then
		local atyp = {}
		atyp.onLeftSide, atyp.onRightSide = "", ""

		-- Iterate through tooltip lines and separate left and right sides
		for i = 1, typFrame:NumLines() do
			local lineLeft = _G[typFrame:GetName() .. "TextLeft" .. i]
			local lineRight = _G[typFrame:GetName() .. "TextRight" .. i]

			if lineLeft then
				local string = lineLeft:GetText()
				local isRetrieving = string:find("Retrieving")
				if isRetrieving then
					i = 1
				end
				if string then
					atyp.onLeftSide = atyp.onLeftSide .. string .. "\n"
				end
			end

			if lineRight then
				local string = lineRight:GetText()
				if string then
					atyp.onRightSide = atyp.onRightSide .. string .. "\n"
				end
			end
		end
		return atyp
	end
	return nil
end

local function GettypFrameFromItemID(itemID)
	local typFrame = CreateFrame("GameTooltip", "MyAddonTooltip", nil, "GameTooltipTemplate")
	-- Set the tooltip's owner to nil to prevent it from anchoring to the mouse
	typFrame:SetOwner(UIParent, "ANCHOR_NONE")
	typFrame:ClearLines()
	-- Set the tooltip to display information for the specified item ID
	typFrame:SetItemByID(itemID)

	return typFrame
end

-- print("\n")
-- local typFrame = GettypFrameFromItemID(itemID)
-- local typText = TableOfContents(typFrame)
-- if typText then
--    print("Left: \n" .. typText.onLeftSide)
--    print("Right: \n" .. typText.onRightSide)

-- else
--    print("Failed to extract tooltip text for Item ID " .. itemID)
-- end

-- Function to check if a tooltip contains specified regular expressions
function addon.TraceTooltip(itemInfo, ...)
	local typFrame = GettypFrameFromItemID(itemInfo.id)
	local typText = TableOfContents(typFrame)

	if typText then
		local patterns = { ... }

		for _, pattern in ipairs(patterns) do
			if string.match(typText.onLeftSide, pattern) or string.match(typText.onRightSide, pattern) then
				-- Match found! Now do something.
				-- imagine we found "well fed" in the tooltip
				-- we then set the item to the appropriate category eg "Buff Food"

				return true
			end
		end
	end
	return false
end
