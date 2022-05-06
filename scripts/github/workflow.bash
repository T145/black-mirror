#!/usr/bin/env bash
set -euo pipefail

# Handles everything involved in GitHub CI processing
main() {
    :> logs/aria2.log
    ./scripts/v1/build_release.bash
    find -P -O3 ./build/ -type f -name "*.txt" -exec bash ./scripts/github/update_readme_tag.bash {} \;
}

main
