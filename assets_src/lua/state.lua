local Wargroove = require "wargroove/wargroove"
local utils = require "utils"

local State = {}

function State.getMap()
  local abbrv = {
    forest=   "F",
    river=    "I",
    mountain= "M",
    reefs=    "R",
    bridge=   "b",
    deepsea=  "d",
    beach=    "e",
    flagstone="f",
    plains=   "p",
    road=     "r",
    sea=      "s"
  }

  local map = {}
  map.size = Wargroove.getMapSize()
  map.tiles = ""

  for x=0, map.size.x - 1 do
    for y=0, map.size.y - 1 do
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

function State.getPlayers()
  local victory = {}

  for id=0, Wargroove.getNumPlayers(false) - 1 do
    table.insert(victory, {
      id=id,
      team=Wargroove.getPlayerTeam(id),
      is_victorious=Wargroove.isPlayerVictorious(id),
      is_local=Wargroove.isLocalPlayer(id),
      is_human=Wargroove.isHuman(id)
    })
  end

  return victory
end

return State