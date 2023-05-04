#!/usr/bin/bash

function usage() {
  echo "record-scale.sh <mkfs-path> <device> <output-path>"
  exit 1
}

if [[ -z "$SCRIPTS_ROOT" ]]; then
  echo "Must declare SCRIPTS_ROOT to be the root of the f2fs-qemu-scripts repository"
  exit 1
fi

[[ -z "$1" ]] && usage
[[ -z "$2" ]] && usage
[[ -z "$3" ]] && usage

MKFS=$1
DEVICE=$2
PWD=$SCRIPTS_ROOT/scripts
OUTPUT_FILE=$3

echo "fs_size,meta_segments" > "$OUTPUT_FILE"

# start off with 100 GB and go up to the 7.2 TB
for ((size=100;size<=7168;size+=100))
do
  # map the device
  if ! sudo $PWD/map-device.sh $size "$DEVICE" record-scale-device; then
    exit 1 
  fi

  # run mkfs on the device, and caputre the number of meta segments
  if ! sudo $MKFS -fmc /dev/mapper/record-scale-device /dev/nvme0n1 1> /tmp/mkfs.out 2> /tmp/mkfs.err; then
    echo "failed to mount!"
    cat /tmp/mkfs.out
    sudo dmsetup remove /dev/mapper/record-scale-device 
    exit 1
  fi

  total_meta_segments=$(cat /tmp/mkfs.out | sed -n "s/.*TOTAL META SEGMENTS: \([[:digit:]]\+\).*/\1/p")

  echo "$size,$total_meta_segments" >> "$OUTPUT_FILE"

  sleep 2

  # remove the mapped device
  if ! sudo dmsetup remove /dev/mapper/record-scale-device; then
    exit 1
  fi
done
