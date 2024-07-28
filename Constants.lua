local addonName, addon = ...

local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
addon.title = GetAddOnMetadata(addonName, "Title")

-- Table lookup for game versions
local gameVersionLookup = {
    [110000] = "RETAIL",
    [100000] = "DRAGONFLIGHT",
    [90000] = "SHADOWLANDS",
    [80000] = "BFA",
    [70000] = "LEGION",
    [60000] = "WOD",
    [50000] = "MOP",
    [40000] = "CATA",
    [30000] = "WOTLK",
    [20000] = "TBC"
}
local gameVersion = select(4, GetBuildInfo())
addon.gameVersion = gameVersion
-- Find the appropriate game version
for version, name in pairs(gameVersionLookup) do
    if gameVersion >= version then
        addon.game = name
        break
    end
end
