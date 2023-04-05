#!/usr/bin/env bash

# params: list, content filter
apply_content_filter() {
    case $2 in
    NONE) cat -s "$1" ;;
    7Z) 7za -y -so e "$1" ;;
    ZIP) zcat "$1" ;;
    SQUIDGUARD) tar -xOzf "$1" --wildcards-match-slash --wildcards '*/domains' ;;
    esac
}

get_domains_from_urls() {
    perl -M'Data::Validate::Domain qw(is_domain)' -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?"}{-keep}/g) {say $3 if is_domain($3)}'
}

get_ipv4s_from_urls() {
    perl -M'Data::Validate::IP qw(is_ipv4)' -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?"}{-keep}/g) {say $3 if is_ipv4($3)}'
}

# params: content type, format filter
# REQUIRED OUTPUT: Unverified hosts applicable to the designated format (no empty lines)
apply_format_filter() {
    case $1 in
    TEXT)
        case $2 in
        NONE) cat -s ;;
        RAW_HOSTS_WITH_COMMENTS) mawk '/^[^[:space:]|^#|^!]/{print $1}' ;;
        HOSTS_FILE) ghosts -m /dev/fd/0 -o -p -noheader -stats=false ;;
        ABUSE_CH_URLHAUS_DOMAIN) get_domains_from_urls ;;
        ABUSE_CH_URLHAUS_IPV4) get_ipv4s_from_urls ;;
        esac
        ;;
    JSON)
        case $2 in
        ABUSE_CH_FEODOTRACKER_IPV4) jq -r '.[].ip_address' ;;
        ABUSE_CH_FEODOTRACKER_DOMAIN) jq -r '.[] | select(.hostname != null) | .hostname' ;;
        ABUSE_CH_THREATFOX_IPV4) jq -r 'to_entries[].value[].ioc_value | split(":")[0]' ;;
        ABUSE_CH_THREATFOX_DOMAIN) jq -r 'to_entries[].value[].ioc_value' ;;
        esac
        ;;
    CSV)
        case $2 in
        MLR_CUT_1) mlr --mmap --csv --skip-comments -N cut -f 1 ;;
        MLR_CUT_2) mlr --mmap --csv --skip-comments -N cut -f 2 ;;
        MLR_CUT_3) mlr --mmap --csv --skip-comments -N cut -f 3 ;;
        MLR_CUT_4) mlr --mmap --csv --skip-comments -N cut -f 4 ;;
        esac
        ;;
    esac | # filter blank lines and duplicates
        mawk 'NF && !seen[$0]++'
}

# params: list format, method, key
validate_cidr() {
    # https://metacpan.org/pod/Net::CIDR#$ip=Net::CIDR::cidrvalidate($ip);
    perl -MNet::CIDR=cidrvalidate -nE 'chomp($_); if(defined($_) && index($_, "/") != -1 && cidrvalidate($_)) {say $_;}' |
        ipinfo prips |
        validate_output "$1" "$2" "$3"
}

# params: list format, method, key
validate_output() {
    case $1 in
    DOMAIN)
        perl ./scripts/v1/process_domains.pl 2>/dev/null
            >>"build/${2}_${1}.txt"
        ;;
    IPV4)
        perl -MData::Validate::IP -nE 'chomp($_); if(defined($_) && is_ipv4($_) && !is_unroutable_ipv4($_) && !is_private_ipv4($_) && !is_loopback_ipv4($_) && !is_linklocal_ipv4($_) && !is_testnet_ipv4($_)) {say $_;}'
            >>"build/${2}_${1}.txt"
        ;;
    IPV6)
        perl -MData::Validate::IP -nE 'chomp($_); if(defined($_) && is_ipv6($_)) {say $_;}'
            >>"build/${2}_${1}.txt"
        ;;
    CIDR4) validate_cidr 'IPV4' "$2" "$3" ;;
    CIDR6) validate_cidr 'IPV6' "$2" "$3" ;;
    *)
        echo "[ERROR] Invalid ${1} format from ${3}!"
        exit 1
        ;;
    esac
}

main() {
    local LIST
    local KEY
    local CONTENT_FILTER
    local CONTENT_TYPE
    local METHOD
    local LIST_FILTER
    local LIST_FORMAT

    LIST="$1"
    KEY="$2"
    CONTENT_FILTER="$3"
    CONTENT_TYPE="$4"
    METHOD="$5"
    LIST_FILTER="$6"
    LIST_FORMAT="$7"

    readonly LIST KEY CONTENT_FILTER METHOD LIST_FILTER LIST_FORMAT

    #echo "[INFO] Operating on ${LIST} with ${LIST_FORMAT} content with the ${CONTENT_FILTER} filter."

    apply_content_filter "$LIST" "$CONTENT_FILTER" |
        apply_format_filter "$CONTENT_TYPE" "$LIST_FILTER" |
        validate_output "$LIST_FORMAT" "$METHOD" "$KEY"
}

main "$1" "$2" "$3" "$4" "$5" "$6" "$7"
