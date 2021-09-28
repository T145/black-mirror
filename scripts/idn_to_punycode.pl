#!/usr/bin/perl -Wn
use open ':std', ':encoding(UTF-8)';
use strict;
use Try::Tiny;
use Net::IDN::Encode 'domain_to_ascii';

try {
    chomp $_;
    printf "%s\n",domain_to_ascii $_;
}