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

sub colors
  {
#    print Dumper @_;
    shift @_;
    my $number = shift @_;

    my @named_colors = ( "yellow", "red", "blue", "purple", "green", "black", "teamup" );

    my @colors;
    my @extended_colors;

    my $i = 0;
    while ( $i < $number )
      {
	if ( $named_colors[ $i ] )
	  {
	    push @colors, $named_colors[ $i ];
	    push @extended_colors, $named_colors[ $i ];
	  }
	else
	  {
	    push @colors, "color" . sprintf( "%02d", $i + 1 );
	    push @extended_colors, "color" . sprintf( "%02d", $i + 1 );
	  }
	$i++;
      }
    push @extended_colors, "critical";
    return [ \@colors, \@extended_colors ];
  }

sub displaycolor
  {
    my $tile = shift @_;
    my $colors = shift @_;

    my %display = ( "red" => "re",
		    "yellow" => "ye",
		    "blue" => "bl",
		    "green" => "gr",
		    "purple" => "pu",
		    "black" => "bk",
		    "teamup" => "tu",
		    "critical" => "xx",
		    "empty" => "__"
		  );

    foreach my $c ( @$colors )
      {
	$display{ $c } = substr( $c, 5, 2 ) unless $display{ $c };
      }

    return $display{ $tile->{ "color" } };
  }


#get and set colors
sub color
  {
    my $tile = shift @_;
    my $colors = shift @_;
    my $extended_colors = shift @_;

    my $color;

    if ( $color = shift @_ )
      {
#	my $colors = Tile->colors;
#	my $extended_colors = Tile->extended_colors;
 	my %extended_colors;
#	my %colors;
	foreach my $c ( @$extended_colors )
	  {
	    $extended_colors{ $c } = 1;
	  }
	if ( $extended_colors{ $color } )
	  {
	    $tile->{ "color" } = $color;
	    bless ( $tile, "Tile" );
	  }
	elsif ( $color eq "empty" )
	  {
	    $tile->{ "color" } = "empty";
	    bless ( $tile, "Tile" );
	  }
	elsif ( $color eq "random" )
	  {
	    $tile->{ "color" } = $colors->[ rand @$colors ];
	    bless ( $tile, "Tile" );
	  }
	elsif ( $color eq "extended_random" )
	  {
	    $tile->{ "color" } = $colors->[ rand @$extended_colors ];
	    bless ( $tile, "Tile" );
	  }
	else
	  {
	    die "Unknown color.";
	  }
      }
    return $tile->{ "color" };
  }

1;

#
#sub XXcolors
#  {
#    my @colors = ( "red", "yellow", "blue", "green", "purple", "black", "teamup" );
#    return \@colors;
#  }
#
#sub XXextended_colors
#  {
#    my $colors = Tile->colors;
#    my @extended_colors = ( @$colors, "critical" );
#    return \@extended_colors;
#  }
