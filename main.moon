require 'util'

import Battle, Army, ArmyTypes, armygroup, order from require 'army'
import Map, Province from require 'map'
import Camera from require 'camera'
Timer = require 'libs.chrono'
load_data = require 'loaddata'
load_settings = require 'settings'

camera = Camera!

load_settings {
  'controls'
  'misc'
}

load_data {
  'misc'
  'provinces'
  'states'
  'titles'
  'authorities'
  'mapguide'

  'shaders.provinceshaders'
}

a = Army { -- Load a test army for Austria and put in upper graz
  armygroup 470, ArmyTypes.Pikemen
  armygroup 500, ArmyTypes.Cavalry
  armygroup 30, ArmyTypes.Musketeer
  }, authority_definitions.croatia
map = Map!

for _, v in pairs province_definitions
  map\add_province v
  v\set_map map

map\load_provinces province_colors

province_definitions.upper_graz\add_army a
a\add_order order "move", {province: province_definitions.greater_austria}
a\add_order order "move", {province: province_definitions.wolfsberg}

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
        map\tick!
        a\do_order map))
  .update = (dt) ->
    timer\update dt
  .keypressed = (key, sc) ->
    .event.quit! if setting_controls[sc] and setting_controls[sc] == "exit"
    camerakey = setting_controls[sc]
    if camerakey and camerakey\find"camera_" == 1
      switch camerakey
        when "camera_left"
          camera\move -camera_speed, 0
        when "camera_right"
          camera\move camera_speed, 0
        when "camera_up"
          camera\move 0, -camera_speed
        when "camera_down"
          camera\move 0, camera_speed
  .draw = ->
    camera\draw!
    map\draw!
    camera\pop!
        