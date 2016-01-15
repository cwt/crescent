meta = require 'crescent.meta'
log = require 'crescent.log'

logLevels = table.concat [ level for level in pairs log.levels ], ', '

info = "crescent v#{meta._VERSION}

usage:
  crescent [options]

options:
  --help, -h
    take a guess ;)
    if -h is given, every other option will be nullified

  --run, -r <file.moon> [arguments...]
    runs the given file with the specified arguments
    multiple -r flags can be given

  --compile, -c <paths...>
    if a path is a file, compiles a .moon file in the same folder.
    if a path is a folder, searches recursively for .moon files and compiles .lua files into their respective folder.

    examples (when running 'crescent -c file.moon moon'):
      file.moon -> file.lua
      moon/init.moon -> moon/init.lua
      moon/lib/mylib.moon -> moon/lib/mylib.lua

  --output-folder, -d <folder>
    choose a new folder to compile .lua files
    a new folder will be created if it doesn't exist, recursively

    this option will use the same base path of every lua file given
    example: when running 'crescent -c file.moon moon -d lua':
      file.moon -> lua/file.moon
      moon/main.moon -> lua/main.lua
      moon/lib/mylib.moon -> lua/lib/mylib.lua

    when running 'crescent -c code/source -d output/lua':
      code/source/main.moon      -> output/lua/main.lua
      code/source/lib/mylib.moon -> output/lua/lib/mylib.lua

  --watch, -w [paths...]
    watches given paths for changes, then reruns crescent with flags when a change is found

    if no paths are given, watches paths given with --compile and --run and only processes relevant files when a change is found

    example:
      'crescent -w -c source/': watches for every *.moon file in source/ and only compiles whichever file was changed
        
      'crescent -w lib/ -c source/': watches for every file in lib/, and compiles every *.moon file in source/ when a change is found

  --poll-time <time>
    set the amount of time between directory searches for --watch, in seconds
    default is 1s

  --pipe, -p
    writes compiled files to stdout
    this option adds an implicit --silent to prevent logging output from being written

  --log <levels...>
    set the levels logged by crescent. available levels are: #{logLevels}

  --silent
    silence crescent output - only program output will be displayed

  --no-colors
    just in case you're not feelin' the rainbow ;)

examples:
  crescent -r main.moon \"hello world\"
    runs the file \"main.moon\" with the argument \"hello world\"

  crescent -c src -d lua -w
    compiles src/**/*.moon and outputs files into lua/**/*.lua, then watches and recompiles for changes

  crescent -r main.moon --log success error
    run main.moon, but only log 'success' and 'error' levels
"

with {:info}
  indent = (content, n) ->
    content\gsub '[^\r\n]+', (line) -> ('  '\rep n) .. line

  wrap = (content, maxLength) ->
    content\gsub '[^\r\n]+', (line) ->
      indent, rest = line\match '(%s*)(.*)'
      indentLength = #(indent\gsub '\t', ' '\rep 8)

      lines = {''}
      for word in rest\gmatch '%S+'
        newline = #lines[#lines] == 0 and word or "#{lines[#lines]} #{word}"
        if #newline > maxLength - indentLength
          table.insert lines, word
        else
          lines[#lines] = newline

      lines = [indent .. line for line in *lines]
      table.concat lines, '\n'

  .print = (maxLineWidth = 80) ->
    wrapped = wrap info, maxLineWidth
    print wrapped
