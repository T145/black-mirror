#!/usr/bin/env bash
set -euo pipefail

install_if_not_exist() {
  if dpkg -s "$1" &>/dev/null; then
    PKG_EXIST=$(dpkg -s "$1" | grep "install ok installed")
    if [[ -n "$PKG_EXIST" ]]; then
      return
    fi
  fi
  sudo apt install "$1" -y
}

sudo apt update -y

for dep in aria2 coreutils gawk jq moreutils sed; do
  install_if_not_exist $dep
done
