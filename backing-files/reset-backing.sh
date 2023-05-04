#!/usr/bin/bash

# Use this script to replace backing files

rm -rf f2fs_mod/zns0.raw
rm -rf f2fs_mod/zns1.raw
rm -rf f2fs_mod/zns2.raw
rm -rf f2fs_mod/zns3.raw
rm -rf f2fs_mod/zns4.raw
rm -rf f2fs_mod/zns5.raw

rm -rf btrfs/zns0.raw
rm -rf btrfs/zns1.raw
rm -rf btrfs/zns2.raw
rm -rf btrfs/zns3.raw
rm -rf btrfs/zns4.raw
rm -rf btrfs/zns5.raw

rm -rf f2fs/zns0.raw
rm -rf f2fs/zns1.raw
rm -rf f2fs/zns2.raw
rm -rf f2fs/zns3.raw
rm -rf f2fs/zns4.raw
rm -rf f2fs/zns5.raw

rm -rf f2fs/zns0-metadata.raw
rm -rf f2fs/zns1-metadata.raw
rm -rf f2fs/zns2-metadata.raw
rm -rf f2fs/zns3-metadata.raw
rm -rf f2fs/zns4-metadata.raw
rm -rf f2fs/zns5-metadata.raw

truncate -s 202G f2fs_mod/zns0.raw
truncate -s 100G f2fs_mod/zns1.raw
truncate -s 100G f2fs_mod/zns2.raw
truncate -s 100G f2fs_mod/zns3.raw
truncate -s 100G f2fs_mod/zns4.raw
truncate -s 100G f2fs_mod/zns5.raw

truncate -s 100G btrfs/zns0.raw
truncate -s 100G btrfs/zns1.raw
truncate -s 100G btrfs/zns2.raw
truncate -s 100G btrfs/zns3.raw
truncate -s 100G btrfs/zns4.raw
truncate -s 100G btrfs/zns5.raw

truncate -s 202G f2fs/zns0.raw
truncate -s 202G f2fs/zns1.raw
truncate -s 95G f2fs/zns2.raw
truncate -s 95G f2fs/zns3.raw
truncate -s 95G f2fs/zns4.raw
truncate -s 95G f2fs/zns5.raw

truncate -s 5G f2fs/zns0-metadata.raw
truncate -s 5G f2fs/zns1-metadata.raw
truncate -s 5G f2fs/zns2-metadata.raw
truncate -s 5G f2fs/zns3-metadata.raw
truncate -s 5G f2fs/zns4-metadata.raw
truncate -s 5G f2fs/zns5-metadata.raw

