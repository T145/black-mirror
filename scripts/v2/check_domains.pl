#!/usr/bin/env perl

use 5.42.0;
use warnings;
use strict;
use feature 'say';
use open ':std', ':encoding(UTF-8)';
use Text::Trim 'trim';
use Net::IDN::Encode 'domain_to_ascii';
use Data::Validate::Domain 'is_domain';

while (<>) {
    chomp;

    my $domain = eval { domain_to_ascii(trim($_)) } || '';

    if (length($domain) and is_domain($domain, { domain_private_tld => { onion => 1 } })) {
        say $domain;
    }
}
