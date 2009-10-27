#!/usr/bin/perl

use strict;
use warnings;

use PDL;
use PDL::Audio;
use PDL::Graphics::PLplot;

sub butterworth
{
  my $w = shift;
  my $wc = shift;
  my $o = shift;

#1/(1 + (w/w0)^(2*o))
  return 1/(1+ ($w/$wc)**(2*$o));
#(($ssq + 0.3902 * $s + 1)*($ssq  + 1.1111 * $s + 1)*($ssq + 1.6629 * $s + 1)*($ssq  + 1.9616 * $s + 1))
}

my $s = sequence(4096);
#8192/(2pi)
my $pi = 3.141592;
my $filt = butterworth(2*$pi*$s/8192, $pi*9/40, 10);

my $pl = PDL::Graphics::PLplot->new (DEV => "png", FILE => "butterworth.png");
$pl->xyplot($s, $filt);
$pl->close();
