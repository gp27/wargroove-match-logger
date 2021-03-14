local utils = {}
local json = require "json"
local io = require "io"

local debug = require "debug"

--local silentCmdFilename = "silent-cmd.vbs"
local tempFileName = "send-data.json"

local function escapeCommand(cmd)
    return string.gsub(cmd, '"', '""')
end

local vbsFilename = "wg-commands.vbs"
local filenamePlaceholder = "TMPFILE"

local vbsPipe = nil
--local vbsFin = 'in.tmp'
--local vbsIn = nil
local vbsFout = 'vbs-out.txt'
local vbsFerr = "vbs-err.txt"

local function prepareVbs()
    local script = [[
Set stdIn = WScript.StdIn

Do While Not stdIn.AtEndOfStream
    command = stdIn.ReadLine
    WScript.Echo command
    WScript.CreateObject("WScript.Shell").Run command, 0, False
Loop]]

    if vbsPipe == nil then
        utils.writeFile(vbsFilename, script)
        vbsPipe = io.popen('cscript ' .. vbsFilename .. ' > ' .. vbsFout .. ' 2> ' .. vbsFerr, 'w')
    end

    return vbsPipe
end

function utils.sendVbsCommand(cmd, retry)
    prepareVbs()
    local _, err = vbsPipe:write(cmd, "\n")
    --vbsPipe:write(content or "")
    vbsPipe:flush()

    print('Write error:', tostring(err))

    if err and not retry then
        vbsPipe:close()
        vbsPipe = nil
        prepareVbs()
        utils.sendVbsCommand(cmd, true)
    end
end

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

    print(cmd)
    print(data)

    utils.sendVbsCommand(cmd)
end

function utils.postJSON(url, table)
    local body = json.stringify(table)
    utils.curl("POST", url, { ["Content-Type"] = "application/json" }, body)
end

function utils.openUrlInBrowser(url)
    utils.sendVbsCommand(url)
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

function utils.writeFile(filename, content)
    local f, err = io.open(filename, 'w')
    if f == nil then
        print("Error while opening file " .. filename, err)
        return 1
    end
    f:write(content)
    f:close()
end

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