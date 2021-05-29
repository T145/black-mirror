#!/usr/bin/env bash

set -eu

sources=$(mktemp)
the_blacklist=$(mktemp)
trap 'rm "$sources" && rm "$the_blacklist"' EXIT || exit 1

rm -rf hosts
mkdir hosts -p -m 777 && cd hosts
curl -s -o "$sources" https://raw.githubusercontent.com/openwrt/packages/master/net/adblock/files/adblock.sources

# https://github.com/StevenBlack/hosts#sources-of-hosts-data-unified-in-this-variant
# ---
# Changed the StevenBlack list to be the complete version,
# which makes all sources in the `del` statement other
# than "gaming" and "oisd_basic" redundant.
# The gaming list blocks virtually all gaming-related hosts,
# and the basic oisd list is included in the full version.
cat <<EOF >"$sources"
$(jq -n -f "$sources" |
    jq '.stevenblack.url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"' |
    jq 'del(.["adaway", "adguard_tracking", "gaming", "oisd_basic", "whocares", "winhelp", "yoyo"])')
EOF

jq -n -f "$sources" | jq -r 'keys[] as $k | [$k, .[$k].url, .[$k].rule] | @tsv' |
    while IFS=$'\t' read key url rule; do
        curl -s "$url" |
            case $url in
            *.tar.gz) tar -xOzf - ;;
            *) cat ;;
            esac | gawk --sandbox -- "$rule"
    done | sort -u -S 50% --parallel=2 | sed 's/^/0.0.0.0 /' >|"$the_blacklist"

split -C 100MB -d -a 1 --additional-suffix .txt "$the_blacklist" the_blacklist
