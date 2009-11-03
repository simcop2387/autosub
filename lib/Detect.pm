package Detect;

use strict;
use warnings;
use diagnostics;

use PDL;
use FFTW;

use Data::Dumper;

use List::MoreUtils "uniq";

our $threshold = 40.3661824968879;
our $target = 200;
our $peakthresh = 135;

sub makemap
{
  my $temp = shift;
  my $sums = shift;
  my $graphit = shift;
  my $i = 0;
  my @voices = map {Detect::hasvoice($_, $i++)} @$sums;

#  my @sums = map {$_->[1]} @voices;  
#  my $pdlsum = pdl [];

#  $pdlsum = $pdlsum->append(pdl([$_])) for @sums;  

  my $map = join "", @voices;

  if ($graphit)
  {
  my $linethresh = zeroes(scalar @$sums) + $threshold;
  my $graphx = sequence(scalar @$sums);

  my $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/profile.png', PAGESIZE=>[1600,1000]);
  my $pdlsum = pdl $sums;
  $plot->xyplot($graphx, $pdlsum, COLOR => "BLUE");
  $plot->xyplot($graphx, $linethresh, COLOR => "RED");
  $plot->close();
  }

  return $map;
}

sub autothresh
{
  my $temp = shift;
  my $time = 100 - shift;
  my $i = 0;
  my $sums_ = shift; #@spects
#  my @voices = map {Detect::hasvoice($_, $i++)->[1]} @spects; #i only want the sums
  
  my $sums = pdl [uniq(grep {$_ != 0} @$sums_)];

  $sums = $sums->qsort(); #quick sort it

  my $index = 0;
  my @candidates;

  my $tarlog = log($target);

  while ($index < $sums->nelem())
  {
     $threshold = $sums->index($index);
     my $map = cleanup(cleanup(makemap($temp, $sums_))); #make a map
     
     my @results = collect($map);
     my $blobs = @results;

     my $lengths = pdl [map {$_->[2]} @results];

     #print Dumper([map {$_->[2]} @results]);
#     print "$lengths\n";
     
#($mean,$prms,$median,$min,$max,$adev,$rms)
     my $avg = 0;
     my $std = 0;

     if ($lengths->nelem() > 0)
     {
     ($avg, undef, undef, undef, undef, $std, undef) = $lengths->statsover(ones($lengths->nelem()));
     }

     $avg =int($avg*10)/10;
     my $blog = log($blobs+1)/$tarlog;
     my $hugh = (($blog)**2 + $avg) / ($std+1);
     if ($blobs == 1 || $std == 0) #remove stupid outliers
     {$hugh = pdl [0];
      $avg = 0;#remove them from the graphs
      $std = 0;
     }
     $hugh = $hugh->sum();
     print "threshold $threshold blobs $blobs blogs $blog, avglen $avg, adev $std, hugh == $hugh\n";
     push @candidates, [$blobs, $threshold, $avg, $std, $blog, $hugh];

     $index+=$time; #this ought to be configureable
     #last if ($blobs >= $target); #was faster but i'm not liking the results
  }
  
  my $x = pdl [map {$_->[1]} @candidates];
  my $yblobs = pdl [map {$_->[0]} @candidates];
  my $yhughs = pdl [map {$_->[5]} @candidates];
  my $yavgs  = pdl [map {$_->[2]} @candidates];
  my $ystds  = pdl [map {$_->[3]} @candidates];

  my  $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/autothresh.png', PAGESIZE=>[3200,2000]);
  $plot->xyplot($x, $yblobs, COLOR => "BLUE", XLAB => "threshold", YLAB => "blobs", CHARSIZE=>0.25);
  $plot->close();

  $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/hughs.png', PAGESIZE=>[3200,2000]);
  $plot->xyplot($x, $yhughs, COLOR => "RED", XLAB => "threshold", YLAB => "hugh values", CHARSIZE=>0.25);
  $plot->close();

  $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/avgs.png', PAGESIZE=>[1600,1000]);
  $plot->xyplot($x, $yavgs, COLOR => "GREEN", XLAB => "threshold", YLAB => "average length of speech", CHARSIZE=>0.25);
  $plot->close();

  $plot = PDL::Graphics::PLplot->new(DEV => 'png', FILE => $temp.'/stds.png', PAGESIZE=>[1600,1000]);
  $plot->xyplot($x, $ystds, COLOR => "YELLOW", XLAB => "threshold", YLAB => "std dev of length of speech", CHARSIZE=>0.25);
  $plot->close();

  my @sorted = sort {($b->[5]) <=> ($a->[5])} @candidates;

  print Dumper(\@sorted);

  $threshold = $sorted[0][1];
  my $blobs = $sorted[0][0];

  print "Autothreshold found a threshold of $threshold with $blobs blobs\n";
}

sub hasvoice {
    my $sample = shift;
    my $index  = shift;    #solely for printing out time indexes to check!

    #my $sum = $sample; # ->sum; #optimizing it for this since i'm doing it repeatedly

    #my $left = int $i*$winsize/$overlap;
#    my $time =
#      ( $index * $FFTW::winsize / $FFTW::overlap ) /
#      16000;               #(index * ) / samples per second

#    print $time, " :: ", $sum, " :: ", $sum > 3 ? 1 : 0, "\n";

    return 1 if $sample > $threshold;
    return 0;
}

sub cleanup {
    my $map = shift;       #make it easier to run more than once

    $_ = $map;

    s/1101/1111/g;         #cleanup places where it missed?
    s/1011/1111/g;

     s/100111/111111/g;
     s/111001/111111/g;
 #   s/001100/000000/g;     #clean up 0.10 seconds in the middle of nothing
     s/110011/111111/g;
#    s/000111000/000000000/g;
     s/111000111/111111111/g;
#    s/00100/00000/g;       #clean up 1's in the middle of nothing

    #specific case in output
    s/000101000/000000000/g;

    #i should genericise this one, not sure a good way how yet
    s/000000111000000/000000000000000/g;
    s/111111000111111/111111111111111/g;

#these will get implemented when selecting ranges, it seems to corrupt things too easily when used like this
 s/000111/001111/g; #grow it a little without causing it to join
 s/111000/111100/g;
 # s/0111/1111/g; #pick up a little before
 # s/1110/1111/g; #a little after!

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
            $finish     = $i+2;                            #gets it +3
            $collecting = 0;
            push @codes, [ $start, $finish ];
            next;
        }

        if ( $sample == 1 && $collecting == 0 ) {
            $start      = $i;    #get 6 before this sample
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
    my $length = (fullsamples($code->[1]) - fullsamples($code->[0]))/16000;
    push @trimmed, [(map {fullsamples($_)} @$code), $length] if ($length >= 1.0); #get ones that 1 or more seconds!
  }

  return @trimmed;
}

sub fullsamples
{
    my $index = shift;
    my $time = int( $index * $FFTW::winsize / $FFTW::overlap );
    $time;
}

sub checkpeaks
{
	my $tmp = shift;
	my $peaks = shift;

	my $t = $peaks->nelem();
    my $map = ""; #start empty

	for (0..$t-1)
	{
		if ($peaks->index($_) > $peakthresh)
		{
			$map .= "1";
		}
		else
		{
			$map .= "0";
		}
	}

	return $map;
}

1;
