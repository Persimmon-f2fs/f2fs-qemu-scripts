#!/usr/bin/bash

function usage() {
    echo "fill_fs.sh <mnt point> <size in GB> <number of iterations>"
    exit 1
}

[ -z "$1" ] && usage    
[ -z "$2" ] && usage    
[ -z "$3" ] && usage    

mnt_pnt=$1
size=$2
itr=$3

# repeat this process a few times to ensure gc is initiated
for ((i=0;i<$itr;i++)); do
    # clear files
    rm -rf $mnt_pnt/*
    declare -a pids

    # write $size number of individual GB
    for ((j=0;j<$size;j++)); do
        dd if=/dev/random of=$mnt_pnt/file$j.txt bs=1MB count=1024 1>/dev/null &
        pids[$j]=$! 
    done

    # wait on all pids
    for pid in ${pids[*]}; do
        wait $pid
    done
    
    # indicate we've done a single run
    echo "Itr: $i, Wrote $size GB."
done

echo "Done writing."

