export *

import Title, State from require 'state'
import Map, Province from require 'map'

state_definitions =
  austria: State "austria", {province_definitions.graz, province_definitions.upper_graz, province_definitions.wolfsberg, province_definitions.voitsberg, province_definitions.volkermarkt, province_definitions.klagenfurt, province_definitions.greater_austria, province_definitions.leoben}
  croatia: State "croatia", {province_definitions.zagreb, province_definitions.velika_gorica, province_definitions.northern_croatia, province_definitions.western_zagreb, province_definitions.sistak, province_definitions.inner_dinaric}
  dalmatia: State "dalmatia", {province_definitions.inner_split, province_definitions.split, province_definitions.sibenik, province_definitions.trilj, province_definitions.biograd}