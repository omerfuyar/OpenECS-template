#!/bin/sh
# Builds the native plugins of plugins/: each folder with C files becomes lib<name>.so in that folder.
# OPENECS names the folder of OpenECS's release, whose include/ holds the plugin interface; openecs/ if it is not set.
set -eu

openecs="${OPENECS:-openecs}"

for folder in plugins/*/; do
    name=$(basename "$folder")

    if ls "$folder"*.c > /dev/null 2>&1; then
        gcc -std=c23 -Wall -Wextra -Wpedantic -Wconversion -O2 -shared -fPIC -fvisibility=hidden \
            -I"$openecs/include" -o "${folder}lib$name.so" "$folder"*.c
        echo "built ${folder}lib$name.so"
    fi
done
