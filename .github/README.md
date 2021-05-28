## Building the List

Use the following scripts to update The Blacklist:

---

### Linux/OSX

Dependencies:
- curl (included in coreutils on Linux)
- jq

#### **compile.sh**
```sh
#!/bin/sh

set -e

curl -s -H 'Accept: application/vnd.github.v3+json' \
    https://api.github.com/repos/T145/the-blacklist/contents/hosts |
    jq -r '.[] | [.download_url] | @tsv' |
    while IFS=$'\t' read -r url; do
        curl -s $url
    done >|the_blacklist.txt
```

---

### Windows

Dependencies:
- TODO

#### TODO

---

## List Format

1. No comments
2. No excess whitespace (trailing, blank lines)
3. Ending with `lf`
4. Prepended with `0.0.0.0 `
