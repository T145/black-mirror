#!/usr/bin/env perl

use 5.42.0;
use warnings;
use strict;
use feature 'say';
use open ':std', ':encoding(UTF-8)';
use Text::Trim 'trim';
use Net::Works::Network;

while (<>) {
    chomp;

    eval {
        my $cidr = trim($_);

        if (length($cidr)) {
            my $network = Net::Works::Network->new_from_string(string => $cidr);

            if (not $network->is_single_address()) {
                say $cidr;
            }
        }
    }
}
