package Wave;

use strict;
use warnings;
use Data::Dumper;

#order of agents is also tanking order; 0 tanks for the rest if damage values are equal and so on
sub wave
  {
    shift @_;
    my @wave;

    foreach my $agent ( @_ )
      {
	if ( ref $agent eq "Agent" )
	  {
	    push( @wave, $agent );
	  }
	else
	  {
	    print Dumper $agent;
	    die "The above is not a proper agent.\n";
	  }
      }
    my $wave = \@wave;

    bless ( $wave, "Wave" );
    return $wave;

  }

sub waves
  {
    shift @_;
    my @waves;

    foreach my $wave ( @_ )
      {
	if ( ref $wave eq "Wave" )
	  {
	    push( @waves, $wave );
	  }
	else
	  {
	    print Dumper $wave;
	    die "The above is not a proper wave.\n";
	  }
      }
    my $waves = \@waves;

    bless ( $waves, "Waves" );
    return $waves;

  }
    
1;

