colors = require 'term.colors'
inspect = require 'inspect'

with log = {}
  levels =
    info: colors.dim
    success: colors.green
    error: colors.red
    warning: colors.yellow

  concatArgs = (...) ->
    strings = for arg in *{...}
      if (type arg) == 'table'
        inspect arg
      else
        tostring arg

    table.concat strings, '\t'

  logMessage = (message, color = colors.default) ->
    print color "#{message}"

  for level, color in pairs levels
    log[level] = (...) ->
      space = ' '\rep 12 - #level
      logMessage "#{level}#{space}#{concatArgs ...}", color

  setmetatable log,
    __call: (...) =>
      logMessage concatArgs ...
