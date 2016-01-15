local fs = require('lfs')
local inspect = require('inspect')
do
  local _with_0 = { }
  local isMoonFile
  isMoonFile = function(path)
    return (_with_0.getExtension(path)) == 'moon'
  end
  _with_0.version = function(major, minor, patch)
    return setmetatable(({
      major = major,
      minor = minor,
      patch = patch
    }), ({
      __tostring = function(self)
        return ('%d.%d.%d'):format(major, minor, patch)
      end
    }))
  end
  _with_0.escapePattern = function(pattern)
    return pattern:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]', function(char)
      return '%' .. char
    end)
  end
  _with_0.getExtension = function(path)
    return (_with_0.getBasename(path)):match('%.([^%.]+)$')
  end
  _with_0.setExtension = function(path, extension)
    return tostring(path:gsub('%.[^%.]+$', '')) .. "." .. tostring(extension)
  end
  _with_0.getFolder = function(path)
    return (path:match('^(.*)[\\/]+')) or '.'
  end
  _with_0.getBasename = function(path)
    return path:match('[^\\/]*$')
  end
  _with_0.readFile = function(path)
    local file, err = io.open(path, 'r')
    if file then
      local content = file:read('*a')
      file:close()
      return content
    else
      return nil, err
    end
  end
  _with_0.writeFile = function(path, content)
    local success, err = _with_0.createDirectory(_with_0.getFolder(path))
    if not success then
      return false, err
    end
    local file
    file, err = io.open(path, 'w')
    if file then
      file:write(content)
      file:close()
      return true
    else
      return false, err
    end
  end
  _with_0.createDirectory = function(dir, current)
    if current == nil then
      current = '.'
    end
    for part in dir:gmatch('[^\\/]*[^\\/]+') do
      local path = current .. '/' .. part
      if (fs.attributes(path, 'mode')) ~= 'directory' then
        local success, err = fs.mkdir(path)
        if not success then
          return false, err
        end
      end
      current = path
    end
    return true
  end
  _with_0.collectFiles = function(path, condition)
    local collected = { }
    local _exp_0 = fs.attributes(path, "mode")
    if 'file' == _exp_0 then
      local file = path
      if not condition or condition(file) then
        table.insert(collected, file)
      end
    elseif 'directory' == _exp_0 then
      local folder = path
      for file in fs.dir(folder) do
        if file ~= '.' and file ~= '..' then
          local subpath = folder .. '/' .. file
          local _list_0 = _with_0.collectFiles(subpath, isMoonFile)
          for _index_0 = 1, #_list_0 do
            file = _list_0[_index_0]
            table.insert(collected, file)
          end
        end
      end
    end
    return collected
  end
  return _with_0
end