package Palette;

use strict;
use warnings;
use Data::Dumper;

sub new
  {
    my @colors;
    my @specials;
    my @empty;
    my @default_colors = ( "yellow", "red", "blue", "purple", "green", "black", "teamup" );
    my @default_specials = ( "critical" );
    my @default_empty = ( "empty" );
    my %col_1 = { "yellow" => "y",
		  "red" => "r",
		  "blue" => "b",
		  "purple" => "p",
		  "green" => "g",
		  "black" => "k",
		  "teamup" => "t",
                  "critical" => "c",
                  "empty" => "_" };
    my %col_2 = { "yellow" => "ye",
		  "red" => "rd",
		  "blue" => "bu",
		  "purple" => "pu",
		  "green" => "gr",
		  "black" => "bk",
		  "teamup" => "tu",
                  "critical" => "cr",
                  "empty" => "__" };
    my %col_3 = { "yellow" => "yel",
		  "red" => "red",
		  "blue" => "blu",
		  "purple" => "pur",
		  "green" => "grn",
		  "black" => "blk",
		  "teamup" => "tup"
                  "critical" => "crt",
                  "empty" => "___" }

    if ( @_ )
      {
	my $palette_size = shift @_
      }
    else
      {
	$palette_size = 7
      }

    foreach my $i ( 1 .. $palette_size )
      {
	if ( @default_colors )
	  {
	    push @colors, shift @default_colors;
	  }
	else
	  {
	    my $color = "color" . sprintf( "%03d", $i );
	    push @colors, $color;
	    $col_1{ $color } = substr( $color, -1 );
	    $col_2{ $color } = substr( $color, -2 );
	    $col_3{ $color } = substr( $color, -3 );
	  }
       }

    @specials = @default_specials;

    @empty = @empty;

    my %palette;
    $palette{ "colors" } = \@colors;
    $palette{ "specials" } = \@specials;
    $palette{ "empty" } = \@empty;

    foreach my $c ( @colors, @specials, @empty )
      {
	$palette{ "abbr" }{ 1 }{ $c } = $col_1{ $c }
	$palette{ "abbr" }{ 2 }{ $c } = $col_1{ $c }
	$palette{ "abbr" }{ 3 }{ $c } = $col_1{ $c }
      }

    bless ( %palette, "Palette" );
    return \%palette;
  }

sub colors
  {
  }

1;
