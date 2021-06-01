
# Philosophy

- Keep it 100% open-source.
> The "how it's made" is just as important as the final product. Many open-source blocklist projects I've seen don't have "how" made public.
> This project is open and flexible, so you can fork it and whitelist what you need for personalized application.
- Make it secure.
> This project takes on a firewall security mindset, which is basically block everything and whitelist what's needed.
> Obviously this list isn't a firewall, so it just blocks as much as possible.
> Please report any "false positives" in an issue.
> Be sure to set up client and network firewalls, as this is no substitute.
- Let it grow!
> Contribute any useful sources you can think of manually by editting the `sources.json` file directly on a fork and making a pull request,
> or by creating an issue and placing your recommendations there. Help The Blacklist reach `node_modules`-level heights!

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
