# Copyrights 2008-2010 by Mark Overmeer.
#  For other contributors see ChangeLog.
# See the manual pages for details on the licensing terms.
# Pod stripped from pm file by OODoc 1.06.

use warnings;
use strict;

package Geo::KML;
use vars '$VERSION';
$VERSION = '0.92';

use base 'XML::Compile::Cache';

use Log::Report 'geo-kml', syntax => 'SHORT';

use Geo::KML::Util;    # all constants
use XML::Compile::Util qw/pack_type type_of_node/;
use XML::Compile       ();
use Archive::Zip       qw/AZ_OK COMPRESSION_LEVEL_DEFAULT/;
use Data::Peek         qw/DDual/;

use Data::Dumper;

use constant KML_NAME_IN_KMZ => 'doc.kml';

my %ns2version  =
  ( &NS_KML_21     => '2.1'
  , &NS_KML_22BETA => '2.2-beta'
  , &NS_KML_22     => '2.2.0'
  );
my %version2ns  = reverse %ns2version;
my %implement;

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
    { prefixes => [ '' => NS_KML_220, atom => NS_ATOM_2005, xal => NS_XAL_20
                  , gx => NS_KML_EXT_22 ]
    , schemas  => [ 'kml-2.2.0/*.xsd', 'atom-2005/*.xsd', 'xal-2.0/*.xsd' ]

    , hooks_r  => [ { type => 'colorType', replace => \&color_hex_read } ]
    , hooks_w  => [ { type => 'colorType', replace => \&color_hex_write} ]
    }
  );


sub init($)
{   my ($self, $args) = @_;

    my $version  =  $args->{version}
        or error __x"KML object requires an explicit version";

    unless(exists $info{$version})
    {   exists $ns2version{$version}
            or error __x"KML version {v} not recognized", v => $version;
        $version = $ns2version{$version};
    }
    $self->{GK_version}   = $version;

    my $info = $info{$version};

    $self->compression(delete $args->{compression} ||COMPRESSION_LEVEL_DEFAULT);
    $self->format(delete $args->{format});

    push @{$args->{prefixes}}, @{$info->{prefixes} || []};

    unshift @{$args->{opts_readers}}
      , mixed_elements     => 'TEXTUAL'
      , sloppy_floats      => 1
      , sloppy_integers    => 1
      , hooks              => $info->{hooks_r};

    unshift @{$args->{opts_writers}}
      , hooks              => $info->{hooks_w};

    $self->SUPER::init($args);

    (my $xsd = __FILE__) =~ s,\.pm$,/xsd,;
    my @xsds = map {glob "$xsd/$_"} @{$info->{schemas}};

    # don''t worry, XML::Compile::Schema will parse each file only once,
    # so only the first KML object created will consume considerable time.
    $self->importDefinitions(\@xsds);

    $self->declare(READER => 'kml', include_namespaces => 1);
    $self->declare(WRITER => 'kml');
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

    my $doc    = XML::LibXML::Document->new('1.0', 'UTF-8');
    my $xml    = $self->writer('kml')->($doc, $data);
    $doc->setDocumentElement($xml);

    my $format = $self->format;
    $zipped ||= $file =~ m/\.kmz$/i;

    if($zipped)
    {   my $arch   = Archive::Zip->new;
        defined $format or $format = 0;
        my $member = $arch->addString($doc->toString($format), KML_NAME_IN_KMZ);
        $member->desiredCompressionLevel($self->compression);
        
        if(ref $file eq 'GLOB' || UNIVERSAL::isa($file, 'IO::Handle'))
        {   $arch->writeToFileHandle($file) == AZ_OK
                or fault __x"cannot write zip to filehandle";
        }
        else
        {   $arch->writeToFileNamed($file) == AZ_OK
                or fault __x"cannot write zip to {fn}", fn => $file;
        }
        return MIME_KMZ;
    }

    defined $format or $format = 1;
    if(ref $file eq 'GLOB' || UNIVERSAL::isa($file, 'IO::Handle'))
         { $doc->toFH  ($file, $format) }
    else { $doc->toFile($file, $format) }

    MIME_KML;
}

# name upto 0.02
sub readKML($;$)
{   my ($self, $data) = (shift, shift);
    @_ ? $self->from($data, is_compressed => shift) : $self->from($data);
}


sub from($@)
{   my ($class, $source, %args) = @_;
    my $zipped = exists $args{is_compressed}
               ? delete $args{is_compressed}
               : !ref $source && $source =~ m/\.kmz$/i;

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

    my $kml     = $implement{$version} ||= $class->new(version => $version);
    ($ns, $kml->reader('kml', %args)->($root));
}

# IMO, the KML design makes a mistake in defining colors as hexBinary.
# The colors are integer values, in the program represented by things
# like 0xff34135, not binary blobs.  The following hooks make this work.
# Without those hooks, you would have to write pack("N", $color) all the
# time.

sub color_hex_read(@)
{   my ($elem, $reader, $path, $label, $replaced) = @_;

    my $text = $elem->textContent;
    $text =~ s/\s//g;

    my $value = unpack 'N', pack 'H8', $text;    # parse hex value into int.
    ($label => $value);
}

sub color_hex_write(@)
{   my ($doc, $value, $path, $label, $replaced) = @_;
    defined $value or return;  # for template

    my $node = $doc->createElement($label);
    my ($pv, $iv) = (DDual $value)[0,1];
    my $text = defined $iv  # integer value prevails
      ? (unpack 'H8', pack "N", $value)
      : $pv;   # validation by XML

    $node->appendText($text);
    $node;
}

1;
