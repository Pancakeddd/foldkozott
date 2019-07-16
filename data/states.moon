export *

import Title, State from require 'state'
import Map, Province from require 'map'

state_definitions =
  austria: State "austria", {province_definitions.greater_austria, province_definitions.graz, province_definitions.upper_graz, province_definitions.klagenfurt, province_definitions.wolfsberg, province_definitions.villach}
  croatia: State "croatia", {province_definitions.zagreb}