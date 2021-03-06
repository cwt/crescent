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

    peek = ->
      arguments[current + 1]

    for arg in next
      if opt = options[arg]
        params = for i=1, opt.paramCount
          with param = peek!
            break if not param
            break if options[param]
            next!

        opt.callback unpack params
      else
        return false, "unknown argument \"#{arg}\""

    true
