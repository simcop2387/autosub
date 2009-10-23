package Detect;

use strict;
use warnings;

use PDL;
use FFTW;

sub hasvoice
{
   my $sample = shift;
   my $index = shift; #solely for printing out time indexes to check!

   my $sum = $sample->sum;
   #my $left = int $i*$winsize/$overlap;
   my $time = ($index*$FFTW::winsize/$FFTW::overlap)/48000; #(index * ) / samples per second

   print $time," :: ",$sum, " :: ", $sum > 3?1:0,"\n";

   return 1 if $sum > 3;
   return 0
}

sub cleanup
{
  my @maps = @_;
  my $map = join "", @maps;

  $_=$map;

  s/1101/1111/g; #cleanup places where it missed?
  s/1011/1111/g;
  s/00011000/00000000/g; #clean up 0.10 seconds in the middle of nothing
  s/11100111/11111111/g;
  s/00100/00000/g; #clean up 1's in the middle of nothing

  #specific case in output
  s/000101000/000000000/g;

  s/000000111000000/000000000000000/g; #i should genericise this one, not sure a good way how yet
  s/111111000111111/111111111111111/g;
#these will get implemented when selecting ranges, it seems to corrupt things too easily when used like this
#  s/0111/1111/g; #pick up a little before
#  s/1110/1111/g; #a little after! 

  return $_;
}

1;
