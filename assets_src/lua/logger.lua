local Wargroove = require "wargroove/wargroove"
local State = require "state"
local json = require "json"
local utils = require "utils"

local Logger = {}

local matchIdUnitPos = { x=-85, y=-64 }
local matchIdUnitKey = "MLOG_MatchId"

local ORIGIN = "https://worker.wgroove.tk"

function Logger.getEndpoint(path)
    return ORIGIN .. path
end

function Logger.shouldSendInfo()
  local shouldSend = false

  for id = 0, Wargroove.getNumPlayers(false) - 1 do
    if Wargroove.isLocalPlayer(id) and Wargroove.getCurrentPlayerId() == id then
      shouldSend = true
    end
  end

  return shouldSend
end

function Logger.setMatchId()
    local matchId = tostring(math.floor(Wargroove.pseudoRandomFromString("MLOG") * 4294967295))

    Wargroove.spawnUnit( -1, matchIdUnitPos, "soldier", true, "")
    Wargroove.waitFrame()
    local stateUnit = Wargroove.getUnitAt(matchIdUnitPos)
    Wargroove.setUnitState(stateUnit, matchIdUnitKey, matchId)
    Wargroove.updateUnit(stateUnit)

    print('MLOG_MatchId: ' .. matchId)
end

function Logger.getMatchId()
  local stateUnit = Wargroove.getUnitAt(matchIdUnitPos)
  local matchId = Wargroove.getUnitState(stateUnit, matchIdUnitKey)
  return matchId
end

function Logger.sendMap()
  local matchId = Logger.getMatchId()
  local map = State.getMap()
  print('map: ' .. json.stringify(map))
  if Logger.shouldSendInfo() then
    utils:postJSON(Logger.getEndpoint('/mlog/' .. matchId .. '/map'), map)
  end
end

function Logger.sendState(stateId)
  local matchId = Logger.getMatchId()
  local state = State.getState()
  state.id = tonumber(stateId)
  print('state: ' .. json.stringify(state))
  if Logger.shouldSendInfo() then
    utils:postJSON(Logger.getEndpoint('/mlog/' .. matchId .. '/state'), state)
  end
end

function Logger.sendPlayers()
  local matchId = Logger.getMatchId()
  local players = State.getPlayers()
  print('players: ' .. json.stringify(players))
  if Logger.shouldSendInfo() then
    utils:postJSON(Logger.getEndpoint('/mlog/' .. matchId .. '/players'), players)
  end
end

return Logger