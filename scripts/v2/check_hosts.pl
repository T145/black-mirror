#!/usr/bin/env perl

use 5.41.1;
use feature 'say';

use utf8;
use strict;
use autodie;
use warnings;
use warnings    qw< FATAL  utf8 >;
use open        qw< :std  :utf8 >;
use charnames   qw< :full >;
use feature     qw< unicode_strings >;
use Text::Trim  qw< trim >;

use File::Basename      qw< basename >;
use Carp                qw< carp croak confess cluck >;
use Encode              qw< encode decode >;
use Unicode::Normalize  qw< NFD NFC >;

use Getopt::Long;
use Domain::PublicSuffix;
use Net::Works::Network;
use Net::IDN::Encode        qw< domain_to_ascii >;
use Data::Validate::Domain  qw< is_domain >;
use Data::Validate::IP      qw< is_ipv4 is_ipv6 is_public_ipv4 is_public_ipv6 >;

#END { close STDOUT }

if (grep /\P{ASCII}/ => @ARGV) {
   @ARGV = map { decode("UTF-8", $_) } @ARGV;
}

$0 = basename($0);  # shorter messages
$| = 1;

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

# Give a full stack dump on any untrapped exceptions.
local $SIG{__DIE__} = sub {
    confess("Uncaught exception: @_") unless $^S;
};

# Now promote run-time warnings into stack-dumped
#   exceptions *unless* we're in an try block, in
#   which case just cluck the stack dump instead.
local $SIG{__WARN__} = sub {
    if ($^S) { cluck   ("Trapped warning: @_") }
    else     { confess ("Deadly warning: @_")  }
};

# Written as a modulino: See Chapter 17 in "Mastering Perl". Executes main() if
#   run as script, otherwise, if the file is imported from the test scripts,
#   main() is not run.
main() unless caller;

sub main {
    my $format;
    my $method;

    # Process params using Getopts::Long
    # EXAMPLE USAGE: ./check_hosts.pl --format DOMAIN --method BLOCK
    GetOptions('format=s' => \$format, 'method=s' => \$method);

    while (<>) {
        chomp;

        my $host = eval { check_host(NFD(trim($_)), $format, $method) } || '';

        if (length $host) {
            say $host;
        }
    }
}

sub check_host {
    my ($host, $format, $method) = @_;

    if (defined($host)) {
        if ($format eq 'DOMAIN') {
            $host = domain_to_ascii($host, UseSTD3ASCIIRules => 1);

            if (is_domain($host, { domain_private_tld => { onion => 1 } })) {
                if ($method eq 'BLOCK') {
                    my $suffix = Domain::PublicSuffix->new();
                    my $root = $suffix->get_root_domain($host);
                    my $suf = $suffix->suffix();

                    if ($suf !~ /^blogspot/) {
                        return $host;
                    }
                } else {
                    # Allow blogspot domains in the whitelists to
                    # let other list compilers avoid including them!
                    return $host;
                }
            }
        } elsif ($format eq 'IPV4') {
            if (($method eq 'BLOCK' and is_public_ipv4($host)) or ($method eq 'ALLOW' and is_ipv4($host))) {
                return $host;
            }
        } elsif ($format eq 'IPV6') {
            if (($method eq 'BLOCK' and is_public_ipv6($host)) or ($method eq 'ALLOW' and is_ipv6($host))) {
                return $host;
            }
        } elsif ($format eq 'CIDR4' or $format eq 'CIDR6') {
            my $network = Net::Works::Network->new_from_string(string => $host);

            if (not $network->is_single_address()) {
                return $host;
            }
        }
    }

    return '';
}

__END__
