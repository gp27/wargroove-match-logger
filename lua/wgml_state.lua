local Wargroove = require "wargroove/wargroove"
local json = require "wgml_lib_json"

local State = {}

local metadataPrefix = "wgml_"
local metadataKeys = {
    user_options = metadataPrefix .. "user_options",
    match_id = metadataPrefix .. "match_id",
    deltas = metadataPrefix .. "deltas",
    has_fog = metadataPrefix .. "has_fog"
}

local function genUniqueId(str)
    return tostring(math.floor(Wargroove.pseudoRandomFromString(str) * 4294967295))
end

-- metadata utils

function State.getMetadataUnit()
    local unit1 = Wargroove.getUnitById(1)

    if unit1 then
        return unit1
    end

    local min = math.huge
    local allUnits = Wargroove.getAllUnitIds()
    for _, id in ipairs(allUnits) do
       if id < min then
           min = id
       end
    end

    return Wargroove.getUnitById(min)
end

function State.clearMetaDataFromUnit(unit)
    local newState = {}

    for i, stateKey in ipairs(unit.state) do
        if (string.sub(stateKey.key, 1, string.len(metadataPrefix)) ~= metadataPrefix) then
            table.insert(newState, stateKey)
        end
    end
    unit.state = newState
end

function State.getMetadata(key)
    local unit = State.getMetadataUnit()
    return Wargroove.getUnitState(unit, key)
end

function State.setMetadata(key, value)
    local unit = State.getMetadataUnit()
    Wargroove.setUnitState(unit, key, value)
    Wargroove.updateUnit(unit)
end

function State.getJsonMetadata(key)
    local value = State.getMetadata(key)
    if value ~= nil then
        value = json.parse(value)
    end
    return value
end

function State.setJsonMetadata(key, value)
    State.setMetadata(key, json.stringify(value))
end


-- metadata getters and setters

function State.getUserOptions()
    return State.getJsonMetadata(metadataKeys.user_options)
end

function State.setUserOptions(options)
    return State.setJsonMetadata(metadataKeys.user_options, options)
end

function State.getMatchId()
    local match_id = State.getMetadata(metadataKeys.match_id)

    if match_id then
        return match_id, true
    end
    
    match_id = State.setMatchId()
    return match_id, false
end

function State.setMatchId()
    local match_id = genUniqueId('wgml')
    State.setMetadata(metadataKeys.match_id, match_id)
    return match_id
end

function State.getDeltas()
    return State.getJsonMetadata(metadataKeys.deltas) or {}
end

function State.setDeltas(deltas) 
    State.setJsonMetadata(metadataKeys.deltas, deltas)
end

function State.setFog(fog)
    State.setMetadata(metadataKeys.has_fog, fog and 1 or 0)
end

--[[function State.getUserId()
    local localUsers = ""
    for id=0, Wargroove.getNumPlayers(false) - 1 do
        if Wargroove.isLocalPlayer(id) then
            localUsers = localUsers .. "." .. id
        end
    end
    local user_id = genUniqueId(localUsers)
end]]

return State