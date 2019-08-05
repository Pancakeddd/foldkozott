require 'util'

import Battle, Army, ArmyTypes, armygroup, order from require 'army'
import Camera from require 'camera'
import Game from require 'game'
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
  'tradegoods'

  'shaders.provinceshaders'
}

game = Game!

with love

  onkeypress = ->
    for k, v in pairs setting_controls
      if .keyboard.isDown k
        switch v
          when "camera_left"
            camera\move -camera_speed, 0
          when "camera_right"
            camera\move camera_speed, 0
          when "camera_up"
            camera\move 0, -camera_speed
          when "camera_down"
            camera\move 0, camera_speed
          when "exit"
            .event.quit!
            

  .load = ->
      love.window.setMode 1920, 1080

      for k, country in pairs game.countries
        print k
        --country\conscript!
      game\load!

      a = Army { -- Load a test army for Austria and put in upper graz
      armygroup 470, ArmyTypes.Militia
      armygroup 100, ArmyTypes.Artillery
      }, authority_definitions.croatia

      province_definitions.graz\add_army a
      a\move_to game.map, province_definitions['greater_austria']
      game\register_army a

      game.countries.croatia\war game.countries.austria
      game.countries.croatia\trade game.countries.venetian_adriatic

      print game\get_provinces!['graz']

      export timer = Timer!
      timer\every(0.2, (-> 
        --battle\battletick!
        game\tick!))

  .update = (dt) ->

    onkeypress!
    timer\update dt

  .draw = ->
    camera\draw!
    game\draw!
    camera\pop!