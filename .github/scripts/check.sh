#!/bin/sh
# Formats the tool's C files with clang-format and checks them with clang-tidy (.clang-format, .clang-tidy), for agents before they commit.
# With no files named, it takes the C files of plugins/ that differ from dev, committed or not.
# It prints only the problems, and fails when clang-tidy finds one.
# OPENECS names the folder of OpenECS's release, whose include/ holds the plugin interface; OpenECS/ if it is not set, as build.sh says.
set -u
cd "$(dirname "$0")/../.." || exit 2

if [ $# -eq 0 ]; then
    base=$(git merge-base HEAD origin/dev 2> /dev/null || echo HEAD)
    # shellcheck disable=SC2046
    set -- $({
        git diff --name-only "$base"
        git ls-files --others --exclude-standard
    } | grep -E '^plugins/.*\.[ch]$' | sort -u)
fi

files=
for file in "$@"; do
    [ -f "$file" ] && files="$files $file"
done
[ -z "$files" ] && exit 0

# shellcheck disable=SC2086
clang-format -i $files || exit 2

include="${OPENECS:-OpenECS}/include"
if [ ! -f "$include/OpenECS.h" ]; then
    echo "clang-tidy needs OpenECS's release: OPENECS names its folder, as build.sh says"
    exit 2
fi

failed=0
for file in $files; do
    case "$file" in
    *.c) ;;
    *) continue ;;
    esac

    # the flags of build.sh
    if ! clang-tidy --quiet "$file" -- -std=c23 -isystem "$include" > tidy.ignore.log 2>&1; then
        grep -E "(warning|error):" -A3 tidy.ignore.log | grep -v -E "^[0-9]+ warnings? generated"
        failed=1
    fi
done

rm -f tidy.ignore.log
exit $failed
