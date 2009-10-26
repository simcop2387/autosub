#!/usr/bin/perl

use PDL;
use PDL::Graphics::PLplot;
use PDL::Audio;

my $winsize=8192;

my $voicequant = gen_fft_window 4096, "GAUSSIAN", 5.5;

$voicequant = concat($voicequant, zeroes($winsize/2+1 - 4096));

my $graphx = sequence($winsize/2+1);

    my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE =>'test.png');
    $plot->xyplot($graphx, $voicequant);
    $plot->close();

