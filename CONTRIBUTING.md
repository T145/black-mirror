# How to Report

| **Problem**              | **Forum**                       | **Required Label** |
|--------------------------|---------------------------------|--------------------|
| Adding a list            | Issue, Pull Request, Discussion | maintenance        |
| Modifying a list         | Issue, Pull Request             | maintenance        |
| List redundancy          | Issue, Discussion               | maintenance        |
| List deprecation         | Issue                           | maintenance        |
| Whitelist specific hosts | Issue, Discussion               | maintenance        |
| Blacklist specific hosts | Issue, Discussion               | maintenance        |
| Bug in the main scripts  | Issue                           | bug                |
| Security vulnerability   | Security Tab                    | N/A                |

# Adding Lists

`Black Mirror` works by taking objects from [`data/v2/manifest.json`](https://github.com/T145/black-mirror/blob/master/data/v2/manifest.json) defined like so:

* **_notes**: (`optional`) Any extra information about the list or its filters.
* **active**: If a list is enabled or not. Disabled lists will *not* be compiled into `Black Mirror`.
* **checksums**: (Fields are `optional`) Checksums for the list in the form of a JSON object with the key being the checksum format and the value being the checksum's URL.
* **content**:
  * **filter**: A preprocessing command to transform the list into plain text. Reference where the filters [are defined](https://github.com/T145/black-mirror/blob/master/scripts/v2/apply_filters.bash).
  * **retriever**: The utility to download the list. Reference where retrievers [are defined](https://github.com/T145/black-mirror/blob/master/scripts/v2/build_lists.bash#L60).
  * **type**: Determines which filter type is applied. Reference where filters [are defined](https://github.com/T145/black-mirror/blob/master/scripts/v2/apply_filters.bash).
* **formats**: Applies a designated filter and sends the output to a list with the specified host type. Reference where filters [are defined](https://github.com/T145/black-mirror/blob/master/scripts/v2/apply_filters.bash).
* **metadata**: An object with a `description`, `homepage`, and `license` string objects.
* **method**: `BLOCK` or `ALLOW` to respectively blacklist or whitelist the hosts.
* **mirrors**: An array of URLs where the list and its mirrors are located.
* **topic**: A general topic to summarize the list's goal, such as `PRIVACY` or `SECURITY`.

Example:

```json
"botvrij_misp_ip_dst": {
  "active": true,
  "checksums": {
    "md5": "https://www.botvrij.eu/data/misp.md5.ADMIN.txt",
    "sha1": "https://www.botvrij.eu/data/misp.sha1.ADMIN.txt",
    "sha256": "https://www.botvrij.eu/data/misp.sha256.ADMIN.txt"
  },
  "content": {
    "filter": "NONE",
    "retriever": "ARIA2",
    "type": "TEXT"
  },
  "formats": [
    {
      "filter": "NONE",
      "format": "IPV4"
    }
  ],
  "metadata": {
    "description": "https://www.botvrij.eu/data/",
    "homepage": "https://www.botvrij.eu/",
    "license": "not-available"
  },
  "method": "BLOCK",
  "mirrors": [
    "https://www.botvrij.eu/data/misp.text_ip-dst.ADMIN.txt"
  ],
  "topic": "SECURITY"
}
```

## Adding Adblock Lists

Reference [this page](https://github.com/AdguardTeam/tsurlfilter/blob/master/packages/agtree/README.md#references) about domain filtering syntax.
Most principles should carry over to other syntaxes, but don't be afraid to ask.

# Blocking or allowing specific hosts

If while using `Black Mirror` you notice certain hosts should be whitelisted to not break something,
please follow the given rubric and create an issue or a discussion and document them.
Those hosts can be put in a list under `data/v2/contrib` and submitted via pull request. If they can't be categorized by an existing list feel free to make one.
