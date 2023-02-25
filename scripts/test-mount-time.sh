#!/usr/bin/zsh

sudo umount /mnt/f2fs
sudo umount /mnt/f2fs_mod
# mount the deivces
time sudo mount -t f2fs /dev/nvme0n1 /mnt/f2fs
time sudo mount -t f2fs_mod /dev/mapper/mapped-nvme1n2 /mnt/f2fs_mod
