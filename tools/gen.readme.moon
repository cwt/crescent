util = require 'crescent.util'
help = require 'crescent.help'

readmePath = 'README.md'
usageFormat = "## Usage
```
%s
```"

usageMatch = usageFormat\format '(.-)'
usageOutput = usageFormat\format help.info

content = assert util.readFile readmePath

assert util.writeFile readmePath, content\gsub usageMatch, usageOutput
