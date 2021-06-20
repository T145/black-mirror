#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

readonly DOWNLOADS=$(mktemp -d)
trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

for color in 'white' 'black'; do
    cache_dir="${DOWNLOADS}/${color}"

    jq -r --arg color "$color" 'to_entries[] |
        select(.value.color == $color) |
        {key, mirrors: .value.mirrors} |
        .extension = (.mirrors[0] | match(".(tar.gz|zip|json)").captures[0].string // "txt") |
        (.mirrors | join("\t")), " out=\(.key).\(.extension)"' sources.json |
        aria2c --conf-path='./configs/aria2.conf' -d "$cache_dir"

    # this logic is technically order agnostic
    jq -r --arg color "$color" 'to_entries[] | select(.value.color == $color) |
        .key as $k | .value.filters[] | "\($k)#\(.engine)#\(.format)#\(.rule)"' sources.json |
        while IFS='#' read -r key engine format rule; do
            list="${color}_${format}.txt"
            file_path=$(find -P -O3 "$cache_dir" -type f -name "$key*")

            case $file_path in
            *.tar.gz)
                # Both Shallalist and Ut-capitole adhere to this format
                # If any archives are added that do not, this line needs to change
                tar -xOzf "$file_path" --wildcards-match-slash --wildcards '*/domains'
                ;;
            *.zip) zcat "$file_path" ;;
            *) cat "$file_path" ;;
            esac |
                case $engine in
                jq) jq -r "$rule" ;;
                gawk) gawk --sandbox -O -- "$rule" ;;
                mawk) mawk "$rule" ;;
                *) echo "WARN: \"${key}\" doesn't have a valid engine!" ;;
                esac | gawk -v format="$format" -v list="$list" '
                        BEGIN {
                            prefixes["ipv4"] = "0.0.0.0 "
                            prefixes["ipv6"] = ":: "
                            prefixes["domain"] = ""
                        }
                        !seen[$0]++ {
                            print prefixes[format] $0 >> list
                        }'
        done

    for format in 'ipv4' 'ipv6' 'domain'; do
        list="${color}_${format}.txt"

        if test -f "$list"; then
            sort -o "$list" -u -S 90% --parallel=4 -T "$cache_dir" "$list"

            if [[ "$color" == 'black' ]]; then
                if test -f "white_${format}.txt"; then
                    grep -Fxvf "white_${format}.txt" "$list" | sponge "$list"
                fi

                if [[ "$format" == 'domain' ]]; then
                    gawk '{ print "0.0.0.0 " $0 }' "$list" >>'black_ipv4.txt'
                    gawk '{ print ":: " $0 }' "$list" >>'black_ipv6.txt'
                    tar -czf 'black_domain.tar.gz' "$list"
                    tar -czf 'black_ipv4.tar.gz' 'black_ipv4.txt'
                    tar -czf 'black_ipv6.tar.gz' 'black_ipv6.txt'
                    md5sum 'black_domain.tar.gz' >'black_domain.md5'
                    md5sum 'black_ipv4.tar.gz' >'black_ipv4.md5'
                    md5sum 'black_ipv6.tar.gz' >'black_ipv6.md5'
                fi
            fi
        fi
    done
done
