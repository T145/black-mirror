#!/usr/bin/env bash

# params: list, content filter
apply_content_filter() {
  case $2 in
  NONE) cat -s "$1" ;;
  7Z) 7za -y -so e "$1" ;;
  ZIP) zcat "$1" ;;
  SQUIDGUARD) tar -xOzf "$1" --wildcards-match-slash --wildcards '*/domains' ;;
  esac
}

# params: content type, filter
apply_filter() {
  case $1 in
  TEXT)
    case $2 in
    NONE) cat -s ;;
    esac
    ;;
  JSON)
    case $2 in
    esac
    ;;
  CSV)
    case $2 in
    esac
    ;;
  esac |
    mawk 'NF && !seen[$0]++'
}

# params: format, method, key
validate_output() {
  case $1 in
  DOMAIN) perl ./scripts/v1/process_domains.pl 2>/dev/null ;;
  IPV4) ;;
  IPV6) ;;
  CIDR) validate_output 'IPV4' "$2" "$3" ;;
  *)
    echo "[INVALID FORMAT] { source: ${3}, format: ${1} }"
    exit 1
    ;;
  esac >>"build/${METHOD}_${FORMAT}.txt"
}

main() {
  local LIST
  local KEY
  local CONTENT_FILTER
  local CONTENT_TYPE
  local METHOD
  local LIST_FILTER
  local CACHE

  LIST="$1"
  KEY="$2"
  CONTENT_FILTER="$3"
  CONTENT_TYPE="$4"
  METHOD="$5"
  LIST_FILTER="$6"
  CACHE="$7"

  readonly LIST KEY CONTENT_FILTER METHOD LIST_FILTER CACHE

  echo "[INFO] Operating on: ${LIST}"

  apply_content_filter "$LIST" "$CONTENT_FILTER" |
    apply_filter "$CONTENT_TYPE" "$FILTER" |
    validate_output "$FORMAT" "$METHOD" "$KEY"
}

main "$1" "$2" "$3" "$4" "$5" "$6" "$7"
