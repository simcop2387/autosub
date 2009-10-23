package PrepareAudio;

use strict;
use warnings;

sub getaudio
{
  my $input = shift;
  my $tempdir = shift;
  my $temp = $tempdir."/audiodump.wav";

  system("/usr/bin/mplayer", "-ao", "pcm:fast:file=$temp", qw(-vo null -vc null), $input) == 0
	or die "Couldn't extract audio, $?";
  return $temp;
}

sub prepareaudio
{
  my $tempdir = shift;
  my $newfile = $tempdir."/resampled.wav";

  system("/usr/bin/sox", qw(-S), "$tempdir/audiodump.wav", qw(-t wav -s -b 16 -r 48000 -c 1), $newfile) == 0
	or die "Couldn't resample audio, $?";
  return $newfile;
}

1;
