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
    outputFolder: nil
    watching: false
    watchPollTime: 1
    cliErrors: {}

  arguments = nil

  with cli
    .option '--help', 0, ->
      options.printHelp = true

    .option '--compile', 1, (path) ->
      table.insert options.compilePaths, path

    .option '--output-folder', 1, (folder) ->
      options.outputFolder = folder

    .option '--watch', 0, ->
      options.watching = true

    .option '--poll-time', 1, (time) ->
      options.watchPollTime = time

    .option '--moonify', 1, (path) ->
      log.error "sorry, moonify doesn't work yet!"

    .alias '-h', '--help'
    .alias '-c', '--compile'
    .alias '-d', '--output-folder'
    .alias '-w', '--watch'
    .alias '-pt', '--poll-time'

    arguments = .parse {...}

  if #options.cliErrors > 0
    log.error err for err in *options.cliErrors
  elseif options.printHelp or (#arguments == 0 and #options.compilePaths == 0)
    help.print!
  else
    runFile = (script, ...) ->
      message = "running #{script}"
      message ..= if (select '#', ...) > 0
        " with arguments: #{table.concat{...}, ', '}"
      else
        " without arguments"

      log.info message

      results = { run.file script, ... }
      success = table.remove results, 1

      if success
        returnValues = [inspect v for v in *results]

        log.success "file ran successfully!"
        if #returnValues > 0
          log.success "returned: #{table.concat returnValues, ','}"
        else
          log.success "returned nothing"
      else
        log.error results[1]

    compilePath = (path, root) ->
      for file in *util.collectFiles path
        outputFile = util.setExtension file, 'lua'

        if options.outputFolder
          rootPattern = '^' .. (util.escapePattern root) .. '[\\/]*'
          outputFile = "#{ options.outputFolder }/#{ outputFile\gsub rootPattern, '' }"

        log.info 'compiling', file
        success, err = compile.file file, outputFile
        if success
          log.success 'compiled', outputFile
        else
          log.error err

    runFile unpack arguments if #arguments > 0
    compilePath path, path for path in *options.compilePaths

    if options.watching
      print!
      log.info "starting watch loop!"

      logPaths = {}
      table.insert logPaths, path for path in *options.compilePaths
      table.insert logPaths, arguments[1] if #arguments > 0

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
              log.info "changed", ...

            when 'fileCreated'
              log.info "created", ...

            when 'fileRemoved'
              log.info "removed", ...

      if #arguments > 0
        watch.path arguments[1], (event, ...) ->
          if event == 'fileChanged'
            runFile unpack arguments

      for path in *options.compilePaths
        watch.path path, (event, ...) ->
          switch event
            when 'fileChanged', 'fileCreated'
              compilePath ..., path


      while true
        sleep options.watchPollTime
        watch.loop!
