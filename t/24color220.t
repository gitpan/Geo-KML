#!/usr/bin/perl
# test KML 2.2.0 color hook
use warnings;
use strict;

use Test::More tests => 9;

use Geo::KML;
use XML::LibXML;

#use Log::Report mode => 3;  # XML debugging

my $kml = Geo::KML->new(version => '2.2.0'
  , allow_undeclared => 1);
ok($kml, 'kml object');

my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
my $w = $kml->writer('bgColor');
ok($w, 'create color writer');

my $r = $kml->reader('bgColor');
ok($r, 'create color reader');


my $xmlexp = <<'_XML';
<bgColor xmlns="http://www.opengis.net/kml/2.2">12345678</bgColor>
_XML

my $xml = $w->($doc, 0x12345678);
is($xml->toString."\n", $xmlexp, 'encoding');

$xml = $w->($doc, '12345678');
is($xml->toString."\n", $xmlexp, 'string');

my $data = $r->($xmlexp);
cmp_ok($data, '==', 0x12345678, 'decoding');


my $xmlexp2 = <<'_XML';
<bgColor xmlns="http://www.opengis.net/kml/2.2">00000012</bgColor>
_XML

my $xml2 = $w->($doc, 0x12);
is($xml2->toString."\n", $xmlexp2, 'encoding');

$xml2 = $w->($doc, '00000012');
is($xml2->toString."\n", $xmlexp2, 'string');

my $data2 = $r->($xmlexp2);
cmp_ok($data2, '==', 0x12, 'decoding');

