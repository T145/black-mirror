#!/usr/bin/env bash

get_ipv4s() {
    ipinfo grepip -4hox --nocolor
}

get_ipv6s() {
    ipinfo grepip -6hox --nocolor
}

get_domains_from_urls() {
    perl -M'Data::Validate::Domain qw(is_domain)' -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?"}{-keep}/g) {say $3 if is_domain($3)}' 2>/dev/null
}

get_ipv4s_from_urls() {
    perl -M'Data::Validate::IP qw(is_ipv4)' -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?"}{-keep}/g) {say $3 if is_ipv4($3)}' 2>/dev/null
}

# params: column number
mlr_cut_col() {
    mlr --csv --skip-comments -N clean-whitespace then cut -f "$1"
}

# params: list format, method, key
validate_cidr() {
    # https://metacpan.org/pod/Net::CIDR#$ip=Net::CIDR::cidrvalidate($ip);
    perl -MNet::CIDR=cidrvalidate -nE 'chomp($_); if(defined($_) && index($_, "/") != -1 && cidrvalidate($_)) {say $_;}' |
        ipinfo prips
}

main() {
    local FILE_PATH
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
    'GZIP') tar -xOzf "$FILE_PATH" ;;
    'SQUIDGUARD') tar -xOzf "$FILE_PATH" --wildcards-match-slash --wildcards '*/domains' ;;
    'SCAFROGLIA') unzip -p "$FILE_PATH" blocklists-master/*.txt ;;
    esac |
        case "$CONTENT_TYPE" in
        'TEXT')
            case "$LIST_FILTER" in
            'NONE') cat -s ;;
            'RAW_HOSTS_WITH_COMMENTS') mawk '/^[^[:space:]|^#|^!|^;]/{print $1}' ;;
            'HOSTS_FILE') hosts-bl -f fqdn -compression 1 /dev/stdin /dev/stdout ;;
            'ABUSE_CH_URLHAUS_DOMAIN') get_domains_from_urls ;;
            'ABUSE_CH_URLHAUS_IPV4') get_ipv4s_from_urls ;;
            'ALIENVAULT') mawk -F# '{print $1}' ;;
            'ADBLOCK') hostsblock | mawk '{print $2}' ;;
            'GREP_IPV4') get_ipv4s ;;
            'GREP_IPV6') get_ipv6s ;;
            'BOTVIRJ_IPV4') mawk -F'|' '{print $1}' ;;
            'CRYPTOLAEMUS_DOMAIN') hxextract code /dev/stdin | head -n -1 | tail -n +6 ;;
            'CRYPTOLAEMUS_IPV4') hxextract code /dev/stdin | head -n -1 | tail -n +6 | get_ipv4s ;;
            'CYBERCRIME_DOMAIN') mawk -F/ '{print $1}' ;;
            'CYBERCRIME_IPV4') mawk -F/ '{split($1,a,":");print a[1]}' | get_ipv4s ;;
            'DATAPLANE_IPV4') mawk -F'|' '$0~/^[^#]/{gsub(/ /,""); print $3}' ;;
            'DSHIELD') mlr --tsv --skip-comments -N put '$cidr = $1 . "/" . $3' then cut -f cidr ;;
            'MYIP_DOMAIN') mawk -F, '$0~/^[^#]/{print $2}' ;;
            'MYIP_IPV4') mawk '$0~/^[^#]/{print $1}' | get_ipv4s ;;
            'MYIP_IPV6') mawk '$0~/^[^#]/{print $1}' | get_ipv6s ;;
            'XFILES') tr -d "[:blank:]" | hostsblock | mawk '{print $2}' ;;
            esac
            ;;
        'JSON')
            case "$LIST_FILTER" in
            'ABUSE_CH_FEODOTRACKER_IPV4') jq -r '.[].ip_address' ;;
            'ABUSE_CH_FEODOTRACKER_DOMAIN') jq -r '.[] | select(.hostname != null) | .hostname' ;;
            'ABUSE_CH_THREATFOX_IPV4') jq -r 'to_entries[].value[].ioc_value | split(":")[0]' ;;
            'ABUSE_CH_THREATFOX_DOMAIN') jq -r 'to_entries[].value[].ioc_value' ;;
            'AYASHIGE') jq -r '.[].fqdn' ;;
            'CYBER_CURE_IPV4') jq -r '.data.ip[]' ;;
            'CYBERSAIYAN_DOMAIN') jq -r '.[] | select(.value.type == "URL") | .indicator' | get_domains_from_urls ;;
            'CYBERSAIYAN_IPV4') jq -r '.[] | select(.value.type == "URL") | .indicator' | get_ipv4s_from_urls ;;
            'DISCONNECTME_ENTITIES') jq -r '.entities[] | "\(.properties[])\n\(.resources[])"' ;;
            'DISCONNECTME_SERVICES') jq -r '.categories[] | to_entries[].value[] | to_entries[].value[]' ;;
            'HIPO_UNIVERSITIES') jq -r '.[].domains | join("\n")' ;;
            'ISCSANS') jq -r '.[].ipv4' ;;
            'MALSILO_DOMAIN') jq -r '.data[].network_traffic | select(.dns != null) | .dns[]' ;;
            'MALSILO_IPV4') jq -r '.data[].network_traffic | select(.tcp != null) | .tcp[] | split(":")[0]' ;;
            'MALTRAIL') jq -r '.[].ip' ;;
            'TINYCHECK_DOMAIN') jq -r '.iocs[] | select(.type == "domain") | .value' ;;
            'TINYCHECK_FREEDNS') jq -r '.iocs[] | select(.type == "freedns") | .value' ;;
            'TINYCHECK_IPV4') jq -r '.iocs[] | select(.type == "ip4addr") | .value' ;;
            'TINYCHECK_CIDR') jq -r '.iocs[] | select(.type == "cidr") | .value' ;;
            esac
            ;;
        'CSV')
            case "$LIST_FILTER" in
            'MLR_CUT_1') mlr_cut_col 1 ;;
            'MLR_CUT_2') mlr_cut_col 2 ;;
            'MLR_CUT_3') mlr_cut_col 3 ;;
            'MLR_CUT_4') mlr_cut_col 4 ;;
            'BENKOW_DOMAIN') mlr --csv --headerless-csv-output --ifs ';' cut -f url | get_domains_from_urls ;;
            'BENKOW_IPV4') mlr --csv --headerless-csv-output --ifs ';' cut -f url | get_ipv4s_from_urls ;;
            'BOTVIRJ_COVID') mawk 'NR>1' ;;
            'CYBER_CURE_DOMAIN_URL') tr ',' '\n' | get_domains_from_urls ;;
            'MALWARE_DISCOVERER_DOMAIN') mlr --csv --headerless-csv-output cut -f domain ;;
            'MALWARE_DISCOVERER_IPV4') mlr --csv --headerless-csv-output cut -f ip ;;
            'PHISHSTATS_DOMAIN') mlr_cut_col 3 | get_domains_from_urls ;;
            'PHISHSTATS_IPV4') mlr_cut_col 4 | get_ipv4s ;;
            'PHISHSTATS_IPV6') mlr_cut_col 4 | get_ipv6s ;;
            'TURRIS') mlr --csv --headerless-csv-output --skip-comments cut -f Address ;;
            'VIRIBACK_DOMAIN') mlr --csv --headerless-csv-output cut -f URL | get_domains_from_urls ;;
            'VIRIBACK_IPV4') mlr --csv --headerless-csv-output cut -f IP ;;
            'SHADOWSERVER_HOST') mlr --csv --headerless-csv-output cut -f http_host ;;
            'SHADOWSERVER_TARGET') mlr --csv --headerless-csv-output cut -f redirect_target ;;
            'SHADOWSERVER_IPV4') mlr --csv --headerless-csv-output cut -f ip ;;
            esac
            ;;
        esac | mawk 'NF && !seen[$0]++' |
        case "$LIST_FORMAT" in
        'DOMAIN')
            perl ./scripts/v2/process_domains.pl 2>/dev/null >>"build/${LIST_METHOD}_${LIST_FORMAT}.txt"
            ;;
        'IPV4')
            perl -M'Data::Validate::IP' -nE 'chomp($_); if(defined($_) && is_ipv4($_) && !is_unroutable_ipv4($_) && !is_private_ipv4($_) && !is_loopback_ipv4($_) && !is_linklocal_ipv4($_) && !is_testnet_ipv4($_)) {say $_;}' 2>/dev/null
                >>"build/${LIST_METHOD}_${LIST_FORMAT}.txt"
            ;;
        'IPV6')
            perl -M'Data::Validate::IP' -nE 'chomp($_); if(defined($_) && is_ipv6($_)) {say $_;}' 2>/dev/null
                >>"build/${LIST_METHOD}_${LIST_FORMAT}.txt"
            ;;
        'CIDR4') validate_cidr >>"build/${LIST_METHOD}_IPV4.txt" ;;
        'CIDR6') validate_cidr >>"build/${LIST_METHOD}_IPV6.txt" ;;
        esac
}

main "$1" "$2" "$3" "$4" "$5" "$6"
