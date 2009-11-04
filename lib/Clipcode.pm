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

	double thresh = $adev() * $t();
	char above = 0;

	loop(i) %{ 
		double d = $a()-thresh;
		if ((d < 0) && (above == 1))
		{
		   q++;
		   above=0;
		};
		
		if ((d > 0) && (above == 0))
		{
		   above=1;
		};
	%}
	$count() = q;'
);

pp_def('downsample',
	Pars => 'a(i); t(); [o]b(n)',
    GenericTypes => [D],
	Code => 'double t=$t();
	double tmp;
	int limit = $SIZE(n)/$t();
	register int j;
	register int k = $t();
	double *bp = $P(b);
	double *ap = $P(a);

	for (j = 0; j < limit; j++)
	{
		bp[j] = 0.0;
		for (k = 0; k < $t(); k++)
		{
			bp[j] += ap[j+k];
		}
	}
	for (j = limit; j < $SIZE(n); j++)
	{
		bp[j] = 0.0;
	}
');



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
