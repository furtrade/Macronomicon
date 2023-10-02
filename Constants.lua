--@class ma : Macrobial
local Macrobial = LibStub("AceAddon-3.0"):GetAddon("Macrobial")

ma.spellBookHeals = {
    ["Crimson Vial"] = 185311, --Rogue
    ["Renewal"] = 108238, --Druid
    ["Exhilaration"] = 109304, --Hunter
    ["Fortitude of the Bear"] = 272679, --Hunter
    ["Bitter Immunity"] = 383762, --Warrior
    ["Desperate Prayer"] = 19236, --Priest
    ["Expel Harm"] = 322101, --Monk
    ["Healing Elixir"] = 122281 --Monk
    }
    
    
    function ma:getSpellsHeals();
        local spellBook = {};
    
        -- iterate through ma.spellList and check if spell is known.
        -- if spell is known, add it to spellKnown table.
        for spellName, spellId in pairs(ma.spellBookHeals) do
            if IsSpellKnown(spellId) then
                table.insert(spellBook, spellName);
            end
        end
        return spellBook
    end