require 'localization'

gr = love.graphics

import Battle, Army, ArmyTypes, armygroup from require 'army'
import in_conflict from require 'state'

class Province
  new: (@name, @modifiers, @loyalty, @population = 1000) =>
    @linkedarmies = {}
    @shape = {}

  add_army: (army) =>
    @linkedarmies[tostring army] = army

  remove_army: (army) =>
    for k, _ in pairs @linkedarmies
      if tostring(army) == k
        @linkedarmies[k] = nil

  set_map: (@map) =>
  
  tick: =>
    @population += (@population / 100)

    for _, v in pairs @linkedarmies
      if v.loyalty.__class == Authority
        for _, v2 in pairs @linkedarmies
          if v2 ~= v and in_conflict v.loyalty, v2.loyalty
            if v\canfight! and v2\canfight!
              print v\canfight!, v2\canfight!
              @map\add_battle Battle v, v2


  conscript: (law, authority) =>
    t = {}
    print @population / 1000
    t[#t+1] = armygroup 1000 * (@population / authority.government.levy), ArmyTypes.Pikemen
    @add_army Army t, authority

class Map
  new: =>
    @battles = {}
    @provinces = {}
    @shader = gr.newShader shader_province_f
    @prov_img = gr.newImage 'assets/provinces.png'

  add_province: (province) =>
    @provinces[#@provinces+1] = province

  add_battle: (battle) =>
    @battles[#@battles+1] = battle

  update_provinces: =>
    for p in *@provinces
      p\tick!
    for b in *@battles
      b\battletick!
      print b.ended
      if b.ended
        _list_1[_index_0] = nil

  draw: =>
    --gr.setShader @shader
    gr.setColor 1, 1, 1
    gr.draw @prov_img, 0, 0
    for b in *@battles
      for _, p in pairs province_definitions
        if p.linkedarmies[tostring b.attacker or tostring b.defender]
          b.attacker\draw p, b
          return
      

    for _, p in pairs province_definitions
      for _, a in pairs p.linkedarmies
        a\draw p
    --gr.setShader!

  tick: =>
    @update_provinces!

  load_provinces: (p_defs)=>
    @data = love.image.newImageData 'assets/provinces.png'
    w, h = @data\getWidth!, @data\getHeight!
    for y = 0, h-1
      for x = 0, w-1
        r, g, b = @data\getPixel x, y
        r, g, b = r*255, g*255, b*255
        for k, p in pairs p_defs
          if p[1] == r and p[2] == g and p[3] == b
            if prov = province_definitions[k]
              prov.shape[#prov.shape+1] = {:x, :y}
    -- set centers
    for _, p in pairs province_definitions
      c = {0, 0}
      for v in *p.shape
        c[1] += v.x
        c[2] += v.y
      p.shapecenter = {c[1]/#p.shape, c[2]/#p.shape}
            
          

{:Province, :Map}

