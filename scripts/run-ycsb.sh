#!/usr/bin/bash

# Use this script for running all ycsb benchmarks

function usage() {
	echo "run-ycsb.sh <recordcount> <operationcount> <directory> <output-directory> <device>"
	exit 1
}

function main() {
	[ -z "$1" ] && usage
	[ -z "$2" ] && usage
	[ -z "$3" ] && usage
	[ -z "$4" ] && usage
    [ -z "$5" ] && usage

    recordcount=$1
    operationcount=$2
    target_dir=$3
    output_dir=$4
    device=$5

    if [[ $device == "nvme0n2" ]]
    then
        loglocation="f2fs/nvme0n1"
    else
        loglocation="f2fs_mod/dm-5"
    fi
	# check that the target_dir is a directory
    run_ycsb
}

function run_ycsb() {
    if ! [[ -d $output_dir ]]; then
        mkdir $output_dir
    fi
	if ! [[ -d "$target_dir" ]]; then
		sudo mkdir $target_dir
	fi
    ./f2fs-qemu-scripts/scripts/fs-stats.sh $device $loglocation $output_dir/init
    ycsb load rocksdb \
    -s -P /scratch/modified-workloads/workloada \
    -p recordcount=$recordcount \
    -p operationcount=$operationcount \
    -p rocksdb.dir=$target_dir > $output_dir/loada

    /scratch/f2fs-qemu-scripts/scripts/fs-stats.sh $device $loglocation $output_dir/load

    for workload in a b c f d
    do
        ycsb run rocksdb \
        -s -P /scratch/modified-workloads/workload$workload \
        -p recordcount=$recordcount \
        -p operationcount=$operationcount \
        -p rocksdb.dir=$target_dir > $output_dir/run$workload

        /scratch/f2fs-qemu-scripts/scripts/fs-stats.sh $device $loglocation $output_dir/runs$workload
    done

    rm -rf $target_dir
    mkdir $target_dir

    ycsb load rocksdb \
    -s -P /scratch/modified-workloads/workloade \
    -p recordcount=$recordcount \
    -p operationcount=$operationcount \
    -p rocksdb.dir=$target_dir > $output_dir/loade

    ycsb run rocksdb \
    -s -P /scratch/modified-workloads/workloade \
    -p recordcount=$recordcount \
    -p operationcount=$operationcount \
    -p rocksdb.dir=$target_dir > $output_dir/rune

    /scratch/f2fs-qemu-scripts/scripts/fs-stats.sh $device $loglocation $output_dir/runse
}

main $1 $2 $3 $4 $5
