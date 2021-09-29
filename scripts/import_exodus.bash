#!/usr/bin/env bash
set -euo pipefail # put bash into strict mode
umask 055         # change all generated file perms from 755 to 700

# edge cases:
# "mns\..*\.aliyuncs\.com" (currently being ignored)
# "mst[0-9]*.is.autonavi.com" / "mt[0-9]*.google.cn" (currently being ignored)

# these sections currently have invalid domains:
# (.network_signature | split ("|")[] | gsub("\\\\"; "") | ltrimstr(".*")),
# (.code_signature | split("|")[] | rtrimstr(".") | split(".") | reverse | join(".")),

# https://etip.exodus-privacy.eu.org/trackers/export
curl -s 'https://reports.exodus-privacy.eu.org/api/trackers' |
    jq -r '.trackers[] |
          (.website | split("/")[2])
      | ltrimstr(".")
    ' |
    gawk '{
        switch ($1) {
        case /^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/:
            print tolower($1) > "exports/exodus_domains.txt"
            break
        case /^([0-9]{1,3}\.){3}[0-9]{1,3}+(\/|:|$)/:
            sub(/:.*/, "", $1)
            print $1 > "exports/exodus_ips.txt"
            break
        }
    }'

for list in 'exports/exodus_domains.txt' 'exports/exodus_ips.txt'; do
    sort -o "$list" -u -S 90% --parallel=4 "$list"
done

# TODO: Verify and record live sources
