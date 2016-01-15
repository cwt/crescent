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
crescent [options]
if no options are given, prints help

```

### Options
#### `--help, -h `
  take a guess ;)  
if -h is given, every other option will be nullified  

#### `--run, -r <file.moon> [arguments...]`
  runs the given file with the specified arguments  
multiple -r flags can be given  

#### `--compile, -c <paths...>`
  if a path is a file, compiles a .moon file in the same folder.  
if a path is a folder, searches recursively for .moon files and compiles .lua files into their respective folder.  
  
examples (when running "crescent -c file.moon moon"):  
```  
file.moon -> file.lua  
moon/init.moon -> moon/init.lua  
moon/lib/mylib.moon -> moon/lib/mylib.lua  
```  

#### `--output-folder, -d <folder>`
  choose a new folder to compile .lua files  
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

#### `--watch, -w `
  recursively watches associated files for changes, then reruns/recompiles when a change, file creation, or file deletion is found  

#### `--poll-time <time>`
  set the amount of time between directory searches for --watch, in seconds  
default is 1s  

#### `--log <levels>`
  specify which levels to log to output  

#### `--silent `
  silence crescent, except for program output  

#### `--no-colors `
  be a boring person :(  


### Examples
#### `$ crescent -r countdown.moon 5 4 3 2 1`
runs the file &quot;countdown.moon&quot; in the current working directory with the arguments &quot;5 4 3 2 1&quot;  

#### `$ crescent -w -c . -pt 5`
compiles every file in the current directory and its folders, then watches each file for changes and compiles any changed or added files, waiting 5 seconds between each watch check  

#### `$ crescent -c moon -d lua`
compiles all files in the &quot;moon&quot; directory and outputs them into the &quot;lua&quot; directory  


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
