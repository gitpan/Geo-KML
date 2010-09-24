#!/usr/bin/perl
# test KML 2.2.0 template
use warnings;
use strict;

use Test::More tests => 2;

use Geo::KML;

#use Log::Report mode => 3;  # XML debugging

my $kml = Geo::KML->new(version => '2.2.0');
ok($kml, 'kml object');

my $templ = $kml->template(PERL => 'Style');

# useful for debugging, but hard to test output: template format does
# change regularly.
print $templ;

ok(length $templ > 100);
