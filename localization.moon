export i18n = require 'libs/i18n'

i18n.loadFile 'localization/en.lua'

export set_language = (lang) ->
  i18n.setLocale lang