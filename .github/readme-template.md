
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

## 📋 Attributes

1. No comments
2. No excess whitespace (trailing, blank lines)
3. No lingering webscraper garbage
4. Ending with `lf`
5. Domain-only, IPv4, and IPv6 variants
6. Updates at [0:00 UTC](https://www.timeanddate.com/time/zone/timezone/utc)

## 📚 Sources

> _Please report any redundant sources in an issue!_

- [OpenWRT Adblock Sources](https://github.com/openwrt/packages/blob/master/net/adblock/files/adblock.sources)
  - Redundant sources removed include the following: `adaway`, `adguard`, `adguard_tracking`, `anudeep`, `bitcoin`, `disconnect`, `reg_cn`, `reg_cz`, `reg_de`, `reg_es`, `reg_fr`, `reg_it`, `reg_nl`, `reg_ro`, `reg_ru`, `reg_vn`, `stevenblack`, `spam404`, `stopforumspam`, `whocares`, `winhelp`, `yoyo`
  - These redundant sources are included in the Energized list and its extensions
- [Energized Unified](https://github.com/EnergizedProtection/block#packs-2)
- [Energized Extensions](https://github.com/EnergizedProtection/block#extensions-2)
  - The `Xtreme Extension` isn't very descriptive, but has been included anyway
- [StevenBlack Extensions](https://github.com/StevenBlack/hosts/tree/master/extensions)
  - Unified hosts and some extensions contained in `Energized`
- [Anudeep Facebook](https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt)
  - [Other lists](https://github.com/anudeepND/blacklist) contained in `Energized`
- [WindowsSpyBlocker Extra & Update](https://github.com/crazy-max/WindowsSpyBlocker/tree/master/data/hosts)
  - Spy list contained in `Energized`
- [The Block List Project](https://blocklistproject.github.io/Lists/)
- [Blackbird for Windows](https://getblackbird.net/blacklist/hosts/)
- [Amazon Alexa Top 1M Sites](https://github.com/T145/the-blacklist/blob/master/sources.json#L5)
  - Used to block popular porn sites
- [FireHOL Level 4](https://github.com/firehol/blocklist-ipsets)
  - Levels 1-3 are included in `Energized Extensions`
- [IPverse](http://ipverse.net/)
- [1Hosts Xtra](https://github.com/badmojr/1Hosts)
  - Mini & Pro versions are now being included in `Energized`
- [Dean's Filterlist Sources](https://github.com/hl2guide/Filterlist-for-AdGuard-or-PiHole)
  - Unique sources include: [`blocklist_de`](https://www.blocklist.de/en/index.html), [`geoffrey_frogeye`](https://hostfiles.frogeye.fr/) (Taken from [`sebsauvage`](https://sebsauvage.net/hosts/hosts)), `threatcrowd`, [`antisocialengineer`](https://github.com/TheAntiSocialEngineer/AntiSocial-BlockList-UK-Community), `windscribe`, `cyberthreat`, `not_on_my_shift`

## ⚓ Hyperlinks

|     List Name    |                                                                     Description                                                                    | Unique Entries | ~ File Size |                                                   Source                                                  |
|:----------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------:|----------------|-------------|:---------------------------------------------------------------------------------------------------------:|
| black_domain.txt |                                                            Contains regular host entries                                                           |        __DOMAIN_ENTRIES        |      __DOMAIN_SIZE       | [black_domain.tar.gz](https://github.com/T145/the-blacklist/releases/latest/download/black_domain.tar.gz) |
|  black_ipv4.txt  | Prepended with [`0.0.0.0`](https://github.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist#recommendation-for-using-0000-instead-of-127001) |        __IPV4_ENTRIES        |      __IPV4_SIZE       |   [black_ipv4.tar.gz](https://github.com/T145/the-blacklist/releases/latest/download/black_ipv4.tar.gz)   |
|  black_ipv6.txt  |                    Prepended with [`::`](https://stackoverflow.com/questions/40189084/what-is-ipv6-for-localhost-and-0-0-0-0)                    |        __IPV6_ENTRIES        |      __IPV6_SIZE       |   [black_ipv6.tar.gz](https://github.com/T145/the-blacklist/releases/latest/download/black_ipv6.tar.gz)   |

## 🧰 Usage

#### dnsmasq

Many popular platforms such as OpenWRT, DDWRT, and Pihole use DNSmasq as their choice TCP powerhouse.
After inspecting many domain blocklists you'll inevitably run across a list in the `dnsmasq.conf` format.
This list doesn't support it because you can just place `addn-hosts=black_ipv{4-6}.txt` in the config or as a passed parameter and have it work properly.
I've tested this across all the mentioned platforms using `dig{6}` on a small sample size and had each host null-routed successfully.
[DNSmasq's man page](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) discusses this further, and [DDWRT's ad blocking wiki page](https://wiki.dd-wrt.com/wiki/index.php/Ad_blocking) provides examples.

#### ubound

Similar to dnsmasq, but requires more manual configuration.
Use the `black_ipv{4-6}.txt` list(s), and rename the extracted file into a *.conf file.
[Steffinstanly discusses how to apply blocklists](https://medium.com/@steffinstanly/unbound-dns-blocking-3567986a5735).

#### personalDNSfilter

Use the domain list.
