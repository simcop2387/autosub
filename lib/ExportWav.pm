package ExportWav;

use strict;
use warnings;

use PDL::Audio;
use PDL;

sub writewav
{
  my $orig = shift; #original audio file, needed for the header
  my $slice = shift; #slice of the detected samples
  my $idx = shift; #which file it is
  my $tmp = shift; #where to save to
  
  $slice->waudio($orig->gethdr, path=>sprintf("%s/sample%05d.wav", $tmp, $idx));
}

sub makewavs
{
}

1;
