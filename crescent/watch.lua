local fs = require('lfs')
local sleep
sleep = require('socket').sleep
local collectFiles
collectFiles = require('crescent.util').collectFiles
do
  local _with_0 = { }
  local watchers = { }
  _with_0.path = function(watchPath, eventCallback)
    local currentFiles = { }
    local _list_0 = collectFiles(watchPath)
    for _index_0 = 1, #_list_0 do
      local collectedFile = _list_0[_index_0]
      currentFiles[collectedFile] = {
        modtime = fs.attributes(collectedFile, 'modification')
      }
    end
    local filesArray
    do
      local _accum_0 = { }
      local _len_0 = 1
      for file in pairs(currentFiles) do
        _accum_0[_len_0] = file
        _len_0 = _len_0 + 1
      end
      filesArray = _accum_0
    end
    eventCallback('initialized', filesArray)
    local watcher
    watcher = function()
      local existing = { }
      local _list_1 = collectFiles(watchPath)
      for _index_0 = 1, #_list_1 do
        local file = _list_1[_index_0]
        local modtime = fs.attributes(file, 'modification')
        if currentFiles[file] then
          if modtime > currentFiles[file].modtime then
            eventCallback('fileChanged', file)
          end
        else
          eventCallback('fileCreated', file)
        end
        existing[file] = {
          modtime = modtime
        }
      end
      for file in pairs(currentFiles) do
        if not existing[file] then
          eventCallback('fileRemoved', file)
        end
      end
      currentFiles = existing
    end
    return table.insert(watchers, watcher)
  end
  _with_0.loop = function()
    for _index_0 = 1, #watchers do
      local watcher = watchers[_index_0]
      watcher()
    end
  end
  return _with_0
end