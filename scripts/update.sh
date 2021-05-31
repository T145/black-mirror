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
# Now using the complete StevenBlack list.
# Includes adaway, adguard tracking, whocares, winhelp, and yoyo.
#
# https://github.com/EnergizedProtection/block#package-sources
# ---
# Now using the complete EnergizedProtection list.
# Includes adguard, bitcoin, disconnect, reg_cn, reg_cz, reg_de, reg_es, reg_fr,
# reg_it, reg_nl, reg_ro, reg_ru, reg_vn, stopforumspam, spam404, and winspy.
# All Anudeep lists are included except the Facebook list, so that's being added in.
#
# TODO: Add in the extension packs, if they aren't included somewhere already.
# TODO: Inlcude other winspy packs?
# #
cat <<EOF >"$sources"
$(jq -n -f "$sources" |
    jq '.stevenblack.url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"' |
    jq '.energized.url = "https://block.energized.pro/unified/formats/domains.txt"' |
    jq '.anudeep.url = "https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt"' |
    jq 'del(.["adaway", "adguard", "adguard_tracking", "bitcoin", "disconnect", "gaming", "oisd_basic", "reg_cn", "reg_cz", "reg_de", "reg_es", "reg_fr", "reg_it", "reg_nl", "reg_ro", "reg_ru", "reg_vn", "stopforumspam", "spam404", "whocares", "winhelp", "winspy", "yoyo"])')
EOF

cat "$sources" | jq -r 'to_entries[] | [.key, .value.url] | @tsv' |
    awk -F'\t' '{ if ($2 ~ /\.tar.gz$/) { printf "%s\n out=%s.tar.gz\n",$2,$1 } else { printf "%s\n out=%s.txt\n",$2,$1 } }' |
    aria2c -i- -q -d "$downloads" --max-concurrent-downloads=10 --optimize-concurrent-downloads=true --auto-file-renaming=false --realtime-chunk-checksum=false --async-dns-server=[1.1.1.1:53,1.0.0.1:53,8.8.8.8:53,8.8.4.4:53,9.9.9.9:53,9.9.9.10:53,77.88.8.8:53,77.88.8.1:53,208.67.222.222:53,208.67.220.220:53]

cat "$sources" | jq -r 'to_entries[] | [.key, .value.url, .value.rule] | @tsv' |
    while IFS=$'\t' read key url rule; do
        case $url in
        *.tar.gz) tar -xOzf "$downloads/$key.tar.gz" ;;
        *) cat "$downloads/$key.txt" ;;
        esac | gawk --sandbox -- "$rule" | sed 's/^/0.0.0.0 /'
    done | sort -u -k 2 -S 75% --parallel=4 >|"$the_blacklist"

split -C 100MB -d -a 1 --additional-suffix .txt "$the_blacklist" the_blacklist
