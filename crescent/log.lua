local colors = require('term.colors')
local inspect = require('inspect')
do
  local log = { }
  local levels = {
    info = colors.dim,
    success = colors.green,
    error = colors.red,
    warning = colors.yellow
  }
  local concatArgs
  concatArgs = function(...)
    local strings
    do
      local _accum_0 = { }
      local _len_0 = 1
      local _list_0 = {
        ...
      }
      for _index_0 = 1, #_list_0 do
        local arg = _list_0[_index_0]
        if (type(arg)) == 'table' then
          _accum_0[_len_0] = inspect(arg)
        else
          _accum_0[_len_0] = tostring(arg)
        end
        _len_0 = _len_0 + 1
      end
      strings = _accum_0
    end
    return table.concat(strings, '\t')
  end
  local logMessage
  logMessage = function(message, color)
    if color == nil then
      color = colors.default
    end
    return print(color(tostring(message)))
  end
  for level, color in pairs(levels) do
    log[level] = function(...)
      local space = (' '):rep(12 - #level)
      return logMessage(tostring(level) .. tostring(space) .. tostring(concatArgs(...)), color)
    end
  end
  setmetatable(log, {
    __call = function(self, ...)
      return logMessage(concatArgs(...))
    end
  })
  return log
end