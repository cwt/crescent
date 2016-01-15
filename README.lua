# crescent
a *lovely* compiler for moonscript - with pretty colors!

- [Usage](#usage)
  - [Options](#options)
  - [Examples](#examples)
- [Why?](#why)
- [WARNING](#warning)

## Install
Using luarocks:
```sh
$ luarocks install crescent
```

## Usage
```
{{usage}}
```

### Options
{% for i, option in ipairs(options) do %}
#### `{* table.concat(option.flags, ', ') .. ' ' .. option.params  *}`
  {* option.info *}
{% end %}

### Examples
{% for i, example in ipairs(examples) do %}
#### `$ {* example.example *}`
{{ example.info }}
{% end %}

## Why?
leafo's compiler either didn't have enough functionality, or had the incorrect sort of functionality that I didn't quite want. Not trying to outshine the guy - I'm using his work here in this small project, after all! Only providing an alternate solution to the problem.

Here's a few things I've done differently:

### Output Directories
When a directory switch is provided, the compiler will use the *base path* of the input file and replace it with the output directory, as opposed to appending the full path of the input file to the output directory.

```moon
moonc source/init.moon -t lua
  source/init.moon -> lua/source/init.lua

crescent -c source/init.moon -d lua
  source/init.moon -> lua/init.lua
```

### An Attentive Watcher
The watcher indexes files that were created and compiles them accordingly, along with removing the .lua sources of any deleted files. This works the same for files that are moved. `moonc` has a bit of this functionality with linotify installed, though it's not natively available for Windows.

### Unified Operations
I've spliced together both the task of running files and compiling them into one solution. This can be an upside or a downside depending on your perspective, but I felt as though only one binary should be necessary.

### Colors!
Colors are really nice. So I used them. You can still turn them off if you want.


## *WARNING*
crescent is *not* fully tested and, therefore, **not** production ready! if you happen to use it with something that someone's life depends on, i'm not legally obligated to attend their funeral ;)

on another note, more testing and more feedback is **greatly** appreciated! tell me what you do and don't like about it, and make a few issues if you like!

that aside, have fun! or don't, your choice ^^
