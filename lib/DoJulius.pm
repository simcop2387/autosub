package DoJulius;

use strict;
use warnings;

use Data::Dumper;
use Encode;
use utf8;

sub runsample
{
   my $samplenum = shift;
   my $tmp = shift;

   my $filename = sprintf "%s/sample%05d.wav", $tmp, $samplenum;
   
   #i'd love to use the same copy of julius over and over, but my experiments have shown that it sometimes doesn't like that :/
   open (my $pipe, "|-", "/usr/bin/julius", qw(-48 -outfile -input file -C fast.jconf)) or die "PIPE: $!";
   print $pipe $filename;
   close $pipe;
   return $?;
}

sub dovoices
{
   my $tmp = shift;
   my @codes = @_; #get the timecodes so that we can give back a proper structure

   my @newcodes;

   for my $i (0..$#codes)
   {
	my $ret = runsample($i, $tmp);
	unless ($ret)
	{
		my $hr = readoutput($i, $codes[$i], $tmp);
		push @newcodes, $hr; #using temp variable so i can check for errors later
	}
   }
}

sub readoutput
{
  my $samplenum = shift;
  my $timecodes = shift;
  my $tmp = shift;

  open(my $samplefile, "<:encoding(shiftjis)", sprintf()) or die;
}
