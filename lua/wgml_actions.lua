local Events = require "wargroove/events"
local Logger = require "wgml_logger"


local Actions = {}

function Actions.init()
  Events.addToActionsList(Actions)
end

function Actions.populate(dst)
  dst["wgml_start_session"] = Actions.startSession
  dst["wgml_start_match"] = Actions.startMatch
  dst["wgml_update_match"] = Actions.updateMatch
  dst["wgml_send_victory"] = Actions.sendVictory
end

function Actions.startSession(context)
  wrapCall(Logger.startSession)
end

function Actions.startMatch(context)
  wrapCall(Logger.startMatch)
end


function Actions.updateMatch(context)
  wrapCall(function()
    Logger.updateMatch({ isStartOfTurn = context:checkState("startOfTurn") })
  end)
end

function Actions.sendVictory(context)
  wrapCall(function()
    Logger.updateMatch({ isVictory = true })
  end)
end

return Actions
