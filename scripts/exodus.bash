#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

# edge cases:
# "mns\..*\.aliyuncs\.com" (currently being ignored)
# "mst[0-9]*.is.autonavi.com" / "mt[0-9]*.google.cn" (currently being ignored)
# has a lot of improper domains:
# (.code_signature | split("|")[] | rtrimstr(".") | split(".") | reverse | join("."))
curl -s 'https://etip.exodus-privacy.eu.org/trackers/export' |
    jq -r '.trackers[] |
          (.network_signature | split ("|")[] | gsub("\\\\"; "") | ltrimstr(".*"))
        , (.website | split("/")[2])
      | ltrimstr(".")
    ' |
    gawk '{
        switch ($1) {
        case /^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/:
            print tolower($1) > "exodus_domains.txt"
            break
        case /^([0-9]{1,3}\.){3}[0-9]{1,3}+(\/|:|$)/:
            sub(/:.*/, "", $1)
            print $1 > "exodus_ips.txt"
            break
        }
    }'

for list in 'exodus_domains.txt' 'exodus_ips.txt'; do
    sort -o "$list" -u -S 90% --parallel=4 "$list"
done

# TODO: Verify and record live sources
