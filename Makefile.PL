use ExtUtils::MakeMaker;

use 5.008;

WriteMakefile
 ( NAME	 	=> 'Geo::KML'
 , VERSION	=> '0.92'
 , PREREQ_PM    =>
   { XML::Compile        => 1.18
   , XML::Compile::Cache => 0.97
   , Log::Report         => 0.28
   , Archive::Zip        => 1.30
   , Test::More          => 0.54
   , Data::Peek          => 0.32
   }
 , EXE_FILES    => [ ]
 , AUTHOR       => 'Mark Overmeer'
 , ABSTRACT     => 'Create GoogleEarth and -Map KML/KMZ'
 , LICENSE      => 'perl'
 );

### used by oodist during production of distribution
sub MY::postamble { <<'__POSTAMBLE' }

# for DIST
RAWDIR          = ../public_html/geo-kml/raw
DISTDIR         = ../public_html/geo-kml/source
LICENSE         = artistic

# for POD
FIRST_YEAR      = 2008
EMAIL           = perl@overmeer.net
WEBSITE         = http://perl.overmeer.net/geo-kml
PODTAIL		= ../Geo-shared-podtail
__POSTAMBLE
