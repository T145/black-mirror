#!/usr/bin/env bash

main() {
    local result

    result=$(curl --proto '=https' --tlsv1.3 -H 'Accept: application/vnd.github.v3+json' -sSf https://api.github.com/repos/T145/black-mirror/tags | jq -r '.[] | select(.name == "latest") | .commit.sha')

    echo "::set-output name=latest_commit::${result}"
}

main
