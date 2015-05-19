package Agent;

use strict;
use warnings;
use Data::Dumper;

sub new
  {
    shift @_;
    my %agent;
    $agent{ "name" } = shift @_;
    $agent{ "health" } = shift @_;
    $agent{ "damage" } = shift @_; # % incl TU and critx
    $agent{ "powerset" } = shift @_;
    $agent{ "status" } = "active"; #not stunned or downed or airborne

    my $agent = \%agent;
    bless( $agent, "Agent" );

    return $agent;
  }

sub status
    {
      my $agent = shift @_;
      $agent->{ "status" } = shift @_ if @_;
      return $agent->{ "status" };
    }

1;

