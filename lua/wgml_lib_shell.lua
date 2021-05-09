local io = require "io"
local Wargroove = require "wargroove/wargroove"

local vbsFerr = 'wgml-vbs-log.txt'
--local vbsFout = 'wgml-vbs-out'
local vbsFin = 'wgml-vbs-in'

local vbsFilename = "wgml-commands.vbs"

local vbsScript = [[
waitExit = False
If WScript.Arguments.Count > 0 Then
    arg1 = WScript.Arguments.item(0)
    If arg1 = "wait-exit" Then
        waitExit = True
    End If
End If

Set stdIn  = WScript.StdIn
'Set stdIn  = CreateObject("Scripting.FileSystemObject").OpenTextFile(arg1, 1)
Set stdOut = WScript.StdOut
Set stdErr = WScript.StdErr

Do While Not stdIn.AtEndOfStream
    action = stdIn.ReadLine

    If action = "exit" Then
        stdErr.WriteLine "closing"
        WScript.Quit 0
    ElseIf action = "echo" Then
        stdOut.WriteLine "echo"

    ElseIf action = "command" Then
        command = stdIn.ReadLine
        stdErr.WriteLine command
        WScript.CreateObject("WScript.Shell").Run command, 0, False

    ElseIf action = "confirm" Then
        message = stdIn.ReadLine
        stdErr.WriteLine message
        result = MsgBox(message, 4, "Wargroove Match Logger")
        If result = 6 Then
            stdOut.WriteLine "yes"
        Else
            stdOut.WriteLine "no"
        End If
    Else
        stdErr.WriteLine "Unknown action: " & action
    End If

    Do While stdIn.AtEndOfStream AND waitExit
        WScript.Sleep 100
    Loop
Loop
stdErr.WriteLine "closing"
]]

local function writeVbsScript()
    local f = io.open(vbsFilename, 'w')
    if f then
        f:write(vbsScript)
        f:close()
    end
end

local Shell = {}

function Shell:new(o)
    o = o or {}

    self.__gc = function(self)
        self:close()
    end

    setmetatable(o, self)
    self.__index = self

    o.vbsIn = nil
    o.vbsOut = nil
    --o.vbsErr = nil
    o.vbsFin =  o.vbsFin or vbsFin
    --o.vbsFout = o.vbsFout or vbsFout
    o.vbsFerr = o.vbsFerr or nil
    o.bilateral = o.bilateral or false
    o.verbose = o.verbose or false

    o:open()
    --o:readFlush()

    return o
end

function Shell:getVbsScriptCmd()
    local cmd = 'cscript //Nologo ' .. vbsFilename

    if self.bilateral then
        cmd = cmd .. ' wait-exit' .. ' < ' .. self.vbsFin
    end

    if self.vbsFerr then
        cmd = cmd .. ' 2> ' .. self.vbsFerr
    end

    return cmd
end

function Shell:open()
    if self.opened then
        self:close()
    end
    writeVbsScript()
    local cmd = self:getVbsScriptCmd()
    self:print('cmd:', cmd)

    if self.bilateral then
        self.vbsIn = io.open(self.vbsFin, 'w')
        self.vbsIn:setvbuf("no")
        self.vbsOut = io.popen(cmd, 'r')
    else
        self.vbsIn = io.popen(cmd, 'w')
        self.vbsIn:setvbuf("no")
    end
    self.opened = true
end

function Shell:close()
    if self.vbsIn then
        if self.bilateral then
            self:writel('exit')
        end
        self.vbsIn:close()
        self.vbsIn = nil
    end

    if self.vbsOut then
        self.vbsOut:close()
        self.vbsOut = nil
        --self.seekOut = nil
    end

    if self.vbsErr then
        self.vbsErr:close()
        self.vbsErr = nil
    end
    self.opened = true
end

function Shell:writel(text)
    local _, err = self.vbsIn:write(text, "\n")
    self.vbsIn:flush()
    self:print('shell w:', text)
    return err
end

function Shell:readl()
    if self.vbsOut then
        local line = self.vbsOut:read("*l")
        if line and line ~= "" then
            self:print('shell r:', line)
        end
        return line
    end
end

function Shell:readFlush()
    self:writel("echo")
    while true do
        local line = self:readl()
        if line == "echo" then
            return
        end
        Wargroove.waitFrame()
    end
end

function Shell:print(...)
    if self.verbose then
        print(...)
    end
end


-- shell commands

function Shell:confirm(message)
    self:writel("confirm")
    self:writel(message)
    local res = self:readl()
    return res == "yes"
end

function Shell:command(cmd)
    self:writel("command")
    self:writel(cmd)
end


-- Static

local function shellCheckOpen(shell)
    if not shell.open then
        shell:open()
    end
end

local defaultShell = nil
local defaultBilateralShell = nil

function Shell.getDefaultShell()
    if not defaultShell then
        defaultShell = Shell:new({ vbsFerr = vbsFerr })
    end

    shellCheckOpen(defaultShell)
    return defaultShell
end

function Shell.getBilateralShell()
    if not defaultBilateralShell then
        defaultBilateralShell = Shell:new({ bilateral = true, vbsFin = vbsFin, vbsFerr = vbsFerr })
    end

    shellCheckOpen(defaultBilateralShell)
    return defaultBilateralShell
end

return Shell