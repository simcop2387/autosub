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


#e is a small value to avoid divide by zero
pp_def('getoutliers',
	Pars => 'a(i); adev(); avg(); t(); [o]count()',
    GenericTypes => [D],
	Code => 'int q = 0;
	double e = 0.0005;
	if ($adev() > e)
	{
		loop(i) %{ 
		double d = ($a() - $avg()) / ($adev()+e);
		if (d >= $t())
		{
			q++;
		}
		%}
	};
	$count() = q;'
);

pp_def('smoothlines',
	Pars => 'a(i); [o]b(i)',
	Code => 'double d1=0,d2=0,d3=0,d4=0,d5=0;
		double t;
	loop(i) %{
		switch(i % 5)
		{
			case 0:
				d1 = $a();
				break;
			case 1:
				d2 = $a();
				break;
			case 2:
				d3 = $a();
				break;
			case 3:
				d4 = $a();
				break;
			case 4:
				d5 = $a();
				break;
		}

		t = (d1 + d2 + d3 + d4 + d5)/5;
		$b() = t;
	%};'
);
