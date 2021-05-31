
## List Format

1. No comments
2. No excess whitespace (trailing, blank lines)
3. Ending with `lf`
4. Prepended with `0.0.0.0 `
5. In multiple parts capped at 100MB (GitHub's max file size)

## Building the List

Use the following scripts to update The Blacklist:

---

### Linux/OSX

Dependencies:
- jq ([Linux](https://stedolan.github.io/jq/download/) / [OSX](https://formulae.brew.sh/formula/jq))

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
