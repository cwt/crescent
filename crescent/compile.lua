local util = require('crescent.util')
local to_lua
to_lua = require('moonscript').to_lua
do
  local _with_0 = { }
  _with_0.file = function(path, outputPath)
    local source, err = util.readFile(path)
    if not source then
      return false, err
    end
    local output
    output, err = to_lua(source)
    if not output then
      return false, err
    end
    return util.writeFile(outputPath, output)
  end
  return _with_0
end