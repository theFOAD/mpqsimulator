package Player;

use strict;
use warnings;
use Data::Dumper;

sub new
  {
    shift @_;
    my $name = shift @_;
    my $waves = shift @_;
    my $ai = shift @_;
    my $colors = shift @_;

    my $player;

    $player->{ "name" } = $name;

    $player->{ "waves" } = $waves;

    if ( $ai eq "random" )
      {
	$ai = "random";
      }
    else
      {
	die "Unknown kind of AI.\n";
      }
    $player->{ "AI" } = $ai;


    foreach my $c ( @{ $colors } )
      {
	$player->{ "AP" }{ $c } = 0;
      }
    
    bless( $player, "Player" );
    $player->updatemetadata;

    return $player;    
  }

sub updatemetadata
  {
    my $player = shift @_;
#    print Dumper $player; die;
    $player->{ "status" }{ "active_wave" } = -1;
    my @waves = @{ $player->{ "waves" } };
    foreach my $w ( 0 .. $#waves )
      {
	my $wave = $waves[ $w ];
	foreach my $agent ( @$wave )
	  {
	    if ( $agent->status ne "down" )
	      {
		$player->{ "status" }{ "active_wave" } = $w;
		last;
	      }
	  }
	last if $player->{ "status" }{ "active_wave" } != -1;
      }

    return $player if $player->{ "status" }{ "active_wave" } == -1; #game over man, game over!

    my @colors = keys $player->{ "AP" };
    foreach my $c ( @colors, "critical" )
      {
	$player->{ "color_owner" }{ $c } = "";
	$player->{ "damage" }{ $c } = 0;
      }

    my $wave = $waves[ $player->{ "status" }{ "active_wave" } ];

    foreach my $c ( @colors, "critical" )
      {
	foreach my $agent ( @$wave )
	  {
#	    print Dumper $agent, $c; die;

	    if ( $agent->{ "damage" }{ $c } > $player->{ "damage" }{ $c } )
	      {
		$player->{ "damage" }{ $c } = $agent->{ "damage" }{ $c };
		$player->{ "color_owner" }{ $c } = $agent->{ "name" };
		#note this means the earlier guy tanks if damage is equal
	      }
	  }
      }
    
#    print Dumper $player; die;
    return $player;    
  }

sub move
  {
    my $player = shift @_;
    my $board = shift @_;
    if ( $player->{ "AI" } eq "random" )
      {
	my $move = $board->getmove( "random" );
	$board->setmove( $move );
      }
    else
      {
	die "Unknown kind of AI.\n";
      }
    return $board;
  }

sub statistics
  {
    my $player = shift @_;
    my $board = shift @_;

    print "Player: ", $player->{ "name" }, "\n";
    foreach my $c ( @{ $board->{ "colors" } } )
      {
	print "$c: ", $player->{ "AP" }{ $c }, "\n";
      }
    print "\n";
  }

1;
