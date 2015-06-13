package Board;

use strict;
use warnings;
use Data::Dumper;

use Palette;
use Tile;

sub new
  {
    shift( @_ );
    my $palette = shift @_;
    my $X = shift @_;
    my $Y = shift @_;

    my $board;
    my @tile;

    for my $i ( 0 .. $X - 1 )
      {
	for my $j ( 0 .. $Y - 1 )
	  {
	    $tile[ $i ][ $j ] = Tile->new( $palette );
	  }
      }
    $board->{ "X" } = $X;
    $board->{ "Y" } = $Y;
    $board->{ "tile" } = \@tile;
    $board->{ "palette" } = $palette;
    bless( $board, "Board" );
    return $board;
  }

sub palette
  {
    my $board = shift @_;
    return $board->{ "palette" }
  }

sub X
  {
    my $board = shift @_;
    return $board->{ "X" }
  }

sub Y
  {
    my $board = shift @_;
    return $board->{ "Y" }
  }

sub tile
  {
    my $board = shift @_;
    return $board->{ "tile" }[ shift @_ ][ shift @_ ]
  }

#replaces empty tiles with by default random ones
sub fill
  {
    my $board = shift @_;
    my @arguments = ( "color" => "random" );
    if ( @_ )
      {
	push @arguments, @_
      }

    for my $i ( 0 .. $board->X - 1 )
      {
	for my $j ( 0 .. $board->Y - 1 )
	  {
	    if ( $board->tile( $i, $j )->isempty )
	      {
		$board->tile( $i, $j )->color( $board->palette, @arguments );
	      }
	  }
      }
    
  }

1;
