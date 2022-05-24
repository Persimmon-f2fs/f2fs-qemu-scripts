#!/usr/bin/perl

use strict;
use warnings;

my @labels = qw/%usr %nice %sys %iowait %irq %soft %steal %guest %gnice %idle/;
my $labelCount = scalar @labels;
my @highestVals = map {0} 1..$labelCount;
my @avgVals = map {0} 1..$labelCount;
my $itr = 0;

$SIG{INT} = sub {
    for (my $i = 0; $i < $labelCount; ++$i) {
        printf("\r%s => max: %.2f, avg: %.2f\n",
            $labels[$i],
            $highestVals[$i],
            $avgVals[$i]);
    }
    exit;
};

while (1) {
    my $usage = `mpstat`;
    while($usage =~ /\d+:\d+:\d+(.*)/g) {
        my $line = $1;
        my $idx = 0;
        
        while ($line =~ /(\d+\.\d+)/g) {
            my $number = $1;
            
            # update max vals accordingly
            if ($highestVals[$idx] < $number) {
                $highestVals[$idx] = $number;
            }

            # process rolling average
            if ($itr == 0) {
                $avgVals[$idx] = $number;
            } else {
                $avgVals[$idx] = ($avgVals[$idx] * $itr + $number) / ($itr + 1)
            }
            ++$idx;
        }

        # increment to the next recording iteration.
        ++$itr;
    }
}

