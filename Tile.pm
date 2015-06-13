package Tile;

use strict;
use warnings;
use Data::Dumper;

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
    
    return $tile;
  }

sub color
  {
    my $tile = shift @_;

    if ( scalar( @_ ) == 0 )
      {
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
	$tile->set( $palette, %properties );
      }
    return $tile->{ "color" };
  }

sub printf
  {
    my $tile = shift @_;
    my $palette = shift @_;
    die "Palette required!\n" unless ref( $palette ) eq "Palette";
    my $size = 3;
    $size = shift @_ if @_;
    if ( $size == 1 )
      {
	return $palette->shortname( $tile->color, $size );
      }
    elsif ( $size == 2 )
      {
	return $palette->shortname( $tile->color, $size );
      }
    else # $size == 3, we shall assume..
      {
	#not yet done, should return a 4x4 block
	return $palette->shortname( $tile->color, $size );
      }
  }

1;
