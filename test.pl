#!/usr/bin/perl

use strict;
use warnings;

use lib './lib';

use PDL;
use PDL::Audio;
use File::Temp;

use Extract;

Extract::getaudio("/mnt/huge/torrents/Detective Conan - 551 [DCTP][98C947A7].avi", "tmp");
