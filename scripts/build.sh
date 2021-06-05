#!/usr/bin/env bash

set -eu

downloads=$(mktemp -d)
trap 'rm -rf "$downloads"' EXIT || exit 1

jq -r 'to_entries[] | [.key, .value.url] | @tsv' sources.json |
    gawk -F'\t' '{ if ($2 ~ /\.tar.gz$/ || /\.zip$/) { printf "%s\n out=%s.%s\n",$2,$1,gensub(/^(.*[/])?[^.]*[.]?/, "", 1, $2) } else { printf "%s\n out=%s.txt\n",$2,$1 } }' |
    aria2c -i- -q -d "$downloads" --max-concurrent-downloads=10 --optimize-concurrent-downloads=true --auto-file-renaming=false --realtime-chunk-checksum=false --async-dns-server=[1.1.1.1:53,1.0.0.1:53,8.8.8.8:53,8.8.4.4:53,9.9.9.9:53,9.9.9.10:53,77.88.8.8:53,77.88.8.1:53,208.67.222.222:53,208.67.220.220:53]

whitelisted=$(cat the_whitelist.txt | paste -sd'|')

for format in 'domain' 'ipv4' 'ipv6'; do
    jq --arg format "$format" 'to_entries[] | select(.value.format == $format)' sources.json |
        jq -r -s 'from_entries | keys[] as $k | "\($k)#\(.[$k] | .rule)"' |
        while IFS=$'#' read -r key rule; do
            fpath=$(find -P -O3 "$downloads" -type f -name "$key*")

            case $fpath in
            *.tar.gz)
                if [[ $key == 'utcapitole' ]]; then
                    tar -xOzf $fpath --wildcards-match-slash --wildcards '*/domains'
                else
                    tar -xOzf $fpath
                fi
                ;;
            *.zip) zcat $fpath ;;
            *) cat $fpath ;;
            esac |
                gawk --sandbox -O -- "$rule" | # apply the regex rule
                gawk '!x[$0]++' |              # filter duplicates out
                gawk -v fmt="$format" '{
                    switch (fmt) {
                    case "domain":
                        print $0  >> "black_domain.txt"
                        print "0.0.0.0 " $0  >> "black_ipv4.txt"
                        print ":: " $0 >> "black_ipv6.txt"
                        break
                    case "ipv4":
                        print "0.0.0.0 " $0  >> "black_ipv4.txt"
                        break
                    case "ipv6":
                        print ":: " $0 >> "black_ipv6.txt"
                        break
                    default:
                        break
                    }
                }'
        done

    sort -o "black_$format.txt" -u -S 90% --parallel=4 -T "$downloads" "black_$format.txt"
    gawk -i inplace -v wlstd="$whitelisted" '!/wlstd$/' "black_$format.txt"
    tar -czf "black_$format.tar.gz" "black_$format.txt"
done
