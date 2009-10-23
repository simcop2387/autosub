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

   print $time," :: ",$sum,"\n";

}
