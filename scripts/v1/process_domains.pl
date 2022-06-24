#!/usr/bin/env perl

use warnings;
use strict;
use open ':std', ':encoding(UTF-8)';
use feature 'say';
use Try::Tiny;
use Text::Trim 'trim';
use Net::IDN::Encode 'domain_to_ascii';
use Data::Validate::Domain 'is_domain';

# Written as a modulino: See Chapter 17 in "Mastering Perl". Executes main() if
#   run as script, otherwise, if the file is imported from the test scripts,
#   main() is not run.
main() unless caller;

sub main {
  while (<>) {
    my $line = parse_line( $_ );
    last if !defined $line;
    say $line;
  }
}

sub parse_line {
  my ($line) = @_;

  chomp $line;
  trim $line;

  my $result = try {
    domain_to_ascii( $line );
  };
  return $result;
}
