#!/usr/bin/env bash

CONTENT_TYPE=$1
FORMAT_FILTER=$2
FORMAT=$3
METHOD=$4
LIST=$5
CACHE=$6
readonly CONTENT_TYPE FORMAT_FILTER FORMAT METHOD LIST CACHE

#case "$CONTENT_FILTER" in
#    NONE) cat -s "$LIST" ;;
#    7Z) 7za -y -so e "$LIST" ;;
#    ZIP) zcat "$LIST" ;;
#    SQUIDGUARD) tar -xOzf "$LIST" --wildcards-match-slash --wildcards '*/domains' ;;
#esac |

# content filters will be applied to lists as soon as they're downloaded
# this way multiple extract operations per format will not be necessary

cat -s "$LIST" |
    case "$CONTENT_TYPE" in
        TEXT)
            case "$FORMAT_FILTER" in
                NONE) cat -s ;;
                MAWK_WITH_COMMENTS_FIRST_COLUMN) mawk '$0~/^[^#]/{print $1}' ;;
                MAWK_WITH_COMMENTS_SECOND_COLUMN) mawk '$0~/^[^#]/{print $2}' ;;
                ADGUARD)
                    # https://kb.adguard.com/en/general/dns-filtering-syntax
                    # https://kb.adguard.com/en/general/how-to-create-your-own-ad-filters#examples-1
                    mawk -F"[|^]" '$0~/^\|/{if ($4~/^$/) {print $3}}'
                    ;;
                HOSTS_FILE) ghosts -m -o -p -noheader -stats=false ;;
                ALIENVAULT) mawk -F# '{print $1}' ;;
            esac
        ;;
        JSON)
            case "$FORMAT_FILTER" in
                FEODO_DOMAIN) jq -r '.[] | select(.hostname != null) | .hostname' ;;
                FEODO_IPV4) jq -r '.[].ip_address' ;;
                THREATFOX_DOMAIN) jq -r '.[] | .[] | select(.ioc_type == "domain") | .ioc_value' ;;
                THREATFOX_IPV4) jq -r '.[] | .[] | select(.ioc_type == "ip:port") | .ioc_value | split(":")[0]' ;;
                AYASHIGE) jq -r '.[].fqdn' ;;
            esac
        ;;
        CSV)
            case "$FORMAT_FILTER" in
                NO_HEADER_SECOND_COLUMN) mlr --mmap --csv --skip-comments -N cut -f 2 ;;
                URLHAUS_DOMAIN) mlr --mmap --csv --skip-comments -N put -S '$3 =~ "https?://([a-z][^/|^:]+)"; $Domain = "\1"' then cut -f Domain then uniq -a ;;
                URLHAUS_IPV4) mlr --mmap --csv --skip-comments -N put -S '$3 =~ "https?://([0-9][^/|^:]+)"; $IP = "\1"' then cut -f IP then uniq -a ;;
            esac
        ;;
    esac >> "build/${FORMAT,,}_${METHOD,,}.txt"
