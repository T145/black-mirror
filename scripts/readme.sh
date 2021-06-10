#!/usr/bin/env bash

set -eu

domain_entries=$(LC_ALL=en_US.UTF-8 printf "%'d" "$(cat black_domain.txt | wc -l)")
domain_size=$(du -h black_domain.txt | gawk -F'\t' '{ print $1 }')

ipv4_entries=$(LC_ALL=en_US.UTF-8 printf "%'d" "$(($(cat black_ipv4.txt | wc -l) - $domain_entries))")
ipv4_size=$(du -h black_ipv4.txt | gawk -F'\t' '{ print $1 }')

ipv6_entries=$(LC_ALL=en_US.UTF-8 printf "%'d" "$(($(cat black_ipv6.txt | wc -l) - $domain_entries))")
ipv6_size=$(du -h black_ipv6.txt | gawk -F'\t' '{ print $1 }')

sed -i \
    -e "s/\(<td id=\"domain-entries\">\).*\(<\/td>\)/<td id=\"domain-entries\">$domain_entries<\/td>/g" \
    -e "s/\(<td id=\"domain-size\">\).*\(<\/td>\)/<td id=\"domain-size\">${domain_size}B<\/td>/g" \
    -e "s/\(<td id=\"ipv4-entries\">\).*\(<\/td>\)/<td id=\"ipv4-entries\">$ipv4_entries<\/td>/g" \
    -e "s/\(<td id=\"ipv4-size\">\).*\(<\/td>\)/<td id=\"ipv4-size\">${ipv4_size}B<\/td>/g" \
    -e "s/\(<td id=\"ipv6-entries\">\).*\(<\/td>\)/<td id=\"ipv6-entries\">$ipv6_entries<\/td>/g" \
    -e "s/\(<td id=\"ipv6-size\">\).*\(<\/td>\)/<td id=\"ipv6-size\">${ipv6_size}B<\/td>/g" ./.github/README.md
# xmlstarlet is probably better to handle this
