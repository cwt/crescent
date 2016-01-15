local meta = require('crescent.meta')
local formatInfo
formatInfo = function(info)
  info = info:gsub('([\r\n]*)(      )', '%1')
  info = info:gsub('```%s-[\r\n]', '')
  return info
end
local usage = [[crescent [options]
if no options are given, prints help
]]
local options
do
  local option
  option = function(flags, params, info)
    return {
      flags = flags,
      params = params,
      info = info
    }
  end
  options = {
    option({
      '--help',
      '-h'
    }, '', [[      take a guess ;)
      if -h is given, every other option will be nullified
    ]]),
    option({
      '--run',
      '-r'
    }, '<file.moon> [arguments...]', [[      runs the given file with the specified arguments
      multiple -r flags can be given
    ]]),
    option({
      "--compile",
      "-c"
    }, '<paths...>', [[      if a path is a file, compiles a .moon file in the same folder.
      if a path is a folder, searches recursively for .moon files and compiles .lua files into their respective folder.

      examples (when running "crescent -c file.moon moon"):
      ```
        file.moon -> file.lua
        moon/init.moon -> moon/init.lua
        moon/lib/mylib.moon -> moon/lib/mylib.lua
      ```
    ]]),
    option({
      "--output-folder",
      "-d"
    }, '<folder>', [[      choose a new folder to compile .lua files
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
    ]]),
    option({
      '--watch',
      '-w'
    }, '', [[      recursively watches associated files for changes, then reruns/recompiles when a change, file creation, or file deletion is found
    ]]),
    option({
      '--poll-time'
    }, '<time>', [[      set the amount of time between directory searches for --watch, in seconds
      default is 1s
    ]]),
    option({
      '--log'
    }, '<levels>', [[      specify which levels to log to output
    ]]),
    option({
      '--silent'
    }, '', [[      silence crescent, except for program output
    ]]),
    option({
      '--no-colors'
    }, '', [[      be a boring person :(
    ]])
  }
end
local examples
do
  local example
  example = function(example, info)
    return {
      example = example,
      info = info
    }
  end
  examples = {
    example('crescent -r countdown.moon 5 4 3 2 1', [[      runs the file "countdown.moon" in the current working directory with the arguments "5 4 3 2 1"
    ]]),
    example('crescent -w -c . -pt 5', [[      compiles every file in the current directory and its folders, then watches each file for changes and compiles any changed or added files, waiting 5 seconds between each watch check
    ]]),
    example('crescent -c moon -d lua', [[      compiles all files in the "moon" directory and outputs them into the "lua" directory
    ]])
  }
end
local contentFormat = [[cresent v%s

usage:
%s

options:
%s

examples:
%s
]]
do
  local _with_0 = {
    usage = usage,
    options = options,
    examples = examples
  }
  local tinsert = table.insert
  local tconcat = table.concat
  local print = print
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
  local contents
  do
    local optionsString
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #options do
        local _des_0 = options[_index_0]
        local flags, params, info
        flags, params, info = _des_0.flags, _des_0.params, _des_0.info
        info = formatInfo(info)
        local flagsString
        do
          local _accum_1 = { }
          local _len_1 = 1
          for _index_1 = 1, #flags do
            local flag = flags[_index_1]
            _accum_1[_len_1] = flag .. ' ' .. params
            _len_1 = _len_1 + 1
          end
          flagsString = _accum_1
        end
        local _value_0 = (tconcat(flagsString, '\n')) .. '\n' .. indent(info, 1)
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
      end
      optionsString = _accum_0
    end
    local examplesString
    do
      local _accum_0 = { }
      local _len_0 = 1
      for _index_0 = 1, #examples do
        local _des_0 = examples[_index_0]
        local example, info
        example, info = _des_0.example, _des_0.info
        info = formatInfo(info)
        local _value_0 = example .. '\n' .. indent(info, 1)
        _accum_0[_len_0] = _value_0
        _len_0 = _len_0 + 1
      end
      examplesString = _accum_0
    end
    contents = contentFormat:format((tostring(meta._VERSION)), (indent(usage, 1)), (indent((tconcat(optionsString, '\n\n')), 1)), (indent((tconcat(examplesString, '\n\n')), 1)))
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