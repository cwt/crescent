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
    compiling = false,
    compilePaths = { },
    running = false,
    runFiles = { },
    watching = false,
    watchPaths = { },
    watchDefault = false,
    watchPollTime = 1,
    outputFolder = nil,
    logLevels = (function()
      local _accum_0 = { }
      local _len_0 = 1
      for level in pairs(log.levels) do
        _accum_0[_len_0] = level
        _len_0 = _len_0 + 1
      end
      return _accum_0
    end)(),
    colors = true,
    stdout = false
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
      options.compiling = true
      local _list_0 = {
        ...
      }
      for _index_0 = 1, #_list_0 do
        local path = _list_0[_index_0]
        options.compilePaths[path] = true
      end
    end)
    cli.option('--run', math.huge, function(file, ...)
      if not (verify(file, "no file or arguments were given to --run")) then
        return 
      end
      options.running = true
      options.runFiles[file] = {
        ...
      }
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
    cli.option('--watch', math.huge, function(...)
      options.watching = true
      if ... then
        local _list_0 = {
          ...
        }
        for _index_0 = 1, #_list_0 do
          local path = _list_0[_index_0]
          options.watchPaths[path] = true
        end
      else
        options.watchDefault = true
      end
    end)
    cli.option('--pipe', 0, function()
      options.pipe = true
      options.logLevels = { }
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
    cli.option('--moonify', 1, function(path)
      return log("sorry, moonify doesn't work yet!")
    end)
    cli.alias('-h', '--help')
    cli.alias('-r', '--run')
    cli.alias('-c', '--compile')
    cli.alias('-d', '--output-folder')
    cli.alias('-w', '--watch')
    cli.alias('-p', '--pipe')
    local success, err = cli.parse({
      ...
    })
    if not success then
      table.insert(cliErrors, err)
    end
  end
  log.these(options.logLevels)
  log.colors = options.colors
  if #cliErrors > 0 then
    for _index_0 = 1, #cliErrors do
      local err = cliErrors[_index_0]
      log.error(err)
    end
    print()
    return help.print()
  elseif options.printHelp or (not options.compiling and not options.running) then
    log.info('no --compile or --run instructions given')
    print()
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
        if (util.getExtension(file)) == 'moon' then
          local outputFile = compile.outputPath(file, basePath, options.outputFolder)
          log.info('compiling', file)
          local result, err
          if options.pipe then
            result, err = compile.source(file)
          else
            result, err = compile.write(file, outputFile)
          end
          if result then
            log.success('compiled', outputFile)
            if options.pipe then
              io.stdout:write(result, '\n')
            end
          else
            log.error(err)
          end
        end
      end
    end
    local runTasks
    runTasks = function()
      for path in pairs(options.compilePaths) do
        compilePath(path, path)
      end
      for file, args in pairs(options.runFiles) do
        runFile(file, args)
      end
    end
    runTasks()
    do
      local _ = nothing
    end
    if options.watching then
      local glob
      glob = function(path)
        return (fs.attributes(path, 'mode')) == 'directory' and path .. '/*' or path
      end
      local remove
      remove = function(path, sourceFile)
        local success, err = os.remove(path)
        if success then
          return log.info("removed " .. tostring(outputPath) .. " (source file " .. tostring(sourceFile) .. " was removed)")
        else
          return log.error("could not remove " .. tostring(outputPath) .. ": " .. tostring(err))
        end
      end
      local watchDefault
      watchDefault = function()
        for basePath in pairs(options.compilePaths) do
          watch.path(basePath, function(event, ...)
            local _exp_0 = event
            if 'changed' == _exp_0 or 'created' == _exp_0 then
              return compilePath(..., basePath)
            elseif 'removed' == _exp_0 then
              local outputPath = compile.outputPath(..., basePath, options.outputFolder)
              return remove(outputPath, ...)
            end
          end)
        end
        for scriptPath, args in pairs(options.runFiles) do
          watch.path(scriptPath, function(event, ...)
            local _exp_0 = event
            if 'changed' == _exp_0 or 'created' == _exp_0 then
              return runFile(scriptPath, args)
            end
          end)
        end
      end
      local watchPaths
      watchPaths = function()
        for path in pairs(options.watchPaths) do
          watch.path(path, function(event, ...)
            local _exp_0 = event
            if 'changed' == _exp_0 or 'created' == _exp_0 or 'removed' == _exp_0 then
              log.info(event, ...)
              return runTasks()
            end
          end)
        end
      end
      print()
      log.info("starting watch loop!")
      if options.watchDefault then
        watchDefault()
      end
      watchPaths()
      while true do
        sleep(options.watchPollTime)
        watch.loop()
      end
    end
  end
end