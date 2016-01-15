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
    runFiles = { },
    outputFolder = nil,
    watching = false,
    watchPollTime = 1,
    logLevels = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for level in pairs(log.levels) do
        _accum_0[_len_0] = level
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)(),
    colors = true
  }
  local cliErrors = { }
  local verify
  verify = function(value, err)
    if value ~= nil then
      return true
    end
    table.insert(cliErrors, err)
    return false
  end
  do
    cli.option('--help', 0, function()
      options.printHelp = true
    end)
    cli.option('--compile', math.huge, function(...)
      if not (verify(..., "no paths were given to --compile")) then
        return 
      end
      local _list_0 = {
        ...
      }
      for _index_0 = 1, #_list_0 do
        local path = _list_0[_index_0]
        table.insert(options.compilePaths, path)
      end
    end)
    cli.option('--run', math.huge, function(file, ...)
      if not (verify(file, "no file or arguments were given to --run")) then
        return 
      end
      return table.insert(options.runFiles, {
        file = file,
        args = {
          select(2, ...)
        }
      })
    end)
    cli.option('--output-folder', 1, function(folder)
      if not (verify(folder, "no folders were given to --output-folder")) then
        return 
      end
      options.outputFolder = folder
    end)
    cli.option('--poll-time', 1, function(time)
      if not (verify(time, "no time was given to --poll-time")) then
        return 
      end
      options.watchPollTime = time
    end)
    cli.option('--watch', 0, function()
      options.watching = true
    end)
    cli.option('--moonify', 1, function(path)
      return log("sorry, moonify doesn't work yet!")
    end)
    cli.option('--log', math.huge, function(...)
      local levelString = table.concat((function()
        local _accum_0 = { }
        local _len_0 = 1
        for level in pairs(log.levels) do
          _accum_0[_len_0] = level
          _len_0 = _len_0 + 1
        end
        return _accum_0
      end)(), ', ')
      local errorString = "no log levels were given to --log; available levels: " .. tostring(levelString)
      if not (verify(..., errorString)) then
        return 
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        local _list_0 = {
          ...
        }
        for _index_0 = 1, #_list_0 do
          local level = _list_0[_index_0]
          _accum_0[_len_0] = level
          _len_0 = _len_0 + 1
        end
        options.logLevels = _accum_0
      end
    end)
    cli.option('--silent', 0, function()
      options.logLevels = { }
    end)
    cli.option('--no-colors', 0, function()
      options.colors = false
    end)
    cli.alias('-h', '--help')
    cli.alias('-r', '--run')
    cli.alias('-c', '--compile')
    cli.alias('-d', '--output-folder')
    cli.alias('-w', '--watch')
    cli.parse({
      ...
    })
  end
  log.these(options.logLevels)
  log.colors = options.colors
  if #cliErrors > 0 then
    local _list_0 = cliErrors
    for _index_0 = 1, #_list_0 do
      local err = _list_0[_index_0]
      log.error(err)
    end
  elseif options.printHelp or (#options.runFiles == 0 and #options.compilePaths == 0) then
    return help.print()
  else
    local runFile
    runFile = function(script, args)
      local message = "running " .. tostring(script)
      message = message .. (function()
        if #args > 0 then
          return " with arguments: " .. tostring(table.concat(args, ', '))
        else
          return " without arguments"
        end
      end)()
      log.info(message)
      local results = {
        run.file(script, unpack(args))
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
          return log.success("returned: " .. tostring(table.concat(returnValues, ', ')))
        else
          return log.success("returned nothing")
        end
      else
        return log.error(results[1])
      end
    end
    local compilePath
    compilePath = function(path, basePath)
      if (fs.attributes(basePath, 'mode')) == 'file' then
        basePath = util.getFolder(basePath)
      end
      local _list_0 = util.collectFiles(path)
      for _index_0 = 1, #_list_0 do
        local file = _list_0[_index_0]
        local outputFile = compile.outputPath(file, basePath, options.outputFolder)
        log.info('compiling', file)
        local success, err = compile.file(file, outputFile)
        if success then
          log.success('compiled', outputFile)
        else
          log.error(err)
        end
      end
    end
    local _list_0 = options.compilePaths
    for _index_0 = 1, #_list_0 do
      local path = _list_0[_index_0]
      compilePath(path, path)
    end
    local _list_1 = options.runFiles
    for _index_0 = 1, #_list_1 do
      local file = _list_1[_index_0]
      runFile(file.file, file.args)
    end
    if options.watching then
      print()
      log.info("starting watch loop!")
      local logPaths = { }
      local _list_2 = options.compilePaths
      for _index_0 = 1, #_list_2 do
        local path = _list_2[_index_0]
        table.insert(logPaths, path)
      end
      local _list_3 = options.runFiles
      for _index_0 = 1, #_list_3 do
        local file = _list_3[_index_0]
        table.insert(logPaths, file.file)
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
            print()
            return log.info("changed", ...)
          elseif 'fileCreated' == _exp_0 then
            print()
            return log.info("created", ...)
          elseif 'fileRemoved' == _exp_0 then
            print()
            return log.info("removed", ...)
          end
        end)
      end
      local _list_4 = options.compilePaths
      for _index_0 = 1, #_list_4 do
        local sourcePath = _list_4[_index_0]
        watch.path(sourcePath, function(event, ...)
          local _exp_0 = event
          if 'fileChanged' == _exp_0 or 'fileCreated' == _exp_0 then
            return compilePath(..., sourcePath)
          elseif 'fileRemoved' == _exp_0 then
            local outputPath = compile.outputPath(..., sourcePath, options.outputFolder)
            local ok, err = os.remove(outputPath)
            if ok then
              return log.info("deleted", outputPath)
            else
              return log.error("could not remove " .. tostring(outputPath) .. ": " .. tostring(err))
            end
          end
        end)
      end
      local _list_5 = options.runFiles
      for _index_0 = 1, #_list_5 do
        local _des_0 = _list_5[_index_0]
        local file, args
        file, args = _des_0.file, _des_0.args
        watch.path(file, function(event, ...)
          if event == 'fileChanged' then
            return runFile(file, args)
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