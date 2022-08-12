#!/usr/bin/env bash

# Sorts the designated source file and constructs new list formats from it
main() {
	local sources

	sources='dist/sources.txt'

	git config --global --add safe.directory /__w/black-mirror/black-mirror

	case $(dirname "$1" | mawk -F/ '{print $2}') in
	v1)
		jq -jr 'to_entries[] | select(.value.color == "black") | .value.mirrors[0] as $url | .value.filters[] | if (.engine == "cat" or .engine == "mawk") then ($url, " ") else empty end' data/v1/sources.json | sed 's/ $/\n/' >dist/sources.pihole
		jq -r 'to_entries[] | select(.value.variants != null) | .value.variants[]' "$1" >"$sources"
		;;
	v2)
		jq -jr 'to_entries[] | select(.value.method == "BLOCK" and .value.variants.pihole != null) | (.value.variants.pihole, " ")' data/v2/lists.json | sed 's/ $/\n/' >dist/sources.pihole
		jq -jr 'to_entries[] | select(.value.method == "BLOCK" and .value.variants.adguard != null) | ("!#include ", .value.variants.adguard, "\n")' data/v2/lists.json >dist/sources.adguard
		jq -r 'to_entries[].value | select(.variants != null) | .variants | to_entries[].value' "$1" >"$sources"
		;;
	esac

	jq -r 'to_entries[].value.mirrors[]' "$1" >>"$sources"
	sort -bfiuS 100% -o "$sources" --parallel 200000 "$sources"
}

main "$1"
