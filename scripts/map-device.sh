#!/bin/sh

usage() {
	echo "map-device: <size in GB> <device>"
	exit 1
}

[ -z "$1" ] && usage
[ -z "$2" ] && usage

size=$(($1 * 1024 * 1024 * 1024 / 512))
device=$2

echo "Creating a mapping of device: $device of size $size"

# Create an identity mapping for a device
echo "0 $size linear $device 0" | dmsetup create identity
