#!/usr/bin/env bash

function usage {
	echo "Usage: ./execute-workload.sh <output name> <test dir> <device> <fio options>"
	exit 1
}

# check variables
[ -z "$1" ] && usage
[ -z "$2" ] && usage
[ -z "$3" ] && usage
[ -z "$4" ] && usage

sudo mkdir /share/output

output_name=/share/output/$1
test_dir=$2
device=$3
fio_options=$4

blkzone_output=/tmp/${output_name}_blkzone.txt
meminfo_output=/tmp/${output_name}_meminfo.txt
beforesmart_output=/tmp/${output_name}_beforesmart.json
aftersmart_output=/tmp/${output_name}_aftersmart.json

# remove tmp files (potentially from previous run)
sudo rm $blkzone_output $meminfo_output $beforesmart_output $aftersmart_output

declare -a pids
sudo perl /share/poll_blkzone.perl $device > $blkzone_output &
pids[0]=$!
sudo perl /share/poll_meminfo.perl > $meminfo_output &
pids[1]=$!

# run some stuff
sudo mkdir $test_dir

sudo smartctl -aj $device > $beforesmart_output

# sudo filebench -f /share/workloads/fileserver.f > ${output_name}_benchmark
sudo fio --directory="$test_dir" $fio_options /share/f2fs-qemu-scripts/fio/garbagecollect.fio 1> /dev/null 2>&1

sudo smartctl -aj $device > $aftersmart_output

# send interrupt signals
for pid in ${pids[*]}; do
	    sudo kill -s SIGINT $pid
done

# copy data from temp files
echo '{'
echo '\t"blkzone": $(cat ${blkzone_output}),'
echo '\t"meminfo": $(cat ${meminfo_output}),'
echo '\t"beforesmart": $(cat ${beforesmart_output}),'
echo '\t"aftersmart": $(cat ${aftersmart_output})'
echo '}'

# cleanup files
sudo rm $blkzone_output $meminfo_output $beforesmart_output $aftersmart_output
