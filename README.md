<div align="center">
  <img src=".github/images/logo.png"
       width="600"
       alt="logo"
       longdesc="https://github.com/T145/black-mirror/master/README.md" />
  <h3>🌓 Reflection | 💿 Redundancy | ✅ Reliability</h3>
  <hr>
  <p>Automatically compiled and maintained malicious domain & IP blacklist.</p>
  <hr>
		<a href="https://github.com/T145/black-mirror/commits/master.atom">
			<img src="https://img.shields.io/static/v1?logo=rss&label=rss&message=feed&color=FFA500"
								alt="release"
								longdesc="https://github.com/badges/shields/"
								crossorigin="anonymous"
								referrerpolicy="no-referrer" />
		</a>
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
      <th>File Name</th>
      <th>File Content</th>
      <th>Unique Entries</th>
      <th>File Size</th>
      <th>Checksums</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><a href="https://github.com/T145/black-mirror/releases/download/latest/black_domain.txt">black_domain.txt</a></td>
      <td>Domain entries</td>
      <td id="domain-count">9,289,543</td>
      <td id="domain-filesize">204M</td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_domain.checksums">[🔗]</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4.txt">black_ipv4.txt</a></td>
      <td>IPv4 addresses</td>
      <td id="ipv4-count">925,827</td>
      <td id="ipv4-filesize">13M</td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4.checksums">[🔗]</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4_cidr.txt">black_ipv4_cidr.txt</a></td>
      <td>IPv4 CIDR blocks</td>
      <td id="ipv4-cidr-count">29,166</td>
      <td id="ipv4-cidr-filesize">491K</td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv4_cidr.checksums">[🔗]</a></td>
    </tr>
    <tr>
      <td><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv6.txt">black_ipv6.txt</a></td>
      <td>IPv6 addresses</td>
      <td id="ipv6-count">6,312</td>
      <td id="ipv6-filesize">206K</td>
      <td align="center"><a href="https://github.com/T145/black-mirror/releases/download/latest/black_ipv6.checksums">[🔗]</a></td>
    </tr>
  </tbody>
</table>

### 🧮 Checksum Evaluation

```
cat black_domain.txt | sha256sum -c black_domain.checksums --status && echo $?
```

A return code of `0` means the check was successful. The specific checksum command can be any of the following:

- `md5sum`
- `b2sum`
- `sha1sum`
- `sha224sum`
- `sha256sum`
- `sha384sum`
- `sha512sum`

### 🐙 Fetching GitHub Releases

Recently, GitHub Release artifacts have been appearing with hashes after their names and before their file extensions.
It's not an issue with the build process, and only happens after being uploaded.
Why this specifically has been happening is unknown, but here are some temporary workaround examples.

#### Get all build artifacts

```
curl -s https://api.github.com/repos/T145/black-mirror/releases/latest | jq -r '.assets[].browser_download_url'
```

#### Get a build artifact & its checksum

```
curl -s https://api.github.com/repos/T145/black-mirror/releases/latest | jq -r '.assets[] | select(.name | startswith("black_domain")).browser_download_url'
```

#### Get a single build artifact

```
curl -s https://api.github.com/repos/T145/black-mirror/releases/latest | jq -r '.assets[] | select(.name | startswith("black_domain")) | select(.name | endswith(".txt")).browser_download_url'
```

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
