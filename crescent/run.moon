{:loadfile} = require 'moonscript'

with {}
  .file = (path, ...) ->
    chunk, err = loadfile path
    return false, err if not chunk

    pcall chunk, ...
