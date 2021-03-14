local Events = require "wargroove/events"
local Wargroove = require "wargroove/wargroove"
local utils = require('utils')

local originalGetMapTriggers = Wargroove.getMapTriggers

local Triggers = {}

function Triggers.init()
    Wargroove.getMapTriggers = Triggers.getMapTriggers
end

-- triggers utility functions
function Triggers.getMapTriggers()
    local triggers = originalGetMapTriggers()

    local referenceTrigger = triggers[1] -- Events.getTrigger("$trigger_default_defeat_hq")

    --utils.debugObject(utils, 'utils', 2)
    --utils.debugObject(print, 'print', 3)

    Triggers.addToList(triggers, Triggers.getMatchLoggerStartSessionTrigger(referenceTrigger))
    Triggers.addToList(triggers, Triggers.getMatchLoggerInitTrigger(referenceTrigger))
    Triggers.addToList(triggers, Triggers.getStateTrigger(referenceTrigger))
    Triggers.addToList(triggers, Triggers.getVictoryTrigger(referenceTrigger))

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

function Triggers.getMatchLoggerStartSessionTrigger(referenceTrigger)
    local trigger = {}
    trigger.id =  "MatchLog Start Session"
    trigger.recurring = "repeat"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}
    
    table.insert(trigger.conditions, { id = "player_turn", parameters = { "current" } })
    table.insert(trigger.conditions, { id = "once_per_session", parameters = {} })
    table.insert(trigger.actions, { id = "mlog_start_session", parameters = {} })
    
    return trigger
end

function Triggers.getMatchLoggerInitTrigger(referenceTrigger)
    local trigger = {}
    trigger.id =  "MatchLog Init"
    trigger.recurring = "once"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}
    
    table.insert(trigger.conditions, { id = "player_turn", parameters = { "current" } })
    table.insert(trigger.conditions, { id = "start_of_turn", parameters = {} })
    table.insert(trigger.actions, { id = "mlog_init_match", parameters = {} })
    
    return trigger
end

function Triggers.getStateTrigger(referenceTrigger)
    local trigger = {}
    trigger.id =  "MatchLog State Change"
    trigger.recurring = "repeat"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}
    
    table.insert(trigger.conditions, { id = "player_turn", parameters = { "current" } })
    table.insert(trigger.conditions, { id = "state_change", parameters = {} })
    table.insert(trigger.actions, { id = "mlog_update_state", parameters = {} })
    
    return trigger
end

function Triggers.getVictoryTrigger(referenceTrigger)
    local trigger = {}
    trigger.id =  "MatchLog Victory"
    trigger.recurring = "once"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}
    
    table.insert(trigger.conditions, { id = "player_victorious", parameters = { "current" } })
    table.insert(trigger.actions, { id = "mlog_send_victory", parameters = {} })
    
    return trigger
end

return Triggers