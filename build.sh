#!/bin/sh
# Builds the native plugins of plugins/: each folder with C files becomes a library in that folder, lib<name>.so on Linux and <name>.dll on Windows.
# OPENECS names the folder of OpenECS's release, whose include/ holds the plugin interface; OpenECS/ if it is not set.
# CC names the compiler: gcc on Linux, and clang on Windows, from LLVM-MinGW as OpenECS is built with; a cross compiler such as x86_64-w64-mingw32-clang builds for Windows.
set -eu

OpenECS="${OPENECS:-OpenECS}"

case "$(uname -s)" in
MINGW* | MSYS* | CYGWIN*) cc="${CC:-clang}" ;;
*) cc="${CC:-gcc}" ;;
esac

# the compiler names the system it builds for
case "$("$cc" -dumpmachine)" in
*mingw* | *windows*)
    # a DLL cannot leave OpenECS's functions to be found when it is loaded, so it links OpenECS's import library, and SDL's for a plugin that calls SDL; the release has them in lib/
    file=%s.dll
    flags="-L$OpenECS/lib -lOpenECS -lSDL3 -lSDL3_ttf"
    ;;
*)
    # OpenECS's functions are found when the library is loaded, in the program that loads it
    file=lib%s.so
    flags="-fPIC"
    ;;
esac

for folder in plugins/*/; do
    name=$(basename "$folder")

    if ls "$folder"*.c > /dev/null 2>&1; then
        # shellcheck disable=SC2059
        output="$folder$(printf "$file" "$name")"
        # shellcheck disable=SC2086
        "$cc" -std=c23 -Wall -Wextra -Wpedantic -Wconversion -O2 -shared -fvisibility=hidden \
            -I"$OpenECS/include" -o "$output" "$folder"*.c $flags
        echo "built $output"
    fi
done
