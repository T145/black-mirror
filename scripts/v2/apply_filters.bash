#!/usr/bin/env bash

main() {
    local LIST
    local CACHE

    LIST="$1"
    CACHE="$2"

    readonly LIST CACHE

    echo "[INFO] Operating on: ${LIST}"
}

main "$1" "$2"
