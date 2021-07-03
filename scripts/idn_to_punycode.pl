#!/usr/bin/perl -Wn
use strict;
use Try::Tiny;
use Net::IDN::Encode ':all';
use open ':std', ':encoding(UTF-8)';

try {
    chomp $_;
    printf "%s\n",domain_to_ascii $_;
}