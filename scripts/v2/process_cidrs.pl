#!/usr/bin/env perl

use warnings;
use strict;
use open ':std', ':encoding(UTF-8)';
use feature 'say';
use Try::Tiny;
use Text::Trim 'trim';
use Net::CIDR 'cidrvalidate';

while (<>) {
  chomp;

  try {
    # https://metacpan.org/pod/Net::CIDR#$ip=Net::CIDR::cidrvalidate($ip);
    my $cidr = cidrvalidate(trim($_));
    last if !defined $cidr;
    say $cidr;
  }
}
