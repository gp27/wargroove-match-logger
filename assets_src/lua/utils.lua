local utils = {}
local json = require "json"
local io = require "io"

local debug = require "debug"

local silentCmdFilename = "silent-cmd.vbs"
local tempFileName = "send-data.json"

local function prepareSilentCommand(cmd)
    cmd = string.gsub(cmd, '"', '""')
    local silentCmd = 'WScript.CreateObject("WScript.Shell").Run "' .. cmd .. '", 0 , False'

    print(silentCmd)

    local sCurlFile = io.open(silentCmdFilename, "w")
    sCurlFile:write(silentCmd)
    sCurlFile:close()
end

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

function utils:curl(method, url, headers, data, silent)
        local cmd = 'curl --location -X ' .. (method or "GET") .. ' "' .. url .. '" '
    for key, value in pairs(headers) do
        cmd = cmd .. '-H  "' .. key .. ': ' .. value .. '" '
    end

    if(data) then
        -- direct usage of data as an argument doesnt work because of cmd string limitation to 8191 characters
        --cmd = cmd .. '-d "' .. tostring(data):gsub('\\', '\\\\'):gsub('"', '\\"') .. '" '

        local tempFile = io.open(tempFileName, "w")
        tempFile:write(data)
        tempFile:close()
        cmd = cmd .. '-d @' .. tempFileName .. ' '
    end

    print(cmd)

    if silent then
        prepareSilentCommand(cmd)
        cmd = 'wscript ' .. silentCmdFilename
    end

    print(data)

    local curlProc = io.popen(cmd, "r")
    local response = curlProc:read("a*")
    curlProc:close()
    return response
end

function utils:postJSON(url, table)
    local body = json.stringify(table)
    local resp = utils:curl("POST", url, { ["Content-Type"] = "application/json" }, body, true)
    if resp ~= "" then
        return resp
    end
    
    return nil
end

function utils:openUrlInBrowser(url)
    local cmd = 'start ' .. url 
    local proc = io.popen(cmd, "r")
    proc:read("a*")
    proc:close()
end

function utils:debugObject(obj, name, maxDepth, depth)
    if not maxDepth or maxDepth < 0 then
        maxDepth = 1
    end

    if depth == nil then
        depth = 1
    end

    if depth > maxDepth then
        return
    end

    local pad = ""
    for i=1, depth - 1 do
        pad = pad .. "  "
    end

    if type(obj) == 'function' then
        local info = debug.getinfo(obj)
        local params = {}
        for i=1, info.nparams do
            local param, val = debug.getlocal(obj, i)
            table.insert(params, param)
        end

        local fn_name = info.name or name

        print(pad .. 'Signature: ' .. fn_name .. '(' .. table.concat(params, ', ') .. ')')
        print(pad .. 'Upvalues:')
        for i=1, info.nups do
            local upval, val = debug.getupvalue(obj, i)
            print(pad .. i..': '.. upval)
            utils:debugObject(val, fn_name .. ' > ' .. upval, maxDepth, depth + 1)
        end
    elseif type(obj) == 'table' then
        for key, val in pairs(obj) do
            local propName = name .. '.' .. key
            
            if depth == maxDepth then
                print(pad .. propName .. ': ' .. tostring(obj))
            else
                utils:debugObject(val, propName, maxDepth, depth + 1)
            end
        end
    else 
        print(pad .. name .. ': ' .. tostring(obj))
    end
end

return utils