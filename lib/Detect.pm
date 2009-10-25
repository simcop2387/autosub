package Detect;

use strict;
use warnings;

use PDL;
use FFTW;

use Data::Dumper;

our $threshold = 40.3661824968879;

sub makemap
{
  my $temp = shift;
  my @sums = @_;
  my $i = 0;
  my @voices = map {Detect::hasvoice($_, $i++)} @sums;

#  my $linethresh = zeroes(scalar @spects) + $threshold;
#  my $graphx = sequence(scalar @spects);

#  my @sums = map {$_->[1]} @voices;  
#  my $pdlsum = pdl [];

#  $pdlsum = $pdlsum->append(pdl([$_])) for @sums;  

  my $map = join "", map {$_->[0]} @voices;

#  my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/spectrum.png', PAGESIZE=>[1600,1000]);
#  $plot->xyplot($graphx, $pdlsum, COLOR => "BLUE");
#  $plot->xyplot($graphx, $linethresh, COLOR => "RED");
#  $plot->close();

  return $map;
}

sub autothresh
{
  my $temp = shift;
  my $time = 100 - shift;
  my @spects = @_;
  my $i = 0;
  my @sums = map {$_->sum} @spects;
#  my @voices = map {Detect::hasvoice($_, $i++)->[1]} @spects; #i only want the sums
  
  my $sums = pdl [@sums];

  $sums = $sums->qsort(); #quick sort it

  my $index = 0;
  my $target = 350;
  my @candidates;

  while ($index < $sums->nelem())
  {
     $threshold = $sums->index($index);
     my $map = cleanup(cleanup(makemap($temp, @sums))); #make a map
     
     my $blobs = scalar collect($map);

     print "Current threshold $threshold with $blobs blobs\n";
     push @candidates, [$blobs, $threshold];

     $index+=$time; #this ought to be configureable
  }
  
  my @sorted = sort {($a->[0] - $target) ** 2 <=> ($b->[0] - $target)**2} @candidates;

  $threshold = $sorted[0][1];
  my $blobs = $sorted[0][0];

  my $x = pdl [];
  my $y = pdl [];

  for (@candidates)
  {
    $x = $x->append(pdl [$_->[1]]);
    $y = $y->append(pdl [$_->[0]]);
  }

  my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/thresholds.png', PAGESIZE=>[1600,1000]);
  $plot->xyplot($x, $y, COLOR => "BLUE");
  $plot->close();
  
  print "Autothreshold found a threshold of $threshold with $blobs blobs\n";
  return @sums;
}

sub hasvoice {
    my $sample = shift;
    my $index  = shift;    #solely for printing out time indexes to check!

    my $sum = $sample; # ->sum; #optimizing it for this since i'm doing it repeatedly

    #my $left = int $i*$winsize/$overlap;
    my $time =
      ( $index * $FFTW::winsize / $FFTW::overlap ) /
      16000;               #(index * ) / samples per second

#    print $time, " :: ", $sum, " :: ", $sum > 3 ? 1 : 0, "\n";

    return [1, $sum] if $sum > $threshold;
    return [0, $sum];
}

sub cleanup {
    my $map = shift;       #make it easier to run more than once

    $_ = $map;

    s/1101/1111/g;         #cleanup places where it missed?
    s/1011/1111/g;

    s/100111/111111/g;
    s/111001/111111/g;
    s/001100/000000/g;     #clean up 0.10 seconds in the middle of nothing
    s/110011/111111/g;
    s/000111000/000000000/g;
    s/111000111/111111111/g;
    s/00100/00000/g;       #clean up 1's in the middle of nothing

    #specific case in output
    s/000101000/000000000/g;

    #i should genericise this one, not sure a good way how yet
    s/000000111000000/000000000000000/g;
    s/111111000111111/111111111111111/g;

#these will get implemented when selecting ranges, it seems to corrupt things too easily when used like this
  s/0111/1111/g; #pick up a little before
  s/1110/1111/g; #a little after!

    return $_;
}

sub collect {
    my $map = shift;
    my @codes;

    my @samples = split//,$map;

    #i'm gonna use map2 here, to get a good list
    my $i = -1;    #start at -1 for this
    my $start      = 0;
    my $finish     = 0;
    my $collecting = 1;
    for my $sample ( @samples) {
        $i++;
#        my $nextsample = $samples[$i+1] || "0";
#        my $nextsample2 = $samples[$i+2] || "0";
        next if ( $sample == 1 && $collecting == 1 );    #don't do anything

#	 if ( $sample == 0 && $collecting == 1 && $nextsample == 1 && $nextsample2 == 1) {
#            $finish     = $i+5;                            #gets it +6
#            $collecting = 0;
#            push @codes, [ $start, $finish ];
#            next;
#        }

        if ( $sample == 0 && $collecting == 1 ) {
            $finish     = $i+5;                            #gets it +6
            $collecting = 0;
            push @codes, [ $start, $finish ];
            next;
        }

        if ( $sample == 1 && $collecting == 0 ) {
            $start      = $i - 6;    #get 6 before this sample
            $collecting = 1;
            next;
        }
    }

    if ( $collecting == 1 ) {
        push @codes, [ $start, $i ];
    };                                #collect the last end of it

    return trimcodes(@codes);
}

sub trimcodes
{
  my @codes = @_;
  my @trimmed;

  for my $code (@codes)
  {
    my $length = $code->[1] - $code->[0];
    push @trimmed, [map {fullsamples($_)} @$code] if ($length >= 20); #get ones that 1 or more seconds!
  }

  return @trimmed;
}

sub fullsamples
{
    my $index = shift;
    my $time = int( $index * $FFTW::winsize / $FFTW::overlap );
    $time;
}

1;
