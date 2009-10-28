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
