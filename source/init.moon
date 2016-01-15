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
    compilePaths: {}
    runFiles: {}
    outputFolder: nil
    watching: false
    watchPollTime: 1
    logLevels: [ level for level in pairs log.levels ]
    colors: true

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
      table.insert options.compilePaths, path for path in *{...}

    .option '--run', math.huge, (file, ...) ->
      return unless verify file, "no file or arguments were given to --run"
      table.insert options.runFiles, :file, args: { select 2, ... }

    .option '--output-folder', 1, (folder) ->
      return unless verify folder, "no folders were given to --output-folder"
      options.outputFolder = folder

    .option '--poll-time', 1, (time) ->
      return unless verify time, "no time was given to --poll-time"
      options.watchPollTime = time

    .option '--watch', 0, ->
      options.watching = true

    .option '--moonify', 1, (path) ->
      log "sorry, moonify doesn't work yet!"

    .option '--log', math.huge, (...) ->
      levelString = table.concat [ level for level in pairs log.levels ], ', '
      errorString = "no log levels were given to --log; available levels: #{levelString}"
      return unless verify ..., errorString

      options.logLevels = [ level for level in *{...} ]

    .option '--silent', 0, ->
      options.logLevels = {}

    .option '--no-colors', 0, ->
      options.colors = false

    .alias '-h', '--help'
    .alias '-r', '--run'
    .alias '-c', '--compile'
    .alias '-d', '--output-folder'
    .alias '-w', '--watch'

    .parse {...}

  log.these options.logLevels
  log.colors = options.colors

  if #cliErrors > 0
    log.error err for err in *cliErrors
  elseif options.printHelp or (#options.runFiles == 0 and #options.compilePaths == 0)
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
        outputFile = compile.outputPath file, basePath, options.outputFolder

        log.info 'compiling', file
        success, err = compile.file file, outputFile
        if success
          log.success 'compiled', outputFile
        else
          log.error err

    compilePath path, path for path in *options.compilePaths
    runFile file.file, file.args for file in *options.runFiles

    if options.watching
      print!
      log.info "starting watch loop!"

      logPaths = {}
      table.insert logPaths, path for path in *options.compilePaths
      table.insert logPaths, file.file for file in *options.runFiles

      for path in *logPaths
        watch.path path, (event, ...) ->
          switch event
            when 'initialized'
              paths = for path in *logPaths
                switch fs.attributes path, 'mode'
                  when 'file'
                    path
                  when 'directory'
                    path .. '/**/*.moon'

              log.info "watching", table.concat paths, ', '

            when 'fileChanged'
              print!
              log.info "changed", ...

            when 'fileCreated'
              print!
              log.info "created", ...

            when 'fileRemoved'
              print!
              log.info "removed", ...

      for sourcePath in *options.compilePaths
        watch.path sourcePath, (event, ...) ->
          switch event
            when 'fileChanged', 'fileCreated'
              compilePath ..., sourcePath

            when 'fileRemoved'
              outputPath = compile.outputPath ..., sourcePath, options.outputFolder
              ok, err = os.remove outputPath
              if ok
                log.info "deleted", outputPath
              else
                log.error "could not remove #{outputPath}: #{err}"

      for {:file, :args} in *options.runFiles
        watch.path file, (event, ...) ->
          -- no need for fileCreated
          -- we can't run a file that was never created to begin with ;)
          if event == 'fileChanged'
            runFile file, args

      while true
        sleep options.watchPollTime
        watch.loop!
