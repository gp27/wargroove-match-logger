local Wargroove = require "wargroove/wargroove"
local Events = require "wargroove/events"

local Conditions = {}

-- This is called by the game when the map is loaded.
function Conditions.init()
  Events.addToConditionsList(Conditions)
end

function Conditions.populate(dst)
    dst["state_change"] = Conditions.stateChange
end

function Conditions.stateChange(context)
    return context:checkState("startOfTurn") or context:checkState("endOfUnitTurn")
end

return Conditions
