g = love.graphics

class Camera
  new: (@ox = 0, @oy = 0) =>
    @zoom = 0

  draw: =>
    with g
      .push!
      .translate -@ox, -@oy

  pop: => g.pop!
  
  move: (x, y) =>
    @ox += x
    @oy += y

{:Camera}