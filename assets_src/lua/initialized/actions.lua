local Wargroove = require "wargroove/wargroove"
local Events = require "wargroove/events"
local Logger = require "logger"


local Actions = {}

function Actions.init()
  Events.addToActionsList(Actions)
end

function Actions.populate(dst)
    dst["mlog_send_init"] = Actions.sendInit
    dst["mlog_send_state"] = Actions.sendState
    dst["mlog_send_players"] = Actions.sendPlayers
end

function Actions.sendInit(context)
    Logger.init()
end


function Actions.sendState(context)
  local stateID = context:getMapCounter(0)
  context:setMapCounter(0, stateID + 1)
  Logger.sendState(stateID, context:checkState("startOfTurn"))
end

function Actions.sendPlayers(context)
    Logger.sendPlayers()
end

return Actions
