#!/usr/bin/env bash

get_ipv4s() {
	ipinfo grepip -4hox --nocolor
}

get_ipv6s() {
	ipinfo grepip -6hox --nocolor
}

get_ipv4_cidrs() {
	ipinfo grepip -4h --nocolor --cidrs-only
}

get_ipv6_cidrs() {
	ipinfo grepip -6h --nocolor --cidrs-only
}

get_domains() {
	perl -MData::Validate::IP=is_ipv4 -nE 'chomp; if(defined($_) && !is_ipv4($_)) {say $_;}'
}

get_domains_from_urls() {
	perl -MData::Validate::Domain=is_domain -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?|udp"}{-keep}/g) {say $3 if is_domain($3, { domain_private_tld => { onion => 1 } })}' 2>/dev/null
}

get_ipv4s_from_urls() {
	perl -MData::Validate::IP=is_ipv4 -MRegexp::Common=URI -nE 'while (/$RE{URI}{HTTP}{-scheme => "https?|udp"}{-keep}/g) {say $3 if is_ipv4($3)}' 2>/dev/null
}

hostsblock() {
	gawk -F'[|^]' '/^\|\|([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+\^(\$third-party|\$important|\$all|\$xmlhttprequest)?/{print tolower($3)}'
}

# params: column number
mlr_cut_col() {
	mlr --mmap --csv --skip-comments -N clean-whitespace then cut -f "$1"
}

process_list() {
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
	'GZIP') gzip -cd "$FILE_PATH" ;;
	'TARBALL') tar -xOzf "$FILE_PATH" ;;
	'SQUIDGUARD') tar -xOzf "$FILE_PATH" --wildcards-match-slash --wildcards '*/domains' ;;
	'SCAFROGLIA') unzip -p "$FILE_PATH" blocklists-master/*.txt ;;
	'SHADOWWHISPERER') unzip -p "$FILE_PATH" BlockLists-master/RAW/* ;;
	'ESOX_LUCIUS') unzip -p "$FILE_PATH" PiHoleblocklists-main/* -x PiHoleblocklists-main/LICENSE PiHoleblocklists-main/README.md ;;
	esac |
		case "$CONTENT_TYPE" in
		'TEXT')
			case "$LIST_FILTER" in
			'NONE') cat -s ;;
			'HOSTS_FILE') mawk '{sub(/\r$/,"");if($1~/^(0.0.0.0|127.0.0.1|0|::)$/&&$2!~/^(localhost|local|localhost.localdomain)$/){print $2}}' ;;
			'MIXED_HOSTS_FILE') mawk '{if($1~/^(0.0.0.0)/){print $2}else{if($1~/^[^[:space:]|^#]/&&$1!~/\*$/){print $1}}}' ;;
			'NPC_HOSTS') mawk '$1~/^0.0.0.0/{for (i=2; i<=NF; i++) print $i}' ;;
			'RAW_HOSTS_WITH_COMMENTS') mawk '/^[^[:space:]|^#|^!|^;|^$|^:|^*]/{print $1}' ;;
			'ABUSE_CH_URLHAUS_DOMAIN') get_domains_from_urls ;;
			'ABUSE_CH_URLHAUS_IPV4') get_ipv4s_from_urls ;;
			'ALIENVAULT') mawk -F# '{print $1}' ;;
			'ADBLOCK') hostsblock ;;
			'GREP_IPV4') get_ipv4s ;;
			'GREP_IPV6') get_ipv6s ;;
			'BOTVIRJ_IPV4') mawk -F'|' '{print $1}' ;;
			'CRYPTOLAEMUS_DOMAIN') hxextract code /dev/stdin | head -n -1 | tail -n +6 ;;
			'CRYPTOLAEMUS_IPV4') hxextract code /dev/stdin | head -n -1 | tail -n +6 | get_ipv4s ;;
			'CYBERCRIME_DOMAIN') mawk -F/ '{print $1}' ;;
			'CYBERCRIME_IPV4') mawk -F/ '{split($1,a,":");print a[1]}' | get_ipv4s ;;
			'DATAPLANE_IPV4') mawk -F'|' '$0~/^[^#]/{gsub(/ /,""); print $3}' ;;
			'DSHIELD') mlr --mmap --tsv --skip-comments -N put '$cidr = $1 . "/" . $3' then cut -f cidr ;;
			'MYIP_DOMAIN') mawk -F, '$0~/^[^#]/{print $2}' ;;
			'MYIP_IPV4') mawk '$0~/^[^#]/{print $1}' | get_ipv4s ;;
			'MYIP_IPV6') mawk '$0~/^[^#]/{print $1}' | get_ipv6s ;;
			'VXVAULT_DOMAIN') mawk '/^[http]/' | get_domains_from_urls ;;
			'VXVAULT_IPV4') mawk '/^[http]/' | get_ipv4s_from_urls ;;
			'XFILES') tr -d "[:blank:]" | hostsblock | mawk '{print $2}' ;;
			'TRACKERSLIST') mawk '{print $1}' | get_domains_from_urls ;;
			'CHARLES_B_HALEY') mawk '$0~/^[^#]/{print $3}' ;;
			'QUANTUMULTX') mawk -F, '$1~/^HOST-SUFFIX$/{print $2}' ;;
			'QUINDECIM') mawk -F= '$0~/^=/{print $2}' | mawk '{print $1}' ;;
			'ZEEK_DOMAIN') mawk '/^[^[:space:]|^#]/&&$2~/^Intel::DOMAIN$/{print $1}' ;;
			'ZEEK_IPV4') mawk '/^[^[:space:]|^#]/&&$2~/^Intel::ADDR$/{print $1}' ;;
			'BETTER_FYI') gawk 'BEGIN{FS="[|^]"}/^\|\|([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+(\$third-party)?$/{print tolower($3)}' | mawk -F$ '{print $1}' ;;
			#'HERRBISCHOFF_IPV4') mawk '$0~/./&&$0!~/\/|:|^#/' ;;
			#'HERRBISCHOFF_IPV6') mawk '$0~/:/&&$0!~/\/|^#/' ;;
			'HERRBISCHOFF_CIDR4') mawk '$0~/\//&&$0!~/:/' ;;
			'HERRBISCHOFF_CIDR6') mawk '$0~/:/&&$0~/\//&&$0!~/^#/' ;;
			'POP3GROPERS_IPV4') mawk '$0~/./&&$0!~/\/|:|^#/{gsub(/ /, "", $1); print $1}' ;;
			'POP3GROPERS_IPV6') mawk '$0~/:/&&$0!~/\/|^#/{gsub(/ /, "", $1); print $1}' ;;
			'CLASH_DOMAIN') mawk -F, '$1~/^DOMAIN/&&$1!~/KEYWORD$/{print $2}' ;;
			'CLASH_CIDR4') mawk -F, '$1~/^IP-CIDR/{print $2}' ;;
			'ASN_CIDR4') mawk '$1~/^route:$/{print $2}' ;;
			'ASN_CIDR6') mawk '$1~/^route6:$/{print $2}' ;;
			'SECOND_COLUMN') mawk '{print $2}' ;;
			'NO_PEDOS') mawk -F: '/^[^[:space:]]/{print $2}' | ipinfo range2cidr ;;
			'DOMAINS_FROM_HOST_MIX') gawk '/^([[:alpha:]_-]{1,63}\.)/' ;;
			'HLC') mawk -F"[|^]" '/^[||]/ && $3!~/\*/{print $3}' ;;
			esac
			;;
		'JSON')
			case "$LIST_FILTER" in
			'ABUSE_CH_FEODOTRACKER_IPV4') jaq -r '.[].ip_address' ;;
			'ABUSE_CH_FEODOTRACKER_DOMAIN') jaq -r '.[] | select(.hostname != null) | .hostname' ;;
			'ABUSE_CH_THREATFOX_IPV4') jaq -r 'to_entries[].value[].ioc_value | split(":")[0]' ;;
			'ABUSE_CH_THREATFOX_DOMAIN') jaq -r 'to_entries[].value[].ioc_value' ;;
			'AYASHIGE') jaq -r '.[].fqdn' ;;
			'CYBER_CURE_IPV4') jaq -r '.data.ip[]' ;;
			'CYBERSAIYAN_DOMAIN') jaq -r '.[] | select(.value.type == "URL") | .indicator' | get_domains_from_urls ;;
			'CYBERSAIYAN_IPV4') jaq -r '.[] | select(.value.type == "URL") | .indicator' | get_ipv4s_from_urls ;;
			'DISCONNECTME_ENTITIES') jaq -r '.entities[] | "\(.properties[])\n\(.resources[])"' ;;
			#'DISCONNECTME_SERVICES') jaq -r '.categories[] | to_entries[].value[] | to_entries[].value[]' ;;
			'HIPO_UNIVERSITIES') jaq -r '.[].domains | join("\n")' ;;
			'ISCSANS') jaq -r '.[].ipv4' ;;
			'MALSILO_DOMAIN') jaq -r '.data[].network_traffic | select(.dns != null) | .dns[]' ;;
			'MALSILO_IPV4') jaq -r '.data[].network_traffic | select(.tcp != null) | .tcp[] | split(":")[0]' ;;
			'MALTRAIL') jaq -r '.[].ip' ;;
			'TINYCHECK_DOMAIN') jaq -r '.iocs[] | select(.type == "domain") | .value' ;;
			'TINYCHECK_FREEDNS') jaq -r '.iocs[] | select(.type == "freedns") | .value' ;;
			'TINYCHECK_IPV4') jaq -r '.iocs[] | select(.type == "ip4addr") | .value' ;;
			'TINYCHECK_CIDR') jaq -r '.iocs[] | select(.type == "cidr") | .value' ;;
			'CHONG_LUA_DAO_DOMAIN') jaq -r '.[].url' | sed 's/\*\.//g' | get_domains_from_urls ;;
			'CHONG_LUA_DAO_IPV4') jaq -r '.[].url' | get_ipv4s_from_urls ;;
			'INQUEST_DOMAIN') jaq -r '.data[] | select(.artifact_type == "domain") | .artifact' ;;
			'INQUEST_IPV4') jaq -r '.data[] | select(.artifact_type == "ipaddress") | .artifact' ;;
			#'CERTEGO') jaq -rs '.[].links[].url' | mawk -F/ '$5~/^domain$/{print $6}' ;;
			'SECUREDROP') jaq -r '.[] | .onion_address as $onion | .organization_url | split("/")[2] as $org | $org, $onion' ;;
			'VIVALDI') jaq -r '.[] | select(.filterStatus == "ON") | .reviewedSite' ;;
			'MSEDGE') jaq -r '.sites[].url' ;;
			'GITHUB_ACTIONS_DOMAINS') jaq -r '.domains.actions[]' ;;
			'GITHUB_META_CIDR4') jaq -r '.hooks[], .web[], .api[], .git[], .github_enterprise_importer[], .packages[], .pages[], .importer[], .actions[], .dependabot[]' | get_ipv4_cidrs ;;
			'GITHUB_META_CIDR6') jaq -r '.hooks[], .web[], .api[], .git[], .github_enterprise_importer[], .pages[], .actions[]' | get_ipv6_cidrs ;;
			'HAAS') jaq -r '.[] | .ip' ;;
			'CIRCL_DOMAIN') jaq -rs '.[].Event.Attribute[]? | select(.type == "domain" or .type == "hostname").value' ;;
			'CIRCL_IPV4') jaq -rs '.[].Event.Attribute[]? | select(.type == "ip-dst").value' ;;
			'CIRCL_URL') jaq -rs '.[].Event.Attribute[]? | select(.type == "url").value | capture("^((?<scheme>[^:/?#]+):)?(//(?<authority>(?<domain>[^/?#:]*)(:(?<port>[0-9]*))?))?((?<path>[^?#]*))?(\\?(?<query>([^#]*)))?(#(?<fragment>(.*)))?").domain' ;;
			'MALWARE_WORLD') jaq -r 'to_entries[] | select(.value.title == "Whitelist").key' ;;
			esac
			;;
		'CSV')
			case "$LIST_FILTER" in
			'MLR_CUT_1') mlr_cut_col 1 ;;
			'MLR_CUT_2') mlr_cut_col 2 ;;
			'MLR_CUT_4') mlr_cut_col 4 ;;
			'BENKOW_DOMAIN') mlr --mmap --csv --headerless-csv-output --ifs ';' cut -f url | get_domains_from_urls ;;
			'BENKOW_IPV4') mlr --mmap --csv --headerless-csv-output --ifs ';' put -S '$url =~ "https?://(((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))"; $IP = "\1"' then cut -f IP then uniq -a ;;
			'BOTVIRJ_COVID') mawk 'NR>1' ;;
			'CYBER_CURE_DOMAIN_URL') tr ',' '\n' | get_domains_from_urls ;;
			'MALWARE_DISCOVERER_DOMAIN') mlr --mmap --csv --headerless-csv-output cut -f domain ;;
			'MALWARE_DISCOVERER_IPV4') mlr --mmap --csv --headerless-csv-output cut -f ip ;;
			'PHISHSTATS_DOMAIN') mlr_cut_col 3 | get_domains_from_urls ;;
			'PHISHSTATS_IPV4') mlr_cut_col 4 | get_ipv4s ;;
			'PHISHSTATS_IPV6') mlr_cut_col 4 | get_ipv6s ;;
			'TURRIS') mlr --mmap --csv --headerless-csv-output --skip-comments cut -f Address ;;
			'VIRIBACK_DOMAIN') mlr --mmap --csv --headerless-csv-output cut -f URL | get_domains_from_urls ;;
			'VIRIBACK_IPV4') mlr --mmap --csv --headerless-csv-output cut -f IP ;;
			'SHADOWSERVER_HOST') mlr --mmap --csv --headerless-csv-output cut -f http_host ;;
			'SHADOWSERVER_TARGET') mlr --mmap --csv --headerless-csv-output cut -f redirect_target ;;
			'WATCHLIST_INTERNET') mlr --mmap --csv --ifs ';' -N cut -f 1 ;;
			'CRUZ_IT') mlr --mmap --csv --headerless-csv-output clean-whitespace then cut -f ip_address ;;
			'PHISHTANK') mlr --mmap --csv --headerless-csv-output --lazy-quotes cut -f url | get_domains_from_urls ;;
			'BLOCKLIST_UA') mlr --mmap --csv --ifs ';' --headerless-csv-output cut -f IP ;;
			'THREATVIEW_C2_HOSTS') mawk -F, '/^[^#]/{print $3}' ;;
			# Ignore IPs that are not from the current month.
			'THREATVIEW_C2_IPV4') awk -F, -v date="$(date +'%B %Y') [0-9]{2}:[0-9]{2} [AP]M [[:upper:]]+$" '/^[^#]/ && $2 ~ date{print $1}';;
			esac
			;;
		'YAML')
			case "$LIST_FILTER" in
			'CRYPTOSCAMDB_BLACKLIST') yq '.[].name' ;;
			'CRYPTOSCAMDB_WHITELIST') yq '.[].url' | get_domains_from_urls ;;
			esac
			;;
		esac | mawk 'NF && !seen[$0]++' |
		case "$LIST_FORMAT" in
		'DOMAIN')
			perl ./scripts/v2/process_domains.pl 2>/dev/null
			;;
		# https://metacpan.org/pod/Data::Validate::IP
		'IPV4')
			case "$LIST_METHOD" in
			'BLOCK')
				perl -MData::Validate::IP=is_public_ipv4 -nE 'chomp; if(defined($_) && is_public_ipv4($_)) {say $_;}'
				;;
			# Ensure bogons get whitelisted
			'ALLOW')
				perl -MData::Validate::IP=is_ipv4 -nE 'chomp; if(defined($_) && is_ipv4($_)) {say $_;}'
				;;
			esac
			;;
		'IPV6')
			case "$LIST_METHOD" in
			'BLOCK')
				perl -MData::Validate::IP=is_public_ipv6 -nE 'chomp; if(defined($_) && is_public_ipv6($_)) {say $_;}'
				;;
			# Ensure bogons get whitelisted
			'ALLOW')
				perl -MData::Validate::IP=is_ipv6 -nE 'chomp; if(defined($_) && is_ipv6($_)) {say $_;}'
				;;
			esac
			;;
		'CIDR4')
			perl ./scripts/v2/process_cidrs.pl 2>/dev/null
			;;
		'CIDR6')
			perl ./scripts/v2/process_cidrs.pl 2>/dev/null
			;;
		esac
}

main() {
	jaq -r --arg key "$(basename "$1")" --arg format "$3" 'to_entries[] |
		select(.key == $key) | .value |
		.content.filter as $content_filter |
		.content.type as $content_type |
		.formats[] |
		select(.format == $format) |
		"\($content_filter)#\($content_type)#\(.filter)"' data/v2/manifest.json |
		while IFS='#' read -r content_filter content_type list_filter; do
			process_list "$1" "$2" "$content_filter" "$content_type" "$list_filter" "$3"
		done
}

main "$1" "$2" "$3"
