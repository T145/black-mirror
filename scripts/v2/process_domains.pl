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
  chomp($_);
  trim($_);

  try {
    my $line = domain_to_ascii($_);

    if (defined($line) && is_domain($line)) {
      say($line);
    }
  }
}
