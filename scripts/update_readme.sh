#!/usr/bin/env bash
set -euo pipefail

export LANG=en_US.UTF-8
export LANGUAGE=en:el

unique_domain_count=$(wc -l <black_domain.txt)
unique_ipv4_count=$(($(wc -l <black_ipv4.txt) - unique_domain_count))
unique_ipv6_count=$(($(wc -l <black_ipv6.txt) - unique_domain_count))

domain_count=$(printf "%'d" "$unique_domain_count")
ipv4_count=$(printf "%'d" "$unique_ipv4_count")
ipv6_count=$(printf "%'d" "$unique_ipv6_count")

get_filesize() {
    stat -c %s "$1" | numfmt --to=iec
}

domain_filesize=$(get_filesize black_domain.txt)
ipv4_filesize=$(get_filesize black_ipv4.txt)
ipv6_filesize=$(get_filesize black_ipv6.txt)

# Produces a sed script that replaces TD element contents
# with the value of a same-named variable.
# Arguments: variable name list
make_subst_script() {
    for i; do
        printf 's/\(<td id="%s">\).*\(<\/td>\)/\\1%s\\2/\n' "$i" "${!i//_/-}"
    done
}

sed -e "$(make_subst_script domain_count domain_filesize ipv4_count ipv4_filesize ipv6_count ipv6_filesize)" \
    -i .github/README.md
