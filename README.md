<div align="center">
  <img src=".github/images/logo.png"
       width="600"
       alt="logo"
       longdesc="https://github.com/T145/black-mirror/master/README.md" />
  <h3>🌓 Reflection | 💿 Redundancy | ✅ Reliability</h3>
  <hr>
  <p>Automatically compiled and maintained malicious domain & IP blacklist.</p>
  <hr>
  <img src="https://badges.pufler.dev/created/T145/black-mirror"
       alt="nonce"
       longdesc="https://pufler.dev/git-badges/"
       crossorigin="anonymous"
       referrerpolicy="no-referrer" />
  <img src="https://badges.pufler.dev/updated/T145/black-mirror"
       alt="last_updated"
       longdesc="https://pufler.dev/git-badges/"
       crossorigin="anonymous"
       referrerpolicy="no-referrer" />
  <img src="https://badges.pufler.dev/visits/T145/black-mirror"
       alt="visits"
       longdesc="https://pufler.dev/git-badges/"
       crossorigin="anonymous"
       referrerpolicy="no-referrer" />
  <img src="https://img.shields.io/github/workflow/status/T145/black-mirror/Create%20Release/master?label=release&logo=github"
       alt="release"
       longdesc="https://github.com/badges/shields/"
       crossorigin="anonymous"
       referrerpolicy="no-referrer" />
  <img src="https://img.shields.io/github/workflow/status/T145/black-mirror/Update%20Docker%20Image/master?color=%232496ED&label=docker&logo=docker"
       alt="docker"
       longdesc="https://github.com/badges/shields/"
       crossorigin="anonymous"
       referrerpolicy="no-referrer" />
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
      <th>Files</th>
      <th>File Contents</th>
      <th>Unique Entries</th>
      <th>File Size</th>
      <th>MD5</th>
      <th>SHA1</th>
      <th>SHA256</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/T145/black-mirror/releases/download/latest/black_domain.txt">black_domain.txt</a></td>
      <td>Domain entries</td>
      <td id="domain-count">9,161,592</td>
      <td id="domain-filesize">201M</td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_domain.md5">[🔗]</a></td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_domain.sha1">[🔗]</a></td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_domain.sha256">[🔗]</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4.txt">black_ipv4.txt</a></td>
      <td>IPv4 addresses</td>
      <td id="ipv4-count">940,467</td>
      <td id="ipv4-filesize">13M</td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4.md5">[🔗]</a></td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4.sha1">[🔗]</a></td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4.sha256">[🔗]</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4_cidr.txt">black_ipv4_cidr.txt</a></td>
      <td>IPv4 CIDR blocks</td>
      <td id="ipv4-cidr-count">28,452</td>
      <td id="ipv4-cidr-filesize">480K</td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4_cidr.md5">[🔗]</a></td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4_cidr.sha1">[🔗]</a></td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4_cidr.sha256">[🔗]</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv6.txt">black_ipv6.txt</a></td>
      <td>IPv6 addresses</td>
      <td id="ipv6-count">7,709</td>
      <td id="ipv6-filesize">240K</td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv6.md5">[🔗]</a></td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv6.sha1">[🔗]</a></td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv6.sha256">[🔗]</a></td>
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

If you're using the `RADVD` daemon, prepend any listed hosts with [`::`](https://stackoverflow.com/questions/40189084/what-is-for-localhost-and-0-0-0-0). Otherwise, even if you have IPv6 support set up, prepend hosts with [`0.0.0.0`](https://github.com/StevenBlack/hosts#we-recommend-using-0000-instead-of-127001).

This has been tested across all the mentioned platforms using `dig{6}` on a small sample size and had each host null-routed successfully. [DNSmasq's man page](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) discusses configuration further, and [DDWRT's ad blocking wiki page](https://wiki.dd-wrt.com/wiki/index.php/Ad_blocking) provides some examples.

##### Amazon EC2 DNS Resolver

Follow [this guide](https://aws.amazon.com/premiumsupport/knowledge-center/dns-resolution-failures-ec2-linux/) to create a DNS server on a Amazon EC2 instance.

#### pihole

If you'd like to update when some sources do or not extract a production build, just use the [single-line list](https://discourse.pi-hole.net/t/how-to-add-blocklists-v5-and-later/32127) [`sources.pihole`](https://github.com/T145/black-mirror/blob/master/sources/sources.pihole). Note that this list only contains Pihole-compatible sources, and not all sources handled by The Blacklist. Some manual configuration may also be required.

#### unbound

Similar to dnsmasq, but requires more manual configuration. Name any products as a \*.conf file. [Then follow Steffinstanly's instructions on how to apply blocklists](https://medium.com/@steffinstanly/unbound-dns-blocking-3567986a5735).

#### personalDNSfilter

Use the domain list.

---

<div align="center">
  <h2>Together we'll make a better internet!</h2>
  <sub>A project by <a href="https://github.com/T145" target="_blank">T145</a> made with 💖<pub>
</div>
