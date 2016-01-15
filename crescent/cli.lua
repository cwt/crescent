local inspect = require('inspect')
do
  local _with_0 = { }
  local options = { }
  local argumentCallback
  argumentCallback = function() end
  local matchOption
  matchOption = function(arg)
    for option in pairs(options) do
      if arg == option then
        return option
      end
    end
    for alias, option in pairs(aliases) do
      if arg == alias then
        return option
      end
    end
  end
  local escapePattern
  escapePattern = function(pattern)
    return pattern:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', function(char)
      return '%' .. char
    end)
  end
  _with_0.option = function(flag, paramCount, callback)
    options[flag] = {
      paramCount = paramCount,
      callback = callback
    }
  end
  _with_0.alias = function(alias, option)
    options[alias] = options[option]
  end
  _with_0.parse = function(arguments)
    local current = 0
    local next
    next = function()
      current = current + 1
      return arguments[current]
    end
    local peek
    peek = function()
      return arguments[current + 1]
    end
    for arg in next do
      do
        local opt = options[arg]
        if opt then
          local params
          do
            local _accum_0 = { }
            local _len_0 = 1
            for i = 1, opt.paramCount do
              do
                local param = peek()
                if not param then
                  break
                end
                if options[param] then
                  break
                end
                next()
                _accum_0[_len_0] = param
              end
              _len_0 = _len_0 + 1
            end
            params = _accum_0
          end
          opt.callback(unpack(params))
        else
          return false, "unknown argument \"" .. tostring(arg) .. "\""
        end
      end
    end
    return true
  end
  return _with_0
end