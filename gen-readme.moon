template = require 'resty.template'

util = require 'crescent.util'
{:usage, :options, :examples} = require 'crescent.help'

removeIndent = (text) ->
  text\gsub '[^\r\n]+', (line) ->
    line\gsub '^%s+', ''

convertMarkdownBreak = (text) ->
  text\gsub '[\r\n]', '  \n'

for option in *options
  option.info = removeIndent option.info
  option.info = convertMarkdownBreak option.info

for example in *examples
  example.info = removeIndent example.info
  example.info = convertMarkdownBreak example.info

format = assert util.readFile 'README.lua'
output = template.compile format

assert util.writeFile 'README.md', output :usage, :options, :examples
