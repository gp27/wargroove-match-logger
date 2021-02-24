local utils = {}
local json = require "json"
local io = require "io"

function utils:copyTable(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = self:copyTable(orig_value)
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function utils:curl(method, url, headers, data)
    local cmd = 'curl --location -X ' .. (method or "GET") .. ' "' .. url .. '" '
    for key, value in ipairs(headers) do
        cmd = cmd .. '-H  "' .. key .. ': ' .. value .. '" '
    end
    if(data) then
        cmd = cmd .. tostring(data)
    end
    local curlProc = io.popen(cmd, "r")
    local response = curlProc:read("a*")
    curlProc:close()
    return response
end

function utils:postJSON(url, table)
    --[[local body = json.stringify(table)
    local resp = utils:curl("POST", url, { ["Content-Type"] = "application/json" }, body)
    if resp ~= "" then
        return resp
    end]]
    
    return nil
end

return utils