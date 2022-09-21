#!/usr/bin/bash

# Use this script for running all ycsb benchmarks

function usage() {
	echo "run-ycsb.sh <recordcount> <operationcount> <directory> <output
    directory>"
	exit 1
}

function main() {
	[ -z "$1" ] && usage
	[ -z "$2" ] && usage
	[ -z "$3" ] && usage
	[ -z "$4" ] && usage

    recordcount=$1
    operationcount=$2
    target_dir=$3
    output_dir=$4

	# check that the target_dir is a directory
	if ! [[ -d "$target_dir" ]]; then
		echo "$target_dir does not exist or is not a directory"
		exit 1
	fi
    run_ycsb
}

function run_ycsb() {
    if ! [[ -d $output_dir ]]; then
        mkdir $output_dir
    fi

    sudo /scratch/ycsb-0.17.0/bin/ycsb load rocksdb \
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloada \
    -p recordcount=$recordcount \
    -p operationcount=$operationcount \
    -p rocksdb.dir=$target_dir \
    -p  hdrhistogram.output.path=$output_dir/loada

    for workload in a b c f d
    do
        sudo /scratch/ycsb-0.17.0/bin/ycsb run rocksdb \
        -s -P /scratch/ycsb-0.17.0/modified-workloads/workload$workload \
        -p recordcount=$recordcount \
        -p operationcount=$operationcount \
        -p rocksdb.dir=$target_dir \
        -p  hdrhistogram.output.path=$output_dir/run$workload
    done

#    sudo rm -rf $target_dir

    sudo /scratch/ycsb-0.17.0/bin/ycsb load rocksdb \
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloade \
    -p recordcount=$recordcount \
    -p operationcount=$operationcount \
    -p rocksdb.dir=${target_dir}1 \
    -p  hdrhistogram.output.path=$output_dir/loade

    sudo /scratch/ycsb-0.17.0/bin/ycsb run rocksdb \
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloade \
    -p recordcount=$recordcount \
    -p operationcount=$operationcount \
    -p rocksdb.dir=${target_dir}1 \
    -p  hdrhistogram.output.path=$output_dir/rune
}

main $1 $2 $3 $4
