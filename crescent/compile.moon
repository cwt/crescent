util = require 'crescent.util'
{:to_lua} = require 'moonscript'

with {}
  .outputPath = (inputPath, basePath, outputFolder) ->
    outputPath = util.setExtension inputPath, 'lua'

    if outputFolder
      basePattern = '^' .. (util.escapePattern basePath) .. '[\\/]*'
      outputPath = "#{ outputFolder }/#{ outputPath\gsub basePattern, '' }"

    outputPath

  .source = (sourcePath) ->
    source, err = util.readFile sourcePath
    return false, err if not source

    to_lua source

  .write = (sourcePath, outputPath) ->
    output, err = .source sourcePath
    return false, err if not output
      
    util.writeFile outputPath, output
