g = love.graphics

ArmyTypes =
  Militia:
    Defense: 25
    DefenseMorale: 0.6
    Attack: 35
    AttackAccuracy: 75
    AttackMorale: 1
    Armor: 0.9
    Morale: 100

  Artillery:
    Defense: 25
    DefenseMorale: 0.3
    Attack: 80
    AttackAccuracy: 45
    AttackMorale: 1
    Armor: 0.9
    Morale: 100


armygroup = (people, armytype) ->
  {
  :people
  :armytype
  morale: armytype.Morale
  isrouting: false
  }

class Battle
  new: (@attacker, @defender) =>
    @whoattacking = false
    @attacker.inbattle = true
    @defender.inbattle = true

  battletick: =>
      attacker, defender = nil
      if @whoattacking
        attacker = @attacker
        defender = @defender
      else
        attacker = @defender
        defender = @attacker

      if attacker\gettotalmorale! < 0 or attacker\gettotalfightingarmysize! < 1
        @defender.inbattle = false
        @attacker.inbattle = false
        @ended = true
        print "Battle Ended"
        attacker\afterbattle!
        return defender, "defender"
      if defender\gettotalmorale! < 0 or defender\gettotalfightingarmysize! < 1
        @defender.inbattle = false
        @attacker.inbattle = false
        @ended = true
        print "Battle Ended"
        defender\afterbattle!
        return attacker, "attacker"

      -- Attacker attacks defender
      for army in *attacker.army
        if not army.isrouting
          defenderarmy = [item for item in *defender.army when not item.isrouting]
          if #defenderarmy < 1
            break
          enemyarmy = nil
          while true
            enemyarmy = defenderarmy[love.math.random(1, #defenderarmy)]
            break unless enemyarmy.isrouting
          if math.random(0, 100) > enemyarmy.armytype.AttackAccuracy
            damage = clampzero ((army.people/100) * love.math.random(1, army.armytype.Attack)) - ((enemyarmy.people/100) * love.math.random(1, enemyarmy.armytype.Defense))
            enemyarmy.morale -= damage/5
            enemyarmy.people -= math.floor damage
          if army.morale <= 20
            print "Army of #{attacker.loyalty.name} has routed"
            army.isrouting = true
      print @defender\gettotalfightingarmysize!, defender\gettotalmorale!, "Defender"
      print @attacker\gettotalfightingarmysize!, attacker\gettotalmorale!, "Attacker"
      @whoattacking = not @whoattacking

  draw: (p) =>
    center = p.shapecenter
    g.print display_pop(@attacker\gettotalarmysize!), center[1] + 50, center[2]
    @attacker\draw_morale center[1] + 150, center[2] + 20
    @attacker\draw_flag false, center[1] + 70, center[2]
    g.print display_pop(@defender\gettotalarmysize!), center[1] - 50, center[2]
    @defender\draw_morale center[1] - 150, center[2] + 20
    @defender\draw_flag true, center[1] - 70, center[2]

order = (name, pred) ->
  {:name, :pred}

class Army
  new: (@army, @loyalty) =>
    @routing = false
    @total = @gettotalarmysize!
    @inbattle = false
    @isdead = false
    @movement = {-1, nil}
    @orders = {}
    @currentorder = nil

  gettotalarmysize: =>
    t = 0
    for p in *@army
      t += p.people
    return t

  afterbattle: =>
    for a in *@army
      a.isrouting = false
    @routing = true

  recovermorale: =>
    for a in *@army
      a.morale += 10 if a.morale < 100

  gettotalfightingarmysize: =>
    t = 0
    for p in *@army
        t += p.people unless p.isrouting
    return t

  is_dead: =>
    if @gettotalarmysize! <= 0
      @isdead = true

  getprov: (map) =>
    for p in *map.provinces
      if p\find_army @
        return p

  add_order: (order) =>
    @orders[#@orders+1] = order

  peek_order: =>
    @orders[1]

  pop_order: =>
    table.remove @orders, 1

  do_order: (map) =>
    if @currentorder == nil
      if #@orders > 0
        @currentorder = @pop_order!
      else
        return
    
    if @currentorder.name == "move"
      @currentorder = nil if @move(map, @currentorder.pred.province) == true

  move: (map, p) =>
    return if @inbattle
    ap = @getprov map
    distance = dist_real p.shapecenter[1], p.shapecenter[2], ap.shapecenter[1], ap.shapecenter[2]
    if @movement[1] == -1
      @movement[1] = distance
      @movement[2] = p
    else
      @movement[1] -= 25
      if @movement[1] <= 0
        ap\remove_army @
        p\add_army @
        @movement = {-1, nil}
        return true
    print "Distance:", distance

  move_to: (map, p) =>
    ap = @getprov map
    path = map\get_path ap, p
    return if #path < 1
    for province in *trimf path
      @add_order order "move", {province: province}

  gettotalmorale: =>
    t = 0
    for p in *@army
      t += p.morale
    return t/#@army

  gettotalfightingmorale: =>
    t = 0
    for p in *@army
      t += p.morale unless p.isrouting
    return t/#@army

  gettotalpossiblemorale: =>
    t = 0
    for p in *@army
      t += p.armytype.Morale
    return t

  draw_flag: (dir=false, x, y, size=0.1) =>
    direction = (do
      if not dir
        return 1
      else
        return -1)
    flag = @loyalty.flag
    with g
      .push!
      .scale size, size
      .draw flag, (x+(direction*10))/size, y/size
      .pop!

  draw_morale: (x, y) =>
    with g
      .setColor 219/255, 42/255, 42/255
      .rectangle 'fill', x, y, 100, 10
      .setColor 42/255, 219/255, 45/255
      .rectangle 'fill', x, y, 100*(@gettotalfightingmorale!/@gettotalpossiblemorale!), 10
      .setColor 1, 1, 1

  draw: (p, b) =>
    if not b
      g.setColor 1, 1, 1
      g.print display_pop(@gettotalarmysize!), p.shapecenter[1], p.shapecenter[2]
      @draw_flag false, p.shapecenter[1], p.shapecenter[2] - 20
    else
      b\draw p

  battletick: (army) =>

  canfight: =>
    not @inbattle and not @routing

  update: (dt) =>
    @recovermorale!
    @is_dead!

{:ArmyTypes, :Army, :Battle, :armygroup, :order}