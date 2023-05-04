#!/usr/bin/bash

if [[ -z "$PROJECT_ROOT" ]]; then
  echo "Must define PROJECT_ROOT"
  exit 1
fi

if [[ -z "$F2FS_MKFS" ]]; then
  echo "Must define F2FS_MKFS"
  exit 1
fi

if [[ -z "$F2FS_MOD_MKFS" ]]; then
  echo "Must define F2FS_MOD_MKFS"
  exit 1
fi

if [[ -z "$SCRIPTS_ROOT" ]]; then
  echo "Must define SCRIPTS_ROOT"
  exit 1
fi

FS_DIR=$PROJECT_ROOT/fs/f2fs
PWD=$SCRIPTS_ROOT/scripts

# 1. select scheduler
sudo bash -c "echo mq-deadline > /sys/block/nvme1n2/queue/scheduler"
sudo bash -c "echo mq-deadline > /sys/block/nvme0n2/queue/scheduler"

# 3. prepare linear mapped devices
if ! [[ -e /dev/mapper/mapped-nvme0n2 ]]; then
  echo "creating mapped-nvme0n2"
  sudo $PWD/map-device.sh 196 /dev/nvme0n2 mapped-nvme0n2 || exit 1
else
  echo "mapped-nvme0n2 already exists!"
fi

if ! [[ -e /dev/mapper/mapped-nvme1n2 ]]; then
  echo "creating mapped-nvme1n2"
  sudo $PWD/map-device.sh 202 /dev/nvme1n2 mapped-nvme1n2 || exit 1
else
  echo "mapped-nvme1n2 already exists"
fi

# 4. create some directories
if ! [[ -d /mnt/f2fs ]]; then
  sudo mkdir /mnt/f2fs
fi

if ! [[ -d /mnt/f2fs ]]; then
  sudo mkdir /mnt/f2fs_mod
fi

# 5. format the devices
echo "formatting f2fs"
sudo $F2FS_MKFS -fmc /dev/mapper/mapped-nvme0n2 /dev/nvme0n1 || exit 1

echo "formatting f2fs_mod"
sudo $F2FS_MOD_MKFS /dev/mapper/mapped-nvme1n2 || exit 1

# 2. module is probably already installed, try to install regardless
if ! [[ -e $FS_DIR/f2fs_mod.ko ]]; then
  echo "module does not exist, run make on the fs directory"
  exit 1
fi

if [[ -h /lib/modules/$(uname -r)/f2fs_mod.ko ]]; then
  echo "removing module"
  sudo rm /lib/modules/$(uname -r)/f2fs_mod.ko || exit 1
fi

sudo ln -s $FS_DIR/f2fs_mod.ko /lib/modules/`uname -r` || exit 1
sudo depmod -a || exit 1

sudo modprobe f2fs_mod || exit 1

# 6. mount the deivces
sudo mount -t f2fs /dev/nvme0n1 /mnt/f2fs || exit 1
sudo mount -t f2fs_mod /dev/mapper/mapped-nvme1n2 /mnt/f2fs_mod || exit 1
