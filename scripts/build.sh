#!/usr/bin/env bash

set -eu

downloads=$(mktemp -d)
trap 'rm -rf "$downloads"' EXIT || exit 1

cat sources.json | jq -S -r 'to_entries[] | [.key, .value.url] | @tsv' |
    gawk -F'\t' '{ if ($2 ~ /\.tar.gz$/ || /\.zip$/) { printf "%s\n out=%s.%s\n",$2,$1,gensub(/^(.*[/])?[^.]*[.]?/, "", 1, $2) } else { printf "%s\n out=%s.txt\n",$2,$1 } }' |
    aria2c -i- -q -d "$downloads" --max-concurrent-downloads=10 --optimize-concurrent-downloads=true --auto-file-renaming=false --realtime-chunk-checksum=false --async-dns-server=[1.1.1.1:53,1.0.0.1:53,8.8.8.8:53,8.8.4.4:53,9.9.9.9:53,9.9.9.10:53,77.88.8.8:53,77.88.8.1:53,208.67.222.222:53,208.67.220.220:53]

cat sources.json | jq -S -r 'to_entries[] | [.key, .value.rule] | @tsv' |
    while IFS=$'\t' read key rule; do
        fpath=$(find -P -O3 "$downloads" -type f -name "$key*")

        if test -f "whitelists/$key.txt"; then
            while read host; do
                gawk -i inplace "!/$host/" $fpath
            done <"whitelists/$key.txt"
        fi

        case $fpath in
        *.tar.gz) tar -xOzf "$fpath" ;;
        *.zip) zcat "$fpath" ;;
        *) cat "$fpath" ;;
        esac | gawk --sandbox -- "$rule"
    done | sort -u -k 2 -S 75% --parallel=4 -T "$downloads" >|black_domains.txt

gawk '{ print "0.0.0.0 " $0; }' black_domains.txt > black_ipv4.txt
gawk '{ print ":: " $0; }' black_domains.txt > black_ipv6.txt

tar -czf black_domains.tar.gz black_domains.txt
tar -czf black_ipv4.tar.gz black_ipv4.txt
tar -czf black_ipv6.tar.gz black_ipv6.txt
