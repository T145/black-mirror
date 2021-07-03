#!/usr/bin/perl -W
use strict;
use Try::Tiny;
use Net::IDN::Encode ':all';
use open ':std', ':encoding(UTF-8)';

while ( <STDIN> ) {
    try {
        chomp $_;
        printf "%s\n",domain_to_ascii $_;
    }
}