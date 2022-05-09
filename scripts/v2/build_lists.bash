#!/usr/bin/env bash

#shopt -s extdebug     # or --debugging
set +H +o history     # disable history features (helps avoid errors from "!" in strings)
shopt -u cmdhist      # would be enabled and have no effect otherwise
shopt -s execfail     # ensure interactive and non-interactive runtime are similar
shopt -s extglob      # enable extended pattern matching (https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
set -euET -o pipefail # put bash into strict mode & have it give descriptive errors
umask 055             # change all generated file perms from 755 to 700
export LC_ALL=C       # force byte-wise sorting and default langauge output

DOWNLOADS=$(mktemp -d)
METHOD_ALLOW='ALLOW'
METHOD_BLOCK='BLOCK'
FORMAT_DOMAIN='DOMAIN'
FORMAT_IPV4='IPV4'
FORMAT_CIDR='CIDR'
FORMAT_IPV6='IPV6'
readonly DOWNLOADS METHOD_ALLOW METHOD_BLOCK FORMAT_DOMAIN FORMAT_IPV4 FORMAT_CIDR FORMAT_IPV6

METHODS=("$METHOD_ALLOW" "$METHOD_BLOCK")
FORMATS=("$FORMAT_DOMAIN" "$FORMAT_IPV4" "$FORMAT_CIDR" "$FORMAT_IPV6")
readonly -a METHODS
readonly -a FORMATS

trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

# params: method
generate_aria_downloads() {
    jq -r --arg method "$1" 'to_entries[] |
        select(.value.method == $method) |
        {key, mirrors: .value.mirrors} |
        .ext = (.mirrors[0] | match(".(tar.gz|zip|7z|json)").captures[0].string // "txt") |
        (.mirrors | join("\t")), " out=\(.key).\(.ext)"' data/v2/lists.json
}

# params: method, cache
download_lists() {
    # 'set +e' temporarily disables strict fail in case downloads fail: the OR clause is to ensure it's enabled after processing.
    generate_aria_downloads "$1" | (set +e && aria2c -i- -d "$2" --conf-path='./configs/aria2.conf' && set -e) || set -e
}

main() {
    local cache

    mkdir -p build/

    for method in "${METHODS[@]}"; do
        cache="${DOWNLOADS}/${method}"

        download_lists "$method" "$cache"

        find -P -O3 "$cache" -type f -exec sem -j+0 ./scripts/v2/apply_filters.bash {} "$DOWNLOADS" \;
        sem --wait
    done
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main

# reset the locale after processing
unset LC_ALL
