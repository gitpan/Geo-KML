#!/usr/bin/env perl
#
# Simple script to demonstrate how some KML or KMZ file gets decoded
# into a Perl data-structure.
#
# Usage:    ./kml-decode.pl [-v] data.kml

use warnings;
use strict;

use Log::Report;
use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Quotekeys = 0;

# try to find the code when the module is not yet really installed
use lib 'lib', '../lib';
use Geo::KML;

if(@ARGV && $ARGV[0] eq '-v')
{   shift @ARGV;
    dispatcher mode => DEBUG => 'ALL';
}

@ARGV==1
    or error "Usage:  $0 [-v] data.kml";

my ($fn) = @ARGV;

my $data = Geo::KML->from($fn);

print Dumper $data;
