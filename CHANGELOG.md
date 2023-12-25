# Changelog

## [Unreleased](https://github.com/T145/black-mirror/tree/HEAD)

[Full Changelog](https://github.com/T145/black-mirror/compare/latest...HEAD)

**Merged pull requests:**

- chore\(deps\): bump geekyeggo/delete-artifact from 2 to 4 in /.github/workflows [\#118](https://github.com/T145/black-mirror/pull/118) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump actions/upload-artifact from 3 to 4 in /.github/workflows [\#117](https://github.com/T145/black-mirror/pull/117) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump actions/download-artifact from 3 to 4 in /.github/workflows [\#116](https://github.com/T145/black-mirror/pull/116) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump stefanzweifel/git-auto-commit-action from 4 to 5 in /.github/workflows [\#114](https://github.com/T145/black-mirror/pull/114) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump docker/setup-buildx-action from 2 to 3 in /.github/workflows [\#113](https://github.com/T145/black-mirror/pull/113) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump docker/setup-qemu-action from 2 to 3 in /.github/workflows [\#112](https://github.com/T145/black-mirror/pull/112) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump docker/build-push-action from 4 to 5 in /.github/workflows [\#111](https://github.com/T145/black-mirror/pull/111) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump otto-de/purge-deprecated-workflow-runs from 1 to 2 in /.github/workflows [\#110](https://github.com/T145/black-mirror/pull/110) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump docker/login-action from 2 to 3 in /.github/workflows [\#109](https://github.com/T145/black-mirror/pull/109) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump actions/checkout from 3 to 4 in /.github/workflows [\#108](https://github.com/T145/black-mirror/pull/108) ([dependabot[bot]](https://github.com/apps/dependabot))
- \[Snyk\] Upgrade mega-linter-runner from 6.22.2 to 7.0.0 [\#107](https://github.com/T145/black-mirror/pull/107) ([T145](https://github.com/T145))
- chore\(deps\): bump tj-actions/github-changelog-generator from 1.18 to 1.19 in /.github/workflows [\#106](https://github.com/T145/black-mirror/pull/106) ([dependabot[bot]](https://github.com/apps/dependabot))

## [latest](https://github.com/T145/black-mirror/tree/latest) (2023-05-11)

[Full Changelog](https://github.com/T145/black-mirror/compare/4.0.0...latest)

**Implemented enhancements:**

- \[feature\]: Improve CIDR processing [\#105](https://github.com/T145/black-mirror/issues/105)
- \[feature\]: Convert ATS to a Lychee GitHub task [\#102](https://github.com/T145/black-mirror/issues/102)
- \[feature\]: Categorize the domain list into unique topics for V2 [\#96](https://github.com/T145/black-mirror/issues/96)

**Fixed bugs:**

- \[bug\]: Windscribe downloads are being blocked [\#87](https://github.com/T145/black-mirror/issues/87)

**Merged pull requests:**

- V2 [\#104](https://github.com/T145/black-mirror/pull/104) ([T145](https://github.com/T145))
- chore\(deps\): bump peter-evans/create-pull-request from 4 to 5 in /.github/workflows [\#103](https://github.com/T145/black-mirror/pull/103) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump actions/upload-artifact from 2 to 3 [\#101](https://github.com/T145/black-mirror/pull/101) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump docker/build-push-action from 3 to 4 [\#100](https://github.com/T145/black-mirror/pull/100) ([dependabot[bot]](https://github.com/apps/dependabot))
- chore\(deps\): bump KevinRohn/github-full-release-data from 2.0.2 to 2.0.4 [\#99](https://github.com/T145/black-mirror/pull/99) ([dependabot[bot]](https://github.com/apps/dependabot))
- Update stalkerware repository URL [\#98](https://github.com/T145/black-mirror/pull/98) ([Te-k](https://github.com/Te-k))
- \[Snyk\] Security upgrade ubuntu from impish to latest [\#97](https://github.com/T145/black-mirror/pull/97) ([snyk-bot](https://github.com/snyk-bot))

## [4.0.0](https://github.com/T145/black-mirror/tree/4.0.0) (2022-05-10)

[Full Changelog](https://github.com/T145/black-mirror/compare/v4.0.0...4.0.0)

**Implemented enhancements:**

- \[feature\]: Block Blogspot & Tubmlr TLDs and ignore all subdomains to debloat the list. [\#77](https://github.com/T145/black-mirror/issues/77)
- Regularly scan every source to determine if any are fully redundant, and create an issue reporting the analytics [\#20](https://github.com/T145/black-mirror/issues/20)

## [v4.0.0](https://github.com/T145/black-mirror/tree/v4.0.0) (2022-05-09)

[Full Changelog](https://github.com/T145/black-mirror/compare/latest-domain...v4.0.0)

**Implemented enhancements:**

- \[feature\]: Filter bogons and reserved CIDR blocks [\#68](https://github.com/T145/black-mirror/issues/68)
- Use more strict line match cases [\#67](https://github.com/T145/black-mirror/issues/67)
- Add alternate file mirrors [\#66](https://github.com/T145/black-mirror/issues/66)
- Use dnsx to find live IPs from a CIDR range [\#56](https://github.com/T145/black-mirror/issues/56)
- Use dnsx to determine if associated hostnames have addresses [\#6](https://github.com/T145/black-mirror/issues/6)

**Fixed bugs:**

- \[bug\]: GitHub messed up CI, so we'll just wait on a fix for now [\#85](https://github.com/T145/black-mirror/issues/85)
- \[bug\]: Fix Abuse.ch FeodoTracker and SSLBL IP lists [\#72](https://github.com/T145/black-mirror/issues/72)
- \[bug\]: Domains beginning with "-" and containing comments appear in the domain list [\#71](https://github.com/T145/black-mirror/issues/71)
- \[bug\]: Unexpected content in black\_domain [\#70](https://github.com/T145/black-mirror/issues/70)
- \[bug\]: Garbage in the IPv4 CIDR list [\#69](https://github.com/T145/black-mirror/issues/69)
- \[bug\] Some release artifacts have hashes in their filename [\#65](https://github.com/T145/black-mirror/issues/65)
- \[bug\] IPv6 addresses are being detected when processing IPv4 addresses. [\#64](https://github.com/T145/black-mirror/issues/64)
- \[bug\] Garbage text appearing in the domain list [\#63](https://github.com/T145/black-mirror/issues/63)

**Closed issues:**

- Use twint to scrape some feeds [\#54](https://github.com/T145/black-mirror/issues/54)
- Add unique sources and maybe some mirrors from MISP's feeds [\#45](https://github.com/T145/black-mirror/issues/45)
- Find some white and black sources in MISP's warninglists [\#44](https://github.com/T145/black-mirror/issues/44)
- Add unique and found blocklist-tools sources [\#40](https://github.com/T145/black-mirror/issues/40)

## [latest-domain](https://github.com/T145/black-mirror/tree/latest-domain) (2021-09-28)

[Full Changelog](https://github.com/T145/black-mirror/compare/latest-ipv4...latest-domain)

## [latest-ipv4](https://github.com/T145/black-mirror/tree/latest-ipv4) (2021-09-28)

[Full Changelog](https://github.com/T145/black-mirror/compare/latest-ipv6...latest-ipv4)

## [latest-ipv6](https://github.com/T145/black-mirror/tree/latest-ipv6) (2021-09-28)

[Full Changelog](https://github.com/T145/black-mirror/compare/auto-build-20210607...latest-ipv6)

**Implemented enhancements:**

- Create separate GitHub releases for each build format [\#55](https://github.com/T145/black-mirror/issues/55)
- Create separate domain builds according to TLD [\#53](https://github.com/T145/black-mirror/issues/53)
- If a build fails, don't upload the release [\#52](https://github.com/T145/black-mirror/issues/52)
- Create a separate IPv4 CIDR blocks release [\#51](https://github.com/T145/black-mirror/issues/51)
- List Pihole-compatible sources in a single-line text file [\#43](https://github.com/T145/black-mirror/issues/43)
- Use column and mawk to process CSV files [\#41](https://github.com/T145/black-mirror/issues/41)
- Expand IPv4 CIDR blocks and IPv6 addresses so they can be handled properly [\#39](https://github.com/T145/black-mirror/issues/39)
- Shrink the IPv4 build by grouping similar IPs into CIDR netblocks [\#29](https://github.com/T145/black-mirror/issues/29)
- Add a comprehensive build in the \*.deny format for Unix systems [\#28](https://github.com/T145/black-mirror/issues/28)
- Find a way to handle multiformat lists [\#25](https://github.com/T145/black-mirror/issues/25)
- Be able to include whitelist sources alongside blacklist sources [\#21](https://github.com/T145/black-mirror/issues/21)
- Make a separate blacklist users can update and maintain with their own hosts [\#19](https://github.com/T145/black-mirror/issues/19)
- \[FEATURE\] Support file mirrors [\#9](https://github.com/T145/black-mirror/issues/9)

**Fixed bugs:**

- \[BUG\] Some sources are dead! [\#62](https://github.com/T145/black-mirror/issues/62)
- \[BUG\] Some sources are dead! [\#61](https://github.com/T145/black-mirror/issues/61)
- Dead Source Report [\#60](https://github.com/T145/black-mirror/issues/60)
- Dead Source Report [\#59](https://github.com/T145/black-mirror/issues/59)
- Fix dnsmasq bad domain name errors by converting offenders to Punycode format [\#38](https://github.com/T145/black-mirror/issues/38)
- ut-capitole contains improperly formatted 0.0.0.0 domains [\#32](https://github.com/T145/black-mirror/issues/32)
- Remove erroring sources in dnsmasq [\#26](https://github.com/T145/black-mirror/issues/26)

**Closed issues:**

- https://assets.windscribe.com/extension/ws/malwaredomains.txt [\#50](https://github.com/T145/black-mirror/issues/50)
- Link Checker Report [\#49](https://github.com/T145/black-mirror/issues/49)
- Parse the betterfyi blockerList [\#47](https://github.com/T145/black-mirror/issues/47)
- Use lychee to check for any dead source or README links [\#46](https://github.com/T145/black-mirror/issues/46)
- Investigate I-BlockList [\#37](https://github.com/T145/black-mirror/issues/37)
- Use Public DNS Info as an IPv4 and IPv6 address whitelist [\#36](https://github.com/T145/black-mirror/issues/36)
- Add unique Sheriff53 sources [\#35](https://github.com/T145/black-mirror/issues/35)
- Use Tranco 1M over Alexa 1M? [\#34](https://github.com/T145/black-mirror/issues/34)
- Add Abuse.ch sources [\#33](https://github.com/T145/black-mirror/issues/33)
- Add unique pDNSf sources [\#31](https://github.com/T145/black-mirror/issues/31)
- Add unique, active sources reported from 2016-2018 [\#30](https://github.com/T145/black-mirror/issues/30)
- Investigate threatcrowd's weird files [\#23](https://github.com/T145/black-mirror/issues/23)
- Investigate scafroglia93's sources [\#22](https://github.com/T145/black-mirror/issues/22)
- \[HOSTS\] Add unused sources from the Ultimate Hosts Blacklist [\#18](https://github.com/T145/black-mirror/issues/18)
- \[HOSTS\] Add badmojr's 1Hosts takeover [\#17](https://github.com/T145/black-mirror/issues/17)
- Update the README to show the number of blocked domains on each build [\#16](https://github.com/T145/black-mirror/issues/16)
- Add unique FireHOL lists to the IPv4 list [\#14](https://github.com/T145/black-mirror/issues/14)
- Add unused sources from hl2guide's filterlist [\#11](https://github.com/T145/black-mirror/issues/11)

## [auto-build-20210607](https://github.com/T145/black-mirror/tree/auto-build-20210607) (2021-06-06)

[Full Changelog](https://github.com/T145/black-mirror/compare/auto-build-20210606...auto-build-20210607)

**Closed issues:**

- \[HOSTS\] Add IPv4 and IPv6 addresses from IPverse [\#15](https://github.com/T145/black-mirror/issues/15)

## [auto-build-20210606](https://github.com/T145/black-mirror/tree/auto-build-20210606) (2021-06-05)

[Full Changelog](https://github.com/T145/black-mirror/compare/manual-build-20210603-183810...auto-build-20210606)

**Fixed bugs:**

- \[BUG\] Fix broken sources [\#13](https://github.com/T145/black-mirror/issues/13)
- \[BUG\] Ucapitole output contains non-domains [\#12](https://github.com/T145/black-mirror/issues/12)

## [manual-build-20210603-183810](https://github.com/T145/black-mirror/tree/manual-build-20210603-183810) (2021-06-03)

[Full Changelog](https://github.com/T145/black-mirror/compare/manual-build-20210603-160950...manual-build-20210603-183810)

## [manual-build-20210603-160950](https://github.com/T145/black-mirror/tree/manual-build-20210603-160950) (2021-06-03)

[Full Changelog](https://github.com/T145/black-mirror/compare/a3cbf4a5187c900eef02900afe389e7bbec78aca...manual-build-20210603-160950)

**Implemented enhancements:**

- \[FEATURE\] Use GitHub Actions to publish an archive release [\#10](https://github.com/T145/black-mirror/issues/10)
- \[FIX\] Build around the Energized list to reduce StevenBlack redundancy [\#8](https://github.com/T145/black-mirror/issues/8)
- \[FEATURE\] Have separate IPv4 & IPv6 list versions [\#7](https://github.com/T145/black-mirror/issues/7)
- \[FEATURE\] Use the Alexa Top 1M domain list [\#5](https://github.com/T145/black-mirror/issues/5)

**Closed issues:**

- \[HOSTS\] Blackbird's Windows hosts [\#4](https://github.com/T145/black-mirror/issues/4)
- \[HOSTS\] EnergizedProtection Extensions [\#3](https://github.com/T145/black-mirror/issues/3)
- \[HOSTS\] The Block List Project [\#2](https://github.com/T145/black-mirror/issues/2)
- \[HOSTS\] Windows Spy Blocker extra and update lists [\#1](https://github.com/T145/black-mirror/issues/1)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
