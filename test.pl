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

our $PP_VERBOSE=1;

#currently using tmp, will soon make it a random temp directory
my $tmp = "tmp552";
#commented out while working
#PrepareAudio::getaudio("/mnt/huge/torrents/Detective Conan - 551 [DCTP][98C947A7].avi", $tmp);
#PrepareAudio::getaudio("552raw.mp4", $tmp);
#PrepareAudio::prepareaudio($tmp);

my @ignore = ([1*60+16, 3*60+11], #ignore the opening music, 1:16-3:11
              [21*60+6, 22*60+26], [0, 76]);

my @voicemap;
my $audio = FFTW::open($tmp);
my $map0;
{
  my $sums = FFTW::getfftw($audio, $tmp, \@ignore); #ignore will set the fftw for the section to 0,0,0,0,...,0 so that it'll be silent

  Detect::autothresh($tmp, 0, $sums);
  $map0 = Detect::cleanup(Detect::cleanup(Detect::makemap($tmp, $sums, 1)));
}

print $map0,"\n";

my @codes = Detect::collect($map0);


ExportWav::makewavs($tmp, $audio, @codes);
#my @results = DoJulius::dovoices($tmp, @codes);

#print Dumper(\@results);
my $i = 0;
my @results = map {{finish=> $_->[1], start=>$_->[0], sentence1=>$i++, length=>($_->[1]-$_->[0])/16000.0}} @codes;

print Dumper(\@results);
MakeAss::writeass($tmp, "fake6.ass", @results);
