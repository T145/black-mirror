#!/usr/bin/perl
use Try::Tiny;
use Net::IDN::Encode ':all';
use open ':std', ':encoding(UTF-8)';
foreach $line ( <STDIN> ) {
    try {
        chomp ( $line );
        my $a = domain_to_ascii( $line );
        print "$a\n";
    }
}