#!/usr/bin/bash

# Use this script for getting fs and smart stats before running a benchmark

function usage() {
	echo "fs-stats.sh <device> <filesystem and device> <output dir>"
	exit 1
}

function main() {
	[ -z "$1" ] && usage
	[ -z "$2" ] && usage
	[ -z "$3" ] && usage

    device=$1
    filesystem=$2
    output_dir=$3

	# check validity
	if ! [[ -d "/sys/fs/$filesystem" ]]; then
		echo "$filesystem does not exist or is not a directory"
		exit 1
	fi
	if ! [[ -d "$output_dir" ]]; then
		mkdir $output_dir
	fi
    get_stats
}

function get_stats(){

    sudo smartctl -Aj /dev/$device > $output_dir/smart.json
    echo "moved_blocks_background,$(cat /sys/fs/$filesystem/moved_blocks_background)" > $output_dir/fs.csv
    echo "moved_blocks_foreground,$(cat /sys/fs/$filesystem/moved_blocks_foreground)" >> $output_dir/fs.csv
    echo "gc_reclaimed_segments,$(cat /sys/fs/$filesystem/gc_reclaimed_segments)" >> $output_dir/fs.csv
    echo "lifetime_write_kbytes,$(cat /sys/fs/$filesystem/lifetime_write_kbytes)" >> $output_dir/fs.csv
    echo "gc_background_calls,$(cat /sys/fs/$filesystem/gc_background_calls)" >> $output_dir/fs.csv
    echo "gc_foreground_calls,$(cat /sys/fs/$filesystem/gc_foreground_calls)" >> $output_dir/fs.csv
}

main $1 $2 $3
