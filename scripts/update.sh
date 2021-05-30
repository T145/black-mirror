#!/usr/bin/env bash

set -eu

sources=$(mktemp)
the_blacklist=$(mktemp)
downloads=$(mktemp -d)
trap 'rm "$sources" && rm "$the_blacklist" && rm -rf "$downloads"' EXIT || exit 1

rm -rf hosts
mkdir hosts -p -m 777 && cd hosts
curl -s -o "$sources" https://raw.githubusercontent.com/openwrt/packages/master/net/adblock/files/adblock.sources

# #
# ---
# The gaming list blocks virtually all gaming-related hosts,
# and the basic oisd list is included in the full version.
#
# https://github.com/StevenBlack/hosts#sources-of-hosts-data-unified-in-this-variant
# ---
# Changed the StevenBlack list to be the complete version,
# which makes all sources in the `del` statement other
# than "gaming" and "oisd_basic" redundant.
#
# https://github.com/EnergizedProtection/block#package-sources
# ---
# TODO: Filter out redundant sources
cat <<EOF >"$sources"
$(jq -n -f "$sources" |
    jq '.stevenblack.url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"' |
    jq '.energized.url = "https://block.energized.pro/unified/formats/domains.txt"' |
    jq 'del(.["adaway", "adguard_tracking", "gaming", "oisd_basic", "whocares", "winhelp", "yoyo"])')
EOF

cat "$sources" | jq -r 'to_entries[] | [.key, .value.url] | @tsv' |
    awk -F'\t' '{ if ($2 ~ /\.tar.gz$/) { printf "%s\n out=%s.tar.gz\n",$2,$1 } else { printf "%s\n out=%s.txt\n",$2,$1 } }' |
    aria2c -i- -q -d "$downloads" --optimize-concurrent-downloads=true --auto-file-renaming=false

cat "$sources" | jq -r 'to_entries[] | [.key, .value.url, .value.rule] | @tsv' |
    while IFS=$'\t' read key url rule; do
        case $url in
        *.tar.gz) tar -xOzf "$downloads/$key.tar.gz" ;;
        *) cat "$downloads/$key.txt" ;;
        esac | gawk --sandbox -- "$rule"
    done | sort -u -S 50% --parallel=2 | sed 's/^/0.0.0.0 /' >|"$the_blacklist"

split -C 100MB -d -a 1 --additional-suffix .txt "$the_blacklist" the_blacklist
