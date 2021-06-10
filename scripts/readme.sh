#!/usr/bin/env bash

set -eu

domain_entries=$(LC_ALL=en_US.UTF-8 gawk num="$(cat black_domain.txt | wc -l)" -f ./scripts/thousands.awk)
domain_size=$(du -h black_domain.txt | gawk -F'\t' '{ print $1 }')

ipv4_entries=$(LC_ALL=en_US.UTF-8 gawk num="$(($(cat black_ipv4.txt | wc -l) - $domain_entries))" -f ./scripts/thousands.awk)
ipv4_size=$(du -h black_ipv4.txt | gawk -F'\t' '{ print $1 }')

ipv6_entries=$(LC_ALL=en_US.UTF-8 gawk num="$(($(cat black_ipv6.txt | wc -l) - $domain_entries))" -f ./scripts/thousands.awk)
ipv6_size=$(du -h black_ipv6.txt | gawk -F'\t' '{ print $1 }')

sed -e "s/__DOMAIN_ENTRIES/$domain_entries/g" -e "s/__DOMAIN_SIZE/${domain_size}B/g" \
    -e "s/__IPV4_ENTRIES/$ipv4_entries/g" -e "s/__IPV4_SIZE/${ipv4_size}B/g" \
    -e "s/__IPV6_ENTRIES/$ipv6_entries/g" -e "s/__IPV6_SIZE/${ipv6_size}B/g" ./.github/README.md >|./.github/README.md
