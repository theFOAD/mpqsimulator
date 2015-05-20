package Board;

use strict;
use warnings;
use Data::Dumper;

use List::Util qw( shuffle );

use Tile;

sub new
  {
    my $board;
    shift @_;
    $board->{ "X" } = ( shift @_ ) - 1;
    $board->{ "Y" } = ( shift @_ ) - 1;
    $board->{ "colorsize" } = shift @_;
    my $cols = Tile->colors( $board->{ "colorsize" } );
    $board->{ "colors" } = $cols->[ 0 ];
    $board->{ "extended_colors" } = $cols->[ 1 ];
#   print Dumper $board->{ "extended_colors" }; die;

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    $board->{ "tile" }[ $i ][ $j ] = Tile->new;
	  }
      }
    bless( $board, "Board" );
    $board->updatemetadata;
    return $board;
  }

sub playableboard
    {
    shift @_;
      my $x = shift @_;
      my $y = shift @_;
      my $c = shift @_;

      my $emergency = 0;

      while ( 1 )
	{
	  die "Can't find a playable board?\n" if $emergency > 1000;
	  my $board = Board->new( $x, $y, $c );
	  $board->fill;
	  $board->findmatches;
	  next if $board->hasmatches;
	  $board->findpotentialmoves;
	  return $board if $board->haspotentialmoves;
	  $emergency++;
	}
    }

sub updatemetadata
  {
    my $board = shift @_;
    my $colors = $board->{ "extended_colors" };

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    foreach my $c ( @$colors, "any" )
	      {
		$board->{ "match" }{ $c }[ $i ][ $j ] = 0;
		$board->{ "destroy" }{ $c }[ $i ][ $j ] = 0;
		$board->{ "critical_match" }{ $c }[ $i ][ $j ] = 0;
		$board->{ "primary_match" }{ $c }[ $i ][ $j ] = 0;
		$board->{ "secondary_match" }{ $c }[ $i ][ $j ] = 0;
		$board->{ "create_critical" }{ $c }[ $i ][ $j ] = 0;
		$board->{ "potential_move" }{ $c }[ $i ][ $j ] = 0;
	      }
	  }
      }
    delete $board->{ "potentialmoves" };

    bless( $board, "Board" );
    $board->statistics;
    return $board;
  }



sub calculateboarddamage
  {
    my $board = shift @_;
    my $player1 = shift @_;
    my $player2 = shift @_;
    my $colors = $board->{ "colors" };
#    print Dumper $player1;

    my $damage = 0;

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    foreach my $c ( @$colors )
	      {
		if ( $board->{ "destroy" }{ $c }[ $i ][ $j ] > 0 )
		  {
		    print $c, "\n";
		    $damage += $player1->{ "damage" }{ $c };
		  }
	      }
	  }
      }
    $board->display;
    print "Damage: $damage\n"; die;
  }

sub clearmovedata
  {
    my $board = shift @_;
    delete $board->{ "moved_tile" }{ "primary" };
    delete $board->{ "moved_tile" }{ "secondary" };
    delete $board->{ "primary_move_causes_match" };
    delete $board->{ "secondary_move_causes_match" };
}


sub haspotentialmoves
  {
    my $board = shift @_;
    return 1 if defined $board->{ "potentialmoves" };
    return 0;
  }


sub displaypotentialmoves
  {
    my $board = shift @_;

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    print ( $board->{ "potential_move" }{ "any" }[ $i ][ $j ] == 1 ? uc( $board->{ "tile" }[ $i ][ $j ]->displaycolor( $board->{ "extended_colors" } ) ) : $board->{ "tile" }[ $i ][ $j ]->displaycolor( $board->{ "extended_colors" } ) );
	    print " ";
	  }
	print "\n\n";
      }
  }


#only random for now

sub fill
  {
    my $board = shift @_;
####    print Dumper $board; 
####    print $board->{ "X" }, "\n";
####    die;
    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    $board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" }, "random" ) if $board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "empty";
	  }
      }
    $board->updatemetadata;
    return $board;
  }

sub boardshake
  {
    my $board = shift @_;
    my @tiles;
    my $colors = $board->{ "extended_colors" };
    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    push @tiles, $board->{ "tile" }[ $i ][ $j ];
	  }
      }
    @tiles = shuffle( @tiles );

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    $board->{ "tile" }[ $i ][ $j ] = pop @tiles;
	  }
      }
    $board->updatemetadata;
    return $board;
  }

sub dump
  {
    my $board = shift @_;

    print Dumper $board;
  }

sub display
  {
    my $board = shift @_;

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    print $board->{ "tile" }[ $i ][ $j ]->displaycolor;
	    print " ";
	  }
	print "\n\n";
      }
  }

sub displaymatches
  {
    my $board = shift @_;

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    print ( $board->{ "match" }{ "any" }[ $i ][ $j ] == 1 ? uc( $board->{ "tile" }[ $i ][ $j ]->displaycolor ) : $board->{ "tile" }[ $i ][ $j ]->displaycolor );
	    print " ";
	  }
	print "\n\n";
      }
  }

sub displaydestroyables
  {
    my $board = shift @_;

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    print ( $board->{ "destroy" }{ "any" }[ $i ][ $j ] == 1 ? uc( $board->{ "tile" }[ $i ][ $j ]->displaycolor ) : $board->{ "tile" }[ $i ][ $j ]->displaycolor );
	    print " ";
	  }
	print "\n\n";
      }
  }

sub displaycriticals
  {
    my $board = shift @_;

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    print ( $board->{ "create_critical" }{ "any" }[ $i ][ $j ] == 1 ? "X" : "·" );
	    print " ";
	  }
	print "\n\n";
      }
  }

sub gravity
  {
    my $board = shift @_;
#    $board->{ "tile" }[ 0 ][ 0 ] = Tile->critical;

    foreach my $i ( 0 .. $board->{ "X" } )
      {
	my $k = $board->{ "Y" };
	foreach my $j ( reverse ( 0 .. $board->{ "Y" } ) )
	  {
	    if ( $board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) ne "empty" )
	      {
		$board->{ "tile" }[ $i ][ $k-- ] = $board->{ "tile" }[ $i ][ $j ];
	      }
	  }
	foreach my $j ( reverse ( 0 .. $k ) )
	  {
	    $board->{ "tile" }[ $i ][ $j ] = Tile->new;
	  }
      }
    $board->updatemetadata;
    return $board;
  }

####sub clearmatches
####  {
####    my $board = shift @_;
####    my $colors = $board->{ "colors" };
####
####    foreach my $j ( 0 .. $board->{ "Y" } )
####      {
####	foreach my $i ( 0 .. $board->{ "X" } )
####	  {
####	    if ( $board->{ "create_critical" }{ "any" }[ $i ][ $j ] == 1 )
####	      {
####		$board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" }, "critical" );
####	      }
####	    elsif ( $board->{ "match" }{ "any" }[ $i ][ $j ] == 1 )
####	      {
####		$board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" }, "empty" );
####	      }
####	  }
####      }
####    $board->updatemetadata;
####    return $board;
####  }

sub cleardestroyables
  {
    my $board = shift @_;
    my $player = shift @_;

    my @colors;
    $colors[ 0 ] = $board->{ "colors" };
    $colors[ 1 ] = $board->{ "extended_colors" };

    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    if ( $board->{ "create_critical" }{ "any" }[ $i ][ $j ] == 1 )
	      #then destroy is implied
	      {
		$player->{ "AP" }{ $board->{ "tile" }[ $i ][ $j ]->color( @colors ) }++;
		$board->{ "tile" }[ $i ][ $j ]->color( @colors, "critical" );
	      }
	    elsif ( $board->{ "destroy" }{ "any" }[ $i ][ $j ] == 1 )
	      {
		$player->{ "AP" }{ $board->{ "tile" }[ $i ][ $j ]->color( @colors ) }++;
		$board->{ "tile" }[ $i ][ $j ]->color( @colors, "empty" );
	      }
	  }
      }
    $board->updatemetadata;
    return $board;
  }

#this assumes the board does not contain actual matches
sub findpotentialmoves
  {
    my $board = shift @_;
    my $colors = $board->{ "colors" };
    my @tmppotentialmoves;

    #set up a tmp board to find moves in, so we don't have to specialrule edge cases
    my $tmpboard_regular = Board->new( $board->{ "X" } + 2 + 1, $board->{ "Y" } + 2 + 1, $board->{ "colorsize" } );
    my $tmpboard_transposed = Board->new( $board->{ "Y" } + 2 + 1, $board->{ "X" } + 2 + 1, $board->{ "colorsize" } );
    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    $tmpboard_regular->{ "tile" }[ $i + 1 ][ $j + 1 ]->color( $board->{ "colors" }, $board->{ "extended_colors" }, $board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) );
	    $tmpboard_transposed->{ "tile" }[ $j + 1 ][ $i + 1 ]->color( $board->{ "colors" }, $board->{ "extended_colors" }, $board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) );
	  }
      }

    my $count = 0;

    foreach my $tmpboard ( $tmpboard_regular, $tmpboard_transposed )
      {
	#	$tmpboard->display;
	foreach my $c ( @$colors )
	  {
#	    print $c, "\n";
	    
	    #horizontal...
	    foreach my $j ( 1 .. $tmpboard->{ "Y" } - 1 )
	      {
		foreach my $i ( 1 .. $tmpboard->{ "X" } - 2 - 1 )
		  {
		    # 1) mm_
		    if ( ( $tmpboard->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" ) and ( $tmpboard->{ "tile" }[ $i + 1 ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i + 1 ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" ) )
		      {
			my @relative;
			$relative[ 0 ]{ "X" } = +2;
			$relative[ 0 ]{ "Y" } = -1;
			$relative[ 1 ]{ "X" } = +2;
			$relative[ 1 ]{ "Y" } = +1;
			$relative[ 2 ]{ "X" } = +3;
			$relative[ 2 ]{ "Y" } = 0;
			
			foreach my $k ( 0 .. $#relative )
			  {
			    if ( $tmpboard->{ "tile" }[ $i + $relative[ $k ]{ "X" } ][ $j + $relative[ $k ]{ "Y" } ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i + $relative[ $k ]{ "X" } ][ $j + $relative[ $k ]{ "Y" } ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" )
			      {
				my @alpha = ( $i + $relative[ $k ]{ "X" }, $j + $relative[ $k ]{ "Y" } );
				my @beta = ( $i + 2, $j );
				my @pm = ( \@alpha, \@beta, $c, $count );
				push @tmppotentialmoves, \@pm;
				#			    $tmpboard
			      }
			  }
		      }
		    # 2) m_m
		    elsif ( ( $tmpboard->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" ) and ( $tmpboard->{ "tile" }[ $i + 2 ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i + 2 ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" ) )
		      {
			my @relative;
			$relative[ 0 ]{ "X" } = +1;
			$relative[ 0 ]{ "Y" } = -1;
			$relative[ 1 ]{ "X" } = +1;
			$relative[ 1 ]{ "Y" } = +1;
			
			foreach my $k ( 0 .. $#relative )
			  {
			    if ( $tmpboard->{ "tile" }[ $i + $relative[ $k ]{ "X" } ][ $j + $relative[ $k ]{ "Y" } ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i + $relative[ $k ]{ "X" } ][ $j + $relative[ $k ]{ "Y" } ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" )
			      {
				my @alpha = ( $i + $relative[ $k ]{ "X" }, $j + $relative[ $k ]{ "Y" } );
				my @beta = ( $i + 1, $j );
				my @pm = ( \@alpha, \@beta, $c, $count );
				push @tmppotentialmoves, \@pm;
				#			    $tmpboard
			      }
			  }
		      }
		    # 3) _mm
		    elsif ( ( $tmpboard->{ "tile" }[ $i +1 ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i + 1 ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" ) and ( $tmpboard->{ "tile" }[ $i + 2 ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i + 2 ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" ) )
		      {
			my @relative;
			$relative[ 0 ]{ "X" } = 0;
			$relative[ 0 ]{ "Y" } = -1;
			$relative[ 1 ]{ "X" } = 0;
			$relative[ 1 ]{ "Y" } = +1;
			$relative[ 2 ]{ "X" } = -1;
			$relative[ 2 ]{ "Y" } = 0;
			
			foreach my $k ( 0 .. $#relative )
			  {
			    if ( $tmpboard->{ "tile" }[ $i + $relative[ $k ]{ "X" } ][ $j + $relative[ $k ]{ "Y" } ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or $tmpboard->{ "tile" }[ $i + $relative[ $k ]{ "X" } ][ $j + $relative[ $k ]{ "Y" } ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" )
			      {
				my @alpha = ( $i + $relative[ $k ]{ "X" }, $j + $relative[ $k ]{ "Y" } );
				my @beta = ( $i , $j );
				my @pm = ( \@alpha, \@beta, $c, $count );
				push @tmppotentialmoves, \@pm;
				#			    $tmpboard
			      }
			  }
		      }
		  }
	      }
	  }
	$count++;
      }

#    print Dumper @tmppotentialmoves;
    my @potentialmoves;
    foreach my $pm ( @tmppotentialmoves )
      {
	my @pm;
	if ( $pm->[ 3 ] == 0 )
	  {
	    my @alpha = ( $pm->[ 0 ][ 0 ] - 1, $pm->[ 0 ][ 1 ] - 1 );
	    my @beta = ( $pm->[ 1 ][ 0 ] - 1, $pm->[ 1 ][ 1 ] - 1 );
	    @pm = ( \@alpha, \@beta, $pm->[ 2 ] );
	  }
	else #it better be 1...
	  {
	    my @alpha = ( $pm->[ 0 ][ 1 ] - 1, $pm->[ 0 ][ 0 ] - 1 );
	    my @beta = ( $pm->[ 1 ][ 1 ] - 1, $pm->[ 1 ][ 0 ] - 1 );
	    @pm = ( \@alpha, \@beta, $pm->[ 2 ] );
	  }
	push @potentialmoves, \@pm;
      }
#   print Dumper @potentialmoves;


    foreach my $pm ( @potentialmoves )
      {
	$board->{ "potential_move" }{ "any" }[ $pm->[ 0 ][ 0 ] ][ $pm->[ 0 ][ 1 ] ] = 1;
	$board->{ "potential_move" }{ "any" }[ $pm->[ 1 ][ 0 ] ][ $pm->[ 1 ][ 1 ] ] = 1;
      }

    $board->{ "potentialmoves" } = \@potentialmoves if @potentialmoves;
    return $board;
  }


sub getmove
  {
    my $board = shift @_;

    my $move = $board->{ "potentialmoves" }->[ rand @{ $board->{ "potentialmoves" } } ];

      return $move;
  }


sub setmove
  {
    my $board = shift @_;
    my $move = shift @_;

#    print "Move:\n";
#    print Dumper $move->[ 0 ][ 0 ];
#    print Dumper $move->[ 0 ][ 1 ];
#    print Dumper $move->[ 1 ][ 0 ];
#    print Dumper $move->[ 1 ][ 1 ];
    my $tmptile = Tile->new;

    $tmptile = $board->{ "tile" }[ $move->[ 0 ][ 0 ]][ $move->[ 0 ][ 1 ] ];
    $board->{ "tile" }[ $move->[ 0 ][ 0 ]][ $move->[ 0 ][ 1 ] ] = $board->{ "tile" }[ $move->[ 1 ][ 0 ]][ $move->[ 1 ][ 1 ] ];
    $board->{ "tile" }[ $move->[ 1 ][ 0 ]][ $move->[ 1 ][ 1 ] ] = $tmptile;

    $board->{ "moved_tile" }{ "primary" }{ "X" } = $move->[ 1 ][ 0 ];
    $board->{ "moved_tile" }{ "primary" }{ "Y" } = $move->[ 1 ][ 1 ];
    $board->{ "moved_tile" }{ "secondary" }{ "X" } = $move->[ 0 ][ 0 ];
    $board->{ "moved_tile" }{ "secondary" }{ "Y" } = $move->[ 0 ][ 1 ];

    $board->updatemetadata;
  }


sub findmatches
  {
    my $board = shift @_;
    my $colors = $board->{ "colors" };

    foreach my $c ( @$colors )
      {
#	print $c, "\n";

	#In the first runthrough we mark the matches and set up the criticals 
	#for overlapping matches

	#horizontal...
	foreach my $j ( 0 .. $board->{ "Y" } )
	  {
	    my $i = 0;
	    while ( $i <= $board->{ "X" } - 2 )
	      {
		my $match_size;
		my $h = $i;
		while ( $h <= $board->{ "X" } and
			( $board->{ "tile" }[ $h ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or
			 $board->{ "tile" }[ $h ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" )
		      )
		  {
		    $h++;
		  }
		$match_size = $h - $i;
		if ( $match_size >= 3 )
		  {
#		    print "$i, $j starts a horizontal $match_size-match!\n";
		    foreach my $k ( $i .. $h - 1 )
		      {
			$board->{ "match" }{ $c }[ $k ][ $j ] = $match_size;
			$board->{ "match" }{ "any" }[ $k ][ $j ] = 1;
			$board->{ "destroy" }{ $c }[ $k ][ $j ] = 1;
			$board->{ "destroy" }{ "any" }[ $k ][ $j ] = 1;
		      }
		    if ( $match_size >= 4 )
		      {
##			foreach my $k ( 0  .. $board->{ "X" } )
##			  {
##			    print "BUG! WRONG COLORS GET MARKED AS destroy!\n";
##			    print "SAME GOES FOR VERTICAL AT LEAST!\n";
##			    $board->{ "destroy" }{ $c }[ $k ][ $j ] = 1;
##			    $board->{ "destroy" }{ "any" }[ $k ][ $j ] = 1;
##			  }
			foreach my $k ( 0 .. $i -1, $h .. $board->{ "X" } )
			  {
			    my $co = $board->{ "tile" }[ $k ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } );
			    $board->{ "destroy" }{ $co }[ $k ][ $j ] = 1;
			    $board->{ "destroy" }{ "any" }[ $k ][ $j ] = 1;
			  }
		      }
		    $i = $h + 1
		  }
		else
		  {
		    $i++
		  }
	      }
	  }


	#vertical...
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    my $j = 0;
	    while ( $j <= $board->{ "Y" } - 2 )
	      {
		my $match_size;
		my $h = $j;
		while ( $h <= $board->{ "Y" } and
			( $board->{ "tile" }[ $i ][ $h ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or
			 $board->{ "tile" }[ $i ][ $h ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" )
		      )
		  {
		    $h++;
		  }
		$match_size = $h - $j;
		if ( $match_size >= 3 )
		  {
#		    print "$i, $j starts a vertical $match_size-match!\n";
		    foreach my $k ( $j .. $h - 1 )
		      {
			if ( $board->{ "match" }{ $c }[ $i ][ $k ] == 0 )
			  {
			    $board->{ "match" }{ $c }[ $i ][ $k ] = $match_size;
			    $board->{ "destroy" }{ $c }[ $i ][ $k ] = 1;
			  }
			else
			  {
			    $board->{ "match" }{ $c }[ $i ][ $k ] = $board->{ "match" }{ $c }[ $i ][ $k ] + $match_size - 1;
			    $board->{ "destroy" }{ $c }[ $i ][ $k ] = 1;
			    $board->{ "create_critical" }{ $c }[ $i ][ $k ] = 1;
			    $board->{ "create_critical" }{ "any" }[ $i ][ $k ] = 1;
#unneeded		    $board->{ "temp_crit" } = 1;
			  }
			$board->{ "match" }{ "any" }[ $i ][ $k ] = 1;
			$board->{ "destroy" }{ "any" }[ $i ][ $k ] = 1;
		      }
		    if ( $match_size >= 4 )
		      {
#			foreach my $k ( 0  .. $board->{ "Y" } )
#			  {
#			    $board->{ "destroy" }{ $c }[ $i ][ $k ] = 1;
#			    $board->{ "destroy" }{ "any" }[ $i ][ $k ] = 1;
#			  }
			foreach my $k ( 0 .. $j -1, $h .. $board->{ "Y" } )
			  {
			    my $co = $board->{ "tile" }[ $i ][ $k ]->color( $board->{ "colors" }, $board->{ "extended_colors" } );
			    $board->{ "destroy" }{ $co }[ $i ][ $k ] = 1;
			    $board->{ "destroy" }{ "any" }[ $i ][ $k ] = 1;
			  }
		      }
		    $j = $h + 1
		  }
		else
		  {
		    $j++
		  }
	      }
	  }
      }

	#In the second runthrough we check 5- and larger matches to see if they
	#need a critical set up (ie they aren't part of a crossing)
    foreach my $c ( @$colors )
      {

	
	#horizontal...
	foreach my $j ( 0 .. $board->{ "Y" } )
	  {
	    my $i = 0;
	    while ( $i <= $board->{ "X" } - 2 )
	      {
		my $match_size;
		my $h = $i;
		while ( $h <= $board->{ "X" } and
			( $board->{ "tile" }[ $h ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or
			 $board->{ "tile" }[ $h ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" )
		      )
		  {
		    $h++;
		  }
		$match_size = $h - $i;
		if ( $match_size >= 5 )
		  {
#		    print "$i, $j starts a horizontal $match_size-match!\n";
		    my $place_crit = 1;
		    foreach my $k ( $i .. $h - 1 )
		      {
			if ( $board->{ "create_critical" }{ $c }[ $k ][ $j ] == 1 )
			  {
			    $place_crit = 0
			  }
		      }
		    if ( $place_crit == 1 )
		      {
			$board->{ "create_critical" }{ $c }[ $i + int( ( $match_size - 1 ) / 2 ) ][ $j ] = 1;
			$board->{ "create_critical" }{ "any" }[ $i + int( ( $match_size - 1 ) / 2 ) ][ $j ] = 1;
#unneeded		$board->{ "temp_crit" } = 1;
		      }
		    $i = $h + 1 + $match_size
		  }
		else
		  {
		    $i++
		  }
	      }
	  }





	
	#vertical...
	foreach my $i ( 0 .. $board->{ "X" } )
	  {
	    my $j = 0;
	    while ( $j <= $board->{ "Y" } - 2 )
	      {
		my $match_size;
		my $h = $j;
		while ( $h <= $board->{ "Y" } and
			( $board->{ "tile" }[ $i ][ $h ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq $c or
			 $board->{ "tile" }[ $i ][ $h ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" )
		      )
		  {
		    $h++;
		  }
		$match_size = $h - $j;
		if ( $match_size >= 5 )
		  {
#		    print "$i, $j starts a vertical $match_size-match!\n";
		    my $place_crit = 1;
		    foreach my $k ( $j .. $h - 1 )
		      {
			if ( $board->{ "create_critical" }{ $c }[ $i ][ $k ] == 1 )
			  {
			    $place_crit = 0
			  }
		      }
		    if ( $place_crit == 1 )
		      {
			$board->{ "create_critical" }{ $c }[ $i ][ $j + int( ( $match_size - 1 ) / 2 ) ] = 1;
			$board->{ "create_critical" }{ "any" }[ $i ][ $j + int( ( $match_size - 1 ) / 2 ) ] = 1;
#unneeded		$board->{ "temp_crit" } = 1;
		      }
		    $j = $h + 1 + $match_size
		  }
		else
		  {
		    $j++
		  }
	      }
	  }


      }

    #at this point we have marked exactly which tiles will get destroyed
    #now we need to find
    #1)the tiles that will get destroyed in a match with a critical
    #  (because they get a critical multiplier applied)
    #  (the criticals also need to know which colors they "are", because the
    #  multiplier depends on the color owner) -> this is done


    #locate criticals by color, find neighbours that will be matched away by it, and
    #mark them and the critical up for a critical multiplier
    foreach my $c ( @$colors )
      {
	foreach my $j ( 0 .. $board->{ "Y" } )
	  {
	    foreach my $i ( 0 .. $board->{ "X" } )
	      {
		if ( $board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) eq "critical" and
		     $board->{ "match" }{ $c }[ $i ][ $j ] > 0 )
		  {
		    my $i_min;
		    my $i_max;
		    my $j_min;
		    my $j_max;
		    
		    for my $jj ( reverse ( 0 .. $j ) )
		      {
			if ( $board->{ "match" }{ $c }[ $i ][ $jj ] > 0 )
			  {
			    $j_min = $jj
			  }
			else
			  {
			    last;
			  }
		      }

		    for my $jj ( $j .. $board->{ "Y" } )
		      {
			if ( $board->{ "match" }{ $c }[ $i ][ $jj ] > 0 )
			  {
			    $j_max = $jj
			  }
			else
			  {
			    last;
			  }
		      }

		    if ( $j_max - $j_min >= 2 )
		      {
			for my $jj ( $j_min .. $j_max )
			  {
			    $board->{ "critical_match" }{ $c }[ $i ][ $jj ]++;
			  }
		      }

		    
		    for my $ii ( reverse ( 0 .. $i ) )
		      {
			if ( $board->{ "match" }{ $c }[ $ii ][ $j ] > 0 )
			  {
			    $i_min = $ii
			  }
			else
			  {
			    last;
			  }
		      }

		    for my $ii ( $i .. $board->{ "X" } )
		      {
			if ( $board->{ "match" }{ $c }[ $ii ][ $j ] > 0 )
			  {
			    $i_max = $ii
			  }
			else
			  {
			    last;
			  }
		      }

		    if ( $i_max - $i_min >= 2 )
		      {
			for my $ii ( $i_min .. $i_max )
			  {
			    $board->{ "critical_match" }{ $c }[ $ii ][ $j ]++;
			  }
		      }

		  }

	      }
	  }
      }

    #2)the tiles that will be destroyed because they are matched by the primary
    # moved tile
    #  (because they get multiplier 1, the rest get .75)
    #  (if there IS no primary moved tile, because the board is transformed by
    #   some other method, or because this a post-cascade unstable board, I
    #   wil *assume* everything gets multiplier 1)
    #  (in cases like this one: __X__
    #                           RR_YY, where critical tile X gets moved down
    #   I will *also* *assume* both matches get multiplier 1; I might well be
    #   wrong here...)
    #-note that where I write primary moved tile, it could also be the
    # secondary moved tile, in cases the primary doesn't actually generate a
    # match
    #

    if ( $board->{ "moved_tile" }{ "primary" } )
      #then the board is the direct result of a move
      {
#	print Dumper $board->{ "moved_tile" }{ "primary" };
	foreach my $prio ( "primary", "secondary" )
	  {
	    my $i = $board->{ "moved_tile" }{ "primary" }{ "X" };
	    my $j = $board->{ "moved_tile" }{ "primary" }{ "Y" };

	    foreach my $c ( @$colors )
	      {
	    
		if ( $board->{ "match" }{ $c }[ $i ][ $j ] > 0 )
		  {
		    my $i_min;
		    my $i_max;
		    my $j_min;
		    my $j_max;
		    
		    for my $jj ( reverse ( 0 .. $j ) )
		      {
			if ( $board->{ "match" }{ $c }[ $i ][ $jj ] > 0 )
			  {
			    $j_min = $jj
			  }
			else
			  {
			    last;
			  }
		      }
		    
		    for my $jj ( $j .. $board->{ "Y" } )
		      {
			if ( $board->{ "match" }{ $c }[ $i ][ $jj ] > 0 )
			  {
			    $j_max = $jj
			  }
			else
			  {
			    last;
			  }
		      }
		    
		    if ( $j_max - $j_min >= 2 )
		      {
			$board->{ $prio . "_move_causes_match" } = 1;
			for my $jj ( $j_min .. $j_max )
			  {
			    $board->{ $prio . "_match" }{ $c }[ $i ][ $jj ]++;
			  }
		      }
		    
		    
		    for my $ii ( reverse ( 0 .. $i ) )
		      {
			if ( $board->{ "match" }{ $c }[ $ii ][ $j ] > 0 )
			  {
			    $i_min = $ii
			  }
			else
			  {
			    last;
			  }
		      }
		    
		    for my $ii ( $i .. $board->{ "X" } )
		      {
			if ( $board->{ "match" }{ $c }[ $ii ][ $j ] > 0 )
			  {
			    $i_max = $ii
			  }
			else
			  {
			    last;
			  }
		      }
		    
		    if ( $i_max - $i_min >= 2 )
		      {
			$board->{ $prio . "_move_causes_match" } = 1;
			for my $ii ( $i_min .. $i_max )
			  {
			    $board->{ $prio . "_match" }{ $c }[ $ii ][ $j ]++;
			  }
		      }
		  }
	      }
	  }
	
	
	$board->clearmovedata;
      }
    
    #the board should only return with this information
    #the actual damage number should be calculated elsewhere, in a "mqp_damage"
    #sort of sub
    #also note that the board will *also* need to know how many times it has
    #cascaded, because the damage multiplier goes down with each cascade by
    #a factor .75.

    $board->statistics;
    return $board;
  }


sub hasmatches
  {
    my $board = shift @_;
    return ( $board->{ "statistics" }{ "contains_matches" } ? 1 : 0 )
  }

sub hasdestroyables
  {
    my $board = shift @_;
    return ( $board->{ "statistics" }{ "contains_destroyables" } ? 1 : 0 )
  }


sub statistics
  {
    my $board = shift @_;
    my $extended_colors = $board->{ "extended_colors" };


    # clean old stats
    foreach my $c ( @$extended_colors )
      {
	$board->{ "statistics" }{ "color_count" }{ $c } = 0;
      }
    $board->{ "statistics" }{ "contains_matches" } = 0;

    #generate new stats
    foreach my $j ( 0 .. $board->{ "Y" } )
      {
	foreach my $i ( 0 .. $board->{ "X" } )
	  {

#	    print $board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ), "<<\n"; 

	    $board->{ "statistics" }{ "color_count" }{ $board->{ "tile" }[ $i ][ $j ]->color( $board->{ "colors" }, $board->{ "extended_colors" } ) }++;
	    $board->{ "statistics" }{ "contains_matches" } = 1 if $board->{ "match" }{ "any" }[ $i ][ $j ] > 0;
	    $board->{ "statistics" }{ "contains_destroyables" } = 1 if $board->{ "destroy" }{ "any" }[ $i ][ $j ] > 0;
	  }
      }
  }

sub displaystatistics
  {
    my $board = shift @_;
    my $extended_colors = $board->{ "extended_colors" };
    foreach my $c ( @$extended_colors )
      {
	print "$c: ", $board->{ "statistics" }{ "color_count" }{ $c }, "\n";
      }
    print "Matches ", ( $board->{ "statistics" }{ "contains_matches" } ? "" : "not " ), "present.\n";
    print "Destroyables ", ( $board->{ "statistics" }{ "contains_destroyables" } ? "" : "not " ), "present.\n";
  }

1;
