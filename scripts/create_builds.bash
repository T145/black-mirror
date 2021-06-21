#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

# https://github.com/koalaman/shellcheck/wiki/SC2155
DOWNLOADS=$(mktemp -d)
readonly DOWNLOADS
trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

# params: key, cache dir
get_file_contents() {
    local list
    list=$(find -P -O3 "$2" -type f -name "$1*")

    case $list in
    *.tar.gz)
        # Both Shallalist and Ut-capitole adhere to this format
        # If any archives are added that do not, this line needs to change
        tar -xOzf "$list" --wildcards-match-slash --wildcards '*/domains'
        ;;
    *.zip) zcat "$list" ;;
    *) cat "$list" ;;
    esac
}

# params: key, engine, rule
parse_file_contents() {
    case $2 in
    jq) jq -r "$3" ;;
    gawk) gawk --sandbox -O -- "$3" ;;
    mawk) mawk "$3" ;;
    xmlstarlet)
        # xmlstarlet sel -t -m "/rss/channel/item" -v "substring-before(title,' ')" -n rss.xml
        ;;
    *) echo "WARN: \"${1}\" doesn't have a valid engine!" ;;
    esac
}

# params: color, format
add_to_list() {
    local list
    list="${1}_${2}.txt"

    gawk -v list="$list" '
        !seen[$0]++ {
            print $0 >> list
        }'
}

main() {
    for color in 'white' 'black'; do
        cache_dir="${DOWNLOADS}/${color}"

        jq -r --arg color "$color" 'to_entries[] |
        select(.value.color == $color) |
        {key, mirrors: .value.mirrors} |
        .extension = (.mirrors[0] | match(".(tar.gz|zip|json)").captures[0].string // "txt") |
        (.mirrors | join("\t")), " out=\(.key).\(.extension)"' sources.json |
            aria2c --conf-path='./configs/aria2.conf' -d "$cache_dir"

        jq -r --arg color "$color" 'to_entries[] |
        select(.value.color == $color) |
         .key as $k | .value.filters[] | "\($k)#\(.engine)#\(.format)#\(.rule)"' sources.json |
            while IFS='#' read -r key engine format rule; do
                get_file_contents "$key" "$cache_dir" |
                    parse_file_contents "$key" "$engine" "$rule" |
                    add_to_list "$color" "$format"
            done

        for format in 'ip4' 'ip6' 'dom'; do
            list="${color}_${format}.txt"

            if test -f "$list"; then
                sort -o "$list" -u -S 90% --parallel=4 -T "$cache_dir" "$list"

                if [[ "$color" == 'black' ]]; then
                    if test -f "white_${format}.txt"; then
                        grep -Fxvf "white_${format}.txt" "$list" | sponge "$list"
                    fi
                fi
            fi
        done

        if [[ "$color" == 'black' ]]; then
            for release in 'black_dom' 'black_ip4' 'black_ip6'; do
                tar -czf "${release}.tar.gz" "${release}.txt"
                md5sum "${release}.tar.gz" >"${release}.md5"
            done
        fi
    done
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main
