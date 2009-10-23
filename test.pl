#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use PDL;
use PDL::Audio;
use File::Temp;
use Data::Dumper;

use PrepareAudio; #should probably get this to export things, look nicer in here
use FFTW;

#currently using tmp, will soon make it a random temp directory

#commented out while working
PrepareAudio::getaudio("/mnt/huge/torrents/Detective Conan - 551 [DCTP][98C947A7].avi", "tmp");
PrepareAudio::prepareaudio("tmp");

my $audio = FFTW::open("tmp");
my @spects = FFTW::getfftw($audio, "tmp");


