#!/usr/bin/env bash

set -euo pipefail

# params: integer
add_commas() {
    echo "$1" | sed -e :x -e 's/\([0-9][0-9]*\)\([0-9][0-9][0-9]\)/\1,\2/' -e 'tx'
}

# params: filename
get_filesize() {
    stat -c %s "$1" | numfmt --to=iec
}

# params: filename, value
replace_html_tag() {
    sed -e $(printf 's/\(<td id="%s">\).*\(<\/td>\)/\\1%s\\2/\n' "${1%.txt//_/-}" "$2") -i REAMDME.md
}

update_readme() {
    local line_count
    local file_size

    line_count=$(add_commas $(wc -l <"$1"))
    file_size=$(get_filesize "$1")

    replace_html_tag "$1" "$line_count"
    replace_html_tag "$1" "$file_size"
}

# Handles everything involved in GitHub CI processing
main() {
    :> logs/aria2.log
    ./scripts/v1/build_release.bash
    find -P -O3 ./build/ -type f -name "*.txt" -exec update_readme {} \;
}

main
