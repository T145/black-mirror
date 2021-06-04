#!/usr/bin/env bash

set -eu

if ! test -d sources; then
    jq -r 'to_entries[] | [.key, .value.url] | @tsv' sources.json |
        gawk -F'\t' '{ if ($2 ~ /\.tar.gz$/ || /\.zip$/) { printf "%s\n out=%s.%s\n",$2,$1,gensub(/^(.*[/])?[^.]*[.]?/, "", 1, $2) } else { printf "%s\n out=%s.txt\n",$2,$1 } }' |
        aria2c -i- -q -d sources --max-concurrent-downloads=10 --optimize-concurrent-downloads=true --auto-file-renaming=false --realtime-chunk-checksum=false --async-dns-server=[1.1.1.1:53,1.0.0.1:53,8.8.8.8:53,8.8.4.4:53,9.9.9.9:53,9.9.9.10:53,77.88.8.8:53,77.88.8.1:53,208.67.222.222:53,208.67.220.220:53]
fi

jq -r 'keys[] as $k | "\($k)#\(.[$k] | .rule)"' sources.json |
    while IFS=$'#' read -r key rule; do
        fpath=$(find -P -O3 sources -type f -name "$key*")
        target="sources/$key.txt"

        case $fpath in
        *.tar.gz)
            if [[ $key == 'utcapitole' ]]; then
                tar -xOzf $fpath --wildcards-match-slash --wildcards '*/domains'
            else
                tar -xOzf $fpath
            fi >$target
            ;;
        *.zip) zcat $fpath >$target ;;
        *) ;;
        esac

        gawk -i inplace "$rule" $target

        if test -f "whitelists/$key.txt"; then
            while read host; do
                gawk -i inplace "!/$host/" $target
            done <"whitelists/$key.txt"
        fi
    done

cat sources/*.txt | sort -u -S 75% --parallel=4 >|black_domains.txt

gawk '{ print "0.0.0.0 " $0; }' black_domains.txt >black_ipv4.txt
gawk '{ print ":: " $0; }' black_domains.txt >black_ipv6.txt

tar -czf black_domains.tar.gz black_domains.txt
tar -czf black_ipv4.tar.gz black_ipv4.txt
tar -czf black_ipv6.tar.gz black_ipv6.txt
