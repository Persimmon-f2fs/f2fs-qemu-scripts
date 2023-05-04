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

output_name=$1
test_dir=$2
device=$3
fio_options=$4

blkzone_output=/tmp/${output_name}_blkzone.txt
meminfo_output=/tmp/${output_name}_meminfo.txt
beforesmart_output=/tmp/${output_name}_beforesmart.json
aftersmart_output=/tmp/${output_name}_aftersmart.json
fio_output=/tmp/${output_name}_fio.json

# remove tmp files (potentially from previous run)
sudo rm -f $blkzone_output $meminfo_output $beforesmart_output $aftersmart_output

declare -a pids
sudo perl /share/f2fs-qemu-scripts/scripts/poll_blkzone.perl $device > $blkzone_output &
pids[0]=$!
sudo perl /share/f2fs-qemu-scripts/scripts/poll_meminfo.perl > $meminfo_output &
pids[1]=$!

# record smart data before run
sudo smartctl -aj $device > $beforesmart_output

# sudo filebench -f /share/workloads/fileserver.f > ${output_name}_benchmark
sudo fio --directory="$test_dir" --output=json $fio_options /share/f2fs-qemu-scripts/fio/garbagecollect.fio 1> ${fio_output} 2>> ./log.txt

# record smart data after run
sudo smartctl -aj $device > $aftersmart_output

# send interrupt signals
for pid in ${pids[*]}; do
	    sudo kill -s SIGINT $pid
done

# copy data from temp files
echo '{'
echo "\"blkzone\": $(cat ${blkzone_output}),"
echo "\"meminfo\": $(cat ${meminfo_output}),"
echo "\"fioInfo\": $(cat ${fio_output}),"
echo "\"beforesmart\": $(cat ${beforesmart_output}),"
echo "\"aftersmart\": $(cat ${aftersmart_output})"
echo '}'

# cleanup files
sudo rm $blkzone_output $meminfo_output $beforesmart_output $aftersmart_output
