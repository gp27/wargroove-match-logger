--[[
    wargroove-match-logger
    made by gp27

        @@@@@@@@@@@@  @@@@@@@@@@@@        @@@@@@@@@@@@      
    @@@@@@;;;;;;;;@@@@@@;;;;;;;;@@@@@@@@@@@@;;;;;;;;@@@@    
  @@@@;;;;00000000;;;;;;00000000;;;;;;;;;;;;00000000;;@@@@  
  @@;;000000GGtttttttttt00GGGGGGtttttttttt0000ffffGGGG;;@@  
@@@@;;00GGGGtttttttttt0000GGGGtttttttttttt00ffff1111ff;;@@@@
@@;;0000GG00tttttttttt00GGGG00tttttttttt0000ff111111ffff;;@@
@@;;00GGGGtttttt8888CC00GGGGtttttt8888CC00ffff11111111ff;;@@
@@;;00GGGG888888tttttt00GGGG888888tttttt00ff1111111111ff;;@@
@@;;00GGGGttttttttGGGG00GGGGttttttttGGGG00ff1111111111ff;;@@
@@;;00GGff0000000000GG00GGff0000000000GG00ff;;;;111111ff;;@@
@@;;00GGffGGGGGGGG00GG00GGffGGGGGGGG00GG00ff;;;;;;1111ff;;@@
@@;;00GGffGGGGGGGGGGGG00GGffGGGGGGGGGGGG00ff;;;;;;11ffff;;@@
@@@@;;GGffffffffGGGGGGffGGffffffffGGGGGG00ffff;;;;11ff;;@@@@
  @@;;GGGGffffffffffffffGGffffffffffffff00GGff;;;;;;ff;;@@  
  @@;;GGGGffffffffffffffGGffffffffffffffGGGGff;;;;1111;;@@  
  @@;;GGGG111111ff111111GG11111111ff1111GGGG11;;111111;;@@  
  @@;;1111111111111111111111111111111111111111;;;;;;11;;@@  
  @@@@;;ffffffffffff11111111ffffffffffff111111;;1111;;@@@@  
  @@;;ffff11111111ffff1111ffff11111111ffff1111;;;;;;;;@@    
  @@;;ff111111111111ff1111ff111111111111ff11;;111111;;@@    
  @@;;ff1111ffff1111ff1111ff1111ffff1111ff111111;;;;;;@@    
  @@;;ff1111ffff1111ff11;;ff1111ffff1111ff11;;;;;;;;;;@@    
  @@;;ff;;;;1111;;;;1111;;ff;;;;1111;;;;1111;;;;;;;;@@@@    
  @@;;11ff;;1111;;111111;;11ff;;1111;;111111;;;;;;@@@@      
  @@@@;;11111111111111;;@@;;11111111111111;;@@@@@@@@        
    @@@@;;;;;;;;;;;;;;@@@@@@;;;;;;;;;;;;;;@@@@              
      @@@@@@@@@@@@@@@@@@  @@@@@@@@@@@@@@@@@@                
]]

local Conditions = require "wgml_conditions"
local Actions = require "wgml_actions"
local Triggers = require "wgml_triggers"
local Logger = require "wgml_logger"

local WgmlInit = {}

local initialized = false

function WgmlInit.init()
  if initialized then return end
  initialized = true

  print('#####################################')
  print('### wgml - Wargroove Match Logger ###', '(Loaded as ' .. (Logger.unofficial and 'Unofficial mod)' or 'Official mod)'))
  print('#####################################')

  Conditions.init()
  Actions.init()
  Triggers.init()
end

function WgmlInit.unofficialInit()
  if initialized then return end
  Logger.unofficial = true
  WgmlInit.init()
end

return WgmlInit