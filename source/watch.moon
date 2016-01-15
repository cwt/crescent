fs = require 'lfs'
{:sleep} = require 'socket'
{:collectFiles} = require 'crescent.util'

with {}
  watchers = {}

  .path = (watchPath, eventCallback) ->
    currentFiles = {}

    for collectedFile in *collectFiles watchPath
      currentFiles[collectedFile] =
        modtime: fs.attributes collectedFile, 'modification'

    filesArray = [file for file in pairs currentFiles]
    eventCallback 'initialized', filesArray

    watcher = ->
      existing = {}

      for file in *collectFiles watchPath
        modtime = fs.attributes file, 'modification'
        if currentFiles[file]
          if modtime > currentFiles[file].modtime
            eventCallback 'fileChanged', file
        else
          eventCallback 'fileCreated', file

        existing[file] = :modtime

      for file in pairs currentFiles
        if not existing[file]
          eventCallback 'fileRemoved', file

      currentFiles = existing

    table.insert watchers, watcher

  .loop = ->
    watcher! for watcher in *watchers
