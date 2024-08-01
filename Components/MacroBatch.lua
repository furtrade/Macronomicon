local _, addon = ...

local lastTrigger = 0
local threshold = 5
local retryPending = false
local pauseEditing = false
local phaseOneComplete = false
local inCombat = false

function addon:OnEventThrottle(event, force)
    local currentTime = GetTime()
    if force or currentTime - lastTrigger > threshold then
        self:tryAction()
    elseif not retryPending then
        local timeToAct = threshold - (currentTime - lastTrigger)
        retryPending = true
        C_Timer.After(timeToAct, function()
            retryPending = false
            self:tryAction()
        end)
    end
end

function addon:tryAction()
    if self:ProcessAll() then
        lastTrigger = GetTime()
    end
end

function addon:PrepMacroForEditing(name, info, id)
    local info = info or addon.MacroBank:GetMacroDataByName(name)
    local prefixedName = self:prefixedMacroName(info.name)
    local macroID = id or self:getMacroIDByName(name)
    local macroString = info.isCustom and self:patchMacro(info) or self:buildMacroString(info)
    local iconID = info.icon or "INV_Misc_QuestionMark"
    return {
        macroID = macroID,
        name = prefixedName,
        icon = iconID,
        macroString = macroString
    }
end

function addon:EditQueuedMacro(index)
    if inCombat then
        pauseEditing = true
        return
    end

    local queuedMacro = self.QueuedMacros[index]
    if EditMacro(queuedMacro.macroID, queuedMacro.name, queuedMacro.icon, queuedMacro.macroString) then
        table.remove(self.QueuedMacros, index)
        -- Update the index of remaining macros
        for i = index, #self.QueuedMacros do
            self.QueuedMacros[i].index = i
        end
    end
end

addon.QueuedMacros = {}
function addon:QueueMacros()
    if not self.QueuedMacros then
        self.QueuedMacros = {}
    end

    for _, info in pairs(self.macroData) do
        local prepMacro = self:PrepMacroForEditing(info.name, info)
        prepMacro.index = #self.QueuedMacros + 1
        table.insert(self.QueuedMacros, prepMacro)
    end
end

function addon:FulfilQueuedMacros()
    local index = 1
    while index <= #self.QueuedMacros do
        self:EditQueuedMacro(index)
        if pauseEditing then
            break
        end
        index = index + 1
    end
end

function addon:RunPhaseOne()
    self:UpdateItemCache()
    self:QueueMacros()
    phaseOneComplete = true
end

function addon:RunPhaseTwo()
    self:FulfilQueuedMacros()
end

function addon:ProcessAll()
    if not phaseOneComplete then
        self:RunPhaseOne()
    end
    self:RunPhaseTwo()

    -- Check if all macros have been processed
    if #self.QueuedMacros == 0 then
        phaseOneComplete = false -- Reset for the next cycle
        return true -- signal that tryAction succeeded
    else
        return false -- indicate that phase two is still running
    end
end

function addon:OnCombatStart()
    inCombat = true
end

function addon:OnCombatEnd()
    inCombat = false
    if pauseEditing then
        pauseEditing = false
        self:FulfilQueuedMacros()
    end
end

-- Function to force the process immediately
function addon:ForceProcess()
    -- reset flags so we can force the event
    lastTrigger = 0
    retryPending = false
    pauseEditing = false
    phaseOneComplete = false

    self:OnEventThrottle(_, true)
end

-- Register for combat events
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        addon:OnCombatStart()
    elseif event == "PLAYER_REGEN_ENABLED" then
        addon:OnCombatEnd()
    end
end)
