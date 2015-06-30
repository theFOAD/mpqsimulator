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

sub findmaxhorizontalmatch
  {
    my $board = shift @_;
    my $x = shift @_;
    my $y = shift @_;
    my $color = shift @_;
    my @match;
    if ( $board->tile( $x, $y )->color eq $color )
      {
	push @match, \[ $x, $y ];
        print $x, $y, "\n";
        for my $i ( reverse 0 .. $x - 1 )
	  {
	    if ( $board->tile( $i, $y )->color eq $color )
	      {
		unshift @match, \[ $i, $y ];
       print $i, $y, "\n";
	      }
            else
	      {
	        last;
	      }
          }
        for my $i ( $x + 1 .. $board->X - 1 )
          {
 	    if ( $board->tile( $i, $y )->color eq $color )
 	      {
		push @match, \[ $i, $y ];
        print $i, $y, "\n";
	      }
            else
              {
	        last;
	      }
          }
     }
    return \@match;
  }

sub findmaxverticalmatch
  {
    my $board = shift @_;
    my $x = shift @_;
    my $y = shift @_;
    my $color = shift @_;
    my @match;
    if ( $board->tile( $x, $y )->color eq $color )
      {
	push @match, \[ $x, $y ];
        print $x, $y, "\n";
        for my $j ( reverse 0 .. $y - 1 )
	  {
	    if ( $board->tile( $x, $j )->color eq $color )
	      {
		unshift @match, \[ $x, $j ];
       print $x, $j, "\n";
	      }
            else
	      {
	        last;
	      }
          }
        for my $j ( $y + 1 .. $board->Y - 1 )
          {
 	    if ( $board->tile( $x, $j )->color eq $color )
 	      {
		push @match, \[ $x, $j ];
        print $x, $j, "\n";
	      }
            else
              {
	        last;
	      }
          }
     }
    return \@match;
  }

sub findmatch
  {
    my $board = shift @_;
    my $x = shift @_;
    my $y = shift @_;
####
##### for every color_match of T = (x, y):
##### test T horizontal; test T vertical
##### if at least one 3+-match exists continue
##### if hor 3+-match
#####   add elements to set "hor_tested"
#####   add elements to set "hor_match"
#####   add elements to total match M
#####   add elements other than T to the "to_test" set unless part of "ver_tested"
##### if hor 4+-match
#####   add line number to "destroyable_lines" set
##### if hor 5+-match
#####   add "middle" element to "potential_critical" set
##### if ver 3+-match
#####   add elements to set "ver_tested"
#####   add elements to set "ver_match"
#####   add elements to total match M
#####   add elements other than T to the "to_test" set unless part of "hor_tested"
##### if ver 4+-match
#####   add column number to "destroyable_columns" set
##### if ver 5+-match
#####   add "middle" element to "potential_critical" set
####
##### if hor 3+-match and ver 2-match; U = (x, y +/- 1)
#####   add T and U to "ver_tested"
#####   test U horizontal
##### if hor 3+-match [else discard U]
#####   add T and U to "ver_match"
#####   add elements to set "hor_tested"
#####   add elements to set "hor_match"
#####   add elements to total match M
#####   add elements other than U to the "to_test" set unless part of "ver_tested"
#####   add T and U to "potential_critical" set
##### if hor 4+-match
#####   add line number to "destroyable_lines" set
##### if hor 5+-match
#####   add "middle" element to "potential_critical" set
####
##### if hor 2-match and ver 3+-match; U = (x +/- 1, y)
#####   add T and U to "hor_tested"
#####   test U vertical
##### if ver 3+-match [else discard U]
#####   add T and U to "hor_match"
#####   add elements to set "ver_tested"
#####   add elements to set "ver_match"
#####   add elements to total match M
#####   add elements other than U to the "to_test" set unless part of "hor_tested"
#####   add T and U to "potential_critical" set
##### if ver 4+-match
#####   add column number to "destroyable_lines" set
##### if ver 5+-match
#####   add "middle" element to "potential_critical" set
####

######### for every color_match of (x, y):
######### put "seed-element" (x, y) in "to_test"
#########
######### remove an element T from "to_test";
######### unless T is in "hor_tested"
#########   find the entire horizontal match of T (H)
#########   set hor_size for every element of H
#########   put every element of H in "hor_tested"
######### unless T is in "ver_tested"
#########   find the entire vertical match of T (V)
#########   set ver_size for every element of V
#########   put every element of V in "ver_tested"
######### put every element of H that is in "hor_tested" and "ver_tested" in "tested"
######### [this includes T]
######### if hor_size( T ) >= 3
#########   put every element of H in match M
#########   set hor_matched to true for every element of H
#########   put every element of H that is not in "tested" in "to_test"
#########   if ver_size( T ) = 2
#########     U = (x, y +/- 1)
#########     put U in "ver_tested"
#########     find the entire horizontal match of U (I)
#########     if #I <3 break [else #I >= 3]
#########     set ver_matched to true for every element of (V, U)
#########     set hor_size for every element of I
#########     put every element of I in "hor_tested"
#########     put every element of I that is in "hor_tested" and "ver_tested" in "tested"
#########     put every element of I in match M
#########     set hor_matched to true for every element of I
#########     put every element of I that is not in "tested" in "to_test"
#########     if hor_size( U ) >= 4
#########       put line in "destroyable_lines"
#########       if hor_size( U ) >= 5
#########         put "middle" element in "potential_critical" set
#########   if hor_size( T ) >= 4
#########     put line in "destroyable_lines"
#########     if hor_size( T ) >= 5
#########       put "middle" element in "potential_critical" set

# for every color_match of (x, y):
# put "seed-element" (x, y) in "to_test"
#
# remove an element T from "to_test";
# unless T is in "hor_tested"
#   find the entire horizontal match of T (H)
#   set hor_size for every element of H
#   put every element of H in "hor_tested"
# unless T is in "ver_tested"
#   find the entire vertical match of T (V)
#   set ver_size for every element of V
#   put every element of V in "ver_tested"
# put every element of H that is in "hor_tested" and "ver_tested" in "tested"
# [this includes T]
# if hor_size( T ) >= 3
#   put every element of H in match M
#   set hor_matched to true for every element of H
#   put every element of H that is not in "tested" in "to_test"
#   if ver_size( T ) = 2
#     U = (x, y +/- 1)
#     put U in "ver_tested"
#     find the entire horizontal match of U (I)
#     if #I <3 break [else #I >= 3]
#     set ver_matched to true for every element of (V, U)
#     set hor_size for every element of I
#     put every element of I in "hor_tested"
#     put every element of I that is in "hor_tested" and "ver_tested" in "tested"
#     put every element of I in match M
#     set hor_matched to true for every element of I
#     put every element of I that is not in "tested" in "to_test"
#     if hor_size( U ) >= 4
#       put line in "destroyable_lines"
#       if hor_size( U ) >= 5
#         put "middle" element in "potential_critical" set
#   if hor_size( T ) >= 4
#     put line in "destroyable_lines"
#     if hor_size( T ) >= 5
#       put "middle" element in "potential_critical" set

  }

sub printf
  {
    my $board = shift @_;
    my $size = 3;
    $size = shift @_ if @_;

    my $print;

    if ( $size == 1 or $size == 2 )
      {
	for my $j ( 0 .. $board->Y - 1 )
	  {
	    for my $i ( 0 .. $board->X - 1 )
	      {
		$print .= $board->tile( $i, $j )->printf( $board->palette, $size )->[ 0 ];
	      }
	    $print .= "\n";
	  }
      }
    elsif ( $size == 3 )
      {
	for my $j ( 0 .. $board->Y - 1 )
	  {
	    for my $k  ( 0 .. 3 )
	      {
		for my $i ( 0 .. $board->X - 1 )
		  {
		    $print .= $board->tile( $i, $j )->printf( $board->palette, $size )->[ $k ];
		    $print .= " ";
		  }
		$print .= "\n";
	      }
	    $print .= "\n";
	  }
      }
    else
      {
	die "Unknown board size $size.";
      }
    return $print;
  }

1;
