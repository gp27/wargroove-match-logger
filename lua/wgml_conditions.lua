local Events = require "wargroove/events"

local Conditions = {}

function Conditions.init()
  Events.addToConditionsList(Conditions)
end

function Conditions.populate(dst)
    dst["state_change"] = Conditions.stateChange
    dst["once_per_session"] = Conditions.oncePerSession
end

function Conditions.stateChange(context)
    return context:checkState("startOfTurn") or context:checkState("endOfUnitTurn")
end

local oncePerSessionFlag = false
function Conditions.oncePerSession()
  if oncePerSessionFlag then return false end
  oncePerSessionFlag = true
  return true
end

return Conditions
