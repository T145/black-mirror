# params: build status, commit hash from the head of the previous release
main() {
    if [[ "$1" == 'success' ]]; then
        local latest_commit

        latest_commit=$(git log -n 1 --pretty=format:%H --)

        echo -n '## ' && date +"%d-%m-%Y %T" && git log --oneline "${2}..${latest_commit}" >> CHANGELOG.md
    fi

    rm -rf build/
}

main "$1" "$2"
