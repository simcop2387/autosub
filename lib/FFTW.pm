package FFTW;

use PDL;
use PDL::Audio;
use PDL::Graphics::PLplot;
use Data::Dumper;
use Clipcode;
use Detect;

use strict;
use warnings;

$|++;

our $winsize = 8192;
our $overlap = 10;
#they recommended hamming, gonna try it and their butterworth!
my $window = gen_fft_window $winsize, "HAMMING";#, 2.5;

sub butterworth
{
  my $w = shift;
  my $wc = shift;
  my $o = shift;

#1/(1 + (w/w0)^(2*o))
  return 1/(1+ ($w/$wc)**(2*$o));
#(($ssq + 0.3902 * $s + 1)*($ssq  + 1.1111 * $s + 1)*($ssq + 1.6629 * $s + 1)*($ssq  + 1.9616 * $s + 1))
}

my $graphx = sequence($winsize/2+1);

my $pi = 3.141592;
my $w = 2*$pi*$graphx/$winsize; #use graphx as the freq source for this
my $wc = $pi*9/40; #borrowed from the vocoder thingy
my $voicequant = butterworth($w, $wc, 10); #10th order butterworth

#my $voicequant = gen_fft_window 4096, "GAUSSIAN", 2.0;

#$voicequant = $voicequant->append(zeroes($winsize/2+1 - $voicequant->nelem));

my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE =>'test.png');
$plot->xyplot($graphx, $voicequant);
$plot->close();

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

sub sign
{
  $_[0] > 0? 1 : -1;
}

sub getfftw
{
  my $pdl = shift;
  my $temp = shift;
  my $ignores = processignores(shift);

  my @spects = ();
  my $peaks = pdl [];

  my $size = nelem($pdl);

  for my $i (0..$overlap*$size/$winsize-$overlap) #take $overlap sections off, since i'm not going to code a resizing window XD
  {
    if (!isignored($i, $ignores))
    {
      my $left = int $i*$winsize/$overlap;
      my $right = $left+$winsize-1;

      my $spect = getwindow($pdl->slice("${left}:$right"));
      my $y = $voicequant * $spect;
#      $y = irfft $y;#OMG!

      if (!($i % 200))
      {
        my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => sprintf($temp.'/fft%06d.png', $i));
        $plot->xyplot($graphx, $y);
        $plot->close();
        print "$left $i ".($overlap*$size/$winsize)."\n";
      }

      #they use the sum of squares, with a threshold on 3000, gonna check on that
      $peaks = $peaks->append(peaks($y));
	  push @spects, $y->sum;

    #sleep 10;
#    print "${left}:$right\n";
    }
    else
    {
      push @spects, 0;
	  $peaks=$peaks->append(0);
    }
  }

  my $peakx = sequence($peaks->nelem());
  my $peakthres = zeroes($peaks->nelem)+$Detect::peakthresh;
  my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/peakcnt.png', PAGESIZE=>[16000,800], SUBPAGES=>[1,2]);
  $plot->xyplot($peakx, $peaks, SUBPAGE=>1, CHARSIZE=>0.125);
  $plot->xyplot($peakx, $peaks->smoothlines, SUBPAGE=>2, CHARSIZE=>0.125);
  $plot->xyplot($peakx, $peakthres, SUBPAGE => 1, COLOR => "RED", XLAB => "raw peak counts", YLAB => "", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $peakthres, SUBPAGE => 2, COLOR => "RED", XLAB => "smoothed peak counts", YLAB => "", CHARSIZE=>0.125);
  $plot->close();

  return (\@spects, $peaks);
}

sub peaks
{
	my $spectrum = shift;
	my $normalized = $spectrum/max($spectrum);
    my ($avg, undef, undef, undef, undef, $std, undef) = $normalized->statsover();

	my $count = $normalized->getoutliers($avg, $std, 5.0);
#	print "$count $avg $std\n";
	return $count;
}

sub getwindow
{
  my $slice = shift;
 
  spectrum $slice, undef, $window;
}

1;
