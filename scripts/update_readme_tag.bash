#!/usr/bin/env bash

# params: integer
add_commas() {
    echo "$1" | mawk '/^[0-9]+$/{printf "%\047.f\n", $1}'
}

# params: filename
get_filesize() {
    stat -c %s "$1" | numfmt --to=iec
}

# params: filename, tag variable, value
replace_html_tag() {
    local base
    local match
    local tag_id

    base=$(basename "$1" .txt)
    match="${base}_${2:1}"
    tag_id="${match//_/-}"

    sed -i -e "$(printf 's/\(<td id="%s">\).*\(<\/td>\)/\\1%s\\2/\n' ${tag_id} ${3})" README.md
}

main() {
    local line_count
    local file_size

    line_count=$(add_commas "$(wc -l <"$1")")
    file_size=$(get_filesize "$1")

    replace_html_tag "$1" "\$line_count" "$line_count"
    replace_html_tag "$1" "\$file_size" "$file_size"
}

main "$1"
