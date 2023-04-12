#!/usr/bin/env bash

# Sorts the designated source file and constructs new list formats from it
main() {
	local lists

	lists='data/v2/lists.json'

	git config --global --add safe.directory /__w/black-mirror/black-mirror
	jq -Sr '.' -f "$lists" >"$lists"
	jq -jr 'to_entries[] | select(.value.method == "BLOCK" and .value.variants.pihole != null) | (.value.variants.pihole, " ")' "$lists" | sed 's/ $/\n/' >dist/sources.pihole
	jq -jr 'to_entries[] | select(.value.method == "BLOCK" and .value.variants.adguard != null) | ("!#include ", .value.variants.adguard, "\n")' "$lists" >dist/sources.adguard
	jq -r 'to_entries[].value | select(.variants != null) | .variants | to_entries[].value' "$lists" >"$sources"
	jq -r 'to_entries[].value.mirrors[]' "$lists" >>dist/sources.txt
}

main
