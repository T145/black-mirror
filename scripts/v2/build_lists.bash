#!/usr/bin/env bash

#shopt -s extdebug     # or --debugging
set +H +o history     # disable history features (helps avoid errors from "!" in strings)
shopt -u cmdhist      # would be enabled and have no effect otherwise
shopt -s execfail     # ensure interactive and non-interactive runtime are similar
shopt -s extglob      # enable extended pattern matching (https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
set -euET -o pipefail # put bash into "strict mode" & have it give descriptive errors
umask 055             # change all generated file permissions from 755 to 700

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
readonly DOWNLOADS TMP ERROR_LOG METHOD_ALLOW METHOD_BLOCK FORMAT_DOMAIN FORMAT_CIDR4 FORMAT_CIDR6 FORMAT_IPV4 FORMAT_IPV6

METHODS=("$METHOD_BLOCK" "$METHOD_ALLOW")
FORMATS=("$FORMAT_DOMAIN" "$FORMAT_IPV4" "$FORMAT_IPV6" "$FORMAT_CIDR4" "$FORMAT_CIDR6")
readonly -a METHODS
readonly -a FORMATS

# https://github.com/ildar-shaimordanov/perl-utils#sponge
sponge() {
	perl -ne '
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

# params: output directory,
init() {
	trap 'rm -rf "$DOWNLOADS"' EXIT || exit 1
	mkdir -p "$1"
	# clear all logs
	find -P -O3 ./logs -depth -type f -print0 | xargs -0 truncate -s 0
	chmod -t /tmp
}

cleanup() {
	chmod +t /tmp
}

# params: method id, retriever id
get_lists() {
	jq -r --arg method "$1" --arg retriever "$2" 'to_entries[] |
		select(.value.content.retriever == $retriever and .value.method == $method) |
		{key, mirror: .value.mirrors[0]} |
		"\(.key)#\(.mirror)"' data/v2/manifest.json
}

main() {
	local cache
	local list
	local blacklist
	local results

	outdir="build"

	init "$outdir"

	for method in "${METHODS[@]}"; do
		cache="${DOWNLOADS}/${method}"

		echo "[INFO] Processing method: ${method}"

		# use 'lynx -dump -listonly -nonumbers' to get a raw page

		set +e # temporarily disable strict fail, in case downloads fail
		jq -r 'to_entries[].value.content.retriever' data/v2/manifest.json |
			mawk 'NF && !seen[$0]++' | # remove duplicates
			while read -r retriever; do
				case "$retriever" in
				'ARIA2')
					jq -r --arg method "$method" 'to_entries[] |
						select(.value.content.retriever == "ARIA2" and .value.method == $method) |
						{key, mirrors: .value.mirrors} |
						(.mirrors | join("\t")), " out=\(.key)"' data/v2/manifest.json |
						aria2c -i- -d "$cache" --conf-path='./configs/aria2.conf'
					;;
				'WGET')
					get_lists "$method" 'WGET' |
						while IFS='#' read -r key mirror; do
							wget -P "$cache" --config='./configs/wget.conf' -a 'logs/wget.log' -O "$key" "$mirror"
						done
					;;
				'WGET_INSECURE')
					get_lists "$method" 'WGET_INSECURE' |
						while IFS='#' read -r key mirror; do
							wget -P "$cache" --no-check-certificate --config='./configs/wget.conf' -a 'logs/wget.log' -O "$key" "$mirror"
						done
					;;
				'ASN_QUERY')
					get_lists "$method" 'ASN_QUERY' |
						while IFS='#' read -r key mirror; do
							curl -s "$mirror" | mawk '/^[^[:space:]|^#|^!|^;|^$|^:]/{print $1}' |
							while read -r asn; do
								whois -h whois.radb.net -- "-i origin ${asn}" >>"${cache}/${key}"
							done
						done
					;;
				# 'SNSCRAPE')
				# 	get_lists "$method" 'SNSCRAPE' |
				# 		"\(.key)#\(.mirror)"' data/v2/manifest.json |
				# 		while IFS='#' read -r key mirror; do
				# 			snscrape --jsonl twitter-user "$mirror" >"$key"
				# 		done
				# 	;;
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

			list="${outdir}/${method}_${format}.txt"

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
					blacklist="${outdir}/BLOCK_${format}.txt"

					case "$format" in
					"$FORMAT_CIDR4")
						apply_cidr_whitelist "$blacklist" "$list"
						apply_cidr_whitelist "${outdir}/BLOCK_IPV4.txt" "$list"
						;;
					"$FORMAT_CIDR6")
						apply_cidr_whitelist "$blacklist" "$list"
						apply_cidr_whitelist "${outdir}/BLOCK_IPV6.txt" "$list"
						;;
					*)
						apply_whitelist "$blacklist" "$list"
						;;
					esac
				else
					# Remove IPs from the IP blacklists that are covered by the CIDR blacklists
					case "$format" in
					"$FORMAT_CIDR4")
						apply_cidr_whitelist "${outdir}/BLOCK_IPV4.txt" "$list"
						;;
					"$FORMAT_CIDR6")
						apply_cidr_whitelist "${outdir}/BLOCK_IPV6.txt" "$list"
						;;
					*) ;;
					esac
				fi
			fi
		done
	done

	# https://superuser.com/questions/191889/how-can-i-list-only-non-empty-files-using-ls
	find "${outdir}" -type f -name "*.txt" -size 0 -exec rm {} \;
	find "${outdir}" -type f -name "*.txt" -exec sha256sum {} \; | sort -k2 >>"${outdir}/CHECKSUMS.txt"

	cleanup
}

# https://github.com/koalaman/shellcheck/wiki/SC2218
main
