#!/usr/bin/env bash

CONTENT_TYPE=$1
FORMAT_FILTER=$2
FORMAT=$3
METHOD=$4
LIST=$5
CACHE=$6
readonly CONTENT_TYPE FORMAT_FILTER FORMAT METHOD LIST CACHE

# use 'lynx -dump -listonly -nonumbers' to get a raw page

#case "$CONTENT_FILTER" in
#    NONE) cat -s "$LIST" ;;
#    7Z) 7za -y -so e "$LIST" ;;
#    ZIP) zcat "$LIST" ;;
#    SQUIDGUARD) tar -xOzf "$LIST" --wildcards-match-slash --wildcards '*/domains' ;;
#esac |

# content filters will be applied to lists as soon as they're downloaded
# this way multiple extract operations per format will not be necessary

# TODO: Sort through Spirillen's mess: https://mypdns.org/my-privacy-dns/porn-records

echo "[INFO] Operating on: ${LIST}"

get_domains_from_urls() {
    perl -M'Data::Validate::Domain qw(is_domain)' -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?"}{-keep}/g) {say $3 if is_domain($3)}'
}

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
                URL_REGEX_DOMAIN) get_domains_from_urls ;;
                URL_REGEX_IPV4) ;; # TODO?
                REGEX_IPV4) perl -MRegexp::Common=net -nE 'say $& while /$RE{net}{IPv4}/g' ;;
                REGEX_IPV6) perl -MRegexp::Common=net -nE 'say $& while /$RE{net}{IPv6}/g' ;;
                EASYLIST) ;; # TODO
                BLACKBIRD) mawk 'NR>4' ;; # '$0~/^[^;]/'
                BOTVIRJ_IPV4) mawk -F'|' '{print $1}' ;;
                HOSTS_DENY) mawk '$1~/^ALL$/{print $3}' ;;
                CRYPTOLAEMUS_DOMAIN) perl ./scripts/process_domains.pl ;;
                CERTEGO_DOMAIN) ;; # TODO
                CERTEGO_IPV4) ;; # TODO
                CYBERCRIME_DOMAIN) mawk -F/ '{print $1}' | perl ./scripts/process_domains.pl ;;
                #SCHEMELESS_URL_DOMAIN) gawk -F/ '$1~/^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/{print tolower($1)}' ;;
                #SCHEMELESS_URL_IPV4) gawk -F/ '$1~/^([0-9]{1,3}\.){3}[0-9]{1,3}+(:|$)/{split($1,a,":");print a[1]}' ;;
            esac
        ;;
        JSON)
            case "$FORMAT_FILTER" in
                FEODO_DOMAIN) jq -r '.[] | select(.hostname != null) | .hostname' ;;
                FEODO_IPV4) jq -r '.[].ip_address' ;;
                THREATFOX_DOMAIN) jq -r '.[] | .[] | select(.ioc_type == "domain") | .ioc_value' ;;
                THREATFOX_IPV4) jq -r '.[] | .[] | select(.ioc_type == "ip:port") | .ioc_value | split(":")[0]' ;;
                AYASHIGE) jq -r '.[].fqdn' ;;
                CYBERSAIYAN_DOMAIN) jq -r '.[] | select(.value.type == "domain") | .indicator' ;;
                CYBERSAIYAN_IPV4) jq -r '.[] | select(.value.type == "IPv4") | .indicator' ;;
                CYBER_CURE_IPV4) jq -r '.data.ip[]' ;;
            esac
        ;;
        CSV)
            case "$FORMAT_FILTER" in
                NO_HEADER_SECOND_COLUMN) mlr --mmap --csv --skip-comments -N cut -f 2 ;;
                URLHAUS_DOMAIN) mlr --mmap --csv --skip-comments -N put -S '$3 =~ "https?://([a-z][^/|^:]+)"; $Domain = "\1"' then cut -f Domain then uniq -a ;;
                URLHAUS_IPV4) mlr --mmap --csv --skip-comments -N put -S '$3 =~ "https?://([0-9][^/|^:]+)"; $IP = "\1"' then cut -f IP then uniq -a ;;
                BOTVIRJ_COVID) ;; # TODO
                C2_DOMAIN) ;; # TODO
                C2_IPV4) ;; # TODO
                C2_VPN) ;; # TODO
                CYBER_CURE_DOMAIN_URL) tr ',' '\n' | get_domains_from_urls ;;
            esac
        ;;
    esac | # filter blank lines and duplicates
        mawk 'NF && !seen[$0]++' >> "build/${METHOD,,}_${FORMAT,,}.txt"
