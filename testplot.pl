#!/usr/bin/perl
  use PDL;
  use PDL::Graphics::PLplot;

  my $pl = PDL::Graphics::PLplot->new (DEV => "png", FILE => "test.png");
  my $x  = sequence(256);
  my $y  = $x**2;
  $pl->xyplot($x, $y);
  $pl->close;
