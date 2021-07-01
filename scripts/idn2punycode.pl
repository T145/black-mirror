#!/usr/bin/perl
use Net::IDN::Encode ':all';
use open ':std', ':encoding(UTF-8)';
foreach $line ( <STDIN> ) {
   chomp ( $line );
   my $a = domain_to_ascii( $line );
   print "$a\n";
}
# https://www.farsightsecurity.com/blog/txt-record/bulkconvertingIDNs-20180918/