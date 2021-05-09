local Wargroove = require "wargroove/wargroove"
local utils = require "wgml_lib_utils"
local diff = require "wgml_lib_diff"
local State = require "wgml_state"

local Match = {}

local match_id = nil
local currentState = nil
local deltas = nil
local cachedMatchData = nil


-- Match utils functions

local function generateState()
  local state = {}

  state.gold = {  }
  for id = 0, Wargroove.getNumPlayers(false)-1 do
    state.gold['p_'..id] = Wargroove.getMoney(id)
  end

  local unitClasses = {}
  local units = {}
  for _, unitObj in ipairs(Wargroove.getUnitsAtLocation()) do
    local unit = utils.copyTable(unitObj)
    unitClasses[unit.unitClassId] = unit.unitClass
    unit.unitClass = nil
    State.clearMetaDataFromUnit(unit)
    units['u_' .. unit.id] = unit
  end

  state.units = units
  state.unitClasses = unitClasses
  state.playerId = Wargroove.getCurrentPlayerId()
  state.turnNumber = Wargroove.getTurnNumber()

  return state
end

local function generateDelta()
  if currentState == nil then return nil end
  local newState = generateState()
  return diff(currentState, newState), newState, currentState
end

local function pushDelta(delta)
  table.insert(deltas, delta)
  State.setDeltas(deltas)
end

local function updateMatchData()
    local match_id = Match.getID()
    local deltas = Match.getDeltas()
    local state = Match.getState()
    local map = Match.getMap()
    local players = Match.getPlayers()

    cachedMatchData = { match_id=match_id, state=state, map=map, players=players, deltas=deltas }
end


-- Match exposed functions

function Match.getID()
    if not match_id then
        match_id = State.getMatchId()
    end

    return match_id
end

function Match.getDeltas()
  if not deltas then
    deltas = State.getDeltas()
  end

  return deltas
end

function Match.getMap()
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

function Match.getPlayers()
  local players = {}

  for id=0, Wargroove.getNumPlayers(false) - 1 do
    table.insert(players, {
      id=id,
      team=Wargroove.getPlayerTeam(id),
      is_victorious=Wargroove.isPlayerVictorious(id),
      is_human=Wargroove.isHuman(id),
      --username=State.getUsername(id)
    })
  end

  return players
end

function Match.getState()
    return currentState
end

function Match.getMatchData()
    if cachedMatchData == nil then
        updateMatchData()
    end

    return cachedMatchData
end

function Match.setup()
    currentState = generateState()
    local match_id = Match.getID()
    Match.getDeltas()
    debugMessage('MatchID', match_id)
end

function Match.update(forceUpdate)
    local delta, newState, oldState = generateDelta()

    if delta ~= nil then
        pushDelta(delta)
        currentState = newState
        forceUpdate = true
    end

    if forceUpdate then
      updateMatchData()
      return true
    end

    return false
end

return Match