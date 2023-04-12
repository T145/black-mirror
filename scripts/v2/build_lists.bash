#!/usr/bin/env bash

#shopt -s extdebug     # or --debugging
set +H +o history     # disable history features (helps avoid errors from "!" in strings)
shopt -u cmdhist      # would be enabled and have no effect otherwise
shopt -s execfail     # ensure interactive and non-interactive runtime are similar
shopt -s extglob      # enable extended pattern matching (https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
set -euET -o pipefail # put bash into strict mode & have it give descriptive errors
umask 055             # change all generated file perms from 755 to 700
export LC_ALL=C       # force byte-wise sorting and default langauge output

DOWNLOADS=$(mktemp -d)
TMP=$(mktemp -p "$DOWNLOADS")
METHOD_ALLOW='ALLOW'
METHOD_BLOCK='BLOCK'
FORMAT_DOMAIN='DOMAIN'
FORMAT_CIDR4='CIDR4'
FORMAT_CIDR6='CIDR6'
FORMAT_IPV4='IPV4'
FORMAT_IPV6='IPV6'
readonly DOWNLOADS TMP METHOD_ALLOW METHOD_BLOCK FORMAT_DOMAIN FORMAT_CIDR4 FORMAT_CIDR6 FORMAT_IPV4 FORMAT_IPV6

METHODS=("$METHOD_BLOCK" "$METHOD_ALLOW")
FORMATS=("$FORMAT_DOMAIN" "$FORMAT_CIDR4" "$FORMAT_CIDR6" "$FORMAT_IPV4" "$FORMAT_IPV6")
readonly -a METHODS
readonly -a FORMATS

sorted() {
	parsort -bfiu -S 100% -T "$DOWNLOADS" "$1" | sponge "$1"
}

main() {
	trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

	local cache
	local list
	local blacklist

	mkdir -p build/
	: >logs/aria2.log

	for method in "${METHODS[@]}"; do
		cache="${DOWNLOADS}/${method}"

		# use 'lynx -dump -listonly -nonumbers' to get a raw page

		set +e # temporarily disable strict fail, in case downloads fail
		jq -r --arg method "$method" 'to_entries[] |
			select(.value.content.retriever == "ARIA2" and .value.method == $method) |
			{key, mirrors: .value.mirrors} |
			(.mirrors | join("\t")), " out=\(.key)"' data/v2/lists.json |
			aria2c -i- -d "$cache" --conf-path='./configs/aria2.conf'
		set -e

		jq -r --arg method "$method" 'to_entries[] |
			select(.value.method == $method) |
			.key as $key |
			.value.content.filter as $content_filter |
			.value.content.type as $content_type |
			.value.formats[] |
			"\($key)#\($content_filter)#\($content_type)#\(.filter)#\(.format)"' data/v2/lists.json |
			while IFS='#' read -r key content_filter content_type list_filter list_format; do
				#find -P -O3 "$cache" -name "$key" -type f -exec sem -j+0 ./scripts/v2/apply_filters.bash {} "$method" "$content_filter" "$content_type" "$list_filter" "$list_format" \; 1>/dev/null
				find -P -O3 "$cache" -name "$key" -type f -exec ./scripts/v2/apply_filters.bash {} "$method" "$content_filter" "$content_type" "$list_filter" "$list_format" \; 1>/dev/null
			done

		#sem --wait

		for format in "${FORMATS[@]}"; do
			if [[ "$format" != "$FORMAT_CIDR4" || "$format" != "$FORMAT_CIDR6" ]]; then
				list="build/${method}_${format}.txt"

				if test -f "$list"; then
					if [[ "$method" == "$METHOD_BLOCK" ]]; then
						sorted "$list"
					else
						blacklist="build/BLOCK_${format}.txt"

						# https://askubuntu.com/a/562352
						# send each line into the temp file as it's processed instead of keeping it in memory
						parallel --pipe -k -j+0 grep --line-buffered -Fxvf "$list" - <"$blacklist" >>"$TMP"
						cp "$TMP" "$blacklist"
						: >"$TMP"
					fi
				fi
			fi
		done
	done
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main

# reset the locale after processing
unset LC_ALL
