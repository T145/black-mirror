# Project Contribution

## List recommendations

### Do you have a list you'd like to add?

Join the discussion around lists under the "Discussions" tab!
Issues should be restricted for more critical subjects about how the project works.

### Have you found a redundant list?

A redundant list would be any list that has its own entry in `data/v2/manifest.json` and is mostly or fully included in another list.
Obviously one or the other should be removed, so please make an issue detailing the conflict.

### Have you found a deprecated list?

Please make an issue featuring the list and whether or not it should be removed or archived.

### Do you have a host or some hosts to whitelist or blacklist?

Join the corresponding discussion and post 'em!

### Have you found a bug in the main program?

Please make an issue detailing the problem as thoroughly as possible.

## Manually adding a list

`Black Mirror` works by taking blacklist or whitelist listings from `data/v2/manifest.json`.
Each listing has the following fields:

Example:

```json
"certego_intel": {
  "_notes": "Ignoring the IP reports since they're pretty old.",
  "archive": true,
  "checksums": {},
  "content": {
    "filter": "NONE",
    "retriever": "SNSCRAPE",
    "type": "JSON"
  },
  "formats": [
    {
      "filter": "CERTEGO",
      "format": "DOMAIN"
    }
  ],
  "metadata": {
    "description": "https://twitter.com/Certego_Intel",
    "homepage": "https://twitter.com/Certego_Intel",
    "license": "not-available"
  },
  "method": "BLOCK",
  "mirrors": [
    "Certego_Intel"
  ],
  "topic": "SECURITY"
}
```

* **_notes**: Any information to detail more on how to use the list.
* **archive**: `true` or `false`.
  * Will autocommit the list to the archive submodule in case the original ever becomes unvailable or maliciously modified.
* **checksums**: Provide any checksums for the list in the form of a JSON object with the key being the checksum format and the value being the checksum's URL.
* **content**:
  * **filter**: How any preprocessing required to perform on the list. Reference where the filters [are defined](https://github.com/T145/black-mirror/blob/master/scripts/v2/apply_filters.bash).
  * **retriever**: Download the list. Reference where the retrievers [are defined](https://github.com/T145/black-mirror/blob/master/scripts/v2/build_lists.bash#L60).
  * **type**: Determines which filter type is applied. Reference where the filters [are defined](https://github.com/T145/black-mirror/blob/master/scripts/v2/apply_filters.bash).
* **formats**: Applies a designated filter and sends the output to a list with the specified host type. Reference where the filters [are defined](https://github.com/T145/black-mirror/blob/master/scripts/v2/apply_filters.bash).
* **metadata**: Should be self-explanatory.
* **method**: `BLOCK` or `ALLOW` to respectively blacklist or whitelist the hosts.
* **mirrors**: An array of URLs where the list is located.
* **topic**: A general topic the list emphasizes, such as `PRIVACY` or `SECURITY`.

Now go make a PR!

### Adding an Adblock list

Reference [this page](https://github.com/gorhill/uBlock/wiki/Static-filter-syntax#static-network-filtering) for uBlock on how domains are filtered. Be sure the defined rule is able to extract the domains from similar entries.
