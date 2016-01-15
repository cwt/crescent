local colors = require('term.colors')
local inspect = require('inspect')
do
  local log = { }
  log.levels = {
    info = colors.dim,
    success = colors.green,
    error = colors.red,
    warning = colors.yellow
  }
  local enabledLevels
  do
    local _tbl_0 = { }
    for level in pairs(log.levels) do
      _tbl_0[level] = true
    end
    enabledLevels = _tbl_0
  end
  log.these = function(levels)
    do
      local _tbl_0 = { }
      for _index_0 = 1, #levels do
        local level = levels[_index_0]
        _tbl_0[level] = true
      end
      enabledLevels = _tbl_0
    end
  end
  log.colors = false
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
  for level, color in pairs(log.levels) do
    log[level] = function(...)
      if enabledLevels[level] then
        local space = (' '):rep(12 - #level)
        local message = tostring(level) .. tostring(space) .. tostring(concatArgs(...))
        if log.colors then
          return print(color(message))
        else
          return print(message)
        end
      end
    end
  end
  return log
end