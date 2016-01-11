local meta = require('crescent.meta')
local contents = [[crescent v%s

usage:
  crescent [options] [file.moon] [arg1] [arg2] [...]

  interprets and runs the given .moon file with the provided arguments

  if no file or arguments are given, works off of the options alone
  if no file, arguments, or options are given, prints help


options:
  --help
  -h
    take a guess ;)

    if -h is given, every other option will be nullified


  --compile <path>
  -c <path>
    if <path> is a file, compiles a .moon file in the same folder.

    if <path> is a folder, searches recursively for .moon files and compiles .lua files into their respective folder.
    examples (when running "crescent -c file.moon -c moon"):
      file.moon -> file.lua
      moon/init.moon -> moon/init.lua
      moon/lib/mylib.moon -> moon/lib/mylib.lua


  --output-folder <folder>
  -d <folder>
    choose a new folder for the previously defined -c to compile .lua files
    a new folder will be created if it doesn't exist, recursively

    this option will use the same base path of every lua file given
    examples: when running "crescent -c moon -d lua":
      moon/main.moon -> lua/main.lua
      moon/lib/mylib.moon -> lua/lib/mylib.lua

    when running "crescent -c code/source -d output/lua"
      code/source/main.moon      -> output/lua/main.lua
      code/source/lib/mylib.moon -> output/lua/lib/mylib.lua


  --watch
  -w
    recursively watches associated files for changes, then reruns/recompiles them when a change, file creation, or file deletion is found


  --poll-time <time>
  -pt
    set the amount of time between directory searches for --watch, in seconds
    default is 1s


  --moonify <path> (EXPERIMENTAL)
    converts lua source files to moonscript.
    uses the same methods as --compile to generate files with ".moonified.moon" extension.

  --
    tells crescent to interpret every command line parameter after '--' as an argument

examples:
  crescent countdown.moon 5 4 3 2 1
    runs the file "countdown.moon" in the current working directory with the arguments "5 4 3 2 1"

  crescent -w -c . -pt 1
    recursively compiles every file in the current directory, then watches each file for changes and compiles any changed or added files, waiting 1 second between watch checks

  crescent -c moon -d lua
    compiles all files in the "moon" directory and outputs them into the "lua" directory

  crescent --moonify script.lua
    converts script.lua to moonscript and writes to script.moonified.moon

  crescent -- --compile
    runs the moonscript source in the file named "--compile" (you should stop giving your source files dumb names)
]]
contents = contents:format(tostring(meta._VERSION))
do
  local _with_0 = {
    contents = contents
  }
  local tinsert = table.insert
  local tconcat = table.concat
  local print = print
  local wrap
  wrap = function(content, maxLength)
    return content:gsub('[^\n]+', function(line)
      local indent, rest = line:match('(%s*)(.*)')
      local indentLength = #(indent:gsub('\t', (' '):rep(8)))
      local lines = {
        ''
      }
      for word in rest:gmatch('%S+') do
        local newline = #lines[#lines] == 0 and word or tostring(lines[#lines]) .. " " .. tostring(word)
        if #newline > maxLength - indentLength then
          tinsert(lines, word)
        else
          lines[#lines] = newline
        end
      end
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #lines do
          line = lines[_index_0]
          _accum_0[_len_0] = indent .. line
          _len_0 = _len_0 + 1
        end
        lines = _accum_0
      end
      return tconcat(lines, '\n')
    end)
  end
  _with_0.print = function(maxLineWidth)
    if maxLineWidth == nil then
      maxLineWidth = 80
    end
    local wrapped = wrap(contents, maxLineWidth)
    return print(wrapped)
  end
  return _with_0
end