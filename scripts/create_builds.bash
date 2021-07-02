#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

# https://github.com/koalaman/shellcheck/wiki/SC2155
DOWNLOADS=$(mktemp -d)
readonly DOWNLOADS
trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

# params: src_list
get_file_contents() {
    case $1 in
    *.tar.gz)
        # Both Shallalist and Ut-capitole adhere to this format
        # If any archives are added that do not, this line needs to change
        tar -xOzf "$1" --wildcards-match-slash --wildcards '*/domains'
        ;;
    *.zip) zcat -s "$1" ;;
    *.7z) 7za -y -so e "$1" ;;
    *) cat -s "$1" ;;
    esac
}

# params: engine, rule
parse_file_contents() {
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
    *) ;;
    esac
}

# CAN CONTAIN: domains, unicode domains, punycode domains
# params: color
output_domain_format() {
    ./scripts/idn_to_punycode.pl >>"${color}_domain.txt" # convert unicode domains to punycode (everything else falls through)
}

# CAN CONTAIN: addresses, CIDR block ranges, address-address ranges
# params: color
output_ipv4_format() {
    cat -s >>"${color}_ipv4.txt"
}

# CAN CONTAIN: addresses
# params: color
output_ipv6_format() {
    cat -s >>"${color}_ipv6.txt"
}

main() {
    local cache_dir
    local src_list
    local list

    for color in 'white' 'black'; do
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
                src_list=$(find -P -O3 "$cache_dir" -type f -name "$key*")

                if [ -n "$src_list" ]; then
                    get_file_contents "$src_list" |
                        parse_file_contents "$engine" "$rule" |
                        mawk '!seen[$0]++' |
                        case $format in
                        domain) output_domain_format "$color" ;;
                        ipv4) output_ipv4_format "$color" ;;
                        ipv6) output_ipv6_format "$color" ;;
                        esac
                fi
                # else the download failed and src_list is empty
            done

        for format in 'ipv4' 'ipv6' 'domain'; do
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
