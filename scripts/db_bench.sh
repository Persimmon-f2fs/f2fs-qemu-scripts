#/usr/bin/bash


mkdir f2fs
mkdir us

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n2 f2fs/nvme0n1 f2fs/f2fs-init
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n2 f2fs_mod/dm-5 us/us-init

./rocksdb/db_bench -db=/mnt/f2fs \
-benchmarks="fillseq,stats" --statistics --seed=2 \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=90000000 -threads=16 > f2fs/fillseq.txt &

./rocksdb/db_bench -db=/mnt/f2fs_mod \
-benchmarks="fillseq,stats" --statistics --seed=2 \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=90000000 -threads=16 > us/fillseq.txt &

wait

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n2 f2fs/nvme0n1 f2fs/f2fs-fill
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n2 f2fs_mod/dm-5 us/us-fill

./rocksdb/db_bench -db=/mnt/f2fs_mod \
-benchmarks="deleterandom,stats" --statistics --seed=2 \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction -use_existing_db \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=50000000 -threads=4 > us/deleterandom.txt &


./rocksdb/db_bench -db=/mnt/f2fs \
-benchmarks="deleterandom,stats" --statistics --seed=2 \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction -use_existing_db \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=50000000 -threads=4 > f2fs/deleterandom.txt &

wait

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n2 f2fs/nvme0n1 f2fs/f2fs-del
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n2 f2fs_mod/dm-5 us/us-del

./rocksdb/db_bench -db=/mnt/f2fs_mod \
-benchmarks="updaterandom,stats" --statistics --seed=2 \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction -use_existing_db \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=50000000 -threads=16 > us/updaterandom.txt &


./rocksdb/db_bench -db=/mnt/f2fs \
-benchmarks="updaterandom,stats" --statistics --seed=2 \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction -use_existing_db \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=50000000 -threads=16 > f2fs/updaterandom.txt &

wait

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n2 f2fs/nvme0n1 f2fs/f2fs-update
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n2 f2fs_mod/dm-5 us/us-update

./rocksdb/db_bench -db=/mnt/f2fs_mod \
-benchmarks="overwrite,stats" --statistics --seed=2 \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction -use_existing_db \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=20000000 -threads=16 > us/overwrite.txt &


./rocksdb/db_bench -db=/mnt/f2fs \
-benchmarks="overwrite,stats" --statistics --seed=2 \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction -use_existing_db \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=20000000 -threads=16 > f2fs/overwrite.txt &

wait

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n2 f2fs/nvme0n1 f2fs/f2fs-overwrite
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n2 f2fs_mod/dm-5 us/us-overwrite

./rocksdb/db_bench -db=/mnt/f2fs_mod \
-benchmarks="readrandom,stats" --statistics \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction -use_existing_db \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=20000000 -threads=16 > us/readrandom.txt &


./rocksdb/db_bench -db=/mnt/f2fs \
-benchmarks="readrandom,stats" --statistics \
--target_file_size_base=1129316352 -use_direct_io_for_flush_and_compaction -use_existing_db \
--max_bytes_for_level_multiplier=4 --max_background_jobs=8 \
-num=20000000 -threads=16 > f2fs/readrandom.txt &

wait

./f2fs-qemu-scripts/scripts/fs-stats.sh nvme0n2 f2fs/nvme0n1 f2fs/f2fs-final
./f2fs-qemu-scripts/scripts/fs-stats.sh nvme1n2 f2fs_mod/dm-5 us/us-final
