#!/usr/bin/perl
# test KML 2.1 reading, based on official examples
use warnings;
use strict;

use lib 'lib';
use Test::More tests => 4;

use Geo::KML;
use Geo::KML::Util qw/NS_KML_21/;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $infn = 't/startloc_21.kml';
my ($ns, $data) = Geo::KML->from($infn);

is($ns, NS_KML_21);
ok(defined $data);
#warn Dumper $data;

my $k21 = Geo::KML->new(version => '2.1');

my $buffer = '';
open my($out), '>', \$buffer or die;
$k21->writeKML($data, $out);
close $out;
#print $buffer;
cmp_ok(length $buffer, '>', 100, 'write output produced');
ok($buffer =~ m/\<kml /, 'not compressed');
