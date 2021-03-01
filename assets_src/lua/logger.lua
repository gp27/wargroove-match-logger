local Wargroove = require "wargroove/wargroove"
local State = require "state"
local json = require "json"
local utils = require "utils"

local Logger = {}

local matchIdUnitPos = { x=-85, y=-64 }
local matchIdUnitKey = "MLOG_MatchId"

local URL = "https://wargroove-match-worker.gp27.workers.dev/match_log"
local MATCH_WEBSITE = "https://wgroove.tk/?match_id="

function Logger.isLocalPlayerTurn()
  for id = 0, Wargroove.getNumPlayers(false) - 1 do
    if Wargroove.isLocalPlayer(id) and Wargroove.getCurrentPlayerId() == id then
      return true
    end
  end

  return false
end

function Logger.areAllPlayersLocal()
  for id = 0, Wargroove.getNumPlayers(false) - 1 do
    if not Wargroove.isLocalPlayer(id) then
      return false
    end
  end

  return true
end

function Logger.openMatchInBrowser()
  local matchId = Logger.getMatchId()
  utils:openUrlInBrowser(MATCH_WEBSITE .. matchId)
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


function Logger.init()
  Logger.setMatchId()
  Logger.sendInit()
end

function Logger.sendInit()
  local matchId = Logger.getMatchId()
  local map = State.getMap()
  local players = State.getPlayers()

  if Logger.isLocalPlayerTurn() then
    Wargroove.showMessage("Sending match data...")
    utils:postJSON(URL, { match_id=matchId, map=map, players=players  })
  end
end

function Logger.sendState(stateId, isStartOfTurn)
  local matchId = Logger.getMatchId()
  local state = State.getState()
  state.id = tonumber(stateId)
  
  --[[if Logger.isLocalPlayerTurn() ~= isStartOfTurn then
    utils:postJSON(URL, { match_id=matchId, state=state })
  end]]

  local allLocal = Logger.areAllPlayersLocal()
  local currentIsLocal = Logger.isLocalPlayerTurn()

  if (
    allLocal
    or (
      currentIsLocal ~= isStartOfTurn
    )
  ) then
    Wargroove.showMessage("Sending match data...")
    utils:postJSON(URL, { match_id=matchId, state=state })
  end
end

function Logger.sendPlayers()
  local matchId = Logger.getMatchId()
  local players = State.getPlayers()

  if Logger.isLocalPlayerTurn() then
    Wargroove.showMessage("Sending match data...")
    utils:postJSON(URL, { match_id=matchId, players=players })
  end
end

return Logger