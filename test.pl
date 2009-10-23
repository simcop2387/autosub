#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use PDL;
use PDL::Audio;
use File::Temp;

use PrepareAudio; #should probably get this to export things, look nicer in here
use FFTW;

#commented out while working
#PrepareAudio::getaudio("/mnt/huge/torrents/Detective Conan - 551 [DCTP][98C947A7].avi", "tmp");
#PrepareAudio::prepareaudio("tmp");

FFTW::open("tmp");
