package ExportWav;

use strict;
use warnings;

use PDL::Audio;
use PDL;

use Data::Dumper;

my $silence = zeroes(8000);

sub writewav
{
  my $orig = shift; #original audio file, needed for the header
  my $slice = shift; #slice of the detected samples
  my $idx = shift; #which file it is
  my $tmp = shift; #where to save to

  my $fname = sprintf("%s/sample%05d.wav", $tmp, $idx);

  my %opts = (%{$orig->gethdr}, path => $fname);

  my $movedslice = concat($silence, $slice, $silence); #wrap in silence for julius to work better

  print "Writing WAV: $fname\n";  
  $slice->waudio(%opts);
}

sub makewavs
{
  my $tmp = shift;
  my $audio = shift;
  my @codes = @_;

  for my $i(0..$#codes)
  {
    my $slicestr = $codes[$i][0].":".$codes[$i][1];
    writewav($audio, $audio->slice($slicestr), $i, $tmp);
  }
}

1;
