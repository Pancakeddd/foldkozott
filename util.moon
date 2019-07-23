export *

display_pop = (pop) ->
  return "#{pop/1000000}m" if pop >= 1000000
  return "#{pop/1000}k" if pop >= 1000
  return tostring pop

dist = (x1, y1, x2, y2) -> math.sqrt (x2-x1)^2 + (y2-y1)^2

dist_real = (...) -> dist(...) -- WIP

clampzero = (x) ->
  return 0 if x < 0
  x