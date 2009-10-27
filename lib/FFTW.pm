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

#my $voicequant = gen_fft_window 4096, "GAUSSIAN", 5.5;

#$voicequant = concat($voicequant, zeroes($winsize/2+1 - 4096));

#my $graphx = sequence($winsize/2+1);

#test code imported from testcurve.pl, hopefull should give me a better response than the other one
###########################################
#!/usr/bin/perl
#my $winsize=8192;

my $voicequant = gen_fft_window 4096, "GAUSSIAN", 2.0;

$voicequant = $voicequant->append(zeroes($winsize/2+1 - $voicequant->nelem));

my $graphx = sequence($winsize/2+1);

    my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE =>'test.png');
    $plot->xyplot($graphx, $voicequant);
    $plot->close();

my $vqlop = pdl [];

my $vqsize = $voicequant->nelem-1;
my $blog = log($vqsize*8);
for my $i (1..$vqsize)
{
  my $logi = int((log($i)/$blog)*$vqsize);
  $vqlop = $vqlop->append($voicequant->index($logi));
}

$vqlop = $vqlop->append(zeroes($winsize/2+1 - $vqlop->nelem));
#$vqlop = $vqlop + $voicequant/1.1;
#$vqlop = $voicequant;

#    my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE =>'test2.png');
#    $plot->xyplot($graphx, $vqlop);
#    $plot->close();
###########################################

sub open
{
  my $tmp = shift;

  my $pdl = raudio "$tmp/resampled.wav";

  $pdl
}

sub getsamplerange
{
  my $seconds = shift;
#int( $index * $FFTW::winsize / $FFTW::overlap )
#this is the inverse of the above function
  return (($seconds * 16000) * $overlap / $winsize);
}

sub processignores
{
  my $ignores = shift;
  my @new = map {[getsamplerange($_->[0]), getsamplerange($_->[1])]} @$ignores;

  return \@new;
}

sub isignored
{
  my $index = shift;
  my $ignores = shift;

  my $r = 0;

  for my $ig (@$ignores)
  {
    $r = 1 if ($index < $ig->[1] && $index > $ig->[0])  #before the end, and after the start
  }

  return $r;
}

sub getfftw
{
  my $pdl = shift;
  my $temp = shift;
  my $ignores = processignores(shift);

  my @spects = ();

  my $size = nelem($pdl);

  for my $i (0..$overlap*$size/$winsize-$overlap) #take $overlap sections off, since i'm not going to code a resizing window XD
  {
    if (!isignored($i, $ignores))
    {
      my $left = int $i*$winsize/$overlap;
      my $right = $left+$winsize-1;

      my $spect = getwindow($pdl->slice("${left}:$right"));
      my $y = $vqlop * $spect;

      if (!($i % 200))
      {
#        my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => sprintf($temp.'/fft%06d.png', $i));
#        $plot->xyplot($graphx, $y);
#        $plot->close();
        print "$left $i ".($overlap*$size/$winsize)."\n";
      }

      push @spects, $y->sum;

    #sleep 10;
#    print "${left}:$right\n";
    }
    else
    {
      push @spects, 0;
    }
  }

  return \@spects;
}

sub getwindow
{
  my $slice = shift;
 
  spectrum $slice, 1, $window;
}

1;
