# Copyrights 2008 by Mark Overmeer.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.05.

use warnings;
use strict;

package Geo::KML;
use vars '$VERSION';
$VERSION = '0.01';

use base 'XML::Compile::Schema';

use Log::Report 'geo-kml', syntax => 'SHORT';

use Geo::KML::Util;    # all constants
use XML::Compile::Util qw/pack_type type_of_node/;
use XML::Compile       ();
use Archive::Zip       qw/AZ_OK COMPRESSION_LEVEL_DEFAULT/;

use constant KML_NAME_IN_KMZ => 'doc.kml';

my %ns2version  =
  ( &NS_KML_21     => '2.1'
  , &NS_KML_22BETA => '2.2-beta'
  , &NS_KML_22     => '2.2.0'
  );
my %version2ns  = reverse %ns2version;

my %info =
  ( '2.1'   =>
    { prefixes => [ '' => NS_KML_21 ]
    , schemas  => [ 'kml-2.1/*.xsd' ]
    }

  , '2.2-beta' =>
    { prefixes => [ '' => NS_KML_22BETA, atom => NS_ATOM_2005, xal=> NS_XAL_20]
    , schemas  => [ 'kml-2.2-beta/kml22beta.xsd', 'kml-2.2-beta/fixes.xsd'
                  , 'atom-2005/*.xsd', 'xal-2.0/*.xsd' ]
    }

  , '2.2.0' =>
    { prefixes => [ '' => NS_KML_220, atom => NS_ATOM_2005, xal => NS_XAL_20 ]
    , schemas  => [ 'kml-2.2.0/*.xsd', 'atom-2005/*.xsd', 'xal-2.0/*.xsd' ]
    }
  );


sub init($)
{   my ($self, $args) = @_;
    $self->SUPER::init($args);

    my $version  =  $args->{version}
        or error __x"KML object requires an explicit version";

    unless(exists $info{$version})
    {   exists $ns2version{$version}
            or error __x"KML version {v} not recognized", v => $version;
        $version = $ns2version{$version};
    }
    $self->{GK_version}   = $version;

    my $info = $info{$version};
    $self->{GK_prefixes} = $info->{prefixes};

    $self->compression($args->{compression} || COMPRESSION_LEVEL_DEFAULT);
    $self->format($args->{format});

    (my $xsd = __FILE__) =~ s!\.pm!/xsd!;
    my @xsds     = map {glob "$xsd/$_"} @{$info->{schemas}};

    # don't worry, XML::Compile::Schema will parse each file only once,
    # so only the first KML object created will consume considerable time.
    $self->importDefinitions(\@xsds);

    $self;
}

#-----------------------------


sub version() {shift->{GK_version}}
sub compression(;$)
{   my $self = shift;
    @_ ? ($self->{GK_compress} = shift) : $self->{GK_compress};
}
sub format(;$)
{   my $self = shift;
    @_ ? ($self->{GK_format} = shift) : $self->{GK_format};
}

#-----------------------------


sub writeKML($$;$)
{   my ($self, $data, $file, $zipped) = @_;

    my $type   = pack_type $version2ns{$self->version}, 'kml';
    my $writer = $self->{GK_writer}{$type} ||= $self->_createWriter($type);
    my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
    my $xml    = $writer->($doc, $data);
    $doc->setDocumentElement($xml);

    my $format = $self->format;
    $zipped ||= $file =~ m/\.kmz$/i;

    if($zipped)
    {   my $arch   = Archive::Zip->new;
        defined $format or $format = 0;
        my $member = $arch->addMember($doc->toString($format), KML_NAME_IN_KMZ);
        $member->desiredCompressionLevel($self->compression);
        
        if(ref $file eq 'GLOB' || UNIVERSAL::ISA($file, 'IO::Handle'))
        {   $arch->writeToFileHandle($file) == AZ_OK
                or fault __x"cannot write zip to filehandle";
        }
        else
        {   $arch->writeToFileNamed($file) == AZ_OK
                or fault __x"cannot write zip to {fn}", fn => $file;
        }
        return $self;
    }

    defined $format or $format = 1;
    if(ref $file eq 'GLOB' || UNIVERSAL::ISA($file, 'IO::Handle'))
         { $doc->toFH  ($file, $format) }
    else { $doc->toFile($file, $format) }

    $self;
}

sub _createWriter($)
{   my ($self, $type) = @_;
    $self->compile
      ( WRITER             => $type
      , include_namespaces => 1
      , output_namespaces  => $self->{GK_prefixes}
      );
}


sub readKML($)
{   my ($class, $source, $zipped) = @_;
    $zipped ||= !ref $source && $source =~ m/\.kmz$/i;

    if($zipped)
    {   my $arch = Archive::Zip->new;
        $arch->read($source) == AZ_OK
            or fault __x"cannot read zip headers from {s}", s => $source;

        my $kml  = $arch->memberNamed(KML_NAME_IN_KMZ);
        my $buffer = '';
        open DOC, '>', \$buffer;
        $kml->extractToFileHandle(\*DOC) == AZ_OK
            or fault __x"failed extracting kml from zip {s}", s => $source;
        close DOC;
        $source = \$buffer;
    }

    my ($root, %details) = XML::Compile->dataToXML($source);

    $root->nodeName eq 'kml'
        or error __x"content of {source} is not kml", source => $source;

    my $ns      = $root->namespaceURI;
    my $version = $ns2version{$ns}
        or error __x"kml type {ns} in {source} not supported (yet)"
             , ns => $ns, source => $source;

    my $kml     = $class->new(version => $version);
    my $type    = type_of_node $root;
    my $reader  = $kml->_createReader($type);

    ($ns, $reader->($root));
}

sub _createReader($)
{   my ($self, $type) = @_;
    $self->compile(READER => $type);
}
    
1;
