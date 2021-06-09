#!/usr/bin/env bash

set -eu

domain_entries=$(cat black_domain.txt | wc -l)
domain_size=$(du -h black_domain.txt | gawk -F'\t' '{ print $1 }')

ipv4_entries=$(($(cat black_ipv4.txt | wc -l) - $domain_entries))
ipv4_size=$(du -h black_ipv4.txt | gawk -F'\t' '{ print $1 }')

ipv6_entries=$(($(cat black_ipv6.txt | wc -l) - $domain_entries))
ipv6_size=$(du -h black_ipv6.txt | gawk -F'\t' '{ print $1 }')

sed -e "s/__DOMAIN_ENTRIES/$domain_entries/g" -e "s/__DOMAIN_SIZE/$domain_size/g" \
    -e "s/__IPV4_ENTRIES/$ipv4_entries/g" -e "s/__IPV4_SIZE/$ipv4_size/g" \
    -e "s/__IPV6_ENTRIES/$ipv6_entries/g" -e "s/__IPV6_SIZE/$ipv6_size/g" ./.github/README.R > ./.github/README.md
