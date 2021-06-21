#!/usr/bin/env bash
set -euo pipefail

export LANG=en_US.UTF-8
export LANGUAGE=en:el

unique_dom_count=$(wc -l <black_dom.txt)
unique_ip4_count=$(($(wc -l <black_ip4.txt) - unique_dom_count))
unique_ip6_count=$(($(wc -l <black_ip6.txt) - unique_dom_count))

dom_count=$(printf "%'d" "$unique_dom_count")
ip4_count=$(printf "%'d" "$unique_ip4_count")
ip6_count=$(printf "%'d" "$unique_ip6_count")

get_filesize() {
    stat -c %s "$1" | numfmt --to=iec
}

dom_filesize=$(get_filesize black_dom.txt)
ip4_filesize=$(get_filesize black_ip4.txt)
ip6_filesize=$(get_filesize black_ip6.txt)

# Produces a sed script that replaces TD element contents
# with the value of a same-named variable.
# Arguments: variable name list
make_subst_script() {
    for i; do
        printf 's/\(<td id="%s">\).*\(<\/td>\)/\\1%s\\2/\n' "${i//_/-}" "${!i}"
    done
}

sed -e "$(make_subst_script dom_count dom_filesize ip4_count ip4_filesize ip6_count ip6_filesize)" \
    -i .github/README.md
