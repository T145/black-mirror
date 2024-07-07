#!/usr/bin/env bash

#shopt -s extdebug     # or --debugging
set +H +o history     # disable history features (helps avoid errors from "!" in strings)
shopt -u cmdhist      # would be enabled and have no effect otherwise
shopt -s execfail     # ensure interactive and non-interactive runtime are similar
shopt -s extglob      # enable extended pattern matching (https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
set -euET -o pipefail # put bash into "strict mode" & have it give descriptive errors
umask 055             # change all generated file permissions from 755 to 700

ARCHIVE='dist/ARCHIVE.csv'
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
readonly ARCHIVE OUTDIR DOWNLOADS TMP ERROR_LOG METHOD_ALLOW METHOD_BLOCK FORMAT_DOMAIN FORMAT_CIDR4 FORMAT_CIDR6 FORMAT_IPV4 FORMAT_IPV6

METHODS=("$METHOD_BLOCK" "$METHOD_ALLOW")
FORMATS=("$FORMAT_DOMAIN" "$FORMAT_IPV4" "$FORMAT_IPV6" "$FORMAT_CIDR4" "$FORMAT_CIDR6")
readonly -a METHODS
readonly -a FORMATS

# https://github.com/ildar-shaimordanov/perl-utils#sponge
sponge() {
	perl5.41.1 -ne '
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
	# https://askubuntu.com/a/562352
	# send each line into the temp file as it's processed instead of keeping it in memory
	parallel --pipe -k -j+0 grep --line-buffered -Fxvf "$2" - <"$1" >>"$TMP"
	cp "$TMP" "$1"
	: >"$TMP"
	echo "[INFO] Applied whitelist to: ${1}"
}

# params: ip list, cidr whitelist,
apply_cidr_whitelist() {
	if test -f "$1"; then
		sem -j+0 grepcidr -vf "$2" <"$1" | sponge "$1"
		sem --wait
		echo "[INFO] Applied CIDR whitelist to: ${1}"
	fi
}

main() {
	trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1
	mkdir -p "$OUTDIR"
	# clear all logs
	find -P -O3 ./logs -depth -type f -print0 | xargs -0 truncate -s 0
	chmod -t /tmp

	local cache
	local list
	local blacklist
	local results

	for method in "${METHODS[@]}"; do
		cache="${DOWNLOADS}/${method}"

		echo "[INFO] Processing method: ${method}"

		set +e # Temporarily disable strict fail, in case web requests fail
		echo "[INFO] Archiving ${method} lists..."

		: >"$ARCHIVE"

		# This will archive inactive lists too
		jaq -r --arg method "$method" 'to_entries[] |
			select(.value.method == $method).value.mirrors[] as $mirror |
			("\(.key)#\($mirror)")' data/v2/manifest.json |
			while IFS='#' read -r key url; do
				curl -sSLI "https://web.archive.org/save/${url}" |
					awk -v key="$key" '$1~/^location:$/{print key,$2}' >>"$ARCHIVE"
			done

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
				# 'HLC_MODIFIERS')
				# 	echo -n "{\"name\":\"Blocklist\",\"sources\":[" >>"$TMP"
				# 	jaq -r --arg method 'map(select(.content.retriever == "HLC_MODIFIERS" and .method == $method).mirrors) | flatten | .[]' data/v2/manifest.json |
				# 		mawk '{printf "{\"source\":\"%s\",\"type\":\"adblock\"},", $0}' >>"$TMP"
				# 	echo -n "],\"transformations\":[\"RemoveComments\",\"TrimLines\",\"Deduplicate\",\"Compress\",\"Validate\",\"InsertFinalNewLine\"]}" >>"$TMP"
				# 	hostlist-compiler -c "$TMP" -o "${cache}/${key}" >>'logs/hostlist-compiler.log'
				# 	: >"$TMP"
				# 	;;
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
							# TODO: Do all HLC lists at once by building a large config file.
							'HLC_MODIFIERS') hostlist-compiler -t adblock -i "$mirror" -o "${cache}/${key}" >>'logs/hostlist-compiler.log' ;;
							'HLC_NO_MODIFIERS')
								echo "{ \"name\": \"Blocklist\", \"sources\": [ { \"source\": \"${mirror}\", \"type\": \"adblock\" } ], \"transformations\": [ \"RemoveComments\", \"TrimLines\", \"RemoveModifiers\", \"Deduplicate\", \"Compress\", \"Validate\", \"InsertFinalNewLine\" ] }" >>"$TMP"
								hostlist-compiler -c "$TMP" -o "${cache}/${key}" >>'logs/hostlist-compiler.log'
								: >"$TMP"
								;;
							esac
						done
					;;
				# 'SAFE_GIT')
				# 	# Some repos contain active malware, which we don't want to download.
				# 	curl -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" https://api.github.com/repos/0xDanielLopez/phishing_kits/git/trees/master?recursive=1
				# 	;;
				esac
			done
		set -e

		echo "[INFO] Downloaded ${method} lists!"

		for format in "${FORMATS[@]}"; do
			results="${cache}/${format}"
			mkdir -p "$results"

			echo "[INFO] Sending list results to: ${results}"

			find -P -O3 "$cache" -maxdepth 1 -type f -print0 |
				# https://www.gnu.org/software/parallel/parallel_tutorial.html#controlling-the-execution
				parallel -0 --use-cpus-instead-of-cores --jobs 0 --results "$results" -X ./scripts/v2/apply_filters.bash {} "$method" "$format"

			list="${OUTDIR}/${method}_${format}.txt"

			echo "[INFO] Processed: ${list}"

			find -P -O3 "$results" -type f -name stdout -exec cat -s {} + >>"$list"

			find -P -O3 "$results" -type f -name stderr |
				while read -r file; do
					if [ -s "$file" ]; then
						echo "$file" | mawk -F'\+z' '{printf "[ERROR] %s:\n",$5}' >>"$ERROR_LOG"
						cat -s "$file" >>"$ERROR_LOG"
					fi
				done

			if [ -f "$list" ] && [ -s "$list" ]; then
				sorted "$list"

				if [[ "$method" == "$METHOD_ALLOW" ]]; then
					blacklist="${OUTDIR}/BLOCK_${format}.txt"

					case "$format" in
					"$FORMAT_CIDR4")
						apply_cidr_whitelist "$blacklist" "$list"
						apply_cidr_whitelist "${OUTDIR}/BLOCK_IPV4.txt" "$list"
						;;
					"$FORMAT_CIDR6")
						apply_cidr_whitelist "$blacklist" "$list"
						apply_cidr_whitelist "${OUTDIR}/BLOCK_IPV6.txt" "$list"
						;;
					*)
						apply_whitelist "$blacklist" "$list"
						;;
					esac
				else
					# Remove IPs from the IP blacklists that are covered by the CIDR blacklists
					case "$format" in
					"$FORMAT_CIDR4")
						apply_cidr_whitelist "${OUTDIR}/BLOCK_IPV4.txt" "$list"
						;;
					"$FORMAT_CIDR6")
						apply_cidr_whitelist "${OUTDIR}/BLOCK_IPV6.txt" "$list"
						;;
					*) ;;
					esac
				fi
			fi
		done
	done

	# https://superuser.com/questions/191889/how-can-i-list-only-non-empty-files-using-ls
	find "$OUTDIR" -type f -name "*.txt" -size 0 -exec rm {} \;
	find "$OUTDIR" -type f -name "*.txt" -exec sha256sum {} \; | sort -k2 >>"${OUTDIR}/CHECKSUMS.txt"

	chmod +t /tmp
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main
