util = require 'crescent.util'
{:to_lua} = require 'moonscript'

with {}
  .outputPath = (inputPath, basePath, outputFolder) ->
    outputPath = util.setExtension inputPath, 'lua'

    if outputFolder
      basePattern = '^' .. (util.escapePattern basePath) .. '[\\/]*'
      outputPath = "#{ outputFolder }/#{ outputPath\gsub basePattern, '' }"

    outputPath

  .file = (sourcePath, outputPath) ->
    source, err = util.readFile sourcePath
    return false, err if not source

    output, err = to_lua source
    return false, err if not output

    util.writeFile outputPath, output
