local _, addon = ...

local lastTrigger = 0
local threshold = 5
local retryPending = false

function addon:OnEventThrottle(event)
    -- The throttle logic
    local currentTime = GetTime()
    if currentTime - lastTrigger > threshold then
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
    -- Scan and Collect data for ou macros
    if self:ProcessAll() then
        -- returned true
        lastTrigger = GetTime()
    end
end

function addon:PrepMacroForEditing(name, info, id)
    local info = info or addon.MacroBank:GetMacroDataByName(name)

    -- Gather necessary information
    local prefixedName = self:prefixedMacroName(info.name)
    local macroID = id or self:getMacroIDByName(name)
    local macroString = info.isCustom and self:patchMacro(info) or self:buildMacroString(info)
    local iconID = info.icon or "INV_Misc_QuestionMark"

    -- Return the information needed to edit the macro
    return {
        macroID = macroID,
        name = prefixedName,
        icon = iconID,
        macroString = macroString
    }
end

-- function to edit a macro from the QueuedMacros table
function addon:EditQueuedMacro(queuedMacro)
    -- We should add some combat checks here to pause the process 
    -- and then resume later when combat ends

    -- Edit the macro in the queue
    if EditMacro(queuedMacro.macroID, queuedMacro.name, queuedMacro.icon, queuedMacro.macroString) then
        -- returned macroID so we proceed to...
        -- remove the macro from the QueuedMacros table.
        table.remove(self.QueuedMacros, queuedMacro)
    end
end

addon.QueuedMacros = {}
function addon:QueuMacros()
    if not self.QueuedMacros then
        self.QueuedMacros = {}
    end

    -- Prepare each macro with the macroData
    for _, info in pairs(self.macroData) do
        local prepMacro = self:PrepMacroForEditing(info.name, info)
        table.insert(self.QueuedMacros, prepMacro)
    end
end

-- Processes macros from the provided macro tables
function addon:FulfilQueuedMacros()
    for _, queuedMacro in pairs(self.QueuedMacros) do
        self:EditQueuedMacro(queuedMacro)
    end
end

function addon:ProcessAll()
    if InCombatLockdown() then
        return false -- signal that tryAction failed
    else
        -- Phase 1: Scan Items and Queue Macros for Editing
        self:UpdateItemCache()
        self:QueueMacros()

        -- Phase 2: This needs an overhaul
        self:FulfilQueuedMacros()

        return true -- signal that tryAction succeeded
    end
end
