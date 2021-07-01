#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

# https://github.com/koalaman/shellcheck/wiki/SC2155
DOWNLOADS=$(mktemp -d)
readonly DOWNLOADS
trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

# params: key, cache dir
get_file_contents() {
    local fpath
    fpath=$(find -P -O3 "$2" -type f -name "$1*")

    if [ ! -z "$fpath" ]; then
        case $fpath in
        *.tar.gz)
            # Both Shallafpath and Ut-capitole adhere to this format
            # If any archives are added that do not, this line needs to change
            tar -xOzf "$fpath" --wildcards-match-slash --wildcards '*/domains'
            ;;
        *.zip) zcat "$fpath" ;;
        *.7z) 7za -y -so e "$fpath" ;;
        *) cat "$fpath" ;;
        esac
    else     # the file download failed and fpath is an empty string
        echo # pass on an empty string that should be ignored
    fi
}

# params: engine, rule, format
parse_file_contents() {
    if [[ "$3" == 'domain' ]]; then
        ./scripts/idn2punycode.pl
    fi

    case $1 in
    mawk) mawk "$2" ;;
    gawk) gawk --sandbox -O -- "$2" ;;
    jq) jq -r "$2" ;;
    miller)
        if [[ $2 =~ ^[0-9]+$ ]]; then
            mlr --mmap --csv --skip-comments -N cut -f "$2"
        else
            mlr --mmap --csv --skip-comments --headerless-csv-output cut -f "$2"
        fi
        ;;
    xmlstarlet)
        # xmlstarlet sel -t -m "/rss/channel/item" -v "substring-before(title,' ')" -n rss.xml
        ;;
    cat) ;;
    esac
}

main() {
    for color in 'white' 'black'; do
        local cache_dir
        cache_dir="${DOWNLOADS}/${color}"

        set +e # temporarily disable strict fail, in case downloads fail
        jq -r --arg color "$color" 'to_entries[] |
        select(.value.color == $color) |
        {key, mirrors: .value.mirrors} |
        .extension = (.mirrors[0] | match(".(tar.gz|zip|7z|json)").captures[0].string // "txt") |
        (.mirrors | join("\t")), " out=\(.key).\(.extension)"' sources/sources.json |
            aria2c --conf-path='./configs/aria2.conf' -d "$cache_dir"
        set -e

        jq -r --arg color "$color" 'to_entries[] |
        select(.value.color == $color) |
         .key as $k | .value.filters[] | "\($k)#\(.engine)#\(.format)#\(.rule)"' sources/sources.json |
            while IFS='#' read -r key engine format rule; do
                get_file_contents "$key" "$cache_dir" |
                    parse_file_contents "$engine" "$rule" "$format" | # quickly remove internal duplicates
                    mawk '!seen[$0]++' >>"${color}_${format}.txt"     # then append contents to list
            done

        for format in 'ipv4' 'ipv6' 'domain'; do
            local list
            list="${color}_${format}.txt"

            if test -f "$list"; then
                sort -o "$list" -u -S 90% --parallel=4 -T "$cache_dir" "$list"

                if [[ "$color" == 'black' && -f "white_${format}.txt" ]]; then
                    grep -Fxvf "white_${format}.txt" "$list" | sponge "$list"
                fi
            fi
        done
    done

    for release in 'black_domain' 'black_ipv4' 'black_ipv6'; do
        tar -czf "${release}.tar.gz" "${release}.txt"
        md5sum "${release}.tar.gz" >"${release}.md5"
        sha1sum "${release}.tar.gz" >"${release}.sha1"
        sha256sum "${release}.tar.gz" >"${release}.sha256"
    done
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main
