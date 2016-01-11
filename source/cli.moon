inspect = require 'inspect'

with {}
  options = {}
  argumentCallback = ->

  matchOption = (arg) ->
    for option in pairs options
      if arg == option
        return option

    for alias, option in pairs aliases
      if arg == alias
        return option

  escapePattern = (pattern) ->
    pattern\gsub '[%^%$%(%)%%%.%[%]%*%+%-%?]', (char) -> '%' .. char

  .option = (flag, paramCount, callback) ->
    options[flag] = :paramCount, :callback

  .alias = (alias, option) ->
    options[alias] = options[option]

  .parse = (arguments) ->
    current = 0
    next = ->
      current += 1
      arguments[current]

    cliArgs = {}

    for arg in next
      if arg == '--'
        table.insert cliArgs, arg for arg in next
        break
      elseif opt = options[arg]
        params = [ next! for i=1, opt.paramCount ]
        opt.callback unpack params
      else
        table.insert cliArgs, arg

    cliArgs
