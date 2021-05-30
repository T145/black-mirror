#!/usr/bin/env bash

set -e

install_if_not_exist() {
  if dpkg -s $1 &>/dev/null; then
    PKG_EXIST=$(dpkg -s $1 | grep "install ok installed")
    if [ -z "$PKG_EXIST" ]; then
      sudo apt install $1 -y
    fi
  else
    sudo apt install $1 -y
  fi
}

# https://github.com/actions/virtual-environments/blob/main/images/linux/Ubuntu2004-README.md
install_if_not_exist aria2c
install_if_not_exist coreutils
install_if_not_exist gawk
install_if_not_exist jq
install_if_not_exist sed
