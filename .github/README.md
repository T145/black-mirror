<div align="center">
  <img src="logo.png"
       alt="logo"
       longdesc="https://github.com/T145/the-blacklist/master/.github/logo.png"
       crossorigin="anonymous"
       referrerpolicy="no-referrer" />
  <h1>The Blacklist</h1>
  <h3>⚡ Speed | 🧱 Stability | 🔒 Security</h3>
  <br>
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
      <th style="text-align:center">List Name</th>
      <th style="text-align:center">File Contents</th>
      <th>Unique Entries</th>
      <th>File Size</th>
      <th style="text-align:center">Source</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:center">black_domain.txt</td>
      <td style="text-align:center">Domain entries</td>
      <td id="domain-count">9,020,347</td>
      <td id="domain-filesize">198M</td>
      <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_domain.tar.gz">black_domain.tar.gz</a> </td>
    </tr>
    <tr>
      <td style="text-align:center">black_ipv4.txt</td>
      <td style="text-align:center">IPv4 addresses</td>
      <td id="ipv4-count">1,504,147</td>
      <td id="ipv4-filesize">21M</td>
      <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_ipv4.tar.gz">black_ipv4.tar.gz</a> </td>
    </tr>
    <tr>
      <td style="text-align:center">black_ipv4_cidr.txt</td>
      <td style="text-align:center">IPv4 CIDR blocks</td>
      <td id="ipv4-cidr-count">WILL-UPDATE</td>
      <td id="ipv4-cidr-filesize">WILL-UPDATE</td>
      <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_ipv4_cidr.tar.gz">black_ipv4_cidr.tar.gz</a> </td>
    </tr>
    <tr>
      <td style="text-align:center">black_ipv6.txt</td>
      <td style="text-align:center">IPv6 addresses</td>
      <td id="ipv6-count">6,074</td>
      <td id="ipv6-filesize">198K</td>
      <td style="text-align:center"> <a href="https://github.com/T145/the-blacklist/releases/latest/download/black_ipv6.tar.gz">black_ipv6.tar.gz</a> </td>
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

[Extract any archived release](https://linuxize.com/post/how-to-create-and-extract-archives-using-the-tar-command-in-linux/#extracting-tar-archive) like so:

```bash
tar -xf black_{release}.tar.gz
```
> _NOTE: Windows 10 has native `tar` support._

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
