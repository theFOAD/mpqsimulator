package Tile;

use strict;
use warnings;
use Data::Dumper;

use Colors;

sub new
  {
    my $tile;
    $tile->{ "color" } = "empty";
    bless ( $tile, "Tile" );
    return $tile;
  }

1;
