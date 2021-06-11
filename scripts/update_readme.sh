#!/usr/bin/env bash
set -euo pipefail

export LANG=en_US.UTF-8
export LANGUAGE=en:el

unique_domain_count=$(cat black_domain.txt | wc -l)
unique_ipv4_count=$(($(cat black_ipv4.txt | wc -l) - unique_domain_count))
unique_ipv6_count=$(($(cat black_ipv6.txt | wc -l) - unique_domain_count))

domain_count=$(printf "%'d" "$unique_domain_count")
ipv4_count=$(printf "%'d" "$unique_ipv4_count")
ipv6_count=$(printf "%'d" "$unique_ipv6_count")

get_filesize() {
    echo du -h "$1" | gawk -F'\t' '{ print $1 }'
}

domain_filesize=$(get_filesize black_domain.txt)
ipv4_filesize=$(get_filesize black_ipv4.txt)
ipv6_filesize=$(get_filesize black_ipv6.txt)

sed -i \
    -e "s/\(<td id=\"domain-count\">\).*\(<\/td>\)/<td id=\"domain-count\">$domain_count<\/td>/g" \
    -e "s/\(<td id=\"domain-filesize\">\).*\(<\/td>\)/<td id=\"domain-filesize\">${domain_filesize}B<\/td>/g" \
    -e "s/\(<td id=\"ipv4-count\">\).*\(<\/td>\)/<td id=\"ipv4-count\">$ipv4_count<\/td>/g" \
    -e "s/\(<td id=\"ipv4-filesize\">\).*\(<\/td>\)/<td id=\"ipv4-filesize\">${ipv4_filesize}B<\/td>/g" \
    -e "s/\(<td id=\"ipv6-count\">\).*\(<\/td>\)/<td id=\"ipv6-count\">$ipv6_count<\/td>/g" \
    -e "s/\(<td id=\"ipv6-filesize\">\).*\(<\/td>\)/<td id=\"ipv6-filesize\">${ipv6_filesize}B<\/td>/g" ./.github/README.md
# xmlstarlet is probably better to handle this
