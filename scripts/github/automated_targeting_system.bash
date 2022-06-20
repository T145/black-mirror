#!/usr/bin/env bash

#shopt -s extdebug     # or --debugging
set +H +o history     # disable history features (helps avoid errors from "!" in strings)
shopt -u cmdhist      # would be enabled and have no effect otherwise
shopt -s execfail     # ensure interactive and non-interactive runtime are similar
shopt -s extglob      # enable extended pattern matching (https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
set -euET -o pipefail # put bash into strict mode & have it give descriptive errors
umask 055             # change all generated file perms from 755 to 700
export LC_ALL=C       # force byte-wise sorting and default langauge output

CACHE=$(mktemp -d)
readonly CACHE

trap 'rm -rf "$CACHE"' EXIT || exit 1

apply_filter() {
  case "$1" in
  OISD)
    xmllint --html --xpath '//html//body//main//a/text()' - 2>/dev/null |
      mawk '$0~/^http/{gsub("&amp;","&", $0); print $0}'
    ;;
  1HOSTS) mawk '$0~/^[^#]/' ;;
  STEVENBLACK) jq -r 'to_entries[] | .value.sourcesdata[].url' ;;
  ENERGIZED) jq -r '.sources[].url' ;;
  SHERIFF53) jq -r '.[] | "\(.url[])", "\(select(.mirror) | .mirror[])"' ;;
  DNSFORFAMILY) mawk '$0~/^[^#]/{split($2,a,"\|\|\|\|\|"); print a[1]}' ;;
  *)
    echo "[INVALID FILTER]: ${1}"
    exit 1
    ;;
  esac |
    mawk 'NF && !seen[$0]++' | # filter blank lines and duplicates
    httpx -r configs/resolvers.txt -silent -t 200000 |
    parsort -u -S 100% --parallel=100000 -T "$CACHE" |
    grep -Fxvf exports/sources.txt -
}

main() {
  git config --global --add safe.directory /__w/black-mirror/black-mirror
  mkdir -p target/

  jq -r 'to_entries[] | (.value.mirror), " out=\(.key).txt"' data/v2/targets.json |
    (set +e && aria2c -i- -d "$CACHE" --conf-path='./configs/aria2.conf' && set -e) || set -e

  local list

  jq -r 'to_entries[] | "\(.key)#\(.value.content.filter)"' data/v2/targets.json |
    while IFS='#' read -r key filter; do
      list="${CACHE}/${key}.txt"

      if [ -n "$list" ]; then
        cat "$list" | apply_filter "$filter" >"target/${key}.txt"
      fi
    done
}

main

# reset the locale after processing
unset LC_ALL
