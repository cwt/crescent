{:loadfile} = require 'moonscript'

with {}
  .file = (path) ->
    pcall -> (assert loadfile path)!
