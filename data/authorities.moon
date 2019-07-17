export *

import Authority, Government from require 'state'

authority_definitions =
  austria: Authority "austria", (with Government("")
    .levy = army_levy.small
    ), 
    {title_definitions.austria}
  croatia: Authority "croatia", Government(""), {title_definitions.croatia}