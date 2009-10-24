package Detect;

use strict;
use warnings;

use PDL;
use FFTW;

sub hasvoice {
    my $sample = shift;
    my $index  = shift;    #solely for printing out time indexes to check!

    my $sum = $sample->sum;

    #my $left = int $i*$winsize/$overlap;
    my $time =
      ( $index * $FFTW::winsize / $FFTW::overlap ) /
      48000;               #(index * ) / samples per second

    print $time, " :: ", $sum, " :: ", $sum > 3 ? 1 : 0, "\n";

    return 1 if $sum > 3;
    return 0;
}

sub cleanup {
    my $map = shift;       #make it easier to run more than once

    $_ = $map;

    s/1101/1111/g;         #cleanup places where it missed?
    s/1011/1111/g;
    s/001100/000000/g;     #clean up 0.10 seconds in the middle of nothing
    s/110011/111111/g;
    s/00100/00000/g;       #clean up 1's in the middle of nothing

    #specific case in output
    s/000101000/000000000/g;

    #i should genericise this one, not sure a good way how yet
    s/000000111000000/000000000000000/g;
    s/111111000111111/111111111111111/g;

#these will get implemented when selecting ranges, it seems to corrupt things too easily when used like this
#  s/0111/1111/g; #pick up a little before
#  s/1110/1111/g; #a little after!

    return $_;
}

sub collect {
    my $map = shift;
    my @codes;

    #i'm gonna use map2 here, to get a good list
    my $i = -1;    #start at -1 for this
    my $start      = 0;
    my $finish     = 0;
    my $collecting = 1;
    for my $sample ( split //, $map ) {
        $i++;
        next if ( $sample == 1 && $collecting == 1 );    #don't do anything

        if ( $sample == 0 && $collecting == 1 ) {
            $finish     = $i;                            #gets it +1
            $collecting = 0;
            push @codes, [ $start, $finish ];
            next;
        }

        if ( $sample == 1 && $collecting == 0 ) {
            $start      = $i - 1;    #get 1 before this sample
            $collecting = 1;
            next;
        }
    }

    if ( $collecting == 1 ) {
        push @codes, [ $start, $i ];
    };                                #collect the last end of it

    return trimcodes(@codes);
}

sub trimcodes
{
  my @codes = @_;
  my @trimmed;

  for my $code (@codes)
  {
    my $length = $code->[1] - $code->[0];
    push @trimmed, [map {fullsamples($_)} @$code] if ($length >= 20); #get ones that 1 or more seconds!
  }

  return @trimmed;
}

sub fullsamples
{
    my $index = shift;
    my $time = ( $index * $FFTW::winsize / $FFTW::overlap );
    $time;
}

1;
