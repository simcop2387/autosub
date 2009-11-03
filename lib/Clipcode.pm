#!/usr/bin/perl
package Clipcode;
use strict;
use warnings;

use PDL;
use Inline qw(Pdlpp);
1;
__DATA__
__Pdlpp__

pp_def('myclip', 
	Pars => 'a(i); c(); [o]b(i)',
	Code => 'loop(i) %{ int s=0;
			if ($a() > $c() || $a() < $c()) 
			{
				if ($a() > 0)
				  s = 1;
				else
				  s = -1;
				$b() = $a() - s * $c();
			} 
			else
			  $b() = $a();
			  %}'
);

pp_def('getouliers',
	Pars => 'a(i); adev(); avg(); t(); []count()',
	Code => 'int q = 0;
		loop(i) %{ double d = ($a() - $avg()) / $adev();
	//reality says i should use the abosolute value here, to tell how many std devs away, but i want the sign, don't count those that are in the other direction
	if (d >= $t())
	{
		q++; //add the count
	}
	%};
	$count() = q;'
);
