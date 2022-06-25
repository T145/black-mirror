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

METHODS=("$METHOD_BLOCK" "$METHOD_ALLOW")
FORMATS=("$FORMAT_DOMAIN" "$FORMAT_IPV4" "$FORMAT_CIDR" "$FORMAT_IPV6")
readonly -a METHODS
readonly -a FORMATS

trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1

main() {
  local cache

  mkdir -p build/

  for method in "${METHODS[@]}"; do
    cache="${DOWNLOADS}/${method}"

    jq -r --arg method "$method" 'to_entries[] |
      select(.value.method == $method) |
      {key, mirrors: .value.mirrors} |
      .ext = (.mirrors[0] | match(".(tar.gz|zip|7z|json)").captures[0].string // "txt") |
      (.mirrors | join("\t")), " out=\(.key).\(.ext)"' data/v2/lists.json |
      (set +e && aria2c -i- -d "$cache" --conf-path='./configs/aria2.conf' && set -e) || set -e

    jq -r --arg method "$method" 'to_entries[] |
      select(.value.method == $method) | .key as $k | .value.formats[] |
      "\($k)#\(.filter)#\(.format)#\(.content.type)"' data/v2/lists.json |
    while IFS='#' read -r key filter format content_type; do
      find -P -O3 "$cache" -type f -exec sem -j+0 ./scripts/v2/apply_filters.bash {} "$key" "$method" "$filter" "$format" "$content_type" "$DOWNLOADS" \;
      sem --wait
      # else the download failed and src_list is empty
    done
  done
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main

# reset the locale after processing
unset LC_ALL
