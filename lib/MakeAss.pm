package MakeAss;

use strict;
use warnings;

use Data::Dumper;
use POSIX qw(strftime);
use PrepareAudio;

use Time::HiRes; #to get better precision localtime?

use Encode; #help avoid wide print errors
use utf8;

sub writedialog
{
  my $fh = shift;
  my $code = shift;

#;Dialogue: 0,0:00:19.40,0:00:21.14,Default,,0000,0000,0000,,A courageous heart and deduction power!
  my ($startsec, $endsec) = ($code->{start}/$PrepareAudio::samplerate, $code->{finish}/$PrepareAudio::samplerate);

  my $startfrac = sprintf "%0.2f", int(($startsec-int($startsec))*100)/100; 
  my $endfrac   = sprintf "%0.2f", int(($endsec-  int($endsec))  *100)/100; 

  $startfrac =~ s/^0*//;
  $endfrac =~ s/^0*//;

  my $starttime = strftime("%H:%M:%S", gmtime($startsec)).$startfrac;
  my $endtime   = strftime("%H:%M:%S", gmtime($endsec)).$endfrac;

  if (defined($code->{sentence1}) && $code->{sentence1} !~ /^\s*。\s*$/)
  {
    print $fh "Dialogue: 0,$starttime,$endtime,Default,,0000,0000,0000,,",$code->{sentence1},"\n";
  }
}

sub writeass
{
  my $tmp = shift;
  my $file = shift;
  my @codes = @_;

  open(my $fh, ">:encoding(utf8)", sprintf("%s/%s", $tmp, $file)) or die "ExportAss: $!";
  print $fh <DATA>; #print out the header

  for my $code (@codes)
  {
    writedialog($fh, $code) if defined($code);
  }
  close $fh;
}

1;

__DATA__
﻿[Script Info]
; Script generated by Autosub 0.0.1 alpha
Title: Default Autosub File
ScriptType: v4.00+
WrapStyle: 0
;i should get these correctly, oh well
PlayResX: 640
PlayResY: 480
ScaledBorderAndShadow: yes
Video Aspect Ratio: 0
Video Zoom: 8
Video Position: 4882
;Audio File: audiodump.wav
;Video File: DC215.avi

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,28,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,2,2,2,10,10,10,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
;Dialogue: 0,0:00:19.40,0:00:21.14,Default,,0000,0000,0000,,A courageous heart and deduction power!
