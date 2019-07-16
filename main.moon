require 'util'

import Battle, Army, ArmyTypes, armygroup from require 'army'
import Map, Province from require 'map'
Timer = require 'libs.chrono'
load_data = require 'loaddata'

load_data {
  'misc'
  'provinces'
  'states'
  'titles'
  'authorities'
  'mapguide'

  'shaders.provinceshaders'
}

a = Army { -- Load a test army for Austria and put i
  armygroup 470, ArmyTypes.Pikemen
  armygroup 500, ArmyTypes.Cavalry
  armygroup 30, ArmyTypes.Musketeer
  }, authority_definitions.austria
map = Map!

for _, v in pairs province_definitions
  map\add_province v
  v\set_map map

map\load_provinces province_colors

province_definitions.upper_graz\add_army a

authority_definitions.croatia\war authority_definitions.austria

with love
  .load = ->
      love.window.setMode 1920, 1080

      authority_definitions.croatia\conscript!
      authority_definitions.austria\conscript!
      map\add_province graz
      export timer = Timer!
      timer\every(0.5, (-> 
        --battle\battletick!
        map\tick!))
  .update = (dt) ->
    timer\update dt
  .draw = ->
    map\draw!
        