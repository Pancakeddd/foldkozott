g = love.graphics

ArmyTypes =
  Pikemen:
    Defense: 20
    DefenseMorale: 0.8
    Attack: 12
    AttackMorale: 1
    Armor: 0.9
    Morale: 100
  Cavalry:
    Defense: 10
    DefenseMorale: 1.5
    Attack: 20
    AttackMorale: 1.2
    Armor: 0.9
    Morale: 100
  Artillery:
    Defense: 10
    DefenseMorale: 1.8
    Attack: 20
    AttackMorale: 1.4
    Armor: 0.9
    Morale: 100
  Musketeer:
    Defense: 12
    DefenseMorale: 1
    Attack: 30
    AttackMorale: 1.7
    Armor: 0.7
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
          defenderarmy = {}
          for a in *defender.army
            if not a.isrouting
              defenderarmy[#defenderarmy+1] = a
          if #defenderarmy < 1
            break
          enemyarmy = nil
          while true
            enemyarmy = defenderarmy[love.math.random(1, #defenderarmy)]
            break unless enemyarmy.isrouting
          
          damage = (((army.people/500) + love.math.random(1, army.armytype.Attack) * army.armytype.AttackMorale) - (enemyarmy.people/500) + enemyarmy.armytype.Defense * enemyarmy.armytype.DefenseMorale) * (army.morale / 100)
          enemyarmy.morale -= damage/5
          enemyarmy.people -= math.floor damage

          if army.morale < 20
            army.isrouting = true
      print @defender\gettotalfightingarmysize!, defender\gettotalmorale!, "Defender"
      print @attacker\gettotalfightingarmysize!, attacker\gettotalmorale!, "Attacker"
      @whoattacking = not @whoattacking

  draw: (p) =>
    g.print display_pop(@attacker\gettotalarmysize!), p.shapecenter[1] + 50, p.shapecenter[2]
    @attacker\draw_morale p.shapecenter[1] + 150, p.shapecenter[2] + 20
    g.print display_pop(@defender\gettotalarmysize!), p.shapecenter[1] - 50, p.shapecenter[2]
    @defender\draw_morale p.shapecenter[1] - 150, p.shapecenter[2] + 20


class Army
  new: (@army, @loyalty) =>
    @routing = false
    @total = @gettotalarmysize!
    @inbattle = false

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

  draw_morale: (x, y) =>
    g.setColor 219/255, 42/255, 42/255
    g.rectangle 'fill', x, y, 100, 10
    g.setColor 42/255, 219/255, 45/255
    g.rectangle 'fill', x, y, 100*(@gettotalfightingmorale!/@gettotalpossiblemorale!), 10
    g.setColor 1, 1, 1

  draw: (p, b) =>
    if not b
      g.setColor 1, 1, 1
      g.print display_pop(@gettotalarmysize!), p.shapecenter[1], p.shapecenter[2]
    else
      b\draw p

  battletick: (army) =>

  canfight: =>
    not @inbattle and not @routing

  update: (dt) =>
    @recovermorale!

{:ArmyTypes, :Army, :Battle, :armygroup}