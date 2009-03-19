#!/usr/bin/perl
# test KML 2.2.0 writing
use warnings;
use strict;

use lib 'lib';
use lib '../LogReport/lib', '../XMLCache/lib', '../XMLCompile/lib';

use Test::More tests => 2;

use Geo::KML;
#use Log::Report mode => 3;

use Data::Dumper;
$Data::Dumper::Indent = 1;

my $kml = Geo::KML->new(version => '2.2.0');

isa_ok($kml, 'Geo::KML');

my ($lat, $long) = (55.681597, 12.530516);
my %yapc2008 = 
  ( name => 'YAPC::EU 2008 venue'
  , description => 'YAPC::EU was held at the Copenhagen Business School, 13-15 August 2008'
  , Point => { coordinates => [ "$long,$lat,0" ] }
  );

my $data = { AbstractFeatureGroup => [ {Placemark => \%yapc2008} ] };
#warn Dumper $data;

$kml->writeKML($data, 'example.kml');
ok(1);
