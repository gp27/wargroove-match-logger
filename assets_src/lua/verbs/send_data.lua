local Wargroove = require "wargroove/wargroove"
local Verb = require "wargroove/verb"

local SendData = Verb:new()

--SendData.isSending = false

function SendData:canExecute(unit, endPos, targetPos, strParam)
  return true
end

function SendData:getData()
end

function SendData:processData(data)
end

function SendData:preExecute(unit, targetPos, strParam, endPos)
  strParam = self:getData()
  return true, strParam
end

function SendData:execute(unit, targetPos, strParam, path)
  self:processData(strParam)
  --SendData.isSending = false
end

function SendData:onPostUpdateUnit(unit, targetPos, strParam, path)
  unit.hadTurn = false
end


function SendData:send()
  if not self.id then return end

  --SendData.isSending = true
  local currentPlayerId = Wargroove.getCurrentPlayerId()

  local selectableUnits = {}
  --local targetPositions = {}
  for i, unit in ipairs(Wargroove.getUnitsAtLocation()) do
    if unit.playerId == currentPlayerId and unit.unitClassId == "hq" then
      table.insert(selectableUnits, unit.id)
      --table.insert(targetPositions, unit.pos)
    end
  end

  --stateUnit.playerId = Wargroove.getCurrentPlayerId()
  --Wargroove.updateUnit(stateUnit)
  --print(json.stringify(stateUnit))

  if #selectableUnits > 0 then
    Wargroove.forceAction(selectableUnits, {}, {}, self.id, true, "neutral", "mercival", "")
  end
end

return SendData