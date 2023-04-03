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
FORMAT_IPV4='IPV4'
FORMAT_CIDR='CIDR'
FORMAT_IPV6='IPV6'
readonly DOWNLOADS TMP METHOD_ALLOW METHOD_BLOCK FORMAT_DOMAIN FORMAT_IPV4 FORMAT_CIDR FORMAT_IPV6

METHODS=("$METHOD_BLOCK" "$METHOD_ALLOW")
FORMATS=("$FORMAT_DOMAIN" "$FORMAT_IPV4" "$FORMAT_CIDR" "$FORMAT_IPV6")
readonly -a METHODS
readonly -a FORMATS

# params: file path
sorted() {
	parsort -bfiu -S 100% -T "$DOWNLOADS" "$1" | sponge "$1"
}

# merge list 2 into list 1
# params: list 1, list 2
merge_lists() {
	cat "$1" "$2" | sponge "$1"
	sorted "$1"
}

main() {
	trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

	local cache
	local list
	local nxlist
	local blacklist

	mkdir -p build/

	for method in "${METHODS[@]}"; do
		cache="${DOWNLOADS}/${method}"

		# use 'lynx -dump -listonly -nonumbers' to get a raw page

		set +e # temporarily disable strict fail, in case downloads fail
		jq -r --arg method "$method" 'to_entries[] |
			select(.value.content.retriever == "ARIA2" and .value.method == $method) |
			{key, mirrors: .value.mirrors} |
			.ext = (.mirrors[0] |
			match(".(tar.gz|zip|7z|json)").captures[0].string // "txt") |
			(.mirrors | join("\t")), " out=\(.key).\(.ext)"' data/v2/lists.json |
			aria2c -i- -d "$cache" --conf-path='./configs/aria2.conf'
		set -e

		jq -r --arg method "$method" 'to_entries[] |
			select(.value.method == $method) |
			.key as $k |
			.value.formats[] |
			"\($k)#\(.content.filter)#\(.content.type)#\(.filter)#\(.format)"' data/v2/lists.json |
				while IFS='#' read -r key content_filter content_type list_filter list_format; do
					find -P -O3 "$cache" -type f -exec sem -j+0 ./scripts/v2/apply_filters.bash {} "$key" "$content_filter" "$content_type" "$method" "$list_filter" "$list_format" \;
				done

		sem --wait

		for format in "${FORMATS[@]}"; do
			list="build/${method}_${format}.txt"
			nxlist="dist/NX${format}.txt"

			if test -f "$list"; then
				if [[ "$method" == "$METHOD_BLOCK" ]]; then
					if [[ "$format" != "$FORMAT_CIDR" ]]; then

						# if the nxlist is present, then rescan it to see if any hosts are online
						# put any online hosts into the blacklist and remove them from the nxlist
						# rescan the blacklist using the nxlist as a hosts file to optimize searching
						if test -f "$nxlist"; then
							# TODO: Export JSON from dnsX and use jq to pull out domains & ips
							dnsx -r ./configs/resolvers.txt -l "$nxlist" -o "$TMP" -c 200000 -silent -rcode noerror,servfail,refused 1>/dev/null
							# remove online hosts from the nxlist
							grep -Fxvf "$TMP" "$nxlist" | sponge "$nxlist"
							dnsx -r ./configs/resolvers.txt -hf "$nxlist" -l "$list" -o "$nxlist" -c 200000 -silent -rcode nxdomain 1>/dev/null
							merge_lists "$list" "$TMP"
							#comm "$nxlist" "$TMP" -23 | sponge "$nxlist"
							: >"$TMP"
						else
							sorted "$list"
							dnsx -r ./configs/resolvers.txt -l "$list" -o "$nxlist" -c 200000 -silent -rcode nxdomain 1>/dev/null
						fi

						sorted "$nxlist"
					else
						# can also do more advanced CIDR operations here
						sorted "$list"
					fi
				else
					# apply the whitelist to the blacklist
					blacklist="build/BLOCK_${format}.txt"

					# merge the nxlist and whitelist
					merge_lists "$list" "$nxlist"

					# https://askubuntu.com/a/562352
					# send each line into the temp file as it's processed instead of keeping it in memory
					parallel --pipe -k -j+0 grep --line-buffered -Fxvf "$list" - <"$blacklist" >>"$TMP"
					cp "$TMP" "$blacklist"
					: >"$TMP"
				fi
			fi
		done
	done
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main

# reset the locale after processing
unset LC_ALL
