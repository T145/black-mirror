<div align="center">
  <h1>The Blacklist</h1>
  <h3>⚡ Speed | 🧱 Stability | 🔒 Security</h3>
</div>

## 🥅 Goals

- Promote privacy
  - Blacklist all telemetry services and other data harvesting services.
  - Whitelist all services like Tor, VPNs, and trusted torrenting providers.
- Promote security
  - Blacklist known malicious actors, active attackers, sketchy sites, malvertising, etc.
- Promote sanity
  - Blacklist advertising sources in general, on both desktop and mobile clients.
  - Blacklist social media, irreputable news sources, propaganda, etc.
- Block garbage
  - Blacklist illegal sites, pornography, untrusted torrenting providers, etc.
- Be bigger, not bloated
  - List sources promote growth, minimal redundancy, and modern application.

## 📋 Attributes

1. No comments
2. No excess whitespace (trailing, blank lines)
3. No lingering webscraper garbage
4. Ending with `lf`
5. Domain-only, IPv4, and IPv6 variants
6. Updates at [0:00 UTC](https://www.timeanddate.com/time/zone/timezone/utc)

## 📚 Sources

> _Please report any redundant sources in an issue!_ _Be sure to check out the custom [blacklist](https://github.com/T145/the-blacklist/blob/user-submissions/blacklist.txt) and [whitelist](https://github.com/T145/the-blacklist/blob/user-submissions/whitelist.txt)!_

### ⚫ Blacklists

*   [OpenWRT Adblock](https://github.com/openwrt/packages/blob/master/net/adblock/files/adblock.sources) Sources
    *   Sources in `Energized Unified & Extensions` that were removed: `adaway`, `adguard`, `adguard_tracking`, `anudeep`, `bitcoin`, `disconnect`, `reg_cn`, `reg_cz`, `reg_de`, `reg_es`, `reg_fr`, `reg_it`, `reg_nl`, `reg_ro`, `reg_ru`, `reg_vn`, `stevenblack`, `spam404`, `stopforumspam`, `whocares`, `winhelp`, `yoyo`
*   [Energized Unified](https://github.com/EnergizedProtection/block#packs-2)
*   [Energized Extensions](https://github.com/EnergizedProtection/block#extensions-2)
    *   The `Xtreme Extension` isn't very descriptive, but has been included anyway
*   [StevenBlack Extensions](https://github.com/StevenBlack/hosts/tree/master/extensions)
    *   Unified hosts and some extensions contained in `Energized`
*   [AnudeepND Facebook](https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt)
    *   [Other lists](https://github.com/anudeepND/blacklist) contained in `Energized`
*   [WindowsSpyBlocker Extra & Update](https://github.com/crazy-max/WindowsSpyBlocker/tree/master/data/hosts)
    *   Spy list contained in `Energized`
*   [The Block List Project](https://blocklistproject.github.io/Lists/)
*   [Blackbird for Windows](https://getblackbird.net/blacklist/hosts/)
*   [Amazon Alexa Top 1M Sites](https://www.alexa.com/topsites)
    *   Used to block popular porn sites
*   [FireHOL Level 4](https://github.com/firehol/blocklist-ipsets)
    *   Levels 1-3 are included in `Energized Extensions`
*   <strike>[IPverse](http://ipverse.net/)</strike>
*   [1Hosts Xtra](https://github.com/badmojr/1Hosts)
    *   Mini & Pro versions are now being included in `Energized`
*   [Dean's Filterlist](https://github.com/hl2guide/Filterlist-for-AdGuard-or-PiHole) Sources
    *   Unique sources include: [`blocklist_de`](https://www.blocklist.de/en/index.html), [`geoffrey_frogeye`](https://hostfiles.frogeye.fr/) (Taken from [`sebsauvage`](https://sebsauvage.net/hosts/hosts)), `threatcrowd`, [`antisocialengineer`](https://github.com/TheAntiSocialEngineer/AntiSocial-BlockList-UK-Community), [`windscribe`](https://controld.com/static/e08e8c03918a7abb574c2884a5a177f3/a45dc/filters-tablet%402x.png), `cyberthreat`, `not_on_my_shift`
    *   [lightswitch05/developerdan](https://github.com/lightswitch05/hosts/tree/master/docs/lists) Sources
        *   Unique sources include: `amp_hosts`, `facebook`, `hate_and_junk`
        *   The rest are included in `Energized`
    *   [pDNSf](https://github.com/j-moriarti/pDNSf-Hosts-collection/blob/master/Download-and-Process-Hosts.sh) Sources
        *   Unique sources include: [`resecure_me`](https://rescure.me/feeds.html), [`kriskintel`](https://kriskintel.com/), [`filtri_dns`](https://filtri-dns.ga/)
        *   [blockconvert](https://github.com/mkb2091/blockconvert/blob/master/filterlists.csv)/[Host File Project](https://github.com/hectorm/hblock/blob/master/SOURCES.md) Sources
            *   Unique sources include: [`digitalside`](https://osint.digitalside.it/#SubscribeMISPfeed)
*   [Abuse.ch](https://abuse.ch/#about) Sources
    *   Unique sources include: `feodotracker`, `sslbl`, `urlhaus`
*   [Blackweb](https://github.com/maravento/blackweb/blob/master/bwupdate/bwupdate.sh) Sources
    *   Unique sources include: [`360_netlab`](https://data.netlab.360.com/), [`cybercrime`](https://cybercrime-tracker.net/), [`taz.net.au`](http://taz.net.au/Mail/)
*   Malc0de Domains
    *   IPs are included in `Energized`
    *   **_MALC0DE'S RSS FEED CONTAINS SHADE RANSOMWARE, SO THE SITE HAS NOT BEEN LINKED!_**
    *   My parsing is strict, so there shouldn't be any problems referencing this source. This is also a blacklist, so there shouldn't be any way to back door things.
*   [CyberSaiyanIT](https://github.com/CyberSaiyanIT/InfoSharing)

### ⚪ Whitelists

*   [Energized Unblock](https://github.com/EnergizedProtection/unblock#packs)
*   [AnudeepND False Positives](https://github.com/anudeepND/blacklist/blob/master/miscellaneous/false-positives.txt)
*   [AnudeepND Whitelist](https://github.com/anudeepND/whitelist#overview)
*   [Hipo University Domains List](https://github.com/Hipo/university-domains-list#university-domains-and-names-data-list--api)
*   [Public DNS Server List](https://public-dns.info/)

## ⚓ Hyperlinks

> IPv4 and IPv6 builds include the Domain list!

<table>
  <thead>
  <tr>
    <th style="text-align:center">List Name</th>
    <th style="text-align:center">Description</th>
    <th>Unique Entries</th>
    <th>~ File Size</th>
    <th style="text-align:center">Source</th>
  </tr>
  </thead>
  <tbody>
  <tr>
    <td style="text-align:center">black_domain.txt</td>
    <td style="text-align:center">Contains regular host entries</td>
    <td id="domain-count">8,727,091</td>
    <td id="domain-filesize">190M</td>
    <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_domain.tar.gz">black_domain.tar.gz</a> </td>
  </tr>
  <tr>
    <td style="text-align:center">black_ipv4.txt</td>
    <td style="text-align:center"> Hosts prepended with &quot;<a href="https://github.com/StevenBlack/hosts#we-recommend-using-0000-instead-of-127001">0.0.0.0</a>&quot; </td>
    <td id="ipv4-count">418,596</td>
    <td id="ipv4-filesize">266M</td>
    <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_ipv4.tar.gz">black_ipv4.tar.gz</a> </td>
  </tr>
  <tr>
    <td style="text-align:center">black_ipv6.txt</td>
    <td style="text-align:center"> Hosts prepended with &quot;<a href="https://stackoverflow.com/questions/40189084/what-is-ipv6-for-localhost-and-0-0-0-0">::</a>&quot; </td>
    <td id="ipv6-count">0</td>
    <td id="ipv6-filesize">215M</td>
    <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_ipv6.tar.gz">black_ipv6.tar.gz</a> </td>
  </tr>
  </tbody>
</table>

## ⚒️ Usage

#### dnsmasq

Many popular platforms such as OpenWRT, DDWRT, and Pihole use DNSmasq as their choice TCP powerhouse. After inspecting many domain blocklists you'll inevitably run across a list in the `dnsmasq.conf` format. This list doesn't support it because you can just place `addn-hosts=black_ipv{4-6}.txt` in the config or as a passed parameter and have it work properly. If you're using the `RADVD` daemon, use the IPv6 list. Otherwise, use the IPv4 version even if you have IPv6 support set up. I've tested this across all the mentioned platforms using `dig{6}` on a small sample size and had each host null-routed successfully. [DNSmasq's man page](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) discusses this further, and [DDWRT's ad blocking wiki page](https://wiki.dd-wrt.com/wiki/index.php/Ad_blocking) provides examples.

#### unbound

Similar to dnsmasq, but requires more manual configuration. Use the `black_ipv{4-6}.txt` list(s), and rename the extracted file into a \*.conf file. [Steffinstanly discusses how to apply blocklists](https://medium.com/@steffinstanly/unbound-dns-blocking-3567986a5735).

#### personalDNSfilter

Use the domain list.

#### Desktop OS Hosts File

Use both the IPv4 and IPv6 lists.

---

<div align="center">
  <h2>Together we'll make a better internet!</h2>
  <sub>A project by <a href="https://github.com/T145" target="_blank">T145</a> with 💖<pub>
</div>
