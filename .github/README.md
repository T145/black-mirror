
## 🧠 Philosophy

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

## 📋 List Attributes

1. No comments
2. No excess whitespace (trailing, blank lines)
3. No lingering webscraper garbage
4. Ending with `lf`
5. `0.0.0.0 <domain/host>`
6. Updates at [0:00 UTC](https://www.timeanddate.com/time/zone/timezone/utc)

## 📚 List Sources

Initially used [sources provided by the OpenWRT plugin Adblock](https://github.com/openwrt/packages/blob/master/net/adblock/files/adblock.sources).
After realizing that the [StevenBlack](https://github.com/StevenBlack/hosts#sources-of-hosts-data-unified-in-this-variant)
and [Energized](https://github.com/EnergizedProtection/block#package-sources) listings were incorrect, the list grew after incorporating everything from them.
Any redundant sources shared between them and the original list have been removed. They are as follows in the original list:

**Energized + Extensions**
- adaway, adguard, adguard_tracking, bitcoin, disconnect, reg_cn, reg_cz, reg_de, reg_es, reg_fr, reg_it, reg_nl, reg_ro, reg_ru, reg_vn, stevenblack, spam404, stopforumspam, whocares, winhelp, yoyo
> The "Xtreme" extension isn't very descriptive, but has been included anyway.\
> All Anudeep lists are included except the Facebook list, so that has been added in.\
> Only the WinSpy Spy list is included, so the Extra and Update lists have been added in.

_Feel free to cross-reference these and double-check that unique lists were not dropped!_

### Other Integrated Sources

- [The Block List Project](https://blocklistproject.github.io/Lists/)
- [Blackbird](https://getblackbird.net/blacklist/hosts/)

## ⚓ List Links

Just grab an archive and extract it! These links will not change.

##### black_domains.txt
```
https://github.com/T145/the-blacklist/releases/latest/download/black_domains.tar.gz
```

##### black_ipv4.txt
```
https://github.com/T145/the-blacklist/releases/latest/download/black_ipv4.tar.gz
```

##### black_ipv6.txt
```
https://github.com/T145/the-blacklist/releases/latest/download/black_ipv6.tar.gz
```
