local util = require('crescent.util')
local to_lua
to_lua = require('moonscript').to_lua
do
  local _with_0 = { }
  _with_0.outputPath = function(inputPath, basePath, outputFolder)
    local outputPath = util.setExtension(inputPath, 'lua')
    if outputFolder then
      local basePattern = '^' .. (util.escapePattern(basePath)) .. '[\\/]*'
      outputPath = tostring(outputFolder) .. "/" .. tostring(outputPath:gsub(basePattern, ''))
    end
    return outputPath
  end
  _with_0.source = function(sourcePath)
    local source, err = util.readFile(sourcePath)
    if not source then
      return false, err
    end
    return to_lua(source)
  end
  _with_0.write = function(sourcePath, outputPath)
    local output, err = _with_0.source(sourcePath)
    if not output then
      return false, err
    end
    return util.writeFile(outputPath, output)
  end
  return _with_0
end