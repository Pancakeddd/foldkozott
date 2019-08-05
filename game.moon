import Map, Province from require 'map'

class Game
  new: =>
    @map = Map!
    @countries = {k, v for k, v in pairs authority_definitions}
    @armies = {}
    @month_tick = 1
  
  get_provinces: =>
    @map.provinces

  register_army: (a) =>
    @armies[#@armies+1] = a

  load: =>
    for _, v in pairs province_definitions
      @map\add_province v
      v\set_map @map
    @map\load_provinces province_colors

  monthly_tick: =>
    @map\tick_monthly!

  tick: =>
    if @month_tick >= 30
      @monthly_tick!
      @month_tick = 1

    @map\tick!
    for a in *@armies
      a\do_order @map
      _list_1[_index_0] if a.isdead

    @month_tick += 1

  draw: =>
    @map\draw!

{:Game}