#!/usr/bin/env bash

set -e

# function to check dependencies
install_if_not_exist() {
  if dpkg -s $1 &>/dev/null; then
    PKG_EXIST=$(dpkg -s $1 | grep "install ok installed")
    if [ -z "$PKG_EXIST" ]; then
      sudo apt-get install $1 --assume-yes
    fi
  else
    sudo apt-get install $1 --assume-yes
  fi
}

# https://github.com/actions/virtual-environments/blob/main/images/linux/Ubuntu2004-README.md
install_if_not_exist coreutils
install_if_not_exist gawk
install_if_not_exist jq
install_if_not_exist sed
