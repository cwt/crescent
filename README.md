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

No other installation options are available at the moment.

## Usage
```
crescent v0.3.0

usage:
  crescent [options]

options:
  --help, -h
    take a guess ;)
    if -h is given, every other option will be nullified

  --run, -r <file.moon> [arguments...]
    runs the given file with the specified arguments
    multiple -r flags can be given

  --compile, -c <paths...>
    if a path is a file, compiles a .moon file in the same folder.
    if a path is a folder, searches recursively for .moon files and compiles .lua files into their respective folder.

    examples (when running 'crescent -c file.moon moon'):
      file.moon -> file.lua
      moon/init.moon -> moon/init.lua
      moon/lib/mylib.moon -> moon/lib/mylib.lua

  --output-folder, -d <folder>
    choose a new folder to compile .lua files
    a new folder will be created if it doesn't exist, recursively

    this option will use the same base path of every lua file given
    example: when running 'crescent -c file.moon moon -d lua':
      file.moon -> lua/file.moon
      moon/main.moon -> lua/main.lua
      moon/lib/mylib.moon -> lua/lib/mylib.lua

    when running 'crescent -c code/source -d output/lua':
      code/source/main.moon      -> output/lua/main.lua
      code/source/lib/mylib.moon -> output/lua/lib/mylib.lua

  --watch, -w [paths...]
    watches given paths for changes, then reruns crescent with flags when a change is found

    if no paths are given, watches paths given with --compile and --run and only processes relevant files when a change is found

    example:
      'crescent -w -c source/': watches for every *.moon file in source/ and only compiles whichever file was changed
        
      'crescent -w lib/ -c source/': watches for every file in lib/, and compiles every *.moon file in source/ when a change is found

  --poll-time <time>
    set the amount of time between directory searches for --watch, in seconds
    default is 1s

  --pipe, -p
    writes compiled files to stdout
    this option adds an implicit --silent to prevent logging output from being written

  --log <levels...>
    set the levels logged by crescent. available levels are: error, warning, info, success

  --silent
    silence crescent output - only program output will be displayed

  --no-colors
    just in case you're not feelin' the rainbow ;)

examples:
  crescent -r main.moon "hello world"
    runs the file "main.moon" with the argument "hello world"

  crescent -c src -d lua -w
    compiles src/**/*.moon and outputs files into lua/**/*.lua, then watches and recompiles for changes

  crescent -r main.moon --log success error
    run main.moon, but only log 'success' and 'error' levels

```


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
