require 'localization'

gr = love.graphics

import Battle, Army, ArmyTypes, armygroup from require 'army'
import in_conflict from require 'state'
import abs from math
import sort, remove from table

class Province
  new: (@name, @modifiers, @loyalty, @population = 1000) =>
    @linkedarmies = {}
    @shape = {}
    @production = {"rifles", "food"}
    @supply = {}
    @needs = {}

    @bordering_provinces = {}

  add_army: (army) =>
    @linkedarmies[tostring army] = army

  remove_army: (army) =>
    for k, _ in pairs @linkedarmies
      if tostring(army) == k
        @linkedarmies[k] = nil

  find_army: (army) =>
    for k, _ in pairs @linkedarmies
      if tostring(army) == k
        return true

  set_map: (@map) =>

  produce: =>
    for p in *@production
      can_produce = true
      @supply[p] = 0 if not @supply[p]
      if trade_goods[p].needs
        for k, v in pairs trade_goods[p].needs
          if @supply[k] and @supply[k] - v * @population > 0
            @supply[k] -= v * @population
          else
            can_produce = false

      if can_produce
        produced = @population / #@production * trade_goods[p].per_worker
        if trade_goods[p].production_function
          @supply[p] += trade_goods[p].production_function @, produced
        else
          @supply[p] += produced

    @supply.food += 10000 -- Every city has a base production of 10,000 food.

  tick_population: =>
    pop_before = @population
    is_starving = 1
    
    if @supply.food
      if 0 >= @supply.food - @population
        @population -= abs(@supply.food - @population) / 4
        @supply.food = 0
        is_starving = 1
        print "#{@name}: Population starved #{pop_before - @population}"
      else
        @supply.food -= @population
    else
      @supply.food = 10000


    print "#{@name}: Born #{(@population/100) / (is_starving * 5)}"
    @population += (@population/100) / (is_starving * 5)
    print "Population of #{@name} is #{@population} and the amount of food we have is #{@supply.food}"


  tick: =>
    for k, v in pairs @linkedarmies
      @linkedarmies[k] = nil if v.isdead
      if v.loyalty.__class == Authority
        for _, v2 in pairs @linkedarmies
          if v2 ~= v and in_conflict v.loyalty, v2.loyalty
            if v\canfight! and v2\canfight!
              @map\add_battle Battle v, v2

  tick_monthly: =>
    @produce!
    @tick_population!


  conscript: (law, authority) =>
    t = {}
    t[#t+1] = armygroup 1000 * (@population / authority.government.levy), ArmyTypes.Militia
    @add_army Army t, authority

class Map
  new: =>
    @battles = {}
    @provinces = {}
    pcl = 0
    for _, _ in pairs province_colors
      pcl += 1
    @shader = gr.newShader shader_province_f pcl
    @prov_img = gr.newImage 'assets/provinces.png'

  add_province: (province) =>
    @provinces[#@provinces+1] = province

  add_battle: (battle) =>
    @battles[#@battles+1] = battle

  get_province_distance: (p1, p2) =>
    dist p1.shapecenter[1], p1.shapecenter[2], p2.shapecenter[1], p2.shapecenter[2]

  backtrack_path: (previous_province, current) =>
    path = {current}
    print table_size(previous_province)
    c = current
    while true
      c = previous_province[c]
      path[#path+1] = c
      break unless previous_province[c]
    return reverse_table path

  -- Find path via A*
  get_path: (start, target) =>  
    path = {}
    already_seen = {}
    queue = {}
    queue[start.name] = true
    previous_province = {}

    gscore = {}
    gscore[start] = 0
    get_gscore = (idx) ->
      gscore[idx] or 10000000

    fscore = {}
    fscore[start] = @get_province_distance(start, target)
    get_fscore = (idx) ->
      fscore[idx] or 10000000
    while table_size(queue) > 0
    
      best_province = {nil, 100000000}
      for k, v in pairs queue
        if get_fscore(province_definitions[k]) < best_province[2]
          best_province = {province_definitions[k], get_fscore(province_definitions[k])}

      current_province = best_province[1]
      queue[current_province.name] = nil
      already_seen[current_province.name] = true

      if current_province == target -- Escape if found end province
        return @backtrack_path previous_province, current_province

      for _, province in pairs current_province.bordering_provinces -- For each neighbor
        unless already_seen[province.name]
          score = get_gscore(current_province) + @get_province_distance(current_province, province)
          unless queue[province.name]
            queue[province.name] = province
          if score < get_gscore(province)
            previous_province[province] = current_province
            gscore[province] = score
            fscore[province] = gscore[province] + @get_province_distance(province, target)

      {}


  update_provinces: =>
    for p in *@provinces
      p\tick!
    for b in *@battles
      b\battletick!
      if b.ended
        _list_1[_index_0] = nil

  draw: =>
    gr.setShader @shader
    gr.setColor 1, 1, 1

    --@shader\send "screen", {gr.getWidth!, gr.getHeight!}
    pcl = 0
    for _, _ in pairs province_colors
      pcl += 1
    @shader\send "provinces", pcl
    i = 0
    for p in *@provinces
      for cc in *country_colors
        if p.loyalty.name == cc[5]
          indexprovince = "provinceidxs[#{i}]"
          @shader\send "#{indexprovince}.country", {cc[1]/255, cc[2]/255, cc[3]/255, 1.0}
          for k, v in pairs province_colors
            if p.name == k
              @shader\send "#{indexprovince}.color", {v[1]/255, v[2]/255, v[3]/255, 1.0} 
              i += 1

    gr.draw @prov_img, 0, 0
    gr.setShader!
    for b in *@battles
      for _, p in pairs province_definitions
        if p.linkedarmies[tostring b.attacker or tostring b.defender]
          b.attacker\draw p, b
          break
      
    for _, p in pairs province_definitions
      for _, a in pairs p.linkedarmies
        a\draw p unless a.inbattle

  tick: =>
    @update_provinces!

  tick_monthly: =>
    for p in *@provinces
      p\tick_monthly!

  move_army: (a, p) =>

  try_get_pixel: (x, y, w, h) =>
    return if x < 0 or x > w or y < 0 or y > h
    r, g, b = @data\getPixel x, y
    return r*255, g*255, b*255

  load_provinces: (p_defs) =>
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
              -- Find bordering
              directions = {{@try_get_pixel(x, y+1, w, h)}, {@try_get_pixel(x, y-1, w, h)}, {@try_get_pixel(x-1, y, w, h)}, {@try_get_pixel(x+1, y, w, h)}}
              for d in *directions
                for k2, border_color in pairs p_defs
                  if k2 ~= k
                    if d[1] == border_color[1] and d[2] == border_color[2] and d[3] == border_color[3]
                      unless prov.bordering_provinces[k2]
                        prov.bordering_provinces[k2] = province_definitions[k2]
                        dprint "Found #{k2} on border of #{k}"
    -- set centers
    for _, p in pairs province_definitions
      c = {0, 0}
      for v in *p.shape
        c[1] += v.x
        c[2] += v.y
      p.shapecenter = {c[1]/#p.shape, c[2]/#p.shape}
            
          

{:Province, :Map}

