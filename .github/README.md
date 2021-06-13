<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<body>
  <h2 id="-philosophy">🧠 Philosophy</h2>
  <ul>
    <li>Keep it 100% open-source.
      <ul>
        <li>The "how it's made" is just as important as the final
        product. Many open-source blocklist projects I've seen
        don't have "how" made public. This project is open and
        flexible, so you can fork it and whitelist what you need
        for personalized application.</li>
      </ul>
    </li>
    <li>Make it secure.
      <ul>
        <li>This project takes on a firewall security mindset, which
        is basically block everything and whitelist what's needed.
        Obviously this list isn't a firewall, so it just blocks as
        much as possible. Please report any "false positives" in an
        issue. Be sure to set up client and network firewalls, as
        this is no substitute.</li>
      </ul>
    </li>
    <li>Let it grow!
      <ul>
        <li>Contribute any useful sources you can think of through
        an issue or by forking the <code>user-submissions</code> branch
        and posting some hosts in a respective list. Help The Blacklist
        reach <code>node_modules</code>-level heights!</li>
      </ul>
    </li>
  </ul>
  <h2 id="-attributes">📋 Attributes</h2>
  <ol>
    <li>No comments</li>
    <li>No excess whitespace (trailing, blank lines)</li>
    <li>No lingering webscraper garbage</li>
    <li>Ending with <code>lf</code></li>
    <li>Domain-only, IPv4, and IPv6 variants</li>
    <li>Updates at <a href=
    "https://www.timeanddate.com/time/zone/timezone/utc">0:00
    UTC</a>
    </li>
  </ol>
  <h2 id="-sources">📚 Sources</h2>
  <blockquote>
    <p>
      <em>Please report any redundant sources in an issue!</em>
      <em>Be sure to check out the custom <a href="https://github.com/T145/the-blacklist/blob/user-submissions/blacklist.txt">blacklist</a>
      and <a href="https://github.com/T145/the-blacklist/blob/user-submissions/whitelist.txt">whitelist</a>!</em>
    </p>
  </blockquote>
  <h3 id="-blacklists">⚫ Blacklists</h3>
  <ul>
    <li>
      <a href=
      "https://github.com/openwrt/packages/blob/master/net/adblock/files/adblock.sources">
      OpenWRT Adblock Sources</a>
      <ul>
        <li>Redundant sources removed include the following:
        <code>adaway</code>, <code>adguard</code>,
        <code>adguard_tracking</code>, <code>anudeep</code>,
        <code>bitcoin</code>, <code>disconnect</code>,
        <code>reg_cn</code>, <code>reg_cz</code>,
        <code>reg_de</code>, <code>reg_es</code>,
        <code>reg_fr</code>, <code>reg_it</code>,
        <code>reg_nl</code>, <code>reg_ro</code>,
        <code>reg_ru</code>, <code>reg_vn</code>,
        <code>stevenblack</code>, <code>spam404</code>,
        <code>stopforumspam</code>, <code>whocares</code>,
        <code>winhelp</code>, <code>yoyo</code></li>
        <li>These redundant sources are included in the Energized
        list and its extensions</li>
      </ul>
    </li>
    <li>
      <a href=
      "https://github.com/EnergizedProtection/block#packs-2">Energized
      Unified</a>
    </li>
    <li>
      <a href=
      "https://github.com/EnergizedProtection/block#extensions-2">Energized
      Extensions</a>
      <ul>
        <li>The <code>Xtreme Extension</code> isn't very
        descriptive, but has been included anyway</li>
      </ul>
    </li>
    <li>
      <a href=
      "https://github.com/StevenBlack/hosts/tree/master/extensions">
      StevenBlack Extensions</a>
      <ul>
        <li>Unified hosts and some extensions contained in
        <code>Energized</code></li>
      </ul>
    </li>
    <li>
      <a href=
      "https://raw.githubusercontent.com/anudeepND/blacklist/master/facebook.txt">
      AnudeepND Facebook</a>
      <ul>
        <li>
          <a href="https://github.com/anudeepND/blacklist">Other
          lists</a> contained in <code>Energized</code>
        </li>
      </ul>
    </li>
    <li>
      <a href=
      "https://github.com/crazy-max/WindowsSpyBlocker/tree/master/data/hosts">
      WindowsSpyBlocker Extra &amp; Update</a>
      <ul>
        <li>Spy list contained in <code>Energized</code></li>
      </ul>
    </li>
    <li>
      <a href="https://blocklistproject.github.io/Lists/">The Block
      List Project</a>
    </li>
    <li>
      <a href="https://getblackbird.net/blacklist/hosts/">Blackbird
      for Windows</a>
    </li>
    <li>
      <a href="https://www.alexa.com/topsites">
      Amazon Alexa Top 1M Sites</a>
      <ul>
        <li>Used to block popular porn sites</li>
      </ul>
    </li>
    <li>
      <a href="https://github.com/firehol/blocklist-ipsets">FireHOL
      Level 4</a>
      <ul>
        <li>Levels 1-3 are included in <code>Energized
        Extensions</code></li>
      </ul>
    </li>
    <li>
      <a href="http://ipverse.net/">IPverse</a>
    </li>
    <li>
      <a href="https://github.com/badmojr/1Hosts">1Hosts Xtra</a>
      <ul>
        <li>Mini &amp; Pro versions are now being included in
        <code>Energized</code></li>
      </ul>
    </li>
    <li>
      <a href=
      "https://github.com/hl2guide/Filterlist-for-AdGuard-or-PiHole">
      Dean's Filterlist Sources</a>
      <ul>
        <li>Unique sources include: <a href=
        "https://www.blocklist.de/en/index.html"><code>blocklist_de</code></a>,
        <a href=
        "https://hostfiles.frogeye.fr/"><code>geoffrey_frogeye</code></a>
        (Taken from <a href=
        "https://sebsauvage.net/hosts/hosts"><code>sebsauvage</code></a>),
        <code>threatcrowd</code>, <a href=
        "https://github.com/TheAntiSocialEngineer/AntiSocial-BlockList-UK-Community">
          <code>antisocialengineer</code></a>, <a href=
          "https://controld.com/static/e08e8c03918a7abb574c2884a5a177f3/a45dc/filters-tablet%402x.png">
          <code>windscribe</code><a>, <code>cyberthreat</code>, <code>not_on_my_shift</code>
        </li>
        <li>References lightswitch05 and pDNSf sources</li>
      </ul>
    </li>
    <li>
      <a href="https://github.com/lightswitch05/hosts/tree/master/docs/lists">lightswitch05's Sources</a>
      <ul>
        <li>Unique sources include: <code>amp_hosts</code>, <code>facebook</code>, <code>hate_and_junk</code></li>
        <li>The rest are included in <code>Energized</code></li>
      </ul>
    </li>
    <li>
      <a href="https://github.com/j-moriarti/pDNSf-Hosts-collection/blob/master/Download-and-Process-Hosts.sh">pDNSf Sources</a>
      <ul>
        <li>Unique sources include: <a href="https://rescure.me/feeds.html"><code>resecure_me</code></a>, <a href="https://kriskintel.com/"><code>kriskintel</code></a>,
        <a href="https://filtri-dns.ga/"><code>filtri_dns</code></a>
      </ul>
    </li>
  </ul>
  <h3 id="-whitelists">⚪ Whitelists</h3>
  <ul>
    <li>
      <a href="https://github.com/EnergizedProtection/unblock#packs">Energized Unblock</a>
    </li>
    <li>
      <a href="https://github.com/anudeepND/blacklist/blob/master/miscellaneous/false-positives.txt">AnudeepND False Positives</a>
    </li>
    <li>
      <a href="https://github.com/anudeepND/whitelist#overview">AnudeepND Whitelist</a>
    </li>
  </ul>
  <h2 id="-hyperlinks">⚓ Hyperlinks</h2>
  <blockquote>
    <p><em>The IPv4 and IPv6 lists include the Domain list</em></p>
  </blockquote>
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
        <td id="domain-count">7,291,884</td>
        <td id="domain-filesize">162M</td>
        <td style="text-align:center">
          <a href=
          "https://github.com/T145/the-blacklist/releases/latest/download/black_domain.tar.gz">
          black_domain.tar.gz</a>
        </td>
      </tr>
      <tr>
        <td style="text-align:center">black_ipv4.txt</td>
        <td style="text-align:center">
          Prepended with <a href=
          "https://github.com/StevenBlack/hosts#we-recommend-using-0000-instead-of-127001">
          <code>0.0.0.0</code></a>
        </td>
        <td id="ipv4-count">412,805</td>
        <td id="ipv4-filesize">226M</td>
        <td style="text-align:center">
          <a href=
          "https://github.com/T145/the-blacklist/releases/latest/download/black_ipv4.tar.gz">
          black_ipv4.tar.gz</a>
        </td>
      </tr>
      <tr>
        <td style="text-align:center">black_ipv6.txt</td>
        <td style="text-align:center">
          Prepended with <a href=
          "https://stackoverflow.com/questions/40189084/what-is-ipv6-for-localhost-and-0-0-0-0">
          <code>::</code></a>
        </td>
        <td id="ipv6-count">53,916</td>
        <td id="ipv6-filesize">184M</td>
        <td style="text-align:center">
          <a href=
          "https://github.com/T145/the-blacklist/releases/latest/download/black_ipv6.tar.gz">
          black_ipv6.tar.gz</a>
        </td>
      </tr>
    </tbody>
  </table>
  <h2 id="-usage">⚒️ Usage</h2>
  <h4 id="dnsmasq">dnsmasq</h4>
  <p>Many popular platforms such as OpenWRT, DDWRT, and Pihole use
  DNSmasq as their choice TCP powerhouse. After inspecting many
  domain blocklists you'll inevitably run across a list in the
  <code>dnsmasq.conf</code> format. This list doesn't support it
  because you can just place
  <code>addn-hosts=black_ipv{4-6}.txt</code> in the config or as a
  passed parameter and have it work properly. If you're using the
  <code>RADVD</code> daemon, use the IPv6 list. Otherwise, use the IPv4 version
  even if you have IPv6 support set up. I've tested this
  across all the mentioned platforms using <code>dig{6}</code> on a
  small sample size and had each host null-routed successfully.
  <a href="https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html">DNSmasq's
  man page</a> discusses this further, and <a href=
  "https://wiki.dd-wrt.com/wiki/index.php/Ad_blocking">DDWRT's ad
  blocking wiki page</a> provides examples.</p>
  <h4 id="unbound">unbound</h4>
  <p>Similar to dnsmasq, but requires more manual configuration.
  Use the <code>black_ipv{4-6}.txt</code> list(s), and rename the
  extracted file into a *.conf file. <a href=
  "https://medium.com/@steffinstanly/unbound-dns-blocking-3567986a5735">
  Steffinstanly discusses how to apply blocklists</a>.</p>
  <h4 id="personaldnsfilter">personalDNSfilter</h4>
  <p>Use the domain list.</p>
  <h4 id="desktopos">Desktop OS Hosts File</h4>
  <p>Use both the IPv4 and IPv6 lists.</p>
</body>
</html>
