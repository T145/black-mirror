#!/usr/bin/env bash

#shopt -s extdebug     # or --debugging
set +H +o history     # disable history features (helps avoid errors from "!" in strings)
shopt -u cmdhist      # would be enabled and have no effect otherwise
shopt -s execfail     # ensure interactive and non-interactive runtime are similar
shopt -s extglob      # enable extended pattern matching (https://www.gnu.org/software/bash/manual/html_node/Pattern-Matching.html)
set -euET -o pipefail # put bash into strict mode & have it give descriptive errors
umask 055             # change all generated file perms from 755 to 700
export LC_ALL=C       # force byte-wise sorting and default langauge output

SOURCES='/data/v1/targets.json'
STATUS='/dist/ats/target-status.json'
CACHE=$(mktemp -d)
readonly SOURCES STATUS CACHE

trap 'rm -rf "$CACHE"' EXIT || exit 1

apply_filter() {
	case "$1" in
	NONE) cat -s ;;
	OISD)
		pandoc -f html -t plain |
			mawk '$0~/^http/'
		;;
	1HOSTS) mawk '$0~/^[^#]/' ;;
	STEVENBLACK) jq -r 'to_entries[] | .value.sourcesdata[].url' ;;
	ENERGIZED) jq -r '.sources[].url' ;;
	SHERIFF53) jq -r '.[] | "\(.url[])", "\(select(.mirror) | .mirror[])"' ;;
	DNSFORFAMILY) mawk '$0~/^[^#]/{split($2,a,"\|\|\|\|\|"); print a[1]}' ;;
	ARAPURAYIL) jq -r '.sources[].url' ;;
	HBLOCK) mawk '$0~/^\[source\-/{print $2}' ;;
	BLOCKCONVERT) mlr --mmap --csv --skip-comments cut -f url ;;
	*)
		echo "[INVALID FILTER]: ${1}"
		exit 1
		;;
	esac |
		# Format github.com/*/raw/* and rawcdn.githack.com URLs as raw.githubusercontent.com, b/c they aren't technically mirrors and redirect to raw.githubusercontent.com.
		# Any github.com/*/archive/* URLs are ignored, since single lists are used over an entire repository.
		./scripts/ats/raw_github_url_format.awk |
		mawk 'NF && !seen[$0]++' | # Filter blank lines and duplicates!
		#httpx -r configs/resolvers.txt -silent -t 200000 |
		parsort -bfiu -S 100% --parallel=200000 -T "$CACHE" |
		parallel --pipe -k -j100% grep -Fxvf dist/sources.txt -
}

main() {
	git config --global --add safe.directory /__w/black-mirror/black-mirror
	jq -SM '.' "$SOURCES" | sponge "$SOURCES"

	jq -r 'to_entries[] | (.value.mirror), " out=\(.key).txt"' "$SOURCES" |
		(set +e && aria2c -i- -d "$CACHE" --conf-path='./configs/aria2.conf' && set -e) || set -e

	local list

	jq -r 'to_entries[] | "\(.key)#\(.value.content.filter)"' "$SOURCES" |
		while IFS='#' read -r key filter; do
			list="${CACHE}/${key}.txt"

			if [ -n "$list" ]; then
				apply_filter "$filter" <"$list" | sponge "dist/ats/${key}.txt"
			fi
		done

	lychee --exclude-mail -nEf Json -o "$STATUS" -T 200 -t 10 -r 0 -u 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:101.0) Gecko/20100101 Firefox/101.0' dist/ats/*.txt 1>/dev/null || true
	jq -SM '.' "$STATUS" | sponge "$STATUS"

	jq -r '.fail_map | to_entries[] | .key as $k | .value[] | select(.status | startswith("Failed:") or startswith("Cached:")) | "\($k)#\(.url)"' "$STATUS" |
		while IFS='#' read -r target url; do
			echo "$url" | grep -Fxvf - "$target" | sponge "$target"
		done
}

main

# reset the locale after processing
unset LC_ALL
