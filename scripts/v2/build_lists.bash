#!/usr/bin/env bash

#shopt -s extdebug     # or --debugging
set +H +o history     # disable history features (helps avoid errors from "!" in strings)
shopt -u cmdhist      # would be enabled and have no effect otherwise
shopt -s execfail     # ensure interactive and non-interactive runtime are similar
shopt -s extglob      # enable extended pattern matching (https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
set -euET -o pipefail # put bash into "strict mode" & have it give descriptive errors
umask 055             # change all generated file permissions from 755 to 700

#ARCHIVE='dist/ARCHIVE.csv'
OUTDIR='build'
DOWNLOADS=$(mktemp -d)
TMP=$(mktemp -p "$DOWNLOADS")
ERROR_LOG='logs/error.log'
METHOD_ALLOW='ALLOW'
METHOD_BLOCK='BLOCK'
FORMAT_DOMAIN='DOMAIN'
FORMAT_CIDR4='CIDR4'
FORMAT_CIDR6='CIDR6'
FORMAT_IPV4='IPV4'
FORMAT_IPV6='IPV6'
readonly OUTDIR DOWNLOADS TMP ERROR_LOG METHOD_ALLOW METHOD_BLOCK FORMAT_DOMAIN FORMAT_CIDR4 FORMAT_CIDR6 FORMAT_IPV4 FORMAT_IPV6

METHODS=("$METHOD_BLOCK" "$METHOD_ALLOW")
FORMATS=("$FORMAT_DOMAIN" "$FORMAT_IPV4" "$FORMAT_IPV6" "$FORMAT_CIDR4" "$FORMAT_CIDR6")
readonly -a METHODS
readonly -a FORMATS

# https://github.com/ildar-shaimordanov/perl-utils#sponge
sponge() {
	perl5.42.0 -ne '
	push @lines, $_;
	END {
		open(OUT, ">$file")
		or die "sponge: cannot open $file: $!\n";
		print OUT @lines;
		close(OUT);
	}
	' -s -- -file="$1"
}

# params: file to sort,
sorted() {
	parsort -bfiu -S 100% -T "$DOWNLOADS" "$1" | sponge "$1"
	echo "[INFO] Organized: ${1}"
}

# params: blacklist, whitelist,
apply_whitelist() {
	local temp_file
	temp_file=$(mktemp -p "$DOWNLOADS")
	# https://askubuntu.com/a/562352
	# send each line into the temp file as it's processed instead of keeping it in memory
	parallel --pipe -k -j+0 grep --line-buffered -Fxvf "$2" - <"$1" >>"$temp_file"
	cp "$temp_file" "$1"
	rm -f "$temp_file"
	echo "[INFO] Applied whitelist to: ${1}"
}

# params: ip list, cidr whitelist,
apply_cidr_whitelist() {
	if test -s "$1"; then
		sem -j+0 grepcidr -vf "$2" <"$1" | sponge "$1"
		sem --wait
		echo "[INFO] Applied CIDR whitelist to: ${1}"
	fi
}

# Process a complete method (BLOCK or ALLOW) including download and format processing
process_list_method() {
	local method="$1"
	local cache="${DOWNLOADS}/${method}"
	local method_tmp="${cache}/tmp"
	local method_error_log="${ERROR_LOG}.${method}"

	echo "[INFO] Processing method: ${method}"

	mkdir -p "$cache" "$method_tmp"

	set +e # Temporarily disable strict fail, in case web requests fail

	echo "[INFO] Downloading ${method} lists..."

	jaq -r '[.[] | select(.active) | .content.retriever] | unique | .[]' data/v2/manifest.json |
		while read -r retriever; do
			case "$retriever" in
			'ARIA2')
				jaq -r --arg method "$method" 'to_entries[] |
					select(.value.content.retriever == "ARIA2" and .value.method == $method and .value.active) |
					{key, mirrors: .value.mirrors} |
					(.mirrors | join("\t")), " out=\(.key)"' data/v2/manifest.json |
					aria2c -i- -d "$cache" --conf-path='./configs/aria2.conf'
				;;
			*)
				jaq -r --arg method "$method" --arg retriever "$retriever" 'to_entries[] |
					select(.value.content.retriever == $retriever and .value.method == $method and .value.active) |
					{key, mirror: .value.mirrors[0]} |
					"\(.key)#\(.mirror)"' data/v2/manifest.json |
					while IFS='#' read -r key mirror; do
						case "$retriever" in
						'WGET') wget -P "$cache" --config='./configs/wget.conf' -a 'logs/wget.log' -O "$key" "$mirror" ;;
						'INSECURE_WGET') wget -P "$cache" --no-check-certificate --config='./configs/wget.conf' -a 'logs/wget.log' -O "$key" "$mirror" ;;
						'ASN_QUERY')
							curl -sSL "$mirror" | mawk '/^[^[:space:]|^#|^!|^;|^$|^:]/{print $1}' |
								while read -r asn; do whois -h whois.radb.net -- "-i origin ${asn}"; done |
								sponge "${cache}/${key}"
							;;
						'LYNX') lynx -dump -listonly -nonumbers "$mirror" | sponge "${cache}/${key}" ;;
						'HAAS_WGET')
							local DATE
							local TARGET
							DATE="$(date +'%Y/%m')"
							TARGET="$(date --date='yesterday' +'%Y-%m-%d')"
							wget -P "$cache" --config='./configs/wget.conf' -a 'logs/wget.log' -O "$key" "https://haas.nic.cz/stats/export/${DATE}/${TARGET}.json.gz"
							;;
						'CIRCL')
							curl -sSL "$mirror" |
								jaq -r --arg year "$(date +'%Y')" 'to_entries[] | select(.value.date | startswith($year)).key' |
								while read -r id; do curl -sSL "https://www.circl.lu/doc/misp/feed-osint/${id}.json"; done |
								sponge "${cache}/${key}"
							;;
						'HLC_MODIFIERS') hostlist-compiler -t adblock -i "$mirror" -o "${cache}/${key}" >>'logs/hostlist-compiler.log' ;;
						'HLC_NO_MODIFIERS')
							echo "{ \"name\": \"Blocklist\", \"sources\": [ { \"source\": \"${mirror}\", \"type\": \"adblock\" } ], \"transformations\": [ \"RemoveComments\", \"TrimLines\", \"RemoveModifiers\", \"Deduplicate\", \"Compress\", \"Validate\", \"InsertFinalNewLine\" ] }" >>"${method_tmp}/hlc_config"
							hostlist-compiler -c "${method_tmp}/hlc_config" -o "${cache}/${key}" >>'logs/hostlist-compiler.log'
							: >"${method_tmp}/hlc_config"
							;;
						'CURL_ABUSE_IPDB')
							curl -G "$mirror" \
								-d confidenceMinimum=92 \
								-d plaintext \
								-H "Key: ${ABUSE_IPDB_SECRET}" \
								-H 'Accept: application/json' \
								-o "${cache}/${key}"
							;;
						esac
					done
				;;
			esac
		done
	set -e

	echo "[INFO] Downloaded ${method} lists!"

	# Process all formats for this method
	for format in "${FORMATS[@]}"; do
		local results="${cache}/${format}"
		mkdir -p "$results"

		echo "[INFO] Sending list results to: ${results}"

		find -P -O3 "$cache" -maxdepth 1 -type f -print0 |
			parallel -0 -j+0 -X -N1 --results "$results" ./scripts/v2/apply_filters.bash {} "$method" "$format"

		local list="${OUTDIR}/${method}_${format}.txt"

		echo "[INFO] Processed: ${list}"

		find -P -O3 "$results" -type f -name stdout -exec cat -s {} + >>"$list"

		# Collect errors for this method
		find -P -O3 "$results" -type f -name stderr |
			while read -r file; do
				if [ -s "$file" ]; then
					echo "$file" | mawk -F'\+z' '{printf "[ERROR] %s:\n",$5}' >>"$method_error_log"
					cat -s "$file" >>"$method_error_log"
				fi
			done

		if [ -s "$list" ]; then
			sorted "$list"
		fi
	done

	echo "[INFO] Completed processing method: ${method}"
}

# Apply whitelists after all methods have been processed
apply_whitelists() {
	echo "[INFO] Applying whitelists..."

	for format in "${FORMATS[@]}"; do
		local blacklist="${OUTDIR}/BLOCK_${format}.txt"
		local whitelist="${OUTDIR}/ALLOW_${format}.txt"

		if [ -s "$whitelist" ] && [ -s "$blacklist" ]; then
			case "$format" in
			"$FORMAT_CIDR4")
				apply_cidr_whitelist "$blacklist" "$whitelist"
				apply_cidr_whitelist "${OUTDIR}/BLOCK_IPV4.txt" "$whitelist"
				;;
			"$FORMAT_CIDR6")
				apply_cidr_whitelist "$blacklist" "$whitelist"
				apply_cidr_whitelist "${OUTDIR}/BLOCK_IPV6.txt" "$whitelist"
				;;
			*)
				apply_whitelist "$blacklist" "$whitelist"
				;;
			esac
		fi
	done

	# Remove IPs from the IP blacklists that are covered by the CIDR blacklists
	if [ -s "${OUTDIR}/BLOCK_CIDR4.txt" ]; then
		apply_cidr_whitelist "${OUTDIR}/BLOCK_IPV4.txt" "${OUTDIR}/BLOCK_CIDR4.txt"
	fi
	if [ -s "${OUTDIR}/BLOCK_CIDR6.txt" ]; then
		apply_cidr_whitelist "${OUTDIR}/BLOCK_IPV6.txt" "${OUTDIR}/BLOCK_CIDR6.txt"
	fi
}

main() {
	trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1
	mkdir -p "$OUTDIR"
	# clear all logs
	find -P -O3 ./logs -depth -type f -print0 | xargs -0 truncate -s 0
	chmod -t /tmp

	# Export functions and variables for parallel execution
	export -f process_list_method sorted apply_whitelist apply_cidr_whitelist sponge
	export OUTDIR DOWNLOADS ERROR_LOG METHOD_ALLOW METHOD_BLOCK FORMATS
	export FORMAT_DOMAIN FORMAT_CIDR4 FORMAT_CIDR6 FORMAT_IPV4 FORMAT_IPV6

	echo "[INFO] Starting parallel method processing..."

	parallel -j+0 process_list_method ::: "${METHODS[@]}"

	echo "[INFO] All methods completed! Applying whitelists..."

	# Apply whitelists after all methods are complete
	apply_whitelists

	# Merge error logs from all methods
	if find "$DOWNLOADS" -name "${ERROR_LOG##*/}.*" -type f 2>/dev/null | grep -q .; then
		find "$DOWNLOADS" -name "${ERROR_LOG##*/}.*" -type f -exec cat {} + > "$ERROR_LOG"
	fi

	# https://superuser.com/questions/191889/how-can-i-list-only-non-empty-files-using-ls
	find "$OUTDIR" -type f -name "*.txt" -size 0 -exec rm {} \;
	find "$OUTDIR" -type f -name "*.txt" -exec sha256sum {} \; | sort -k2 >>"${OUTDIR}/CHECKSUMS.txt"

	chmod +t /tmp

	echo "[INFO] Parallel processing complete!"
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main
