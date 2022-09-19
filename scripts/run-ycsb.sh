#!/usr/bin/bash

# Use this script for configuring the cloud image easily

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

    sudo /scratch/ycsb-0.17.0/bin/ycsb load-a rocksdb -s -P /scratch/ycsb-0.17.0/workloads/workloada -p recordcount=$recordcount \
    -p operationcount=$operationcount -p rocksdb.dir=$target_dir > \
    $output_dir/load-a

    sudo /scratch/ycsb-0.17.0/bin/ycsb run rocksdb -s -P /scratch/ycsb-0.17.0/workloads/workloada -p recordcount=$recordcount \
    -p operationcount=$operationcount -p rocksdb.dir=$target_dir > \
    $output_dir/run-a

    sudo /scratch/ycsb-0.17.0/bin/ycsb run rocksdb -s -P /scratch/ycsb-0.17.0/workloads/workloadb -p recordcount=$recordcount \
    -p operationcount=$operationcount -p rocksdb.dir=$target_dir > \
    $output_dir/run-b

    sudo /scratch/ycsb-0.17.0/bin/ycsb run rocksdb -s -P /scratch/ycsb-0.17.0/workloads/workloadc -p recordcount=$recordcount \
    -p operationcount=$operationcount -p rocksdb.dir=$target_dir > \
    $output_dir/run-c

    sudo /scratch/ycsb-0.17.0/bin/ycsb run rocksdb -s -P /scratch/ycsb-0.17.0/workloads/workloadf -p recordcount=$recordcount \
    -p operationcount=$operationcount -p rocksdb.dir=$target_dir > \
    $output_dir/run-f

    sudo /scratch/ycsb-0.17.0/bin/ycsb run rocksdb -s -P /scratch/ycsb-0.17.0/workloads/workloadd -p recordcount=$recordcount \
    -p operationcount=$operationcount -p rocksdb.dir=$target_dir > \
    $output_dir/run-d

    sudo rm -rf $target_dir

    sudo /scratch/ycsb-0.17.0/bin/ycsb load rocksdb -s -P /scratch/ycsb-0.17.0/workloads/workloade -p recordcount=$recordcount \
    -p operationcount=$operationcount -p rocksdb.dir=$target_dir > \
    $output_dir/load-e

    sudo /scratch/ycsb-0.17.0/bin/ycsb run rocksdb -s -P /scratch/ycsb-0.17.0/workloads/workloade -p recordcount=$recordcount \
    -p operationcount=$operationcount -p rocksdb.dir=$target_dir > \
    $output_dir/run-e
}

main $1 $2 $3 $4
