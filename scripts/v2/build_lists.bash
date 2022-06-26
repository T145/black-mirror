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
TMP=$(mktemp)
METHOD_ALLOW='ALLOW'
METHOD_BLOCK='BLOCK'
FORMAT_DOMAIN='DOMAIN'
FORMAT_IPV4='IPV4'
FORMAT_CIDR='CIDR'
FORMAT_IPV6='IPV6'
readonly DOWNLOADS TMP METHOD_ALLOW METHOD_BLOCK FORMAT_DOMAIN FORMAT_IPV4 FORMAT_CIDR FORMAT_IPV6

METHODS=("$METHOD_BLOCK" "$METHOD_ALLOW")
FORMATS=("$FORMAT_DOMAIN" "$FORMAT_IPV4" "$FORMAT_CIDR" "$FORMAT_IPV6")
readonly -a METHODS
readonly -a FORMATS

trap 'rm -rf "$DOWNLOADS" && rm -rf "$TMP"' EXIT || exit 1

# params: file path
sorted() {
  parsort -bfiu -S 100% --parallel=200000 -T "$DOWNLOADS" "$1" | sponge "$1"
}

# merge list 2 into list 1
# params: list 1, list 2
merge_lists() {
  cat "$1" "$2" >"$1"
  sorted "$1"
}

main() {
  local cache
  local list
  local nxlist
  local blacklist

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
      done

    for format in "${FORMATS[@]}"; do
      list="build/${method}_${format}.txt"
      nxlist="dist/ALLOW_NX${format}.txt"

      if test -f "$list"; then
        if [[ "$method" == "$METHOD_BLOCK" ]]; then
          if [[ "$format" != "$FORMAT_CIDR" ]]; then

            # if the nxlist is present, then rescan it to see if any hosts are online
            # put any online hosts into the blacklist and remove them from the nxlist
            # rescan the blacklist using the nxlist as a hosts file to optimize searching
            if test -f "$nxlist"; then
              # TODO: Export JSON from dnsX and use jq to pull out domains & ips
              dnsx -r ./configs/resolvers.txt -l "$nxlist" -o "$TMP" -c 200000 -silent -rcode noerror,servfail,refused 1>/dev/null
              merge_lists "$list" "$TMP"
              #comm "$nxlist" "$TMP" -23 | sponge "$nxlist"
              # nxlist should be small enough that parallel isn't needed
              grep -Fxvf "$TMP" "$nxlist" >"$nxlist"
              dnsx -r ./configs/resolvers.txt -hf "$nxlist" -l "$list" -o "$nxlist" -c 200000 -silent -rcode nxdomain 1>/dev/null
              : >"$TMP"
            else
              sorted "$list"
              dnsx -r ./configs/resolvers.txt -l "$list" -o "$nxlist" -c 200000 -silent -rcode nxdomain 1>/dev/null
            fi

            sorted "$nxlist"
          else
            # can also do more advanced CIDR operations here
            sorted "$list"
          fi
        else
          # apply the whitelist to the blacklist
          blacklist="build/BLOCK_${format}.txt"

          # merge the nxlist and whitelist
          merge_lists "$list" "$nxlist"

          # https://askubuntu.com/a/562352
          # this will send each line into the temp file as it's processed instead of keeping it in memory
          mawk 'NF && !seen[$0]++' "$blacklist" | parallel --pipe -k -j+0 grep --line-buffered -Fxvf "$list" - >>"$TMP"
          cp "$TMP" "$blacklist"
          : >"$TMP"
        fi
      fi
    done
  done
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main

# reset the locale after processing
unset LC_ALL
