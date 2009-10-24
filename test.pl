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
use Detect;
use ExportWav;
use DoJulius;
use MakeAss;

#currently using tmp, will soon make it a random temp directory

#commented out while working
#PrepareAudio::getaudio("/mnt/huge/torrents/Detective Conan - 551 [DCTP][98C947A7].avi", "tmp");
#PrepareAudio::prepareaudio("tmp");

my @voicemap;
my $audio = FFTW::open("tmp");
my $map0;
{
  my @spects = FFTW::getfftw($audio, "tmp");

  Detect::autothresh("tmp", @spects);
  die;
  $map0 = Detect::makemap("tmp", @spects);
}
my $map1 = Detect::cleanup($map0);
my $map2 = Detect::cleanup($map1);

print $map2,"\n";
sleep 10;

my @codes = Detect::collect($map2);

ExportWav::makewavs("tmp", $audio, @codes);
my @results = DoJulius::dovoices("tmp", @codes);

print Dumper(\@results);

MakeAss::writeass("tmp", @results);
