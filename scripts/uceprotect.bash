#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

#rsync -avz rsync-mirrors.uceprotect.net::RBLDNSD-ALL "${PWD}/"

# use these:
# http://wget-mirrors.uceprotect.net/rbldnsd-all/dnsbl-1.uceprotect.net.gz
# http://wget-mirrors.uceprotect.net/rbldnsd-all/dnsbl-2.uceprotect.net.gz
# http://wget-mirrors.uceprotect.net/rbldnsd-all/dnsbl-3.uceprotect.net.gz
# http://wget-mirrors.uceprotect.net/rbldnsd-all/ips.backscatterer.org.gz
