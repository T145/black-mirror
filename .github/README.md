<div align="center">
  <img src="logo.png"
       alt="logo"
       longdesc="https://github.com/T145/the-blacklist/master/.github/logo.png"
       crossorigin="anonymous"
       referrerpolicy="no-referrer" />
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
5. Domain-only, IPv4-only, and IPv6-only variants
6. Updates at [0:00 UTC](https://www.timeanddate.com/time/zone/timezone/utc)

## 📚 Sources

> _Please report any redundant sources in an issue! Be sure to check out the custom [blacklist](https://github.com/T145/the-blacklist/blob/user-submissions/blacklist.txt) and [whitelist](https://github.com/T145/the-blacklist/blob/user-submissions/whitelist.txt)!_

### ⚫ Blacklists

*   [OpenWRT Adblock](https://github.com/openwrt/packages/blob/master/net/adblock/files/adblock.sources) Sources
    *   Unique
        *   android_tracking
        *   andryou
        *   anti_ad
        *   firetv_tracking
        *   games_tracking
        *   gaming
        *   notracking
        *   oisd_full
        *   openphish
        *   phishing_army
        *   reg_fi
        *   reg_id
        *   reg_kr
        *   reg_pl1
        *   reg_pl2
        *   reg_se
        *   shallalist
        *   smarttv_tracking
        *   utcapitole
        *   wally3k
    *   Other sources contained in **Energized Unified & Extensions**
    *   Found
        *   [oisd_extra](https://oisd.nl/downloadsXtra)
*   [Energized Unified](https://github.com/EnergizedProtection/block#packs-2)
*   [Energized Extensions](https://github.com/EnergizedProtection/block#extensions-2)
    *   The **Xtreme Extension** isn't very descriptive, but has been included anyway
*   [StevenBlack Extensions](https://github.com/StevenBlack/hosts/tree/master/extensions)
    *   Unified hosts and some extensions contained in **Energized Unified**
*   [AnudeepND Facebook](https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt)
    *   [Other lists](https://github.com/anudeepND/blacklist) contained in **Energized Unified**
*   [WindowsSpyBlocker Extra & Update](https://github.com/crazy-max/WindowsSpyBlocker/tree/master/data/hosts)
    *   Spy list contained in **Energized Unified**
*   [The Block List Project](https://blocklistproject.github.io/Lists/)
*   [Blackbird for Windows](https://getblackbird.net/blacklist/hosts/)
*   <strike>[Alexa Top 1M](https://s3.amazonaws.com/alexa-static/top-1m.csv.zip)</strike>
    *   <strike>Used to block popular porn sites</strike>
*   [FireHOL Level 4](https://github.com/firehol/blocklist-ipsets)
    *   Levels 1-3 are included in **Energized Extensions**
*   <strike>[IPverse](http://ipverse.net/)</strike>
*   [1Hosts Xtra](https://github.com/badmojr/1Hosts)
    *   Mini & Pro versions are now being included in **Energized Unified**
*   [Dean's Filterlist](https://github.com/hl2guide/Filterlist-for-AdGuard-or-PiHole) Sources
    *   Unique
        *   [blocklist_de](https://www.blocklist.de/en/index.html)
        *   [geoffrey_frogeye](https://hostfiles.frogeye.fr/)
            *   Taken from [sebsauvage](https://sebsauvage.net/hosts/hosts)
        *   [threatcrowd](https://threatcrowd.org/)
        *   [antisocialengineer](https://github.com/TheAntiSocialEngineer/AntiSocial-BlockList-UK-Community)
        *   [windscribe](https://controld.com/static/e08e8c03918a7abb574c2884a5a177f3/a45dc/filters-tablet%402x.png)
        *   [cyberthreat](https://www.cyberthreatcoalition.org/blocklist)
        *   [not_on_my_shift](https://orca.pet/notonmyshift/)
    *   [lightswitch05/developerdan](https://github.com/lightswitch05/hosts/tree/master/docs/lists) Sources
        *   Unique
            *   amp_hosts
            *   facebook
            *   hate_and_junk
        *   The rest are included in **Energized Unified**
    *   [pDNSf](https://github.com/j-moriarti/pDNSf-Hosts-collection/blob/master/Download-and-Process-Hosts.sh) Sources
        *   Unique
            *   [resecure_me](https://rescure.me/feeds.html)
            *   [kriskintel](https://kriskintel.com/)
            *   [filtri_dns](https://filtri-dns.ga/)
            *   [mailscanner](http://phishing.mailscanner.info/)
            *   [binarydefense](https://www.binarydefense.com/)
        *   [blockconvert](https://github.com/mkb2091/blockconvert/blob/master/filterlists.csv)/[Host File Project](https://github.com/hectorm/hblock/blob/master/SOURCES.md) Sources
            *   Unique
                *   [digitalside](https://osint.digitalside.it/#SubscribeMISPfeed)
                *   [matomo_spam](https://github.com/matomo-org/referrer-spam-list)
*   [Abuse.ch](https://abuse.ch/#about) Sources
    *   Unique
        *   feodotracker
        *   sslbl
        *   urlhaus
*   [BlackWeb](https://github.com/maravento/blackweb#blocklists) Sources
    *   Unique
        *   [360_netlab](https://data.netlab.360.com/)
        *   [cybercrime](https://cybercrime-tracker.net/)
        *   [taz_spam](http://taz.net.au/Mail/)
*   [BlackIP](https://github.com/maravento/blackip#blocklists) Sources
    *   Unique
        *   [bruteforceblocker](http://danger.rulez.sk/index.php/bruteforceblocker/)
        *   [myip_full_blacklist](https://myip.ms/browse/blacklist)
    *   Found
        *   [myip_webcrawlers](https://myip.ms/browse/web_bots)
*   Malc0de Domains
    *   IPs are included in **Energized**
    *   **_MALC0DE'S RSS FEED CONTAINS SHADE RANSOMWARE, SO THE SITE HAS NOT BEEN LINKED!_**
    *   My parsing is strict, so there shouldn't be any problems referencing this source. This is also a blacklist, so there shouldn't be any way to back door things.
*   [CyberSaiyanIT](https://github.com/CyberSaiyanIT/InfoSharing)
*   [UnrealSecurity](https://github.com/UnrealSecurity/badips)
*   [4skinSkywalker Anti Porn](https://github.com/4skinSkywalker/anti-porn-hosts-file)
*   [EmergingThreats](https://rules.emergingthreats.net/blockrules/)
*   [Sheriff53](https://notabug.org/phronimon/Sheriff53/src/master/docs/THIRD_PARTY_LISTS.md) Sources
    *   Unique
        *   [ios_trackers](https://github.com/jakejarvis/ios-trackers)
        *   [apple_telemetry](https://github.com/adversarialtools/apple-telemetry)
*   [ISC Sans](https://isc.sans.edu/)/[DShield](https://www.dshield.org/)
    *   Unique
        *   [adscore](https://www.adscore.com/)
        *   [alphastrike](https://www.alphastrike.io/en/frontpage/)
        *   [arbor](https://www.netscout.com/arbor-ddos)
        *   [blindferret](https://zmap.io/)
        *   [censys](https://censys.io/)
        *   [ciarmy](https://cinsarmy.com/list-download/)
        *   [cybergreen](https://github.com/cybergreen-net)
        *   [erratasec](https://github.com/robertdavidgraham/masscan)
        *   [internetcensus](https://www.internet-census.org/home.html)
        *   [ipip](https://en.ipip.net/)
        *   [netsystems](https://www.netsystemsresearch.com/)
        *   [onyphe](https://onyphe.io/)
        *   [rapid7sonar](https://opendata.rapid7.com/)
        *   [recyber](https://www.recyber.net/)
        *   [scorecard](https://www.scorecardresearch.com/about.aspx?newlanguage=1)
        *   [shadowserver](https://www.shadowserver.org/topics/scans/)
        *   [shodan](https://www.shodan.io/)
        *   [stretchoid](http://www.stretchoid.com/)
        *   (Skipping tldns and tor since they're "other" lists and not especially malicious)
            * Whitelist TLD Name Servers and Tor Exit Nodes from Tor Project?
        *   [univmichigan](https://umich.edu/)
        *   [univsydney](https://www.sydney.edu.au/)
    *   Found
        *   [cinsscore](https://cinsscore.com/#list)
        *   [openportstats](http://www.openportstats.com/)
            *   Similar to IPverse; not included
*   [Rutgers University Attack Log](https://www.rutgers.edu/)
*   [threatsourcing](https://www.threatsourcing.com/)
*   [maltrail](https://github.com/stamparm/maltrail#blacklist)
*   [Charles B. Haley](http://charles.the-haleys.org/)
*   [darklist](https://www.darklist.de/)
*   [h3x](https://tracker.h3x.eu/)
*   [pornrecords](https://github.com/mypdns/porn-records#submit)
*   [cryptolaemus](https://paste.cryptolaemus.com/)
*   [vxvault](http://vxvault.net/ViriList.php)
*   [alienvault](https://status.alienvault.cloud/)
*   [turris](https://project.turris.cz/greylist-data/legend.txt)

### ⚪ Whitelists

*   [Energized Unblock](https://github.com/EnergizedProtection/unblock#packs)
*   [AnudeepND False Positives](https://github.com/anudeepND/blacklist/blob/master/miscellaneous/false-positives.txt)
*   [AnudeepND Whitelist](https://github.com/anudeepND/whitelist#overview)
*   [BlackWeb](https://github.com/maravento/blackweb#allowlists-urltld) Sources
    *   Unique
        *   [hipo_universities](https://github.com/Hipo/university-domains-list#university-domains-and-names-data-list--api)
        *   [public_dns](https://public-dns.info/)
*   [BlackIP](https://github.com/maravento/blackip#blocklists) Sources
    *   Unique
        *   [tor_bulkexitlist](https://check.torproject.org/api/bulk)
        *   [dan_me_uk](https://www.dan.me.uk/)

### 🧟 Zombies

> Sources that are dead and not included but may be [worth mentioning](https://blog.talosintelligence.com/2021/03/domain-dumpster-diving.html)

*   [BlackWeb](https://github.com/maravento/blackweb#blocklists) Sources
    *   [Squidguard Archive](http://squidguard.mesd.k12.or.us/)
        *   Found individually a while back
        *   Contains some obvious placeholder/garbage domains
*   [pDNSf](https://github.com/j-moriarti/pDNSf-Hosts-collection/blob/master/Download-and-Process-Hosts.sh) Sources
    *   [Zonefiles.io](https://zonefiles.io/compromised-ip-list/)
        *   Supposedly up-to-date, but references many offline resources like the legacy abuse.ch domains
*   [Sheriff53](https://notabug.org/phronimon/Sheriff53/src/master/docs/THIRD_PARTY_LISTS.md) Sources
    *   [BarbBlock](https://github.com/paulgb/BarbBlock/blob/master/blacklists/domain-list.txt)
    *   [NSABlocklist](https://github.com/nextdns/metadata/blob/master/privacy/blocklists/nsa-blocklist.json)
*   [Wael](https://www.wael.name/other/best-blocklist/)
*   [Sblam](https://github.com/kornelski/Sblam/tree/master/data)
*   [St. Dominic's Priory College](https://www.stdominics.sa.edu.au/) [Droplists](https://threatintel.stdominics.sa.edu.au/)
*   [URLVir](https://www.urlvir.com/)
*   [unit42](https://github.com/pan-unit42/iocs)
    *   Select `Go to file`, then search using the term "domains"
*   [fireeye](https://github.com/fireeye/iocs)
*   [aptnotes](https://github.com/aptnotes/data#how-is-this-data-being-utilized)
*   [malware-indicators](https://github.com/citizenlab/malware-indicators)
*   [da667](https://github.com/da667/667s_Shitlist)
*   [malware-ioc](https://github.com/eset/malware-ioc)
*   [malwaredomains](http://malwaredomains.lehigh.edu/files/)
*   [multiproxy](https://multiproxy.org/)
*   [joewein](https://www.joewein.net/)
    *   https://www.joewein.net/dl/bl/dom-bl-base.txt
    *   https://www.joewein.net/dl/bl/dom-bl.txt
*   [malwaredomainlist](http://www.malwaredomainlist.com/)
*   [malware-traffic-analysis](https://www.malware-traffic-analysis.net/index.html)
*   [nothink](https://www.nothink.org/)
*   [targetedthreats](https://github.com/botherder/targetedthreats/)
*   [policeman-rulesets](https://github.com/futpib/policeman-rulesets/)
*   malwared
    *   https://malwared.malwaremustdie.org/rss.php
    *   https://malwared.malwaremustdie.org/rss_bin.php
    *   https://malwared.malwaremustdie.org/rss_ssh.php
*   [threatfeeds](https://threatfeeds.io/)
    *   Some HTTP-200 sources updated a long time ago
*   [yourcmc](http://vmx.yourcmc.ru/BAD_HOSTS.IP4)
    *   `Last-Modified: Wed, 04 Jul 2012 21:04:35 GMT`
*   [iblocklist](https://www.iblocklist.com/lists)

## ⚓ Hyperlinks

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
      <td style="text-align:center">Contains regular domain entries</td>
      <td id="domain-count">8,836,431</td>
      <td id="domain-filesize">192M</td>
      <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_domain.tar.gz">black_domain.tar.gz</a> </td>
    </tr>
    <tr>
      <td style="text-align:center">black_ipv4.txt</td>
      <td style="text-align:center">Contains valid IPv4 addresses &amp; CIDR blocks</td>
      <td id="ipv4-count">1,541,012</td>
      <td id="ipv4-filesize">21M</td>
      <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_ipv4.tar.gz">black_ipv4.tar.gz</a> </td>
    </tr>
    <tr>
      <td style="text-align:center">black_ipv6.txt</td>
      <td style="text-align:center">Contains valid IPv6 addresses</td>
      <td id="ipv6-count">6,036</td>
      <td id="ipv6-filesize">197K</td>
      <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_ipv6.tar.gz">black_ipv6.tar.gz</a> </td>
    </tr>
  </tbody>
</table>

## ⚒️ Usage

[Extract any archived release](https://linuxize.com/post/how-to-create-and-extract-archives-using-the-tar-command-in-linux/#extracting-tar-archive) like so:

```bash
tar -xf black_{release}.tar.gz
```
> _NOTE: Windows 10 has native `tar` support._

#### dnsmasq

Many popular platforms such as OpenWRT, DDWRT, and Pihole use DNSmasq as their choice TCP powerhouse. After inspecting many domain blocklists you'll inevitably run across a list in the `dnsmasq.conf` format. This list doesn't support it because you can use the `addn-hosts` parameter to hosts in the list.

```bash
gawk '{print "0.0.0.0 " $0}' black_domain.txt >>etc_hosts # OR gawk '{print ":: " $0}' black_domain.txt >>etc_hosts
```

If you're using the `RADVD` daemon, prepend any hosts with [`::`](https://stackoverflow.com/questions/40189084/what-is-ipv6-for-localhost-and-0-0-0-0). Otherwise, even if you have IPv6 support set up, prepend hosts with [`0.0.0.0`](https://github.com/StevenBlack/hosts#we-recommend-using-0000-instead-of-127001).

I've tested this across all the mentioned platforms using `dig{6}` on a small sample size and had each host null-routed successfully. [DNSmasq's man page](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) discusses configuration further, and [DDWRT's ad blocking wiki page](https://wiki.dd-wrt.com/wiki/index.php/Ad_blocking) provides some examples.

#### unbound

Similar to dnsmasq, but requires more manual configuration. Name any products as a \*.conf file. [Then follow Steffinstanly's instructions on how to apply blocklists](https://medium.com/@steffinstanly/unbound-dns-blocking-3567986a5735).

#### personalDNSfilter

Use the domain list.

#### Desktop OS Hosts File

```bash
gawk '{print "0.0.0.0 " $0}' black_domain.txt >>hosts # OR gawk '{print ":: " $0}' black_domain.txt >>hosts
gawk '{print "0.0.0.0 " $0}' black_ipv4.txt >>hosts
gawk '{print ":: " $0}' black_ipv6.txt >>hosts
```

---

<div align="center">
  <h2>Together we'll make a better internet!</h2>
  <sub>A project by <a href="https://github.com/T145" target="_blank">T145</a> made with 💖<pub>
</div>
