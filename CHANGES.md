## 0.3.0
- added `--pipe`
- `--watch` can now accept paths as arguments. crescent will `--compile` and `--run` any given paths when a change in these paths are found. `--watch` without arguments defaults to the old behavior of watching every path given with `--compile` or `--run`, while only processing relevant files.
- went back to the old single-string help format - any higher level of complexity is unneeded.

## 0.2.0
- `--run` is now a cli option, as opposed to crescent working off of arguments
- added `--no-colors`
- added `--log <level>`
- added `--silent`
- rewrote the help format to be more API friendly
- `--compile` and `--run` can now accept multiple parameters, e.g. `-c file1.moon file2.moon directory_of_moon_files`

## 0.1.1
- bug fixes

## 0.1.0
- first release
