#!/usr/bin/perl
# test KML 2.2.0 writing
use warnings;
use strict;

use Test::More tests => 4;

use Geo::KML;

use Data::Dumper;
$Data::Dumper::Indent = 1;
$Data::Dumper::Quotekeys = 0;

#use Log::Report mode => 3;  # XML debugging

# Example taken from
# http://code.google.com/apis/kml/documentation/kmlreference.html#balloonstyle

my $data = Geo::KML->readKML( <<'_KML' );
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
<Document>
  <name>BalloonStyle.kml</name>
  <open>1</open>
  <Style id="exampleBalloonStyle">
    <BalloonStyle>
      <!-- a background color for the balloon -->
      <bgColor>ffffffbb</bgColor>
      <!-- styling of the balloon text -->
      <text><![CDATA[
      <b><font color="#CC0000" size="+3">$[name]</font></b>
      <br/><br/>
      <font face="Courier">$[description]</font>
      <br/><br/>
      Extra text that will appear in the description balloon
      <br/><br/>
      <!-- insert the to/from hyperlinks -->
      $[geDirections]
      ]]></text>
    </BalloonStyle>
  </Style>
  <Placemark>
    <name>BalloonStyle</name>
    <description>An example of BalloonStyle</description>
    <styleUrl>#exampleBalloonStyle</styleUrl>
    <Point>
      <coordinates>-122.370533,37.823842,0</coordinates>
    </Point>
  </Placemark>
</Document>
</kml>
_KML

ok(defined $data, 'reading done');

my $expected =
 { Document => {
    name => 'BalloonStyle.kml',
    open => 1,
    AbstractStyleSelectorGroup => [
      { Style => {
          BalloonStyle => {
            bgColor => "\x{ff}\x{ff}\x{ff}\x{bb}",
            text => '
      <b><font color="#CC0000" size="+3">$[name]</font></b>
      <br/><br/>
      <font face="Courier">$[description]</font>
      <br/><br/>
      Extra text that will appear in the description balloon
      <br/><br/>
      <!-- insert the to/from hyperlinks -->
      $[geDirections]
      '
          },
          id => 'exampleBalloonStyle'
        }
      }
    ],
    AbstractFeatureGroup => [
      {
        Placemark => {
          styleUrl => '#exampleBalloonStyle',
          name => 'BalloonStyle',
          description => 'An example of BalloonStyle',
          Point => {
            coordinates => [
              '-122.370533,37.823842,0'
            ]
          }
        }
      }
    ]
  }
};

is_deeply($data, $expected);

my $data2 = Geo::KML->readKML( <<'_KML' );
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
 xmlns:gx="http://www.google.com/kml/ext/2.2">
  
  <Document>
    <name>balloonVisibility Example</name>
    <open>1</open>
    
    <gx:Tour>
      <name>Play me</name>
      <gx:Playlist>
        
        <gx:FlyTo>
          <gx:duration>8.0</gx:duration>
          <gx:flyToMode>bounce</gx:flyToMode>
          <LookAt>
            <longitude>-119.748584</longitude>
            <latitude>33.736266</latitude>
            <altitude>0</altitude>
            <heading>-9.295926</heading>
            <tilt>84.0957450</tilt>
            <range>4469.850414</range>
            <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
          </LookAt>
        </gx:FlyTo>
        
        <gx:AnimatedUpdate>
          <gx:duration>0.0</gx:duration>
          <Update>
            <targetHref/>
            <Change>
              <Placemark targetId="underwater1">
                <gx:balloonVisibility>1</gx:balloonVisibility>
              </Placemark>
            </Change>
          </Update>
        </gx:AnimatedUpdate>
        
        <gx:Wait>
          <gx:duration>4.0</gx:duration>
        </gx:Wait>

        <gx:AnimatedUpdate>
          <gx:duration>0.0</gx:duration>
          <Update>
            <targetHref/>
            <Change>
              <Placemark targetId="underwater1">
                <gx:balloonVisibility>0</gx:balloonVisibility>
              </Placemark>
            </Change>
          </Update>
        </gx:AnimatedUpdate>
        
        <gx:FlyTo>
          <gx:duration>3</gx:duration>
          <gx:flyToMode>smooth</gx:flyToMode>
          <LookAt>
            <longitude>-119.782630</longitude>
            <latitude>33.862855</latitude>
            <altitude>0</altitude>
            <heading>-9.314858</heading>
            <tilt>84.117317</tilt>
            <range>6792.665540</range>
            <gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>
          </LookAt>
        </gx:FlyTo>
        
        <gx:AnimatedUpdate>
          <gx:duration>0.0</gx:duration>
          <Update>
            <targetHref/>
            <Change>
              <Placemark targetId="underwater2">
                <gx:balloonVisibility>1</gx:balloonVisibility>
              </Placemark>
            </Change>
          </Update>
        </gx:AnimatedUpdate>
        
        <gx:Wait>
          <gx:duration>4.0</gx:duration>
        </gx:Wait>

        <gx:AnimatedUpdate>
          <gx:duration>0.0</gx:duration>
          <Update>
            <targetHref/>
            <Change>
              <Placemark targetId="underwater2">
                <gx:balloonVisibility>0</gx:balloonVisibility>
              </Placemark>
            </Change>
          </Update>
        </gx:AnimatedUpdate>
        
        <gx:FlyTo>
          <gx:duration>3</gx:duration>
          <gx:flyToMode>smooth</gx:flyToMode>
          <LookAt>
            <longitude>-119.849578</longitude>
            <latitude>33.968515</latitude>
            <altitude>0</altitude>
            <heading>-173.948935</heading>
            <tilt>23.063392</tilt>
            <range>3733.666023</range>
            <altitudeMode>relativeToGround</altitudeMode>
          </LookAt>
        </gx:FlyTo>
        
        <gx:AnimatedUpdate>
          <gx:duration>0.0</gx:duration>
          <Update>
            <targetHref/>
            <Change>
              <Placemark targetId="onland">
                <gx:balloonVisibility>1</gx:balloonVisibility>
              </Placemark>
            </Change>
          </Update>
        </gx:AnimatedUpdate>
        
        <gx:Wait>
          <gx:duration>4.0</gx:duration>
        </gx:Wait>
        
      </gx:Playlist>
    </gx:Tour>
    
    <Placemark id="underwater1">
      <name>Underwater off the California Coast</name>
      <description>
        The tour begins near the Santa Cruz Canyon, 
        off the coast of California, USA.
      </description>
      <Point>
        <gx:altitudeMode>clampToSeaFloor</gx:altitudeMode>
        <coordinates>-119.749531,33.715059,0</coordinates>
      </Point>
    </Placemark>
    
    <Placemark id="underwater2">
      <name>Still swimming...</name>
      <description>Were about to leave the ocean, and visit the coast...</description>
      <Point>
        <gx:altitudeMode>clampToSeaFloor</gx:altitudeMode>
        <coordinates>-119.779550,33.829268,0</coordinates>
      </Point>
    </Placemark>
    
    <Placemark id="onland">
      <name>The end</name>
      <description>
        <![CDATA[The end of our simple tour. 
        Use <gx:balloonVisibility>1</gx:balloonVisibility> 
        to show description balloons.]]>
      </description>
      <Point>
        <coordinates>-119.849578,33.968515,0</coordinates>
      </Point>
    </Placemark>
    
    
  </Document>
</kml>
_KML

ok($data2, 'read second example');
#warn Dumper $data2;

my $expected2 = {
  Document => {
    open => 1,
    AbstractFeatureGroup => [
      { Tour => {
          name => 'Play me',
          Playlist => {
            AbstractTourPrimitiveGroup => [
              { FlyTo => {
                  LookAt => {
                    longitude => '-119.748584',
                    latitude => '33.736266',
                    range => '4469.850414',
                    tilt => '84.0957450',
                    heading => '-9.295926',
                    altitudeMode => 'relativeToSeaFloor',
                    altitude => 0
                  },
                  duration => '8.0',
                  flyToMode => 'bounce'
                }
              },
              { AnimatedUpdate => {
                  Update => {
                    cho_Create => [
                      { Change => {
                          AbstractObjectGroup => [
                            { Placemark => {
                                targetId => 'underwater1',
                                AbstractFeatureSimpleExtensionGroup => [
                                  { balloonVisibility => 1
                                  }
                                ]
                              }
                            }
                          ]
                        }
                      }
                    ],
                    targetHref => ''
                  },
                  duration => '0.0'
                }
              },
              { Wait => { duration => '4.0' } },
              { AnimatedUpdate => {
                  Update => {
                    cho_Create => [
                      { Change => {
                          AbstractObjectGroup => [
                            { Placemark => {
                                targetId => 'underwater1',
                                AbstractFeatureSimpleExtensionGroup => [
                                  { balloonVisibility => 0 }
                                ]
                              }
                            }
                          ]
                        }
                      }
                    ],
                    targetHref => ''
                  },
                  duration => '0.0'
                }
              },
              { FlyTo => {
                  LookAt => {
                    longitude => '-119.782630',
                    latitude => '33.862855',
                    range => '6792.665540',
                    tilt => '84.117317',
                    heading => '-9.314858',
                    altitudeMode => 'relativeToSeaFloor',
                    altitude => 0
                  },
                  duration => 3,
                  flyToMode => 'smooth'
                }
              },
              { AnimatedUpdate => {
                  Update => {
                    cho_Create => [
                      { Change => {
                          AbstractObjectGroup => [
                            { Placemark => {
                                targetId => 'underwater2',
                                AbstractFeatureSimpleExtensionGroup => [
                                  { balloonVisibility => 1 }
                                ]
                              }
                            }
                          ]
                        }
                      }
                    ],
                    targetHref => ''
                  },
                  duration => '0.0'
                }
              },
              { Wait => { duration => '4.0' } },
              { AnimatedUpdate => {
                  Update => {
                    cho_Create => [
                      { Change => {
                          AbstractObjectGroup => [
                            { Placemark => {
                                targetId => 'underwater2',
                                AbstractFeatureSimpleExtensionGroup => [
                                  { balloonVisibility => 0 }
                                ]
                              }
                            }
                          ]
                        }
                      }
                    ],
                    targetHref => ''
                  },
                  duration => '0.0'
                }
              },
              { FlyTo => {
                  LookAt => {
                    longitude => '-119.849578',
                    latitude => '33.968515',
                    range => '3733.666023',
                    tilt => '23.063392',
                    heading => '-173.948935',
                    altitudeMode => 'relativeToGround',
                    altitude => 0
                  },
                  duration => 3,
                  flyToMode => 'smooth'
                }
              },
              { AnimatedUpdate => {
                  Update => {
                    cho_Create => [
                      { Change => {
                          AbstractObjectGroup => [
                            { Placemark => {
                                targetId => 'onland',
                                AbstractFeatureSimpleExtensionGroup => [
                                  { balloonVisibility => 1 }
                                ]
                              }
                            }
                          ]
                        }
                      }
                    ],
                    targetHref => ''
                  },
                  duration => '0.0'
                }
              },
              { Wait => { duration => '4.0' } }
            ]
          }
        }
      },
      { Placemark => {
          name => 'Underwater off the California Coast',
          id => 'underwater1',
          description => '
        The tour begins near the Santa Cruz Canyon, 
        off the coast of California, USA.
      ',
          Point => {
            coordinates => [ '-119.749531,33.715059,0' ],
            altitudeMode => 'clampToSeaFloor'
          }
        }
      },
      { Placemark => {
          name => 'Still swimming...',
          id => 'underwater2',
          description => 'Were about to leave the ocean, and visit the coast...',
          Point => {
            coordinates => [ '-119.779550,33.829268,0' ],
            altitudeMode => 'clampToSeaFloor'
          }
        }
      },
      { Placemark => {
          name => 'The end',
          id => 'onland',
          description => '
        The end of our simple tour. 
        Use <gx:balloonVisibility>1</gx:balloonVisibility> 
        to show description balloons.
      ',
          Point => { coordinates => [ '-119.849578,33.968515,0' ] }
        }
      }
    ],
    name => 'balloonVisibility Example'
  }
};

is_deeply($data2, $expected2);
