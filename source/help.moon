meta = require 'crescent.meta'

formatInfo = (info) ->
  info = info\gsub '([\r\n]*)(      )', '%1'
  info = info\gsub '```%s-[\r\n]', ''
  info

usage = [[
crescent [options]
if no options are given, prints help
]]

options = do
  option = (flags, params, info) ->
    {:flags, :params, :info}

  {
    option {'--help', '-h'}, '', [[
      take a guess ;)
      if -h is given, every other option will be nullified
    ]]

    option { '--run', '-r' }, '<file.moon> [arguments...]', [[
      runs the given file with the specified arguments
      multiple -r flags can be given
    ]]

    option { "--compile", "-c" }, '<paths...>', [[
      if a path is a file, compiles a .moon file in the same folder.
      if a path is a folder, searches recursively for .moon files and compiles .lua files into their respective folder.

      examples (when running "crescent -c file.moon moon"):
      ```
        file.moon -> file.lua
        moon/init.moon -> moon/init.lua
        moon/lib/mylib.moon -> moon/lib/mylib.lua
      ```
    ]]

    option { "--output-folder", "-d" }, '<folder>', [[
      choose a new folder to compile .lua files
      a new folder will be created if it doesn't exist, recursively

      this option will use the same base path of every lua file given
      examples: when running "crescent -c file.moon moon -d lua":
      ```
        file.moon -> lua/file.moon
        moon/main.moon -> lua/main.lua
        moon/lib/mylib.moon -> lua/lib/mylib.lua
      ```

      when running "crescent -c code/source -d output/lua"
      ```
        code/source/main.moon      -> output/lua/main.lua
        code/source/lib/mylib.moon -> output/lua/lib/mylib.lua
      ```
    ]]

    option { '--watch', '-w' }, '', [[
      recursively watches associated files for changes, then reruns/recompiles when a change, file creation, or file deletion is found
    ]]

    option { '--poll-time' }, '<time>', [[
      set the amount of time between directory searches for --watch, in seconds
      default is 1s
    ]]

    option { '--log' }, '<levels>', [[
      specify which levels to log to output
    ]]

    option { '--silent' }, '', [[
      silence crescent, except for program output
    ]]

    option { '--no-colors' }, '', [[
      be a boring person :(
    ]]

    -- option { '--moonify <path> (EXPERIMENTAL, NOT IMPLEMENTED)' }, [[
    --   converts lua source files to moonscript.
    --   uses the same methods as --compile to generate files with ".moonified.moon" extension.
    -- ]]
  }

examples = do
  example = (example, info) ->
    {:example, :info}

  {
    example 'crescent -r countdown.moon 5 4 3 2 1', [[
      runs the file "countdown.moon" in the current working directory with the arguments "5 4 3 2 1"
    ]]

    example 'crescent -w -c . -pt 5', [[
      compiles every file in the current directory and its folders, then watches each file for changes and compiles any changed or added files, waiting 5 seconds between each watch check
    ]]

    example 'crescent -c moon -d lua', [[
      compiles all files in the "moon" directory and outputs them into the "lua" directory
    ]]
  }

contentFormat = [[
cresent v%s

usage:
%s

options:
%s

examples:
%s
]]

with {:usage, :options, :examples}
  tinsert = table.insert
  tconcat = table.concat
  print = print

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
          tinsert lines, word
        else
          lines[#lines] = newline

      lines = [indent .. line for line in *lines]
      tconcat lines, '\n'

  contents = do
    optionsString = for {:flags, :params, :info} in *options
      info = formatInfo info
      flagsString = [ flag .. ' ' .. params for flag in *flags ]
      (tconcat flagsString, '\n') .. '\n' .. indent info, 1

    examplesString = for {:example, :info} in *examples
      info = formatInfo info
      example .. '\n' .. indent info, 1

    contentFormat\format (tostring meta._VERSION),
      (indent usage, 1),
      (indent (tconcat optionsString, '\n\n'), 1),
      (indent (tconcat examplesString, '\n\n'), 1)

  .print = (maxLineWidth = 80) ->
    wrapped = wrap contents, maxLineWidth
    print wrapped
