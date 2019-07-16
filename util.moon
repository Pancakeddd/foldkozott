export *

display_pop = (pop) ->
  return "#{pop/1000000}m" if pop >= 1000000
  return "#{pop/1000}k" if pop >= 1000
  return tostring pop