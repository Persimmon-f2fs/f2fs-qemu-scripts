#!/usr/bin/bash


rm mem-f2fs.csv
rm mem-us.csv
echo "memory,static,cached,paged" >> mem-f2fs.csv
echo "memory,static,cached,paged" >> mem-us.csv
while true
do
    cat /sys/kernel/debug/f2fs/status | tail -4 | awk -F ' ' {'print $(NF-1)'} | tr '\n' ',' >> mem-f2fs.csv
    echo "\n" >> mem-f2fs.csv
    cat /sys/kernel/debug/f2fs_mod/status | tail -4 | awk -F ' ' {'print $(NF-1)'} | tr '\n' ',' >> mem-us.csv
    echo "\n" >> mem-us.csv
    sleep 15
done
