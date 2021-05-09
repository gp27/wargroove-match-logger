local io = require "io"
local debug = require "debug"
local json = require "wgml_lib_json"
local Shell = require "wgml_lib_shell"

DEBUG = DEBUG or false

local function formatMessage(...)
    local result = ""
    local args = {...}
    for i,v in ipairs(args) do
        if i > 1 then
            result = result .. "\t"
        end
        if type(v) == "table" then
            v = json.stringify(v)
        end
        result = result .. tostring(v)
    end
    return result
end

function debugMessage(...)
    if DEBUG then
        local message = formatMessage(...)
        print('[wgml]:', message)
    end
end

function wrapCall(fn)
    local success, err = xpcall(fn, debug.traceback)
    if not success then
        print(err)
    end
end

local utils = {}


-- Lua generic utils

local function escapeCmdQuotes(cmd)
    return string.gsub(cmd, '"', '""')
end

function utils.copyTable(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = utils.copyTable(orig_value)
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- file utils

function utils.openFile(filename, perms)
    local f, err = io.open(filename, perms)
    if f == nil then
        print("Error while opening file " .. filename, err)
        return nil
    end

    return f
end

function utils.writeFile(filename, content)
    local f = utils.openFile(filename, 'w')
    if f == nil then
        return 1
    end
    local _, err = f:write(content)
    f:close()

    if err then
        print("Error while writing file " .. filename, err)
        return 1
    end
end

function utils.readFile(filename)
    local f = utils.openFile(filename, 'r')
    if f == nil then
        return nil
    end

    local str = f:read("*a")
    f:close()
    return str
end

function utils.mkdirp(dirname)
    dirname = escapeCmdQuotes(dirname)
    utils.command('cmd /C if not exist "' .. dirname .. '" mkdir "' .. dirname .. '"')
end

function utils.writeJson(filename, table)
    local jsonData = json.stringify(table)
    utils.writeFile(filename, jsonData)
end

-- commands utils

function utils.command(cmd)
    local proc = io.popen(cmd, 'r')
    if proc then
        proc:close()
    end
end

function utils.shellCommand(cmd, close)
    Shell.getDefaultShell():command(cmd)
    if close then
        Shell.getDefaultShell():close()
    end
end


-- http utils

local tempFileName = "wgml-curl-data"

function utils.curl(method, url, headers, data)
        local cmd = 'curl --location -X ' .. (method or "GET") .. ' "' .. url .. '" '
    for key, value in pairs(headers) do
        cmd = cmd .. '-H  "' .. key .. ': ' .. value .. '" '
    end

    if(data) then
        -- direct usage of data as an argument doesnt work because of cmd string limitation to 8191 characters
        --cmd = cmd .. '-d "' .. escapeCommand(data) .. '" '
        --cmd = cmd .. '-d @' .. filenamePlaceholder .. ' '
        utils.writeFile(tempFileName, data)
        cmd = cmd .. '-d @' .. tempFileName .. ' '
    end

    utils.shellCommand(cmd)
end

function utils.postJSON(url, table)
    local body = json.stringify(table)
    utils.curl("POST", url, { ["Content-Type"] = "application/json" }, body)
end


-- browser utils

function utils.openUrlInBrowser(url)
    utils.shellCommand(url)
end


-- debug utils

function utils.debugObject(obj, name, maxDepth, depth)
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
            utils.debugObject(val, fn_name .. ' > ' .. upval, maxDepth, depth + 1)
        end
    elseif type(obj) == 'table' then
        for key, val in pairs(obj) do
            local propName = name .. '.' .. key
            
            if depth == maxDepth then
                print(pad .. propName .. ': ' .. tostring(obj))
            else
                utils.debugObject(val, propName, maxDepth, depth + 1)
            end
        end
    else 
        print(pad .. name .. ': ' .. tostring(obj))
    end
end

return utils