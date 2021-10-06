#!/usr/bin/env perl
use open ':std', ':encoding(UTF-8)';
use warnings;
use strict;
use Try::Tiny;
use Net::IDN::Encode 'domain_to_ascii';

while (<>) {
  try {
    chomp $_;
    printf "%s\n",domain_to_ascii $_;
  }
}
