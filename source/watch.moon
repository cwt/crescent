{:attributes} = require 'lfs'
{:sleep} = require 'socket'
{:collectFiles} = require 'crescent.util'

with {}
  watchers = {}

  .path = (watchPath, eventCallback) ->
    currentFiles = {}

    for collectedFile in *collectFiles watchPath
      currentFiles[collectedFile] =
        modtime: attributes collectedFile, 'modification'

    filesArray = [file for file in pairs currentFiles]
    eventCallback 'initialized', filesArray

    watcher = ->
      existing = {}

      for file in *collectFiles watchPath
        if modtime = attributes file, 'modification'
          if currentFiles[file]
            if modtime > currentFiles[file].modtime
              eventCallback 'fileChanged', file
          else
            eventCallback 'fileCreated', file

          existing[file] = :modtime
        else
          eventCallback 'fileRemoved', file

      currentFiles = existing

    table.insert watchers, watcher

  .loop = ->
    watcher! for watcher in *watchers
