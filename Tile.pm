package Tile;

use strict;
use warnings;
use Data::Dumper;

use List::Util::WeightedChoice qw( choose_weighted );

use Palette;

sub new
  {
    shift @_;
    my $palette = shift @_;
    die "Palette required!\n" unless ref( $palette ) eq "Palette";
    my %properties = @_;
    my $tile;
    $tile->{ "color" } = "empty";

    bless ( $tile, "Tile" );

    $tile->set( $palette, %properties );

    return $tile;
  }

sub set
  {
    my $tile = shift @_;
    my $palette = shift @_;
    die "Palette required!!\n" unless ref( $palette ) eq "Palette";
    my %properties = @_;
    
    #possible properties:
    #color
    #match_color -> is color for everything except criticals, where it is every
    #other color
    #AP
    #special sigil: [s]trike/[a]ttack/[p]rotect/[b]omb/[c]ountdown
    #char[g]ed/[i]nvisible/[t]rap/[w]eb
    #special value/tick
    #special owner
    #lock status
    #lock owner
    
    #for now, we only implement color
    if ( defined $properties{ "color" } and $palette->exists( $properties{ "color" } ) )
      {
	$tile->{ "color" } = $properties{ "color" };
      }
    elsif ( defined $properties{ "color" } and $properties{ "color" } eq "random" )
      {
	if ( $properties{ "color_probabilities" } )
	  {
	    my @choices;
	    my @weights;
	    foreach my $c ( keys %{ $properties{ "color_probabilities" } } )
	      {
		push @choices, $c;
		push @weights, $properties{ "color_probabilities" }{ $c };
	      }
	    $tile->{ "color" } = choose_weighted( \@choices, \@weights );
	  }
	else
	  {
	    my @colors = @{ $palette->colors( "basic" ) };
	    $tile->{ "color" } = $colors[ rand( @colors ) ];
	  }

      }
    elsif ( defined $properties{ "color" } )
      {
	die "Unknown color " . $properties{ "color" } . ".\n";
      }
    
    delete $tile->{ "match_color" };

    if ( $tile->color eq "critical" )
      {
	foreach my $c ( @{ $palette->colors  } )
	  {
	    $tile->{ "match_color" }{ $c } = 1;
	  }
      }
    else
      {
	$tile->{ "match_color" }{ $tile->color } = 1;
      }
    return $tile;
  }

sub match_color #only returns match_colors; setting happens through color or set
  {
    my $tile = shift @_;
    my %mc;
    %mc = %{ $tile->{ "match_color" } } if defined $tile->{ "match_color" };
    return \%mc;
#    return $tile->{ "match_color" };
  }

sub color
  {
    my $tile = shift @_;

    if ( scalar( @_ ) == 0 )
      {
	#we were only asked to report the current color
      }
    else
      {
	my $palette = shift @_;
	my %properties;
	if ( scalar( @_ ) == 1 )
	  {
	    $properties{ "color" } = shift @_;
	  }
	else
	  {
	    %properties = @_;
	  }
	if ( defined $properties{ "color" } ) 
	  {
	    if ( defined $properties{ "color_probabilities" } )
	      {
		$tile->set( $palette, "color" => $properties{ "color" }, "color_probabilities" => $properties{ "color_probabilities" } )
	      }
	    else
	      {
		$tile->set( $palette, "color" => $properties{ "color" } )
	      }
	  }
      }
    return $tile->{ "color" };
  }

sub isempty
  {
    my $tile = shift @_;
    if ( $tile->{ color } eq "empty" )
      {
	return 1
      }
    else
      {
	return 0
      }
  }

sub printf
  {
    my $tile = shift @_;
    my $palette = shift @_;
    die "Palette required!\n" unless ref( $palette ) eq "Palette";
    my $size = 3;
    $size = shift @_ if @_;

    my @p;
    if ( $size == 1 )
      {
	push @p , $palette->shortname( $tile->color, $size );
      }
    elsif ( $size == 2 )
      {
	push @p , $palette->shortname( $tile->color, $size );
      }
    else # $size == 3, we shall assume..
      {
	#not yet done, should return a 8x4 block
	push @p, $palette->shortname( $tile->color, $size ) . ".....";
	push @p, "........";
	push @p, "........";
	push @p, "........";
      }
    return \@p;
  }

1;
