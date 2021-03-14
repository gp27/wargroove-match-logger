local Wargroove = require "wargroove/wargroove"
local Events = require "wargroove/events"
local Logger = require "logger"


local Actions = {}

function Actions.init()
  Events.addToActionsList(Actions)
end

function Actions.populate(dst)
    dst["mlog_init_match"] = Actions.initMatch
    dst["mlog_update_state"] = Actions.updateState
    dst["mlog_send_victory"] = Actions.sendVictory
    dst["mlog_start_session"] = Actions.startSession
end

function Actions.startSession(context)
  Logger.startSession()
end

function Actions.initMatch(context)
  Logger.initMatch()
end


function Actions.updateState(context)
  local updated = Logger.updateState()
  Logger.saveMatchData()

  if updated and Logger.shouldSendMatchData(context:checkState("startOfTurn")) then
    --local stateID = context:getMapCounter(0)
    --context:setMapCounter(0, stateID + 1)
    Logger.sendMatchData()
  end
end

function Actions.sendVictory(context)
  Logger.updateMatchData()
  Logger.saveMatchData()
  Logger.sendMatchData()
end

return Actions
