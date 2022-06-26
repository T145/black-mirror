#!/usr/bin/env bash

main() {
  local LIST
  local KEY
  local METHOD
  local FILTER
  local FORMAT
  local CONTENT_TYPE
  local CACHE

  LIST="$1"
  KEY="$2"
  METHOD="$3"
  FILTER="$4"
  FORMAT="$5"
  CONTENT_TYPE="$6"
  CACHE="$7"

  readonly LIST KEY METHOD FILTER FORMAT CONTENT_TYPE CACHE

  echo "[INFO] Operating on: ${LIST}"

  cat -s "$LIST" |
    case "$CONTENT_TYPE" in
    TEXT)
      case "$FILTER" in
      NONE) cat -s ;;
      esac
      ;;
    JSON)
      case "$FILTER" in
      esac
      ;;
    CSV)
      case "$FILTER" in
      esac
      ;;
    esac | mawk 'NF && !seen[$0]++'
  >>"build/${METHOD,,}_${FORMAT,,}.txt"
}

main "$1" "$2" "$3" "$4" "$5" "$6" "$7"
