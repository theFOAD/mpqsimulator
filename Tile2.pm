package Tile;

use strict;
use warnings;
use Data::Dumper;

sub new
  {
    my $tile;
    $tile->{ "color" } = "empty";
    bless ( $tile, "Tile" );
    return $tile;
  }
