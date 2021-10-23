local io = require "io"

local settings = {
    debug=false,
    no_prompts=nil,
    live_stats=false
}

local settingsFilename = "wgml-settings.txt"

local function formatValue(value)
    if value == nil then return nil end
    local n = tonumber(value)

    if n ~= nil then return n end

    if value == "false" then
        value = false
    elseif value == "true" then
        value = true
    end

    return value
end

local function readSettings()
    local f = io.open(settingsFilename, "r")
    if not f then return end

    for line in f:lines() do
        line = line:match("%s*(.+)")
        if line and line:sub( 1, 1 ) ~= "#" and line:sub( 1, 1 ) ~= ";" then
            local option = line:match("(%S*)%s*=%s*.*%s*"):lower()
            local value  = line:match("%S*%s*=%s*(.*)%s*")

            if option then
                settings[option] = formatValue(value)
            end
        end
    end

    f:close()
end

readSettings()
debugMessage("Settings", settings)

if settings.debug then
    DEBUG = true
end

return settings