#!/usr/bin/env bash

set -eu

downloads=$(mktemp -d)
trap 'rm -rf "$downloads"' EXIT || exit 1

for color in 'black' 'white'; do
    jq --arg color "$color" 'to_entries[] | select(.value.color == $color)' sources.json |
        jq -r -s 'from_entries | keys[] as $k | "\($k)#\(.[$k] | .mirrors)"' |
        while IFS=$'#' read -r key mirrors; do
            echo $mirrors | tr -d '[]"' | tr -s ',' "\t" | gawk -v key="$key" '{
                if ($0 ~ /\.tar.gz$/ || /\.zip$/) {
                    printf "%s\n out=%s.%s\n",$0,key,gensub(/^(.*[/])?[^.]*[.]?/, "", 1, $0)
                } else {
                    printf "%s\n out=%s.txt\n",$0,key
                }
            }'
        done | aria2c -i- -q -d "${downloads}/${color}" --max-concurrent-downloads=10 --optimize-concurrent-downloads=true --auto-file-renaming=false --realtime-chunk-checksum=false --async-dns-server=[1.1.1.1:53,1.0.0.1:53,8.8.8.8:53,8.8.4.4:53,9.9.9.9:53,9.9.9.10:53,77.88.8.8:53,77.88.8.1:53,208.67.222.222:53,208.67.220.220:53]
done

for format in 'domain' 'ipv4' 'ipv6'; do
    for color in 'black' 'white'; do
        jq --arg format "$format" 'to_entries[] | select(.value.format == $format)' sources.json |
            jq -r -s 'from_entries | keys[] as $k | "\($k)#\(.[$k] | .rule)"' |
            while IFS=$'#' read -r key rule; do
                fpath=$(find -P -O3 "${downloads}/${color}" -type f -name "$key*")

                case $fpath in
                *.tar.gz)
                    # Both Shallalist and Ut-capitole adhere to this format
                    # If any archives are added that do not, this line needs to change
                    tar -xOzf $fpath --wildcards-match-slash --wildcards '*/domains'
                    ;;
                *.zip) zcat $fpath ;;
                *) cat $fpath ;;
                esac |
                    gawk --sandbox -O -- "$rule" | # apply the regex rule
                    gawk '!x[$0]++' |              # filter duplicates out
                    gawk -v format="$format" color="$color" '{
                        switch (format) {
                        case "domain":
                            print $0 >> color_domain.txt
                            break
                        case "ipv4":
                            print "0.0.0.0 " $0 >> color_ipv4.txt
                            break
                        case "ipv6":
                            print ":: " $0 >> color_ipv6.txt
                            break
                        default:
                            break
                        }
                    }'
            done

        case $color in
        'black') sort -o "black_${format}.txt" -u -S 90% --parallel=4 -T "${downloads}/${color}" "black_${format}.txt" ;;
        'white') grep -Fxvf "white_${format}.txt" "black_${format}.txt" >"black_${format}.txt" ;;
        esac

        if ["$format" == "domain"]; then
            gawk '{ print "0.0.0.0 " $0 }' "${color}_domain.txt" >"${color}_ipv4.txt"
            gawk '{ print ":: " $0 }' "${color}_domain.txt" >"${color}_ipv6.txt"
        fi
    done
done
