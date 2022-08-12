#!/usr/bin/env bash

# params: file path
get_line_count() {
	wc -l <"$1" | sed -e :x -e 's/\([0-9][0-9]*\)\([0-9][0-9][0-9]\)/\1,\2/' -e 'tx'
}

# params: file path
get_file_size() {
	stat -c %s "$1" | numfmt --to=iec
}

# params: file path, tag variable, value
replace_html_tag() {
	local tag_match

	tag_match="$(basename "$1" .txt)_${2:1}"

	sed -i -e "$(printf 's/\(<td id="%s">\).*\(<\/td>\)/\\1%s\\2/\n' "${tag_match//_/-}" "${3}")" README.md
}

main() {
	local line_count
	local file_size

	line_count=$(get_line_count "$1")
	file_size=$(get_file_size "$1")

	replace_html_tag "$1" "\$line_count" "$line_count"
	replace_html_tag "$1" "\$file_size" "$file_size"
}

main "$1"
