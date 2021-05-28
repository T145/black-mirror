#!/bin/sh

set -e

curl -s -H 'Accept: application/vnd.github.v3+json' \
    https://api.github.com/repos/T145/the_blacklist/contents/hosts |
    jq -r '.[] | [.download_url] | @tsv' |
    while IFS=$'\t' read -r url; do
        curl -s $url
    done >|the_blacklist.txt
