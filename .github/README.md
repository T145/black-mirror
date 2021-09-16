<div align="center">
  <img src="logo.png"
       alt="logo"
       longdesc="https://github.com/T145/the-blacklist/master/.github/logo.png"
       crossorigin="anonymous"
       referrerpolicy="no-referrer" />
  <h1>The Blacklist</h1>
  <h3>⚡ Speed | 🧱 Stability | 🔒 Security</h3>
  <br>
  <img src="https://hitcounter.pythonanywhere.com/count/tag.svg?url=https%3A%2F%2Fgithub.com%2FT145%2Fthe-blacklist" alt="Hits">
  <h3><a href="https://github.com/T145/black-mirror">BLACK MIRROR</a></h3>
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

### ⚓ Hyperlinks

<table>
  <thead>
    <tr>
      <th style="text-align:center">Files</th>
      <th style="text-align:center">File Contents</th>
      <th>Unique Entries</th>
      <th>File Size</th>
      <th>MD5</th>
      <th>SHA1</th>
      <th>SHA256</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-domain/black_domain.txt">black_domain.txt</a></td>
      <td style="text-align:center">Domain entries</td>
      <td id="domain-count">8,334,260</td>
      <td id="domain-filesize">178M</td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-domain/black_domain.md5">[🔗]</a></td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-domain/black_domain.sha1">[🔗]</a></td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-domain/black_domain.sha256">[🔗]</a></td>
    </tr>
    <tr>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv4/black_ipv4.txt">black_ipv4.txt</a></td>
      <td style="text-align:center">IPv4 addresses</td>
      <td id="ipv4-count">809,796</td>
      <td id="ipv4-filesize">11M</td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv4/black_ipv4.md5">[🔗]</a></td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv4/black_ipv4.sha1">[🔗]</a></td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv4/black_ipv4.sha256">[🔗]</a></td>
    </tr>
    <tr>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv4/black_ipv4_cidr.txt">black_ipv4_cidr.txt</a></td>
      <td style="text-align:center">IPv4 CIDR blocks</td>
      <td id="ipv4-cidr-count">26,323</td>
      <td id="ipv4-cidr-filesize">439K</td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv4/black_ipv4_cidr.md5">[🔗]</a></td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv4/black_ipv4_cidr.sha1">[🔗]</a></td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv4/black_ipv4_cidr.sha256">[🔗]</a></td>
    </tr>
    <tr>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv6/black_ipv6.txt">black_ipv6.txt</a></td>
      <td style="text-align:center">IPv6 addresses</td>
      <td id="ipv6-count">6,235</td>
      <td id="ipv6-filesize">203K</td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv6/black_ipv6.md5">[🔗]</a></td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv6/black_ipv6.sha1">[🔗]</a></td>
      <td style="text-align:center"><a href="https://github.com/T145/the-blacklist/releases/download/latest-ipv6/black_ipv6.sha256">[🔗]</a></td>
    </tr>
  </tbody>
</table>

## 📋 Attributes

1. No comments
2. No excess whitespace (trailing, blank lines)
3. No lingering webscraper garbage
4. Ending with `lf`
5. Domain-only, IPv4-only, and IPv6-only variants
6. Updates at [0:00 UTC](https://www.timeanddate.com/time/zone/timezone/utc)

## ⚒️ Usage

#### Desktop OS Hosts File

```bash
mawk '{print "0.0.0.0 " $0}' black_domain.txt >>hosts
# mawk '{print ":: " $0}' black_domain.txt >>hosts
mawk '{print "0.0.0.0 " $0}' black_ipv4.txt >>hosts
mawk '{print ":: " $0}' black_ipv6.txt >>hosts
```

#### dnsmasq

Many popular platforms such as OpenWRT, DDWRT, and Pihole use DNSmasq as their choice TCP powerhouse. After inspecting many domain blocklists you'll inevitably run across a list in the `dnsmasq.conf` format. This list doesn't support it because you can use the `addn-hosts` parameter to add hosts in the list.
Target a file that has the hosts in a format similar to the Desktop OS Hosts File format.

If you're using the `RADVD` daemon, prepend any listed hosts with [`::`](https://stackoverflow.com/questions/40189084/what-is-ipv6-for-localhost-and-0-0-0-0). Otherwise, even if you have IPv6 support set up, prepend hosts with [`0.0.0.0`](https://github.com/StevenBlack/hosts#we-recommend-using-0000-instead-of-127001).

I've tested this across all the mentioned platforms using `dig{6}` on a small sample size and had each host null-routed successfully. [DNSmasq's man page](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) discusses configuration further, and [DDWRT's ad blocking wiki page](https://wiki.dd-wrt.com/wiki/index.php/Ad_blocking) provides some examples.

#### pihole

If you'd like to update when some sources do or not extract a production build, just use the [single-line list](https://discourse.pi-hole.net/t/how-to-add-blocklists-v5-and-later/32127) [`sources.pihole`](https://github.com/T145/the-blacklist/blob/master/sources/sources.pihole). Note that this list only contains Pihole-compatible sources, and not all sources handled by The Blacklist. Some manual configuration may also be required.

#### unbound

Similar to dnsmasq, but requires more manual configuration. Name any products as a \*.conf file. [Then follow Steffinstanly's instructions on how to apply blocklists](https://medium.com/@steffinstanly/unbound-dns-blocking-3567986a5735).

#### personalDNSfilter

Use the domain list.

---

<div align="center">
  <h2>Together we'll make a better internet!</h2>
  <sub>A project by <a href="https://github.com/T145" target="_blank">T145</a> made with 💖<pub>
</div>
