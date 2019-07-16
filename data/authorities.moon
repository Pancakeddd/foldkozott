export *

import Authority, Government from require 'state'

authority_definitions =
  austria: Authority "Austria", (with Government("")
    .levy = army_levy.small
    ), 
    {title_definitions.austria}
  croatia: Authority "Croatia", Government(""), {title_definitions.croatia}