fs = require 'lfs'
inspect = require 'inspect'

with {}
  isMoonFile = (path) ->
    (.getExtension path) == 'moon'

  .append = (base, ...) ->
    for array in *{...}
      for item in *array
        table.insert base, item
    base

  .version = (major, minor, patch) ->
    setmetatable (:major, :minor, :patch),
      (__tostring: => '%d.%d.%d'\format major, minor, patch)

  .escapePattern = (pattern) ->
    pattern\gsub '[%^%$%(%)%%%.%[%]%*%+%-%?]', (char) -> '%' .. char

  .pathInfo = (path) ->
    folder = .getFolder path
    basename = .getBasename path
    extension = .getExtension path
    base = (path\match '(.+)%.(.-)$') or basename
    {:folder, :base, :extension}

  -- e.g. 'file.moon' -> 'moon'
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

  .collectFiles = (path) ->
    collected = {}

    switch fs.attributes path, "mode"
      when 'file'
        table.insert collected, path
      when 'directory'
        folder = path
        for file in fs.dir folder
          if file != '.' and file != '..'
            subpath = folder .. '/' .. file
            for file in *.collectFiles subpath
              table.insert collected, file

    collected
