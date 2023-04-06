#!/usr/bin/env bash

get_domains_from_urls() {
    perl -M'Data::Validate::Domain qw(is_domain)' -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?"}{-keep}/g) {say $3 if is_domain($3)}' 2>/dev/null
}

get_ipv4s_from_urls() {
    perl -M'Data::Validate::IP qw(is_ipv4)' -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?"}{-keep}/g) {say $3 if is_ipv4($3)}' 2>/dev/null
}

main() {
    local FILE_PATH
    local LIST_NAME
    local LIST_METHOD
    local CONTENT_FILTER
    local CONTENT_TYPE
    local LIST_FILTER
    local LIST_FORMAT

    FILE_PATH="$1"
    LIST_METHOD="$2"
    CONTENT_FILTER="$3"
    CONTENT_TYPE="$4"
    LIST_FILTER="$5"
    LIST_FORMAT="$6"

    case "$CONTENT_FILTER" in
    'NONE') cat -s "$FILE_PATH" ;;
    '7Z') 7za -y -so e "$FILE_PATH" ;;
    'ZIP') zcat "$FILE_PATH" ;;
    'SQUIDGUARD') tar -xOzf "$FILE_PATH" --wildcards-match-slash --wildcards '*/domains' ;;
    esac |
        case "$CONTENT_TYPE" in
        'TEXT')
            case "$LIST_FILTER" in
            'NONE') cat -s ;;
            'RAW_HOSTS_WITH_COMMENTS') mawk '/^[^[:space:]|^#|^!]/{print $1}' ;;
            'HOSTS_FILE') ghosts -m /dev/stdin -o -p -noheader -stats=false ;;
            'ABUSE_CH_URLHAUS_DOMAIN') get_domains_from_urls ;;
            'ABUSE_CH_URLHAUS_IPV4') get_ipv4s_from_urls ;;
            esac
            ;;
        'JSON')
            case "$LIST_FILTER" in
            'ABUSE_CH_FEODOTRACKER_IPV4') jq -r '.[].ip_address' ;;
            'ABUSE_CH_FEODOTRACKER_DOMAIN') jq -r '.[] | select(.hostname != null) | .hostname' ;;
            'ABUSE_CH_THREATFOX_IPV4') jq -r 'to_entries[].value[].ioc_value | split(":")[0]' ;;
            'ABUSE_CH_THREATFOX_DOMAIN') jq -r 'to_entries[].value[].ioc_value' ;;
            esac
            ;;
        'CSV')
            case "$LIST_FILTER" in
            'MLR_CUT_1') GODEBUG=gctrace=1 mlr --csv --skip-comments -N clean-whitespace then cut -f 1 ;;
            'MLR_CUT_2') GODEBUG=gctrace=1 mlr --csv --skip-comments -N clean-whitespace then cut -f 2 ;;
            'MLR_CUT_3') GODEBUG=gctrace=1 mlr --csv --skip-comments -N clean-whitespace then cut -f 3 ;;
            'MLR_CUT_4') GODEBUG=gctrace=1 mlr --csv --skip-comments -N clean-whitespace then cut -f 4 ;;
            esac
            ;;
        esac | mawk 'NF && !seen[$0]++' |
            case "$LIST_FORMAT" in
            'DOMAIN')
                perl ./scripts/v1/process_domains.pl 2>/dev/null
                ;;
            'IPV4')
                perl -M'Data::Validate::IP' -nE 'chomp($_); if(defined($_) && is_ipv4($_) && !is_unroutable_ipv4($_) && !is_private_ipv4($_) && !is_loopback_ipv4($_) && !is_linklocal_ipv4($_) && !is_testnet_ipv4($_)) {say $_;}' 2>/dev/null
                ;;
            'IPV6')
                perl -M'Data::Validate::IP' -nE 'chomp($_); if(defined($_) && is_ipv6($_)) {say $_;}' 2>/dev/null
                ;;
            esac >>"build/${LIST_METHOD}_${LIST_FORMAT}.txt"
}

main "$1" "$2" "$3" "$4" "$5" "$6"
