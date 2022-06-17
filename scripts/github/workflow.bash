#!/usr/bin/env bash

# Handles everything involved in GitHub CI processing
main() {
    local result

    git config --global --add safe.directory /__w/black-mirror/black-mirror
    : >logs/aria2.log

    ./scripts/v1/build_release.bash
    [[ "$?" = 0 ]] && result='success' || result='failure'

    if [[ "$result" == 'success' ]]; then
        find -P -O3 ./build/ -type f -name "*.txt" -exec ./scripts/github/update_readme_tag.bash {} \;
    else
        echo "$@" >&2
        exit 1
    fi

    # https://docs.github.com/en/actions/creating-actions/metadata-syntax-for-github-actions#outputs-for-composite-actions=
    # https://help.github.com/en/articles/development-tools-for-github-actions#set-an-output-parameter-set-output
    echo "::set-output name=status::${result}"
}

main
