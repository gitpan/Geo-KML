#!/usr/bin/perl
# test KML 2.20 reading, based on official examples
use warnings;
use strict;

use lib 'lib';
use Test::More tests => 4;

use Geo::KML;
use Geo::KML::Util qw/NS_KML_22BETA/;
#use Log::Report mode => 3;

use Data::Dumper;
$Data::Dumper::Indent = 1;

# the doc.html file was modified manual, to fix the order in the LookAt
# structure.
my $infn = 't/pyram_22b.kmz';
my ($ns, $data) = Geo::KML->from($infn);

#warn Dumper $data;
is($ns, NS_KML_22BETA);
ok(defined $data);

my $k22 = Geo::KML->new(version => '2.2-beta');

my $buffer = '';
open my($out), '>', \$buffer or die;
$k22->writeKML($data, $out);
close $out;
#print $buffer;

cmp_ok(length $buffer, '>', 100, 'write output produced');
ok($buffer =~ m/\<kml /, 'not compressed');
