local Wargroove = require "wargroove/wargroove"
local utils = require "wgml_lib_utils"
local Shell = require "wgml_lib_shell"
local Match = require "wgml_match"
local State = require "wgml_state"
local settings = require "wgml_settings"

local matchesFolder = "matches"
local UPLOAD_URL = "https://worker.wgroove.tk/match_log"
local MATCH_WEBSITE = "https://wgroove.tk/?match_id="
local LIVE_STATS_FILENAME = 'wgml-live-stats.html'

local Logger = {
    unofficial = false,
    info = {},
    options = {
        register = false,
        save_online = false
    }
}


-- lifecycle functions

function Logger.setupSession()
    debugMessage("Logger.setupSession")

    local info = Logger.getMatchInfo()
    debugMessage("MatchInfo", info)
    Logger.info = info

    local options, wasSaved = Logger.getOptions()
    debugMessage("UserOptions", options)

    if not wasSaved then
        State.setUserOptions(options)
    end

    Logger.options = options

    if not options.register then
        return
    end

    utils.mkdirp(matchesFolder)
    Match.setup()

    if settings.live_stats then
        Logger.updateStats()
    end

    if Logger.shouldSaveMatchData() then
       Logger.saveMatchData()

        if options.save_online then
            Logger.sendMatchData()
            Logger.openMatchInBrowser()
        end 
    end
end

function Logger.startSession()
    debugMessage("Logger.startSession")
    Logger.setupSession()
end

function Logger.startMatch()
    debugMessage("Logger.startMatch")
    --Logger.setupSession()
end

function Logger.updateMatch(flags)
    flags = flags or {}
    debugMessage("Logger.updateMatch", flags)
    if not Logger.options.register then
        return
    end

    local shouldForceUpdate = flags.isVictory or false
    local updated = Match.update(shouldForceUpdate)

    if settings.live_stats then
        if flags.isVictory then
            Logger.removeStats()
        else
            Logger.updateStats()
        end
    end

    if Logger.shouldSaveMatchData(flags) then
        Logger.saveMatchData()

        if updated and Logger.options.save_online then
            if Logger.shouldSendMatchData(flags) then
               Logger.sendMatchData()
               Logger.openMatchInBrowser()
            end
        end
    end
end


-- utils functions

function Logger.getMatchInfo()
    local n = Wargroove.getNumPlayers(false)

    local isLocal = true
    local isSpectator = true
    local isSinglePlayer = false

    for id = 0, n - 1 do
        if not Wargroove.isHuman(id) then
            isSinglePlayer = true
        end

        if not Wargroove.isLocalPlayer(id) then
            isLocal = false
            isSinglePlayer = false
        else
            isSpectator = false
        end
    end

    --[[local isFogMode = false

    local mapSize = Wargroove.getMapSize()

    for y=0, mapSize.y - 1 do
      for x=0, mapSize.x - 1 do
        if not Wargroove.canPlayerSeeTile(0, { x=x, y=y }) then
          isFogMode = true
        end
      end
    end]]


    return {
        isLocal = isLocal,
        isSpectator = isSpectator,
        isSinglePlayer = isSinglePlayer,
        --isFogMode = isFogMode
    }
end

function Logger.getOptions()
    local options = State.getUserOptions()
    if options then return options, true end
    options = {}

    if Logger.info.isSinglePlayer then
        return { register = false, save_online = false }, false
    end

    if settings.no_prompts then
        return { register = true, save_online = false }, false
    end

    if Logger.info.isLocal then
        options.save_online = false
    end

    if not Logger.unofficial then
        options.register = true
    end

    options = Logger.askUserOptions(options)

    return options, false
end

function Logger.askUserOptions(options)
    options = options or {}

    local shell = nil

    if options.register == nil then
        shell = Shell.getBilateralShell()
        options.register = shell:confirm("Do you want to register this match?")
    end

    if options.save_online == nil then
        if options.register  then
            shell = Shell.getBilateralShell()
            options.save_online = shell:confirm("Do you want to share the match online?")
        else
            options.save_online = false
        end
    end

    if shell then
        shell:close()
    end

    return options
end

function Logger.isLocalPlayerTurn()
  for id = 0, Wargroove.getNumPlayers(false) - 1 do
    if Wargroove.isLocalPlayer(id) and Wargroove.getCurrentPlayerId() == id then
      return true
    end
  end

  return false
end

function Logger.shouldSaveMatchData(flags)
    flags = flags or {}
    if flags.isVictory then return true end

    local match = Match.getMatchData()
    debugMessage('match.is_fog', match.is_fog)
    return not match.is_fog
end

function Logger.shouldSendMatchData(flags)
    flags = flags or {}

    if flags.isVictory then return true end

    if Logger.unofficial then
        if Logger.info.isSpectator and not flags.isStartOfTurn then
            return false
        end

        return true
    end

    local isLocalPlayerTurn = Logger.isLocalPlayerTurn()
    local isStartOfTurn = flags.isStartOfTurn and true or false
    local isLocal = Logger.info.isLocal

    return isLocal or (isLocalPlayerTurn ~= isStartOfTurn)
end

function Logger.saveMatchData()
    debugMessage('Logger.saveMatchData')
    local matchData = Match.getMatchData()
    utils.writeJson(matchesFolder .. "\\" .. matchData.match_id .. '.json', matchData)
end

function Logger.updateStats()
    debugMessage('Logger.updateStats')
    local stats = Match.getStats()

    local stats_text = '<script>setTimeout(function(){location.reload(true)},2000)</script><style>table{font-family:monospace}th{background:#d0bdac;border:4px groove #f8f9e7;padding:3px 5px;border-radius:8px 8px 0 0;color:#3a4269;text-shadow:1px 1px 0 #fefff1,-1px -1px 0 #fefff1,-1px 1px 0 #fefff1,1px -1px 0 #fefff1}td{background:#f6f8eb;border:4px solid #cbcbcb;border-style:groove;border-radius:3px;padding:3px 5px;text-align:right;color:#3c3e55}td:first-child{font-weight:700;text-transform:capitalize;text-align:left}</style><table><thead><tr><th style="opacity:0"></th><th>Gold</th><th>Income</th><th>Army</th><th>Units</th><th>Combat U.</th></tr></thead><tbody>'

    for playerId, stat in ipairs(stats) do
        stats_text = stats_text ..
          '<tr><td>' .. stat.name .. '</td><td>' ..
          stat.gold .. '</td><td>' .. 
          stat.income .. '</td><td>' .. 
          stat.army_value .. '</td><td>' .. 
          stat.unit_count .. '</td><td>' .. 
          stat.c_unit_count .. '</td></tr>'
    end

    stats_text = stats_text .. '</tbody></table>'

    utils.writeFile(LIVE_STATS_FILENAME, stats_text)
end

function Logger.removeStats()
    utils.writeFile(LIVE_STATS_FILENAME, '<script>setTimeout(function(){location.reload(true)},2000)</script>')
end

function Logger.sendMatchData()
    debugMessage('Logger.sendMatchData')
    local matchData = Match.getMatchData()
    --local url = URL .. matchData.match_id .. '.json'
    utils.postJSON(UPLOAD_URL, matchData)
end

local browserOpened = false

function Logger.openMatchInBrowser()
  if browserOpened then return end
  browserOpened = true

  local match_id = Match.getID()
  utils.openUrlInBrowser(MATCH_WEBSITE .. match_id)
end

return Logger