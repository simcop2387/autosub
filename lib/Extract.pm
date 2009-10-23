package Extract;

use strict;
use warnings;

sub getaudio
{
  my $input = shift;
  my $tempdir = shift;
  my $temp = $tempdir."/audiodump.wav";

  system("/usr/bin/mplayer", qw(-ao pcm:fast:file=$temp -vo null -vc null $input)) 
	or die "Couldn't extract audio";
  return $temp;
}
