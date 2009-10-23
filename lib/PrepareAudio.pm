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

1;
