#!/usr/bin/bash

count=10
for i in $(seq $count); do
    ./f2fs-qemu-scripts/scripts/test-mount-time.sh |& awk {'print $(NF-8), $(NF-1)'} >> times.txt
    sleep 2
done
