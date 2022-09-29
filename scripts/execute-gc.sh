#!/usr/bin/bash

mkdir f2fs
mkdir us

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1 f2fs/f2fs-init
sudo ./ycsb-0.17.0/bin/ycsb load rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloada\
    -p recordcount=12000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1\
    f2fs/f2fs-load
sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloada\
    -p recordcount=12000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1\
    f2fs/f2fs-a
sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloadd\
    -p recordcount=12000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1\
    f2fs/f2fs-d
sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloade\
    -p recordcount=12000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1\
    f2fs/f2fs-e
sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloadg\
    -p recordcount=12000000\
    -p operationcount=20000000\
    -p rocksdb.dir=/mnt/f2fs/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n1 f2fs/nvme0n1\
    f2fs/f2fs-g


./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-init
sudo ./ycsb-0.17.0/bin/ycsb load rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloada\
    -p recordcount=12000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs_mod/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-load
sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloada\
    -p recordcount=12000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs_mod/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-a
sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloadd\
    -p recordcount=12000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs_mod/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-d
sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloade\
    -p recordcount=12000000\
    -p operationcount=10000000\
    -p rocksdb.dir=/mnt/f2fs_mod/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-e
sudo ./ycsb-0.17.0/bin/ycsb run rocksdb\
    -s -P /scratch/ycsb-0.17.0/modified-workloads/workloadg\
    -p recordcount=12000000\
    -p operationcount=20000000\
    -p rocksdb.dir=/mnt/f2fs_mod/rocksdb
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n1 f2fs_mod/dm-5 us/us-g
