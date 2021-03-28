local Wargroove = require "wargroove/wargroove"
local utils = require "utils"
local diff = require "diff"
local json = require "json"

local settings = require "settings"

local State = {}

local matchStateUnitPos = { x=-85, y=-64 }
local stateKeys = {
   matchId="MLOG_MatchId",
   delta="MGLOG_delta",
   username="username_"
}
local currentState = nil

function State.setCurrent(state)
  currentState = state or State.getState()
end

--[[function State.getCurrent()
  return currentState
end]]

function State.getStateUnit()
  local stateUnit = Wargroove.getUnitAt(matchStateUnitPos)
  if not stateUnit then
    Wargroove.spawnUnit( -1, matchStateUnitPos, "soldier", true, "")
    Wargroove.waitFrame()
    stateUnit = Wargroove.getUnitAt(matchStateUnitPos)
  end

  return stateUnit
end

function State.getStateUnitKey(key)
  local stateUnit = State.getStateUnit()
  return Wargroove.getUnitState(stateUnit, key)
end

function State.setStateUnitKey(key, value)
  local stateUnit = State.getStateUnit()
  Wargroove.setUnitState(stateUnit, key, value)
  Wargroove.updateUnit(stateUnit)
end

function State.getMap()
  local abbrv = {
    forest=     "F",
    river=      "I",
    mountain=   "M",
    reef=       "R",
    wall=       "W",
    bridge=     "b",
    ocean=      "o",
    beach=      "e",
    cobblestone="f",
    carpet=     "f",
    plains=     "p",
    road=       "r",
    sea=        "s"
  }

  local map = {}
  map.size = Wargroove.getMapSize()
  map.tiles = ""
  map.biome = Wargroove.getBiome()

  for y=0, map.size.y - 1 do
    for x=0, map.size.x - 1 do
      local name = Wargroove.getTerrainNameAt({x=x, y=y})
      map.tiles = map.tiles .. (abbrv[name] or ('.'..name..'.'))
    end
  end
  
  return map
end

function State.getState()
  local newState = {}

  newState.gold = {}
  for id = 0, Wargroove.getNumPlayers(false)-1 do
    newState.gold[id] = Wargroove.getMoney(id)
  end

  local unitClasses = {}
  local saveUnits = {}
  for _, unit in ipairs(Wargroove.getUnitsAtLocation()) do
    if unit.pos.x ~= matchStateUnitPos.x or unit.pos.y ~= matchStateUnitPos.y then
      local unitCopy = utils.copyTable(unit)
      unitClasses[unitCopy.unitClassId] = unitCopy.unitClass
      unitCopy.unitClass = nil
      saveUnits[unitCopy.id + 1] = unitCopy
    end
  end
  
  newState.units = saveUnits
  newState.unitClasses = unitClasses
  newState.playerId = Wargroove.getCurrentPlayerId()
  newState.turnNumber = Wargroove.getTurnNumber()

  return newState
end

function State.getPlayers()
  local victory = {}

  for id=0, Wargroove.getNumPlayers(false) - 1 do
    table.insert(victory, {
      id=id,
      team=Wargroove.getPlayerTeam(id),
      is_victorious=Wargroove.isPlayerVictorious(id),
      is_local=Wargroove.isLocalPlayer(id),
      is_human=Wargroove.isHuman(id),
      username=State.getUsername(id)
    })
  end

  return victory
end

function State.setMatchId()
    local matchId = tostring(math.floor(Wargroove.pseudoRandomFromString("MLOG") * 4294967295))
    State.setStateUnitKey(stateKeys.matchId, matchId)
    print('MLOG_MatchId: ' .. matchId)
end

function State.getMatchId()
  return State.getStateUnitKey(stateKeys.matchId)
end

function State.generateDelta()
  if currentState == nil then return nil end
  local state = State.getState()
  return diff(currentState, state), state, currentState
end

function State.pushDelta(delta)
  local deltas = State.getDeltas()
  table.insert(deltas, delta)

  local deltasJson = json.stringify(deltas)
  State.setStateUnitKey(stateKeys.delta, deltasJson)
end

function State.getDeltas()
  local deltas = State.getStateUnitKey(stateKeys.delta)
  if deltas ~= nil then
    deltas = json.parse(deltas)
  end
  if type(deltas) ~= "table" then deltas = {} end
  return deltas
end

function State.setUsername(playerId, username)
  State.setStateUnitKey(stateKeys.username .. playerId, username)
end

function State.getUsername(playerId)
  return State.getStateUnitKey(stateKeys.username .. playerId)
end

return State