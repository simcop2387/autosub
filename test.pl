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

#currently using tmp, will soon make it a random temp directory

#commented out while working
#PrepareAudio::getaudio("/mnt/huge/torrents/Detective Conan - 551 [DCTP][98C947A7].avi", "tmp");
#PrepareAudio::prepareaudio("tmp");

my $audio = FFTW::open("tmp");
my @spects = FFTW::getfftw($audio, "tmp");
my $i = 0;

my @voicemap = map {Detect::hasvoice($_, $i++)} @spects;
my $map0 = join "", @voicemap;
my $map1 = Detect::cleanup($map0);
my $map2 = Detect::cleanup($map1);

print $map2,"\n";

my @codes;

#i'm gonna use map2 here, to get a good list
$i=-1; #start at -1 for this
my $start=0;
my $finish=0;
my $collecting=1;
for my $sample (split//,$map2)
{
 $i++;
 next if ($sample == 1 && $collecting == 1); #don't do anything
 
 if ($sample == 0 && $collecting == 1)
 {
  $finish = $i; #gets it +1
  $collecting = 0;
  push @codes, [$start, $finish];
  next;
 }
 
 if ($sample == 1 && $collecting == 0)
 {
   $start = $i-1; #get 1 before this sample
   $collecting = 1;
   next;
 }
}

if ($collecting == 1)
{
  push @codes, [$start, $i];
}; #collect the last end of it


print Dumper(\@codes);
