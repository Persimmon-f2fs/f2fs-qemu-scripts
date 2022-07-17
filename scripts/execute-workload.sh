#!/usr/bin/env bash

function usage {
	echo "Usage: ./execute-workload.sh <output name> <test dir> <device>"
	exit 1
}

# check variables
[ -z "$1" ] && usage
[ -z "$2" ] && usage
[ -z "$3" ] && usage

sudo mkdir /share/output

output_name=/share/output/$1
test_dir=$2
device=$3

echo "==> Testing at $test_dir, with device $device, prefix $output_name"

declare -a pids
sudo perl /share/poll_blkzone.perl $device > ${output_name}_blkzone.txt &
pids[0]=$!
sudo perl /share/poll_meminfo.perl > ${output_name}_meminfo.txt &
pids[1]=$!

# run some stuff
sudo mkdir $test_dir

echo "==> Recording smart data!"
sudo smartctl -aj $device > ${output_name}_beforesmart

echo "==> Running benchmarks!"
# sudo filebench -f /share/workloads/fileserver.f > ${output_name}_benchmark
sudo fio --directory="$test_dir" /share/f2fs-qemu-scripts/fio/garbagecollect.fio

echo "==> Recording smart data!"
sudo smartctl -aj $device > ${output_name}_aftersmart

echo "==> Cleaning up perl scripts!"
# send interrupt signals
for pid in ${pids[*]}; do
	    sudo kill -s SIGINT $pid
done

echo "==> Done!"

