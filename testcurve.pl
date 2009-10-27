#!/usr/bin/perl

use PDL;
use PDL::Graphics::PLplot;
use PDL::Audio;

my $winsize=8192;

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
  print $logi, "\n";
  $vqlop = $vqlop->append($voicequant->index($logi));
}

$vqlop = $vqlop->append(zeroes($winsize/2+1 - $vqlop->nelem));
$vqlop = $vqlop + $voicequant/1.1;

    my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE =>'test2.png');
    $plot->xyplot($graphx, $vqlop);
    $plot->close();
