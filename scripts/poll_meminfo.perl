#!/usr/bin/perl

use strict;
use warnings;

# variables for tracking data
my $largestSlab = 0;
my $avgSlab = 0;
my $iterations = 0;

# register signal handler
$SIG{INT} = sub {
    my $avgInt = int($avgSlab);
    print("{\"largestSlab\": $largestSlab, \"avgSlab\": $avgInt}\n");
    exit(0);
};

while(1) {
    my $meminfo = '/proc/meminfo';
    open (FH, '/proc/meminfo') or die("Could not open $meminfo");

    while (my $string = <FH>) {
        if ($string =~ /^Slab:\s+(\d+)/) {
            my $num = int($1);
            if ($num > $largestSlab) {
                $largestSlab = $num;
            }
            if ($iterations == 0) {
                $avgSlab = $num;
                ++$iterations;
            } else {
                $avgSlab = ($avgSlab * $iterations + $num) / ++$iterations;
            }
        }
    }

    close(FH);
}
