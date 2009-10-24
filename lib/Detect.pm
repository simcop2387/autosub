package Detect;

use strict;
use warnings;

use PDL;
use FFTW;

our $threshold = 35;

sub makemap
{
  my $temp = shift;
  my @spects = @_;
  my $i = 0;
  my @voices = map {Detect::hasvoice($_, $i++)} @spects;

  my $linethresh = zeroes(scalar @spects) + $threshold;
  my $graphx = sequence(scalar @spects);

  my @sums = map {$_->[1]} @voices;  
  my $pdlsum = pdl [];

  $pdlsum = $pdlsum->append(pdl([$_])) for @sums;  

  my $map = join "", map {$_->[0]} @voices;

  my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/spectrum.png', PAGESIZE=>[1600,1000]);
  $plot->xyplot($graphx, $pdlsum, COLOR => "BLUE");
  $plot->xyplot($graphx, $linethresh, COLOR => "RED");
  $plot->close();

  return $map;
}

sub autothresh
{
  my $temp = shift;
  my @spects = @_;
  my @voices = map {Detect::hasvoice($_, $i++)->[1]} @spects; #i only want the sums
  
  my $sums = pdl [];
  $sums = $sums->append(pdl [$_]) for @voices;

  $sums = $sums->qsort(); #quick sort it

  my $left = 0;
  my $right = $sums->nelem();
  my $blobs = 0; #or $sums->nelem? dunno yet
  my $finalthresh = 0;
  my $target = 350;

  while (1)
  {
     my $i = 0;
     my $newthresh = $sums->index(int(($left + $right)/2)); #get the middle sum
     my $map = cleanup(cleanup(makemap($temp, @spects))); #make a map
     
     $blobs = scalar collect($map);

     if ($left == $right)
     {
       $finalthresh = $newthresh;
       last;
     }     

     print "Current threshold $newthresh with $blobs blobs\n";

     if ($blobs < $target)
     {
       $right = int(($left + $right)/2); #move right to current position
     }
     elsif ($blobs > $target)
     {
       $left = int(($left + $right)/2); #move the left to current position
     }
     else
     {
       print "Found Exactly 350 blobs!\n";
       $finalthresh = $newthresh;
       last;
     }
  }
  
  print "Autothreshold found a threshold of $finalthresh with $blobs blobs\n";
  $threshold = $finalthresh;
}

sub hasvoice {
    my $sample = shift;
    my $index  = shift;    #solely for printing out time indexes to check!

    my $sum = $sample->sum;

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
