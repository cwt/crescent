fs = require 'lfs'
meta = require 'crescent.meta'
util = require 'crescent.util'
{:to_lua} = require 'moonscript'

version = ... or tostring meta._VERSION

modules = for file in fs.dir 'crescent'
  info = util.pathInfo file
  continue if file == '.'
  continue if file == '..'
  continue if (util.getExtension file) ~= 'lua'
  continue if info.base == 'init'
  "    'crescent.#{info.base}': 'crescent/#{file}',"

modules = table.concat modules, '\n'

rockspecFormat = assert util.readFile 'tools/rockspec.format.moon'

output = rockspecFormat\gsub '$(%w+)', :version, :modules
output = to_lua output

outputPath = "rockspec/crescent-#{version}-1.rockspec"

assert util.writeFile outputPath, output
