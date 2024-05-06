#!/usr/bin/env perl

use 5.39.9;

use utf8;
use strict;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;
use charnames   qw< :full >;
use feature     qw< unicode_strings >;
use Text::Trim  qw< trim >;
use Net::CIDR   qw< cidrvalidate >;

use File::Basename      qw< basename >;
use Carp                qw< carp croak confess cluck >;
use Encode              qw< encode decode >;
use Unicode::Normalize  qw< NFD NFC >;

use Getopt::Long;
use Try::Tiny;
use Syntax::Keyword::Match;
use Net::IDN::Encode    qw< domain_to_ascii >;
use Data::Validate::Domain  qw< is_domain >;
use Data::Validate::IP  qw< is_ipv4 is_ipv6 is_public_ipv4 is_public_ipv6 >;

END { close STDOUT }

if (grep /\P{ASCII}/ => @ARGV) {
   @ARGV = map { decode("UTF-8", $_) } @ARGV;
}

$0 = basename($0);  # shorter messages
$| = 1;

binmode(DATA, ":utf8");

# Give a full stack dump on any untrapped exceptions.
local $SIG{__DIE__} = sub {
    confess "Uncaught exception: @_" unless $^S;
};

# Now promote run-time warnings into stack-dumped
#   exceptions *unless* we're in an try block, in
#   which case just cluck the stack dump instead.
local $SIG{__WARN__} = sub {
    if ($^S) { cluck   "Trapped warning: @_" }
    else     { confess "Deadly warning: @_"  }
};

# Written as a modulino: See Chapter 17 in "Mastering Perl". Executes main() if
#   run as script, otherwise, if the file is imported from the test scripts,
#   main() is not run.
main() unless caller;

sub main {
    my $format = 'DOMAIN';
    my $method = 'BLOCK';

    # Process params using Getopts::Long
    # EXAMPLE USAGE: ./process_hosts.pl --format DOMAIN --method BLOCK
    GetOptions('format=s' => \$format, 'method=s' => \$method);

    while (<>) {
        chomp;

        try {
            my $line = parse_line(NFD(trim($_)), $format, $method);

            # https://stackoverflow.com/questions/25651126/in-perl-how-do-i-check-for-an-undefined-or-blank-parameter#25651344
            if (length $line) {
                say $line;
            }
        }
    }
}

sub parse_line {
    my ($line, $format, $method) = @_;

    if (defined($line)) {
        if ($format eq 'DOMAIN') {
            $line = domain_to_ascii($line);

            if (is_domain($line, { domain_private_tld => { onion => 1 } })) {
                return $line;
            }
        } elsif ($format eq 'IPV4') {
            if (($method eq 'BLOCK' and is_public_ipv4($line)) or ($method eq 'ALLOW' and is_ipv4($line))) {
                return $line;
            }
        } elsif ($format eq 'IPV6') {
            if (($method eq 'BLOCK' and is_public_ipv6($line)) or ($method eq 'ALLOW' and is_ipv6($line))) {
                return $line;
            }
        } elsif ($format eq 'CIDR4' or $format eq 'CIDR6') {
            # NOTE: This will validate regular IPs too, so be extra sure none slip through.
            if (cidrvalidate($line)) {
                return $line;
            }
        }
    }

    return '';
}

__END__
