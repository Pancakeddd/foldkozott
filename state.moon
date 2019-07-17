claim_to_authority = {
  "god"
}

g = love.graphics

-- A State is a grouping of provinces that are considered tied together by some sort of historical grouping or national ties

class State
  new: (@name, @provinces, @states = {}) =>
    @loyalty = nil

  set_loyalty: (state) =>
    @loyalty = state

  conscript: (loyalty) =>
    for s in *@states
      s\conscript loyalty
    for p in *@provinces
      print loyalty
      p\conscript {conscription: 100}, loyalty
      for k, v in pairs p.linkedarmies
        print k, v\gettotalarmysize!
      print "This happened."

-- Titles are groupings of states and/or other titles, representing different scales of rule.

class Title
  new: (@states, @titles = {}) =>

class Government
  new: (@claim) =>
    @authority = 100
    @levy = army_levy.small

  tick_authority: =>

  tick: =>

-- Authorities rule over titles and/or other authorities as unions. Every Authority has it's own government that rules over it's land.

class Authority
  new: (@name, @government, @titles, @authorities = {}, @startloyal = true) =>
    @diplomacy = {}
    if @startloyal
      for t in *@titles
        for s in *t.states
          for p in *s.provinces
            p.loyalty = @
    @load_flag!

  add_diplomatic_relation: (relation) =>
    @diplomacy[#@diplomacy+1] = relation

  war: (country) =>
    @diplomacy[#@diplomacy+1] = {
        type: "war"
        relation: country
      }

  get_relation_with: (type, country) =>
    t = {}
    for relation in *@diplomacy
      if relation.type == type and relation.relation == country then
        t[#t+1] = relation
    return t
      
  get_relation: (type) =>
    t = {}
    for relation in *@diplomacy
      if relation.type == type
        t[#t+1] = relation
    return t

  add_title: (t) =>
    @titles[@titles] =  t

  conscript: =>
    for t in *@titles
      for s in *t.states
        print "yaa"
        s\conscript @
    for a in *@authorities
      a\conscript!

  load_flag: =>
    @flag = g.newImage "assets/flags/#{@name}.png"

in_conflict = (a, b) ->
  if a\get_relation_with("war", b) or b\get_relation_with("war", a)
    return true

{:State, :Title, :Government, :Authority, :in_conflict}