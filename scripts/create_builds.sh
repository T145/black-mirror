#!/usr/bin/env bash
set -euo pipefail

downloads=$(mktemp -d)
trap 'rm -rf "$downloads"' EXIT || exit 1

# params: list name, sort column, cache dir
sort_list() {
    sort -o "$1" -k "$2" -u -S 90% --parallel=4 -T "$3" "$1"
}

for color in 'white' 'black'; do
    cache_dir="${downloads}/${color}"

    jq --arg color "$color" 'to_entries[] | select(.value.color == $color)' sources.json |
        jq -r -s 'from_entries | keys[] as $k | "\($k)#\(.[$k] | .mirrors)"' |
        while IFS=$'#' read -r key mirrors; do
            echo "$mirrors" | tr -d '[]"' | tr -s ',' "\t" | gawk -v key="$key" '{
                if ($0 ~ /\.tar.gz$/ || /\.zip$/) {
                    printf "%s\n out=%s.%s\n",$0,key,gensub(/^(.*[/])?[^.]*[.]?/, "", 1, $0)
                } else {
                    printf "%s\n out=%s.txt\n",$0,key
                }
            }'
        done | aria2c --conf-path='./configs/aria2.conf' -d "$cache_dir"

    for format in 'domain' 'ipv4' 'ipv6'; do
        list_name="${color}_${format}.txt"

        jq --arg color "$color" --arg format "$format" 'to_entries[] | select(.value.color == $color and .value.format == $format)' sources.json |
            jq -r -s 'from_entries | keys[] as $k | "\($k)#\(.[$k] | .rule)"' |
            while IFS=$'#' read -r key rule; do
                fpath=$(find -P -O3 "$cache_dir" -type f -name "$key*")

                case $fpath in
                *.tar.gz)
                    # Both Shallalist and Ut-capitole adhere to this format
                    # If any archives are added that do not, this line needs to change
                    tar -xOzf "$fpath" --wildcards-match-slash --wildcards '*/domains'
                    ;;
                *.zip) zcat "$fpath" ;;
                *) cat "$fpath" ;;
                esac |
                    gawk --sandbox -O -- "$rule" | # apply the regex rule
                    gawk '!x[$0]++' |              # filter duplicates out
                    gawk -v format="$format" -v color="$color" '{
                        switch (format) {
                        case "domain":
                            print $0 >> color "_domain.txt"
                            break
                        case "ipv4":
                            print "0.0.0.0 " $0 >> color "_ipv4.txt"
                            break
                        case "ipv6":
                            print ":: " $0 >> color "_ipv6.txt"
                            break
                        default:
                            break
                        }
                    }'
            done

        if test -f "$list_name"; then
            if [[ "$format" == 'domain' ]]; then
                sort_list "$list_name" 1 "$cache_dir"
            else
                sort_list "$list_name" 2 "$cache_dir"
            fi

            if [[ "$color" == 'black' ]]; then
                blacklist="black_${format}.txt"

                if test -f "white_${format}.txt"; then
                    grep -Fxvf "white_${format}.txt" "$blacklist" | sponge "$blacklist"
                fi

                if [[ "$format" == 'domain' ]]; then
                    gawk '{ print "0.0.0.0 " $0 }' "$blacklist" >'black_ipv4.txt'
                    gawk '{ print ":: " $0 }' "$blacklist" >'black_ipv6.txt'
                fi

                tar -czf "black_${format}.tar.gz" "$blacklist"
                md5sum "black_${format}.tar.gz" >"black_${format}.md5"
            fi
        fi
    done
done
