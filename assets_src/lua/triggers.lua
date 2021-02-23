local Events = require "wargroove/events"
local Wargroove = require "wargroove/wargroove"

local Triggers = {}

function Triggers.getLoggerSendMapTrigger(referenceTrigger)
    local trigger = {}
    trigger.id =  "MMR MatchId State Set"
    trigger.recurring = "once"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}
    
    table.insert(trigger.conditions, { id = "player_turn", parameters = { "current" } })
    table.insert(trigger.conditions, { id = "start_of_turn", parameters = { } })
    table.insert(trigger.actions, { id = "mmr_set_match_id", parameters = { "current" }  })
    
    return trigger
end

function Triggers.getVictoryTrigger(referenceTrigger)
    local trigger = {}
    trigger.id =  "MMR Victory Trigger"
    trigger.recurring = "repeat"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}
    
    table.insert(trigger.conditions, { id = "player_victorious", parameters = { "current" } })
    table.insert(trigger.actions, { id = "mmr_publish", parameters = { "current" }  })
    
    return trigger
end

return Triggers