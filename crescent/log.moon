colors = require 'term.colors'
inspect = require 'inspect'

with log = {}
  .levels =
    info: colors.dim
    success: colors.green
    error: colors.red
    warning: colors.yellow

  enabledLevels = { level, true for level in pairs .levels }

  .these = (levels) ->
    enabledLevels = { level, true for level in *levels }

  .colors = false

  concatArgs = (...) ->
    strings = for arg in *{...}
      if (type arg) == 'table'
        inspect arg
      else
        tostring arg

    table.concat strings, '\t'

  for level, color in pairs .levels
    log[level] = (...) ->
      if enabledLevels[level]
        space = ' '\rep 12 - #level
        message = "#{level}#{space}#{concatArgs ...}"
        if .colors
          print color message
        else
          print message
