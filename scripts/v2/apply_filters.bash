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

get_exodus_content() {
    # edge cases:
    # "mns\..*\.aliyuncs\.com" (currently being ignored)
    # "mst[0-9]*.is.autonavi.com" / "mt[0-9]*.google.cn" (currently being ignored)

    # "network_signature" & "code_signature" currently have invalid domains
    # https://etip.exodus-privacy.eu.org/trackers/export
    jq -r '.trackers[] |
        (.website | split("/")[2])
        (.network_signature | split ("|")[] | gsub("\\\\"; "") | ltrimstr(".*")),
        (.code_signature | split("|")[] | rtrimstr(".") | split(".") | reverse | join(".")),
    	| ltrimstr(".")'
    # gawk '{
    #     switch ($1) {
    #     case /^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/:
    #         print tolower($1) > "imports/out/exodus_domains.txt"
    #         break
    #     case /^([0-9]{1,3}\.){3}[0-9]{1,3}+(\/|:|$)/:
    #         sub(/:.*/, "", $1)
    #         print $1 > "imports/out/exodus_ips.txt"
    #         break
    #     }
    # }'
}

# params: content type, format filter
apply_format_filter() {
	case $1 in
	TEXT)
		case $2 in
		NONE) cat -s ;;
        MAWK_WITH_COMMENTS_FIRST_COLUMN) mawk '$0~/^[^#]/{print $1}' ;;
        MAWK_WITH_COMMENTS_SECOND_COLUMN) mawk '$0~/^[^#]/{print $2}' ;;
        ADBLOCK)
            # https://github.com/DandelionSprout/adfilt/blob/master/Wiki/SyntaxMeaningsThatAreActuallyHumanReadable.md
            mawk -F"[|^]" '$0~/^\|/{if ($4~/^$/) {print $3}}'
            ;;
        HOSTS_FILE) ghosts -m -o -p -noheader -stats=false ;;
        ALIENVAULT) mawk -F# '{print $1}' ;;
        URL_REGEX_DOMAIN) get_domains_from_urls ;;
        URL_REGEX_IPV4) ;; # TODO?
        REGEX_IPV4) perl -MRegexp::Common=net -nE 'say $& while /$RE{net}{IPv4}/g' ;;
        REGEX_IPV6) perl -MRegexp::Common=net -nE 'say $& while /$RE{net}{IPv6}/g' ;;
        BLACKBIRD) mawk 'NR>4' ;; # '$0~/^[^;]/'
        BOTVIRJ_IPV4) mawk -F'|' '{print $1}' ;;
        CRYPTOLAEMUS_DOMAIN) perl ./scripts/v1/process_domains.pl ;;
        CERTEGO_DOMAIN) ;; # TODO
        CERTEGO_IPV4) ;;   # TODO
        CYBERCRIME_DOMAIN) mawk -F/ '{print $1}' | perl ./scripts/v1/process_domains.pl ;;
        #SCHEMELESS_URL_DOMAIN) gawk -F/ '$1~/^([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+([[:space:]]|$)/{print tolower($1)}' ;;
        #SCHEMELESS_URL_IPV4) gawk -F/ '$1~/^([0-9]{1,3}\.){3}[0-9]{1,3}+(:|$)/{split($1,a,":");print a[1]}' ;;
        REGEX_CIDR) ;; # TODO
        DATAPLANE_IPV4) mawk -F'|' '$0~/^[^#]/{gsub(/ /,""); print $3}' ;;
        DSHIELD) mawk '$0~/^[^#]/&&$1!~/^Start$/{printf "%s/%s\n",$1,$3}' ;;
		esac
		;;
	JSON)
		case $2 in
		FEODO_DOMAIN) jq -r '.[] | select(.hostname != null) | .hostname' ;;
        FEODO_IPV4) jq -r '.[].ip_address' ;;
        THREATFOX_DOMAIN) jq -r '.[] | .[] | select(.ioc_type == "domain") | .ioc_value' ;;
        THREATFOX_IPV4) jq -r '.[] | .[] | select(.ioc_type == "ip:port") | .ioc_value | split(":")[0]' ;;
        AYASHIGE) jq -r '.[].fqdn' ;;
        CYBERSAIYAN_DOMAIN) jq -r '.[] | select(.value.type == "domain") | .indicator' ;;
        CYBERSAIYAN_IPV4) jq -r '.[] | select(.value.type == "IPv4") | .indicator' ;;
        CYBER_CURE_IPV4) jq -r '.data.ip[]' ;;
        DISCONNECTME) jq -r '.entities[] | "\(.properties[])\n\(.resources[])"' ;;
        EXODUS_IPV4)
			get_exodus_content | gawk '/^([0-9]+(\.|:|\/|$)){4}/'
			;;
		esac
		;;
	CSV)
		case $2 in
		NO_HEADER_SECOND_COLUMN) mlr --mmap --csv --skip-comments -N cut -f 2 ;;
        URLHAUS_DOMAIN) mlr --mmap --csv --skip-comments -N put -S '$3 =~ "https?://([a-z][^/|^:]+)"; $Domain = "\1"' then cut -f Domain then uniq -a ;;
        URLHAUS_IPV4) mlr --mmap --csv --skip-comments -N put -S '$3 =~ "https?://([0-9][^/|^:]+)"; $IP = "\1"' then cut -f IP then uniq -a ;;
        BOTVIRJ_COVID) ;; # TODO
        C2_DOMAIN) ;;     # TODO
        C2_IPV4) ;;       # TODO
        C2_VPN) ;;        # TODO
        CYBER_CURE_DOMAIN_URL) tr ',' '\n' | get_domains_from_urls ;;
		esac
		;;
	esac | # filter blank lines and duplicates
		mawk 'NF && !seen[$0]++'
}

# params: list format, method, key
validate_output() {
	case $1 in
	DOMAIN) perl ./scripts/v1/process_domains.pl 2>/dev/null ;;
	IPV4) ;;
	IPV6) ;;
	CIDR) validate_output 'IPV4' "$2" "$3" ;;
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

	echo "[INFO] Operating on ${LIST} with ${LIST_FORMAT} content with the ${CONTENT_FILTER} filter."

	apply_content_filter "$LIST" "$CONTENT_FILTER" |
		apply_format_filter "$CONTENT_TYPE" "$LIST_FILTER" |
		validate_and_export_output "$LIST_FORMAT" "$METHOD" "$KEY" |
		sponge >>"build/${METHOD}_${FORMAT}.txt"
}

main "$1" "$2" "$3" "$4" "$5" "$6" "$7"
