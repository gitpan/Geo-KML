#!/usr/bin/env perl
#
# Simple script to show the whole super complex structure which
# the reader may produce resp. can be passed to the writer.
#
# Usage:    ./kml-explain.pl

use warnings;
use strict;

use Log::Report;
use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Quotekeys = 0;

# try to find the code when the module is not yet really installed
use lib 'lib', '../lib';
use Geo::KML;

my $kml = Geo::KML->new(version => '2.2.0');

print $kml->template(PERL => 'Document');
