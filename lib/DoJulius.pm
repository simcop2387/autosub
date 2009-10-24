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
   open (my $pipe, "|-", "/usr/bin/julius", qw(-input file -outfile -C fast.jconf)) or die "PIPE: $!";
   print $pipe $filename;
   close $pipe;
   return $?;
}

sub runjulius
{
  system ('for i in tmp/sample*.wav; do echo $i| julius -C fast.jconf -outfile -input file -gprune none -tmix 4 -n 20 -confnet; done')
}

sub dovoices
{
   my $tmp = shift;
   my @codes = @_; #get the timecodes so that we can give back a proper structure

   my @newcodes;

   runjulius();

   for my $i (0..$#codes)
   {
	my $hr = readoutput($i, $codes[$i], $tmp);
	push @newcodes, $hr; #using temp variable so i can check for errors later
   }

   return @newcodes;
}

sub readoutput
{
  my $samplenum = shift;
  my $timecodes = shift;
  my $tmp = shift;

  my $ret = {};

  #i should probably also be checking the scores here but i'm not sure what they mean just yet :/

  open(my $samplefile, "<:encoding(euc-jp)", sprintf("%s/sample%05d.out", $tmp, $samplenum )) or warn "DECODE: $samplenum, $tmp, $!" and return undef;
  my @lines = <$samplefile>;

  chomp @lines;

  for (@lines)
  {
    my ($l, $r) = split /:/, $_, 2;
    $ret->{$l} = $r;
  }

  $ret->{start} = $timecodes->[0];
  $ret->{finish} = $timecodes->[1];

  print Dumper($ret);

  return $ret;
}

1;
