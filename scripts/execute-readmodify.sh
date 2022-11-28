#!/usr/bin/bash

mkdir f2fs
mkdir us

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1 f2fs/f2fs-init
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-init
sudo ./ycsb-0.17.0/bin/ycsb load rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloada\
    -p recordcount=24000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs/rocksdb &

sudo ./ycsb-0.17.0/bin/ycsb load rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloada\
    -p recordcount=24000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs_mod/rocksdb &

wait

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1\
    f2fs/f2fs-load
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-load

sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloadf\
    -p recordcount=24000000\
    -p operationcount=100000000\
    -p rocksdb.dir=/mnt/f2fs/rocksdb > f2fs.txt &


sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloadf\
    -p recordcount=24000000\
    -p operationcount=100000000\
    -p rocksdb.dir=/mnt/f2fs_mod/rocksdb > us.txt &

wait

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-f
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1\
    f2fs/f2fs-f
