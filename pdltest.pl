#!/usr/bin/perl

use PDL;

my $a = pdl [1,2,3,4];
my $b = pdl [0,0,0,0];
my $c = pdl [$a, $b];

print $c;
