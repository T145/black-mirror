#!/usr/bin/env bash
set -euo pipefail

for color in 'white' 'black'; do
  list_domain="build/${color}_domain.txt"
  list_ipv4="build/${color}_ipv4.txt"
  list_ipv4_cidr="build/${color}_ipv4_cidr.txt"
  list_ipv6="build/${color}_ipv6.txt"

  unique_domain_count=$(wc -l <"$list_domain")
  unique_ipv4_count=$(wc -l <"$list_ipv4")
  unique_ipv4_cidr_count=$(wc -l <"$list_ipv4_cidr")
  unique_ipv6_count=$(wc -l <"$list_ipv6")

  add_commas() {
    echo "$1" | sed -e :x -e 's/\([0-9][0-9]*\)\([0-9][0-9][0-9]\)/\1,\2/' -e 'tx'
  }

  domain_count=$(add_commas "$unique_domain_count")
  ipv4_count=$(add_commas "$unique_ipv4_count")
  ipv4_cidr_count=$(add_commas "$unique_ipv4_cidr_count")
  ipv6_count=$(add_commas "$unique_ipv6_count")

  get_filesize() {
    stat -c %s "$1" | numfmt --to=iec
  }

  domain_filesize=$(get_filesize "$list_domain")
  ipv4_filesize=$(get_filesize "$list_ipv4")
  ipv4_cidr_filesize=$(get_filesize "$list_ipv4_cidr")
  ipv6_filesize=$(get_filesize "$list_ipv6")

  # Produces a sed script that replaces TD element contents
  # with the value of a same-named variable.
  # Arguments: variable name list
  make_subst_script() {
    for i; do
      exp="${color}_${i}"
      printf 's/\(<td id="%s">\).*\(<\/td>\)/\\1%s\\2/\n' "${exp//_/-}" "${!i}"
    done
  }

  sed -e "$(make_subst_script domain_count domain_filesize ipv4_count ipv4_filesize ipv4_cidr_count ipv4_cidr_filesize ipv6_count ipv6_filesize)" \
    -i README.md
done
