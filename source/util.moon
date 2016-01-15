fs = require 'lfs'
inspect = require 'inspect'

with {}
  isMoonFile = (path) ->
    (.getExtension path) == 'moon'

  .version = (major, minor, patch) ->
    setmetatable (:major, :minor, :patch),
      (__tostring: => '%d.%d.%d'\format major, minor, patch)

  .escapePattern = (pattern) ->
    pattern\gsub '[%^%$%(%)%%%.%[%]%*%+%-%?]', (char) -> '%' .. char

  .getExtension = (path) ->
    (.getBasename path)\match '%.([^%.]+)$'

  .setExtension = (path, extension) ->
    "#{ path\gsub '%.[^%.]+$', '' }.#{ extension }"

  .getFolder = (path) ->
    (path\match '^(.*)[\\/]+') or '.'

  .getBasename = (path) ->
    path\match '[^\\/]*$'

  .readFile = (path) ->
    file, err = io.open path, 'r'
    if file
      content = file\read '*a'
      file\close!
      content
    else
      nil, err

  .writeFile = (path, content) ->
    success, err = .createDirectory .getFolder path
    if not success
      return false, err

    file, err = io.open path, 'w'
    if file
      file\write content
      file\close!
      true
    else
      false, err

  .createDirectory = (dir, current = '.') ->
    for part in dir\gmatch '[^\\/]*[^\\/]+'
      path = current .. '/' .. part

      if (fs.attributes path, 'mode') != 'directory'
        success, err = fs.mkdir path
        if not success
          return false, err

      current = path

    true

  .collectFiles = (path, condition) ->
    collected = {}

    switch fs.attributes path, "mode"
      when 'file'
        file = path
        if not condition or condition file
          table.insert collected, file
      when 'directory'
        folder = path
        for file in fs.dir folder
          if file != '.' and file != '..'
            subpath = folder .. '/' .. file
            for file in *.collectFiles subpath, isMoonFile
              table.insert collected, file

    collected
