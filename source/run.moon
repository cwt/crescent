{:loadfile} = require 'moonscript'

with {}
  .file = (path, ...) ->
    chunk, err = loadfile path
    return err if not chunk

    pcall chunk, ...
