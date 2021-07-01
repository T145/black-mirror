#!/usr/bin/perl
# https://www.farsightsecurity.com/blog/txt-record/bulkconvertingIDNs-20180918/
use Net::IDN::Encode ':all';
use open ':std', ':encoding(UTF-8)';
use Try::Tiny;

foreach $line ( <STDIN> ) {
   chomp ( $line );

   try {
      my $a = domain_to_ascii( $line );
      print "$a\n";
   } catch {
      warn "Attempted to generate Punycode domain >255 characters!";
   }
}
