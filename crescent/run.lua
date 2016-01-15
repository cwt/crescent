local loadfile
loadfile = require('moonscript').loadfile
do
  local _with_0 = { }
  _with_0.file = function(path, ...)
    local chunk, err = loadfile(path)
    if not chunk then
      return err
    end
    return pcall(chunk, ...)
  end
  return _with_0
end