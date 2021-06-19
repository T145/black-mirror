#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

downloads=$(mktemp -d)
trap 'rm -rf "$downloads"' EXIT || exit 1

# params: list name, sort column, cache dir
sort_list() {
    sort -o "$1" -k "$2" -u -S 90% --parallel=4 -T "$3" "$1"
}

for color in 'white' 'black'; do
    local cache_dir="${downloads}/${color}"

    jq -r --arg color "$color" 'to_entries[] |
        select(.value.color == $color) |
        {key, mirrors: .value.mirrors} |
        .extension = (.mirrors[0] | match(".(tar.gz|zip|json)").captures[0].string // "txt") |
        (.mirrors | join("\t")), " out=\(.key).\(.extension)"' sources.json |
        aria2c --conf-path='./configs/aria2.conf' -d "$cache_dir"

    for format in 'domain' 'ipv4' 'ipv6'; do
        local list_name="${color}_${format}.txt"

        jq -r --arg color "$color" --arg format "$format" 'to_entries[] |
            select(.value.color == $color and .value.format == $format) | "\(.key)#\(.value.rule)"' sources.json |
            while IFS=$'#' read -r key rule; do
                local fpath=$(find -P -O3 "$cache_dir" -type f -name "$key*")

                if [[ $fpath == *.json ]]; then
                    jq -r "$rule" "$fpath"
                else
                    case $fpath in
                    *.tar.gz)
                        # Both Shallalist and Ut-capitole adhere to this format
                        # If any archives are added that do not, this line needs to change
                        tar -xOzf "$fpath" --wildcards-match-slash --wildcards '*/domains'
                        ;;
                    *.zip) zcat "$fpath" ;;
                    *) cat "$fpath" ;;
                    esac | gawk --sandbox -O -- "$rule"
                fi | gawk -v format="$format" -v filename="$list_name" '
                        BEGIN {
                            prefixes["ipv4"] = "0.0.0.0 "
                            prefixes["ipv6"] = ":: "
                            prefixes["domain"] = ""
                        }
                        !seen[$0]++ {
                            print prefixes[format] $0 >> filename
                        }'
            done

        if test -f "$list_name"; then
            if [[ "$format" == 'domain' ]]; then
                sort_list "$list_name" 1 "$cache_dir"
            else
                sort_list "$list_name" 2 "$cache_dir"
            fi

            if [[ "$color" == 'black' ]]; then
                local blacklist="black_${format}.txt"

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
