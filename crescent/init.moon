util = require 'crescent.util'
log = require 'crescent.log'
cli = require 'crescent.cli'
help = require 'crescent.help'
run = require 'crescent.run'
compile = require 'crescent.compile'
watch = require 'crescent.watch'

inspect = require 'inspect'
fs = require 'lfs'
{:sleep} = require 'socket'

(...) ->
  io.stdout\setvbuf 'no'

  options =
    printHelp: false

    compiling: false
    compilePaths: {}

    running: false
    runFiles: {}

    watching: false
    watchPaths: {}
    watchDefault: false
    watchPollTime: 1

    outputFolder: nil

    logLevels: [ level for level in pairs log.levels ]
    colors: true
    stdout: false

  cliErrors = {}

  verify = (value, err) ->
    return true if value ~= nil
    table.insert cliErrors, err
    false

  with cli
    .option '--help', 0, ->
      options.printHelp = true

    .option '--compile', math.huge, (...) ->
      return unless verify ..., "no paths were given to --compile"
      options.compiling = true
      options.compilePaths[path] = true for path in *{...}

    .option '--run', math.huge, (file, ...) ->
      return unless verify file, "no file or arguments were given to --run"
      options.running = true
      options.runFiles[file] = {...}

    .option '--output-folder', 1, (folder) ->
      return unless verify folder, "no folders were given to --output-folder"
      options.outputFolder = folder

    .option '--poll-time', 1, (time) ->
      return unless verify time, "no time was given to --poll-time"
      options.watchPollTime = time

    .option '--watch', math.huge, (...) ->
      options.watching = true
      if ...
        for path in *{...}
          options.watchPaths[path] = true
      else
        options.watchDefault = true

    .option '--pipe', 0, ->
      options.pipe = true
      options.logLevels = {}

    .option '--log', math.huge, (...) ->
      levelString = table.concat [ level for level in pairs log.levels ], ', '
      errorString = "no log levels were given to --log; available levels: #{levelString}"
      return unless verify ..., errorString

      options.logLevels = [ level for level in *{...} ]

    .option '--silent', 0, ->
      options.logLevels = {}

    .option '--no-colors', 0, ->
      options.colors = false

    .option '--moonify', 1, (path) ->
      log "sorry, moonify doesn't work yet!"

    .alias '-h', '--help'
    .alias '-r', '--run'
    .alias '-c', '--compile'
    .alias '-d', '--output-folder'
    .alias '-w', '--watch'
    .alias '-p', '--pipe'

    success, err = .parse {...}
    if not success
      table.insert cliErrors, err

  log.these options.logLevels
  log.colors = options.colors

  if #cliErrors > 0
    log.error err for err in *cliErrors
    print!
    help.print!
  elseif options.printHelp or (not options.compiling and not options.running)
    log.info 'no --compile or --run instructions given'
    print!
    help.print!
  else
    runFile = (script, args) ->
      message = "running #{script}"
      message ..= if #args > 0
        " with arguments: #{table.concat args, ', '}"
      else
        " without arguments"

      log.info message

      results = { run.file script, unpack args }
      success = table.remove results, 1

      if success
        returnValues = [inspect v for v in *results]

        log.success "file ran successfully!"
        if #returnValues > 0
          log.success "returned: #{table.concat returnValues, ', '}"
        else
          log.success "returned nothing"
      else
        log.error results[1]

    compilePath = (path, basePath) ->
      if (fs.attributes basePath, 'mode') == 'file'
        basePath = util.getFolder basePath

      for file in *util.collectFiles path
        if (util.getExtension file) == 'moon'
          outputFile = compile.outputPath file, basePath, options.outputFolder

          log.info 'compiling', file

          result, err = if options.pipe
            compile.source file
          else
            compile.write file, outputFile

          if result
            log.success 'compiled', outputFile
            if options.pipe
              io.stdout\write result, '\n'
          else
            log.error err

    runTasks = ->
      compilePath path, path for path in pairs options.compilePaths
      runFile file, args for file, args in pairs options.runFiles

    runTasks!

    do
      nothing
      -- watchCompile = (compilePaths) ->
      --   for sourcePath in *compilePaths
      --     watch.path sourcePath, (event, ...) ->
      --       switch event
      --         when 'initialized'
      --           log.info "compiling #{glob sourcePath} on changes"
      --
      --         when 'fileChanged', 'fileCreated'
      --           compilePath ..., sourcePath
      --
      --         when 'fileRemoved'
      --           outputPath = compile.outputPath ..., sourcePath, options.outputFolder
      --           ok, err = os.remove outputPath
      --           if ok
      --             log.info "deleted", outputPath
      --           else
      --             log.error "could not remove #{outputPath}: #{err}"
      --
      -- watchRun = (runFiles) ->
      --   for {:file, :args} in *runFiles
      --     watch.path file, (event, ...) ->
      --       switch event
      --         when 'initialized'
      --           log.info "running #{file} on changes"
      --
      --         when 'fileCreated', 'fileChanged'
      --           runFile ..., args
      --
      -- watchOther = (watchPaths) ->
      --   for path in *watchPaths
      --     watch.path path, (event, ...) ->
      --       switch event
      --         when 'initialized'
      --           log.info "watching #{glob path}"
      --
      --         when 'fileChanged', 'fileCreated', 'fileRemoved'
      --           runTasks!
      --
      --       switch event
      --         when 'fileChanged'
      --           log.info 'changed', ...
      --         when 'fileCreated'
      --           log.info 'created', ...
      --         when 'fileRemoved'
      --           log.info 'removed', ...

      -- watchOther options.watchPaths
      -- watchCompile options.compilePaths
      -- watchRun options.runFiles

    if options.watching

      glob = (path) ->
        (fs.attributes path, 'mode') == 'directory' and path .. '/*' or path

      remove = (path, sourceFile) ->
        success, err = os.remove path
        if success
          log.info "removed #{outputPath} (source file #{sourceFile} was removed)"
        else
          log.error "could not remove #{outputPath}: #{err}"

      watchDefault = ->
        for basePath in pairs options.compilePaths
          watch.path basePath, (event, ...) ->
            switch event
              when 'changed', 'created'
                compilePath ..., basePath

              when 'removed'
                outputPath = compile.outputPath ..., basePath, options.outputFolder
                remove outputPath, ...

        for scriptPath, args in pairs options.runFiles
          watch.path scriptPath, (event, ...) ->
            switch event
              when 'changed', 'created'
                runFile scriptPath, args

      watchPaths = ->
        for path in pairs options.watchPaths
          watch.path path, (event, ...) ->
            switch event
              when 'changed', 'created', 'removed'
                log.info event, ...
                runTasks!

      print!
      log.info "starting watch loop!"

      watchDefault! if options.watchDefault
      watchPaths!

      while true
        sleep options.watchPollTime
        watch.loop!
