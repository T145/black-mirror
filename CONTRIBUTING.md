# How to Report:

| **Problem**              | **Forum**                       | **Required Label** |
|--------------------------|---------------------------------|--------------------|
| Adding a list            | Issue, Pull Request, Discussion | enhancement        |
| Modifying a list         | Issue, Pull Request             | enhancement        |
| List redundancy          | Issue, Discussion               | redundant hosts    |
| List deprecation         | Issue                           | bug                |
| Whitelist specific hosts | Discussion                      | whitelist hosts    |
| Blacklist specific hosts | Discussion                      | blacklist hosts    |
| Bug in the main scripts  | Issue                           | bug                |

# Adding a list

`Black Mirror` works by taking blacklist or whitelist listings from `data/v2/manifest.json`.
Each listing has the following fields:

* **_notes**: Any extra information about the list or its filters.
* **archive**: `true` or `false`.
  * Will autocommit the list to the archive submodule in case the original ever becomes unvailable or maliciously modified.
* **checksums**: Checksums for the list in the form of a JSON object with the key being the checksum format and the value being the checksum's URL.
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
  "archive": false,
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

### Adding an Adblock list

Reference [this page](https://github.com/gorhill/uBlock/wiki/Static-filter-syntax#static-network-filtering) for uBlock on how domains are filtered. Be sure the defined rule is able to extract the domains from similar entries.
