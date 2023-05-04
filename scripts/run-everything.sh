#!/usr/bin/bash


PWD=/store/fs-experiments

# reset the drives
cd $PWD/backing-files
sudo ./reset-backing.sh
cd ..

# start the vm's
sudo $PWD/fs-scripts/run_f2fs.sh  1> /dev/null 2>&1
sudo $PWD/fs-scripts/run_f2fs_mod.sh 1> /dev/null 2>&1
sudo $PWD/fs-scripts/run_btrfs.sh 1> /dev/null 2>&1

# wait until vm's are ready
while ! ssh ubuntu@localhost -p2222 "echo hello"; do :; done
while ! ssh ubuntu@localhost -p2223 "echo hello"; do :; done
while ! ssh ubuntu@localhost -p2224 "echo hello"; do :; done

echo "vm's are ready"

$PWD/share/f2fs-qemu-scripts/scripts/run-jobs.py --file $PWD/share/f2fs-qemu-scripts/jobfiles/run-all.yaml

