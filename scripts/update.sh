#!/usr/bin/env bash

set -eu

sources=$(mktemp)
the_blacklist=$(mktemp)
trap 'rm "$sources" && rm "$the_blacklist"' EXIT || exit 1

rm -rf hosts
mkdir hosts -p -m 777 && cd hosts
curl -s -o "$sources" https://raw.githubusercontent.com/openwrt/packages/master/net/adblock/files/adblock.sources

jq -n -f "$sources" | jq -r 'keys[] as $k | [$k, .[$k].url, .[$k].rule] | @tsv' |
    while IFS=$'\t' read key url rule; do
        case $key in
        gaming | oisd_basic | yoyo)
            # Ignore these sources:
            # "gaming" blocks virtually all gaming servers
            # "oisd_basic" is included in "oisd_full"
            # "yoyo" is included in "stevenblack"
            ;;
        *)
            curl -s "$url" |
                case $url in
                *.tar.gz) tar -xOzf - ;;
                *) cat ;;
                esac | gawk --sandbox -- "$rule"
            ;;
        esac
    done | sort -u -S 50% --parallel=2 | sed 's/^/0.0.0.0 /' >|"$the_blacklist"

split -C 100MB -d -a 1 --additional-suffix .txt "$the_blacklist" the_blacklist
