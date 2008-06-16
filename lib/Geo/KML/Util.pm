# Copyrights 2008 by Mark Overmeer.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.05.
use warnings;
use strict;

package Geo::KML::Util;
use vars '$VERSION';
$VERSION = '0.01';

use base 'Exporter';

use Log::Report 'geo-kml';

my @kml21   = qw/NS_KML_21/;
my @kml22b  = qw/NS_KML_22BETA NS_ATOM_2005 NS_XAL_20/;
my @kml220  = qw/NS_KML_22 NS_KML_220 NS_ATOM_2005 NS_XAL_20/;

our @EXPORT = (@kml21, @kml22b, @kml220);

our %EXPORT_TAGS =
  ( kml21     => \@kml21
  , kml22beta => \@kml22b
  , kml220    => \@kml220
  );


use constant NS_KML_21     => 'http://earth.google.com/kml/2.1';


use constant NS_KML_22BETA => 'http://earth.google.com/kml/2.2';


use constant NS_KML_22    => 'http://www.opengis.net/kml/2.2';
use constant NS_KML_220   => 'http://www.opengis.net/kml/2.2';

use constant NS_ATOM_2005 => 'http://www.w3.org/2005/Atom';
use constant NS_XAL_20    => 'urn:oasis:names:tc:ciq:xsdschema:xAL:2.0';

1;
