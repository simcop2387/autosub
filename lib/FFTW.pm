package FFTW;

use PDL;
use PDL::Audio;
use PDL::Graphics::PLplot;
use PDL::Transform;
use PDL::Ufunc;
use Data::Dumper;
use Clipcode;
use Detect;
use PrepareAudio;

use strict;
use warnings;

$|++;

our $winsize = 24576*2;
our $overlap = 16*2;
our $peaktol = 7.5;
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
my $zeroes = zeroes($winsize/2+1);

my $pi = 3.141592;
my $w = 2*$pi*$graphx/$winsize; #use graphx as the freq source for this
my $wc = $pi*32/40; #borrowed from the vocoder thingy
my $voicequant = butterworth($w, $wc, 10); #10th order butterworth

my $lowfreqdie = zeroes(63);
$lowfreqdie = $lowfreqdie->append(ones($winsize/2+1-63));

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
  return (($seconds * $PrepareAudio::samplerate) * $overlap / $winsize);
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
  my $pitches = pdl [];
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
	  my $hps = harmonicproductspectrum($y); #get the cepstrum of the signal... hope this works

      if (!($i % 200))
      {
		my ($avg, $std) = fftstats($y);
        my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => sprintf($temp.'/fft%06d.png', $i));
        $plot->xyplot($graphx, $y);
		$plot->xyplot($graphx, $zeroes+$avg, COLOR => "RED");
		$plot->xyplot($graphx, $zeroes+$avg+$std*$peaktol, COLOR => "BLUE");
        $plot->close();

		my $graphxc = sequence(500);
        
		$plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => sprintf($temp.'/cep%06d.png', $i));
        $plot->xyplot($graphxc, $hps->slice("0:499"));
#		$plot->xyplot($graphx, $zeroes+$avg, COLOR => "RED");
#		$plot->xyplot($graphx, $zeroes+$avg+$std*$peaktol, COLOR => "BLUE");
        $plot->close();

        print "$left $i ".($overlap*$size/$winsize)."\n";
      }

      #they use the sum of squares, with a threshold on 3000, gonna check on that
      $peaks = $peaks->append(peaks($y));
	  push @spects, sqrt($y->sum);
	  $pitches = $pitches->append(maximum_ind($hps));

    #sleep 10;
#    print "${left}:$right\n";
    }
    else
    {
      push @spects, 0;
	  $peaks=$peaks->append(0);
	  $pitches=$pitches->append(0);
    }
  }

  my $peakx = sequence($peaks->nelem());
  my $zeroes = zeroes($peaks->nelem);
  my ($smoothavg, $smoothstd) = fftstats($peaks->smoothlines);
  my ($roughavg,  $roughstd) = fftstats($peaks);
  
  $Detect::peakthresh = $smoothavg+$Detect::peakratio*$smoothstd; #for now!

  my $peakthres = $zeroes+$Detect::peakthresh;
  
  my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/peakcnt.png', PAGESIZE=>[16000,800], SUBPAGES=>[1,2]);

  $plot->xyplot($peakx, $peaks, SUBPAGE=>1, COLOR=> "BLACK", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $peakthres, SUBPAGE => 1, COLOR => "RED", XLAB => "raw peak counts", YLAB => "", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $zeroes+$roughavg, SUBPAGE => 1, COLOR => "GREEN", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $zeroes+$roughavg+$roughstd, SUBPAGE => 1, COLOR => "BLUE", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $zeroes+$roughavg-$roughstd, SUBPAGE => 1, COLOR => "BLUE", CHARSIZE=>0.125);

  $plot->xyplot($peakx, $peaks->smoothlines, SUBPAGE=>2, COLOR=>"BLACK", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $peakthres, SUBPAGE => 2, COLOR => "RED", XLAB => "smoothed peak counts", YLAB => "", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $zeroes+$smoothavg, SUBPAGE => 2, COLOR => "GREEN", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $zeroes+$smoothavg+$smoothstd, SUBPAGE => 2, COLOR => "BLUE", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $zeroes+$smoothavg-$smoothstd, SUBPAGE => 2, COLOR => "BLUE", CHARSIZE=>0.125);

  $plot->close();

  #3.0 seconds, rounded down to an int
  my $smoothness = int(3.0/(($winsize/$overlap)/$PrepareAudio::samplerate));
  my $movedavg = $pitches->movingaverage($smoothness);
  my $testalged = $movedavg->testalg(2)->abs()->movingaverage($smoothness/30); #half the time of smoothing
  $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/pitches.png', PAGESIZE=>[16000,800],);
  $plot->xyplot($peakx, $pitches->movingaverage($smoothness), COLOR=> "BLACK", CHARSIZE=>0.125);
  $plot->close();
  
  $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/movingdirv.png', PAGESIZE=>[16000,800],);
  $plot->xyplot($peakx, $testalged, COLOR=> "BLUE", CHARSIZE=>0.125);
  $plot->xyplot($peakx, $zeroes+$Detect::pitchthresh, COLOR=>"RED", CHARSIZE=>0.125);
  $plot->close();

  return (\@spects, $peaks->smoothlines, $testalged);
}

sub fftstats
{
	my $spectrum = shift;
	my ($avg, undef, undef, undef, undef, $std, undef) = $spectrum->statsover();
	return ($avg, $std);
}

sub peaks
{
	my $spectrum = shift;
	my $normalized = $spectrum/max($spectrum);
    my ($avg, undef, undef, undef, undef, $std, undef) = $normalized->statsover();

	my $count = $normalized->getoutliers($avg, $std, $peaktol);
#	print "$count $avg $std\n";
	return $count;
}

sub getwindow
{
  my $slice = shift;
 
  spectrum $slice, undef, $window;
}

#http://cnx.org/content/m11714/latest/
sub harmonicproductspectrum
{
	my $spectrum = shift;
	my $scale2 = $spectrum->downsample(2);
	my $scale3 = $spectrum->downsample(3);
	#normalize it, i hate such large values
	my $sz = $spectrum / max($spectrum);
	   $scale2 = $scale2 / max($scale2);
	   $scale3 = $scale3 / max($scale3);
	my $z = $sz * $scale2 * $scale3;
	$z / max($z);
}

1;
