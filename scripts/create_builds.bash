#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

# https://github.com/koalaman/shellcheck/wiki/SC2155
DOWNLOADS=$(mktemp -d)
readonly DOWNLOADS
trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

RELEASE_IPV4='ipv4'
readonly RELEASE_IPV4

RELEASE_IPV4_CIDR='ipv4_cidr'
readonly RELEASE_IPV4_CIDR

RELEASE_IPV6='ipv6'
readonly RELEASE_IPV6

RELEASE_DOMAIN='domain'
readonly RELEASE_DOMAIN

RELEASES=(RELEASE_IPV4 RELEASE_IPV4_CIDR RELEASE_IPV6 RELEASE_DOMAIN)
readonly RELEASES

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
    cat) cat ;;
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
    *) ;; # TODO: log warning that an engine isn't assigned
    esac
}

# CAN CONTAIN: domains, unicode domains, punycode domains
# params: color
output_domain_format() {
    ./scripts/idn_to_punycode.pl >>"${1}_${RELEASE_DOMAIN}.txt" # convert unicode domains to punycode (everything else falls through)
}

# CAN CONTAIN: addresses, CIDR block ranges, address-address ranges
# params: color
output_ipv4_format() {
    #cat -s >>"${color}_ipv4.txt"
    # TODO: cross-reference IPV4 & IPV4 CIDR to remove any ips that fall in a CIDR block
    while read -r line; do
        case $line in
        */*) printf "%s\n",$line >>"${1}_${RELEASE_IPV4_CIDR}.txt" ;; # cidr block
        *-*) ipcalc "$line" >>"${1}_${RELEASE_IPV4_CIDR}.txt" ;;      # ip range
        *) printf "%s\n",$line >>"${1}_${RELEASE_IPV4}.txt" ;;        # normal address
        esac
    done
}

# CAN CONTAIN: addresses
# params: color
output_ipv6_format() {
    cat -s >>"${1}_${RELEASE_IPV6}.txt"
}

main() {
    local cache_dir
    local src_list
    local output_base
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
                        mawk '!seen[$0]++' | # remove duplicate hosts
                        case $format in
                        domain) output_domain_format "$color" ;;
                        ipv4) output_ipv4_format "$color" ;;
                        ipv6) output_ipv6_format "$color" ;;
                        esac
                fi
                # else the download failed and src_list is empty
            done

        for release in "${RELEASES[@]}"; do
            output_base="${color}_${release}"
            list="${output_base}.txt"

            if test -f "$list"; then
                sort -o "$list" -u -S 90% --parallel=4 -T "$cache_dir" "$list"

                if [[ "$color" == 'black' ]]; then
                    if test -f "white_${release}.txt"; then
                        grep -Fxvf "white_${release}.txt" "$list" | sponge "$list"
                    fi

                    tar -czf "${output_base}.tar.gz" "$list"
                    md5sum "${output_base}.tar.gz" >"${output_base}.md5"
                    sha1sum "${output_base}.tar.gz" >"${output_base}.sha1"
                    sha256sum "${output_base}.tar.gz" >"${output_base}.sha256"
                fi
            fi
        done
    done
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main
