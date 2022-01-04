#!/usr/bin/env perl

use feature qw(say);
use open ':std', ':encoding(UTF-8)';
use warnings;
use strict;
use Try::Tiny;
use Net::IDN::Encode 'domain_to_ascii';
use Data::Validate::Domain qw(is_domain);

sub main() {
    while (<>) {
        chomp($_);

        # https://perlmaven.com/fatal-errors-in-external-modules
        eval {
            my $domain = try {
                domain_to_ascii($_);
            };

            last if !defined $domain;

            if (is_domain($domain, {
                domain_allow_underscore => "true"
            })) {
                say($domain);
            }
        } or do {
            my $error = $@ || 'Unknown failure';
            warn "Could not parse '$_' - $error";
        }
    }
}

# Written as a modulino: See Chapter 17 in "Mastering Perl". Executes main() if
#   run as script. Otherwise, if the file is imported, main() is not run.
main() unless caller;
