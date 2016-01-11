local util = require('crescent.util')
local log = require('crescent.log')
local cli = require('crescent.cli')
local help = require('crescent.help')
local run = require('crescent.run')
local compile = require('crescent.compile')
local watch = require('crescent.watch')
local inspect = require('inspect')
local fs = require('lfs')
local sleep
sleep = require('socket').sleep
return function(...)
  io.stdout:setvbuf('no')
  local options = {
    printHelp = false,
    compilePaths = { },
    outputFolder = nil,
    watching = false,
    watchPollTime = 1,
    cliErrors = { }
  }
  local arguments = nil
  do
    cli.option('--help', 0, function()
      options.printHelp = true
    end)
    cli.option('--compile', 1, function(path)
      return table.insert(options.compilePaths, path)
    end)
    cli.option('--output-folder', 1, function(folder)
      options.outputFolder = folder
    end)
    cli.option('--watch', 0, function()
      options.watching = true
    end)
    cli.option('--poll-time', 1, function(time)
      options.watchPollTime = time
    end)
    cli.option('--moonify', 1, function(path)
      return log.error("sorry, moonify doesn't work yet!")
    end)
    cli.alias('-h', '--help')
    cli.alias('-c', '--compile')
    cli.alias('-d', '--output-folder')
    cli.alias('-w', '--watch')
    cli.alias('-pt', '--poll-time')
    arguments = cli.parse({
      ...
    })
  end
  if #options.cliErrors > 0 then
    local _list_0 = options.cliErrors
    for _index_0 = 1, #_list_0 do
      local err = _list_0[_index_0]
      log.error(err)
    end
  elseif options.printHelp or (#arguments == 0 and #options.compilePaths == 0) then
    return help.print()
  else
    local runFile
    runFile = function(script, ...)
      local message = "running " .. tostring(script)
      message = message .. (function(...)
        if (select('#', ...)) > 0 then
          return " with arguments: " .. tostring(table.concat({
            ...
          }, ', '))
        else
          return " without arguments"
        end
      end)(...)
      log.info(message)
      local results = {
        run.file(script, ...)
      }
      local success = table.remove(results, 1)
      if success then
        local returnValues
        do
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #results do
            local v = results[_index_0]
            _accum_0[_len_0] = inspect(v)
            _len_0 = _len_0 + 1
          end
          returnValues = _accum_0
        end
        log.success("file ran successfully!")
        if #returnValues > 0 then
          return log.success("returned: " .. tostring(table.concat(returnValues, ',')))
        else
          return log.success("returned nothing")
        end
      else
        return log.error(results[1])
      end
    end
    local compilePath
    compilePath = function(path, root)
      local _list_0 = util.collectFiles(path)
      for _index_0 = 1, #_list_0 do
        local file = _list_0[_index_0]
        local outputFile = util.setExtension(file, 'lua')
        if options.outputFolder then
          local rootPattern = '^' .. (util.escapePattern(root)) .. '[\\/]*'
          outputFile = tostring(options.outputFolder) .. "/" .. tostring(outputFile:gsub(rootPattern, ''))
        end
        log.info('compiling', file)
        local success, err = compile.file(file, outputFile)
        if success then
          log.success('compiled', outputFile)
        else
          log.error(err)
        end
      end
    end
    if #arguments > 0 then
      runFile(unpack(arguments))
    end
    local _list_0 = options.compilePaths
    for _index_0 = 1, #_list_0 do
      local path = _list_0[_index_0]
      compilePath(path, path)
    end
    if options.watching then
      print()
      log.info("starting watch loop!")
      local logPaths = { }
      local _list_1 = options.compilePaths
      for _index_0 = 1, #_list_1 do
        local path = _list_1[_index_0]
        table.insert(logPaths, path)
      end
      if #arguments > 0 then
        table.insert(logPaths, arguments[1])
      end
      for _index_0 = 1, #logPaths do
        local path = logPaths[_index_0]
        watch.path(path, function(event, ...)
          local _exp_0 = event
          if 'initialized' == _exp_0 then
            local paths
            do
              local _accum_0 = { }
              local _len_0 = 1
              for _index_1 = 1, #logPaths do
                path = logPaths[_index_1]
                local _exp_1 = fs.attributes(path, 'mode')
                if 'file' == _exp_1 then
                  _accum_0[_len_0] = path
                elseif 'directory' == _exp_1 then
                  _accum_0[_len_0] = path .. '/**/*.moon'
                end
                _len_0 = _len_0 + 1
              end
              paths = _accum_0
            end
            return log.info("watching", table.concat(paths, ', '))
          elseif 'fileChanged' == _exp_0 then
            return log.info("changed", ...)
          elseif 'fileCreated' == _exp_0 then
            return log.info("created", ...)
          elseif 'fileRemoved' == _exp_0 then
            return log.info("removed", ...)
          end
        end)
      end
      if #arguments > 0 then
        watch.path(arguments[1], function(event, ...)
          if event == 'fileChanged' then
            return runFile(unpack(arguments))
          end
        end)
      end
      local _list_2 = options.compilePaths
      for _index_0 = 1, #_list_2 do
        local path = _list_2[_index_0]
        watch.path(path, function(event, ...)
          local _exp_0 = event
          if 'fileChanged' == _exp_0 or 'fileCreated' == _exp_0 then
            return compilePath(..., path)
          end
        end)
      end
      while true do
        sleep(options.watchPollTime)
        watch.loop()
      end
    end
  end
end