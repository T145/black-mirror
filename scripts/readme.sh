#!/usr/bin/env bash

export LANG=en_US.UTF-8
export LANGUAGE=en:el

set -eu

domain_linecount=$(cat black_domain.txt | wc -l)
ipv4_linecount=$(($(cat black_ipv4.txt | wc -l)-$domain_linecount))
ipv6_linecount=$(($(cat black_ipv6.txt | wc -l)-$domain_linecount))

domain_entries=$(printf "%'d" $domain_linecount)
domain_size=$(du -h black_domain.txt | gawk -F'\t' '{ print $1 }')

ipv4_entries=$(printf "%'d" $ipv4_linecount)
ipv4_size=$(du -h black_ipv4.txt | gawk -F'\t' '{ print $1 }')

ipv6_entries=$(printf "%'d" $ipv6_linecount)
ipv6_size=$(du -h black_ipv6.txt | gawk -F'\t' '{ print $1 }')

sed -i \
    -e "s/\(<td id=\"domain-entries\">\).*\(<\/td>\)/<td id=\"domain-entries\">$domain_entries<\/td>/g" \
    -e "s/\(<td id=\"domain-size\">\).*\(<\/td>\)/<td id=\"domain-size\">${domain_size}B<\/td>/g" \
    -e "s/\(<td id=\"ipv4-entries\">\).*\(<\/td>\)/<td id=\"ipv4-entries\">$ipv4_entries<\/td>/g" \
    -e "s/\(<td id=\"ipv4-size\">\).*\(<\/td>\)/<td id=\"ipv4-size\">${ipv4_size}B<\/td>/g" \
    -e "s/\(<td id=\"ipv6-entries\">\).*\(<\/td>\)/<td id=\"ipv6-entries\">$ipv6_entries<\/td>/g" \
    -e "s/\(<td id=\"ipv6-size\">\).*\(<\/td>\)/<td id=\"ipv6-size\">${ipv6_size}B<\/td>/g" ./.github/README.md
# xmlstarlet is probably better to handle this
