--local Events = require "initialized/events"
local Wargroove = require "wargroove/wargroove"
--local io = require "io"

local State = require "state"
local json = require "json"

local Logger = {}

function Logger.isMultiplayer()
    local isMp = 0;
    for i = 0, Wargroove.getNumPlayers(false) - 1 do
        if not Wargroove.isHuman(i) then
            return false
        end
        if Wargroove.isLocalPlayer(i) then
            isMp = isMp + 1;
        end
    end
    print("Player Count: " .. tostring(Wargroove.getNumPlayers(false)))
    return isMp == 1 and Wargroove.getNumPlayers(false) == 2
end

function Logger.sendMap()
  print(json.stringify(State.getMap()))
end

function Logger.sendState()
  print(json.stringify(State.generate()))
end

function Logger.sendWinner()
end

return Logger