package FFTW;

use PDL;
use PDL::Audio;
use PDL::Graphics::PLplot;
use Data::Dumper;

use strict;
use warnings;

$|++;

our $winsize = 8192;
our $overlap = 10;
my $window = gen_fft_window $winsize, "HANNING";#, 2.5;

my $voicequant = gen_fft_window 4096, "GAUSSIAN", 5.5;

$voicequant = concat($voicequant, zeroes($winsize/2+1 - 4096));

my $graphx = sequence($winsize/2+1);

sub open
{
  my $tmp = shift;

  my $pdl = raudio "$tmp/resampled.wav";

  $pdl
}

sub getfftw
{
  my $pdl = shift;
  my $temp = shift;

  my @spects = ();

  my $size = nelem($pdl);

  for my $i (0..$overlap*$size/$winsize-$overlap) #take $overlap sections off, since i'm not going to code a resizing window XD
  {
    my $left = int $i*$winsize/$overlap;
    my $right = $left+$winsize-1;

    print "$left $i ".($overlap*$size/$winsize)."\n" if (!($i % 50));

    my $spect = getwindow($pdl->slice("${left}:$right"));
    my $y = $voicequant * $spect;

    push @spects, $y->sum;

#    my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => sprintf($temp.'/test%04d.png', $i));
#    $plot->xyplot($graphx, $y);
#    $plot->close();

    #sleep 10;
#    print "${left}:$right\n";
  }

  return \@spects;
}

sub getwindow
{
  my $slice = shift;
 
  spectrum $slice, 1, $window;
}

1;
