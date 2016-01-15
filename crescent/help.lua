local meta = require('crescent.meta')
local log = require('crescent.log')
local logLevels = table.concat((function()
  local _accum_0 = { }
  local _len_0 = 1
  for level in pairs(log.levels) do
    _accum_0[_len_0] = level
    _len_0 = _len_0 + 1
  end
  return _accum_0
end)(), ', ')
local info = "crescent v" .. tostring(meta._VERSION) .. "\n\nusage:\n  crescent [options]\n\noptions:\n  --help, -h\n    take a guess ;)\n    if -h is given, every other option will be nullified\n\n  --run, -r <file.moon> [arguments...]\n    runs the given file with the specified arguments\n    multiple -r flags can be given\n\n  --compile, -c <paths...>\n    if a path is a file, compiles a .moon file in the same folder.\n    if a path is a folder, searches recursively for .moon files and compiles .lua files into their respective folder.\n\n    examples (when running 'crescent -c file.moon moon'):\n      file.moon -> file.lua\n      moon/init.moon -> moon/init.lua\n      moon/lib/mylib.moon -> moon/lib/mylib.lua\n\n  --output-folder, -d <folder>\n    choose a new folder to compile .lua files\n    a new folder will be created if it doesn't exist, recursively\n\n    this option will use the same base path of every lua file given\n    example: when running 'crescent -c file.moon moon -d lua':\n      file.moon -> lua/file.moon\n      moon/main.moon -> lua/main.lua\n      moon/lib/mylib.moon -> lua/lib/mylib.lua\n\n    when running 'crescent -c code/source -d output/lua':\n      code/source/main.moon      -> output/lua/main.lua\n      code/source/lib/mylib.moon -> output/lua/lib/mylib.lua\n\n  --watch, -w [paths...]\n    watches given paths for changes, then reruns crescent with flags when a change is found\n\n    if no paths are given, watches paths given with --compile and --run and only processes relevant files when a change is found\n\n    example:\n      'crescent -w -c source/': watches for every *.moon file in source/ and only compiles whichever file was changed\n        \n      'crescent -w lib/ -c source/': watches for every file in lib/, and compiles every *.moon file in source/ when a change is found\n\n  --poll-time <time>\n    set the amount of time between directory searches for --watch, in seconds\n    default is 1s\n\n  --pipe, -p\n    writes compiled files to stdout\n    this option adds an implicit --silent to prevent logging output from being written\n\n  --log <levels...>\n    set the levels logged by crescent. available levels are: " .. tostring(logLevels) .. "\n\n  --silent\n    silence crescent output - only program output will be displayed\n\n  --no-colors\n    just in case you're not feelin' the rainbow ;)\n\nexamples:\n  crescent -r main.moon \"hello world\"\n    runs the file \"main.moon\" with the argument \"hello world\"\n\n  crescent -c src -d lua -w\n    compiles src/**/*.moon and outputs files into lua/**/*.lua, then watches and recompiles for changes\n\n  crescent -r main.moon --log success error\n    run main.moon, but only log 'success' and 'error' levels\n"
do
  local _with_0 = {
    info = info
  }
  local indent
  indent = function(content, n)
    return content:gsub('[^\r\n]+', function(line)
      return (('  '):rep(n)) .. line
    end)
  end
  local wrap
  wrap = function(content, maxLength)
    return content:gsub('[^\r\n]+', function(line)
      local rest
      indent, rest = line:match('(%s*)(.*)')
      local indentLength = #(indent:gsub('\t', (' '):rep(8)))
      local lines = {
        ''
      }
      for word in rest:gmatch('%S+') do
        local newline = #lines[#lines] == 0 and word or tostring(lines[#lines]) .. " " .. tostring(word)
        if #newline > maxLength - indentLength then
          table.insert(lines, word)
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
      return table.concat(lines, '\n')
    end)
  end
  _with_0.print = function(maxLineWidth)
    if maxLineWidth == nil then
      maxLineWidth = 80
    end
    local wrapped = wrap(info, maxLineWidth)
    return print(wrapped)
  end
  return _with_0
end