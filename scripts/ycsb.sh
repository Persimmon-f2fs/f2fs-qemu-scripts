#/usr/bin/bash


mkdir f2fs
mkdir us

sudo ./f2fs-qemu-scripts/scripts/run-ycsb.sh 12000000 10000000 /mnt/f2fs/rocksdb/ f2fs nvme0n2 &
sudo ./f2fs-qemu-scripts/scripts/run-ycsb.sh 12000000 10000000 /mnt/f2fs_mod/rocksdb/ us nvme1n2 &

wait

echo "done!"
