package FFTW;

use PDL;
use PDL::Audio;

use strict;
use warnings;

sub open
{
  my $tmp = shift;

  my $pdl = raudio "$tmp/resampled.wav";
}

1;
