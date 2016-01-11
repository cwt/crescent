local loadfile
loadfile = require('moonscript').loadfile
do
  local _with_0 = { }
  _with_0.file = function(path)
    return pcall(function()
      return (assert(loadfile(path)))()
    end)
  end
  return _with_0
end