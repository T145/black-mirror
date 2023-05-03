#!/usr/bin/env perl

use warnings;
use strict;
use open ':std', ':encoding(UTF-8)';
use feature 'say';
use Try::Tiny;
use Text::Trim 'trim';
use Net::IDN::Encode 'domain_to_ascii';
use Data::Validate::Domain 'is_domain';

while (<>) {
  chomp;

  try {
    my $domain = domain_to_ascii(trim($_));

    if (defined($domain) && is_domain($domain, { domain_private_tld => { onion => 1 } })) {
      say($domain);
    }
  }
}
