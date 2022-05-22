#!/usr/bin/perl

# use strict;
use warnings;

my ($device) = @ARGV;

if (! defined $device) {
    print("poll_blkzone.perl <device>\n");
    exit 1;
}

# set for tracking empty / not empty
# 1 for not empty, 0 for empty
my %not_reset_set;
my $zone_resets = 0;

# define signal handler
$SIG{INT} = sub { 
    print("==> Tracked: $zone_resets zone resets\n");
    exit 0
};

print("Polling for zone events\n");

# loop until interrupted
while (1) {
    # get zone information from blkzone
    my $output = `sudo blkzone report $device`;

    # parse each wp state for the zone
    while ($output =~ /start: (\w+).*zcond: \d\((\w+)\)/g) {
        if (defined $not_reset_set{$1}) {
            # previous state was defined
            if ($2 eq "em" && $not_reset_set{$1} ne "em") {
                # zone was reset, increment
                $zone_resets++;
                print("Zone was reset!\n");
            }
        }

        # track the zone state
        $not_reset_set{$1} = $2;
    }
}

