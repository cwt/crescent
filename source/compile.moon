util = require 'crescent.util'
{:to_lua} = require 'moonscript'

with {}
  .file = (path, outputPath) ->
    source, err = util.readFile path
    if not source
      return false, err

    output, err = to_lua source
    if not output
      return false, err

    util.writeFile outputPath, output
