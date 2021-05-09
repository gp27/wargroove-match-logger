local Events = require "wargroove/events"
local Wargroove = require "wargroove/wargroove"

local originalGetMapTriggers = Wargroove.getMapTriggers

local Triggers = {}

function Triggers.init()
    Wargroove.getMapTriggers = Triggers.getMapTriggers
end

-- triggers utility functions
function Triggers.getMapTriggers()
    local triggers = originalGetMapTriggers()

    local referenceTrigger = triggers[1] -- Events.getTrigger("$trigger_default_defeat_hq")

    Triggers.addToList(triggers, Triggers.getWgmlStartSessionTrigger(referenceTrigger))
    Triggers.addToList(triggers, Triggers.getWgmlInitTrigger(referenceTrigger))
    Triggers.addToList(triggers, Triggers.getWgmlStateChangeTrigger(referenceTrigger))
    Triggers.addToList(triggers, Triggers.getWgmlVictoryTrigger(referenceTrigger))

    return triggers
end

function Triggers.addToList(triggerList, triggerToAdd)
    local notFinished = true
    while notFinished do
        for i, trigger in ipairs(triggerList) do
            if trigger.id ~= nil and trigger.id == triggerToAdd.id then
                table.remove(triggerList, i)
                break;
            end
            if i == #triggerList then
                notFinished = false
            end
        end
    end
    table.insert(triggerList,triggerToAdd)
end

function Triggers.removeFromList(triggerList, triggerId)
    local notFinished = true
    while notFinished do
        for i, trigger in ipairs(triggerList) do
            if trigger.id ~= nil and trigger.id == triggerId then
                table.remove(triggerList, i)
                break;
            end
            if i == #triggerList then
                notFinished = false
            end
        end
    end
end


-- custom triggers

function Triggers.getWgmlStartSessionTrigger(referenceTrigger)
    local trigger = {}
    trigger.id = "$trigger_wgml_start_session"
    trigger.recurring = "repeat"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}

    table.insert(trigger.conditions, { id = "player_turn", parameters = { "current" } })
    table.insert(trigger.conditions, { id = "once_per_session", parameters = {} })
    table.insert(trigger.actions, { id = "wgml_start_session", parameters = {} })

    return trigger
end

function Triggers.getWgmlInitTrigger(referenceTrigger)
    local trigger = {}
    trigger.id = "$trigger_wgml_start_match"
    trigger.recurring = "once"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}

    table.insert(trigger.conditions, { id = "player_turn", parameters = { "current" } })
    table.insert(trigger.conditions, { id = "start_of_turn", parameters = {} })
    table.insert(trigger.actions, { id = "wgml_start_match", parameters = {} })

    return trigger
end

function Triggers.getWgmlStateChangeTrigger(referenceTrigger)
    local trigger = {}
    trigger.id = "$trigger_wgml_state_change"
    trigger.recurring = "repeat"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}

    table.insert(trigger.conditions, { id = "player_turn", parameters = { "current" } })
    table.insert(trigger.conditions, { id = "state_change", parameters = {} })
    table.insert(trigger.actions, { id = "wgml_update_match", parameters = {} })

    return trigger
end

function Triggers.getWgmlVictoryTrigger(referenceTrigger)
    local trigger = {}
    trigger.id = "$trigger_wgml_victory"
    trigger.recurring = "once"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}
    
    table.insert(trigger.conditions, { id = "player_victorious", parameters = { "current" } })
    table.insert(trigger.actions, { id = "wgml_send_victory", parameters = {} })
    
    return trigger
end

return Triggers