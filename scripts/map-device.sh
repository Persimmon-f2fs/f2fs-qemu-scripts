#!/bin/sh

usage() {
	echo "map-device: <size in GB> <device> <name of mapped device>"
	exit 1
}

[ -z "$1" ] && usage
[ -z "$2" ] && usage
[ -z "$3" ] && usage

size=$(($1 * 1024 * 1024 * 1024 / 512))
device=$2
mapped_name=$3

echo "Creating $mapped_name of device: $device of size $size"

# Create an identity mapping for a device
if ! echo "0 $size linear $device 0" | dmsetup create $mapped_name; then
	exit 1
fi
