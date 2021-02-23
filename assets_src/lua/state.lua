local Wargroove = require "wargroove/wargroove"
local utils = require "utils"

local State = {}

function State.getMap()
  local map = {}
  map.size = Wargroove.getMapSize()
  map.tiles = {}

  for x=0, map.size.x do
    for y=0, map.size.y do
      table.insert(map.tiles, Wargroove.getTerrainNameAt({x=x, y=y}))
    end
  end
  
  return map
end

function State.generate()
  local newState = {}

  newState.gold = {}
  for id = 0, Wargroove.getNumPlayers(false)-1 do
    newState.gold[id] = Wargroove.getMoney(id)
  end

  local saveUnits = {}
  for _, unit in ipairs(Wargroove.getUnitsAtLocation()) do
    local unitCopy = utils:copyTable(unit)
    saveUnits[unit.id] = unitCopy
  end
  
  newState.units = saveUnits
  newState.playerId = Wargroove.getCurrentPlayerId()
  newState.turnNumber = Wargroove.getTurnNumber()

  return newState
end

return State