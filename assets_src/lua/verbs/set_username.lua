local Wargroove = require "wargroove/wargroove"
local SendData = require "verbs/send_data"
local State = require "state"
local settings = require "settings"
local json = require "json"

local SetUsername = SendData:new()

function SetUsername:canExecute(unit, endPos, targetPos, strParam)
  return SetUsername:shouldSend()
end

function SetUsername:shouldSend()
  local username = settings.username
  if not username or username == "" then return false end
    
  for id = 0, Wargroove.getNumPlayers(false) - 1 do
    if Wargroove.isLocalPlayer(id) then
      username = State.getUsername(id)
      if not username then return true end
    end
  end

  return false
end

function SetUsername:getData()
  local username = settings.username
  if not username then return end

  local data = {}

  for id = 0, Wargroove.getNumPlayers(false) - 1 do
    if Wargroove.isLocalPlayer(id) then
      data[id] = username
    end
  end

  return json.stringify(data)
end

function SetUsername:processData(data)
  if not data or data == "" then return end
  data = json.parse(data)

  for id = 0, Wargroove.getNumPlayers(false) - 1 do
    local username = data[tostring(id)]

    if username and username ~= "" then
      State.setUsername(id, username)
    end
  end
end

return SetUsername