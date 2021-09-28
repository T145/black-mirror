#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

rsync -avz rsync-mirrors.uceprotect.net::RBLDNSD-ALL "${PWD}/"
#rsync -azv rsync-mirrors.uceprotect.net::RBLDNSD-ALL/ips.whitelisted.org "${PWD}/"
