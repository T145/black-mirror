#!/usr/bin/env bash

# Sorts the designated source file and constructs new list formats from it
main() {
	git config --global --add safe.directory /__w/black-mirror/black-mirror
	jq -Sr '.' -f data/v2/lists.json >data/v2/lists.json
	jq -jr 'to_entries[] | select(.value.method == "BLOCK" and .value.variants.pihole != null) | (.value.variants.pihole, " ")' data/v2/lists.json | sed 's/ $/\n/' >dist/sources.pihole
	jq -jr 'to_entries[] | select(.value.method == "BLOCK" and .value.variants.adguard != null) | ("!#include ", .value.variants.adguard, "\n")' data/v2/lists.json >dist/sources.adguard
	jq -r 'to_entries[].value | select(.variants != null) | .variants | to_entries[].value' "$1" >"$sources"
	jq -r 'to_entries[].value.mirrors[]' "$1" >>dist/sources.txt
}

main
