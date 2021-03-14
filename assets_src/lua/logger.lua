local Wargroove = require "wargroove/wargroove"
local State = require "state"
local json = require "json"
local utils = require "utils"

local settings = require "settings"
local SetUsername = require "verbs/set_username"

local Logger = { }
local cachedMatchData = nil

local matchesFolder = "matches"

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
  local matchId = State.getMatchId()
  utils.openUrlInBrowser(MATCH_WEBSITE .. matchId)
end

function Logger.shouldSendMatchData(isStartOfTurn)
  local allLocal = Logger.areAllPlayersLocal()
  local currentIsLocal = Logger.isLocalPlayerTurn()

  return allLocal or (currentIsLocal ~= isStartOfTurn)
end

function Logger.setupSession()
  State.setCurrent()
  utils.sendVbsCommand("cmd /C if not exist " .. matchesFolder .. " mkdir " .. matchesFolder)

  if settings.save_in_cloud and settings.open_browser then
    Logger.openMatchInBrowser()
  end
end

function Logger.startSession()
  local matchId = State.getMatchId()

  if matchId then -- match already setup (player reopened an async match)
    Logger.setupSession()
  end
end

function Logger.initMatch()
  State.setMatchId()
  Logger.setupSession()
end

function Logger.updateState()
  --[[if SetUsername:shouldSend() then
    SetUsername:send()
  end]]

  local delta, state = State.generateDelta()
  
  if delta ~= nil then
    State.pushDelta(delta)
    State.setCurrent(state)
    Logger.updateMatchData()
    return true
  end

  return false
end

function Logger.updateMatchData()
  local matchId = State.getMatchId()
  local deltas = State.getDeltas()
  local state = State.getState()
  local map = State.getMap()
  local players = State.getPlayers()

  cachedMatchData = { match_id=matchId, state=state, map=map, players=players, deltas=deltas }
end

function Logger.getMatchData()
  if cachedMatchData == nil then 
    Logger.updateMatchData()
  end
  return cachedMatchData
end

function Logger.saveMatchData()
  local matchData = Logger.getMatchData()
  local matchJson = json.stringify(matchData)

  utils.writeFile(matchesFolder .. "\\" .. matchData.match_id .. '.json', matchJson)
end

function Logger.sendMatchData()
  if not settings.save_in_cloud then return end

  local matchData = Logger.getMatchData()

  Wargroove.showMessage("Sending match data...")
  utils.postJSON(URL, matchData)
end

function Logger.sendPlayers()
  local matchData = Logger.getMatchData()

  if Logger.isLocalPlayerTurn() then
    Wargroove.showMessage("Sending match data...")
    utils.postJSON(URL, matchData)
  end
end

return Logger