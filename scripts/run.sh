#!/usr/bin/bash

if [ -z "$F2FS_PROJECT_ROOT" ]; then
  echo "\$F2FS_PROJECT_ROOT must not be empty"
  exit 1
fi
PWD="$F2FS_PROJECT_ROOT/qemu/scripts"

znsimg="$PWD/../system-data/zns.raw"
znsmdimg="$PWD/../system-data/znsmd.raw"
rwimg="$PWD/../system-data/rw.raw"
rwmdimg="$PWD/../system-data/rwmdimg.raw"
userdata="$PWD/../system-data/user-data.img"
kernel_img="$F2FS_PROJECT_ROOT/f2fs/arch/x86/boot/bzImage"
buildroot_img="$F2FS_PROJECT_ROOT/buildroot/output/images/rootfs.ext2"
ubuntu_img="$PWD/../system-data/ubuntu.img"
userdata="$PWD/../system-data/user-data.img"

if [[ $1 == "-r" ]]; then
    echo "====== removing drives ======"

    for drive in ${znsimg} ${znsmdimg} ${rwimg} ${rwmdimg}; do
	    rm -f $drive
    done
fi

# truncate each drive to 20G
for drive in ${znsimg} ${znsmdimg} ${rwimg} ${rwmdimg}; do
    if ! [ -f "$drive" ]; then
        echo "Truncating $drive to 20G."
        touch $drive
        truncate -s 20G $drive
    fi
done

qemu-system-x86_64 \
-machine pc-q35-5.2,accel=kvm \
-kernel ${kernel_img} \
-enable-kvm \
-append "console=ttyS0 root=/dev/vda1" \
-drive if=virtio,format=qcow2,file=${ubuntu_img} \
-drive if=virtio,format=raw,file=${userdata} \
-m 4G \
-smp 8,sockets=8,cores=1,threads=1 \
-rtc base=utc,driftfix=slew \
-nographic \
-no-hpet \
-global ICH9-LPC.disable_s3=1 \
-global ICH9-LPC.disable_s4=1 \
-boot strict=on \
-audiodev none,id=noaudio \
-object rng-random,id=objrng0,filename=/dev/urandom \
-msg timestamp=on \
-device virtio-net-pci,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::2222-:22 \
-virtfs local,path=${F2FS_PROJECT_ROOT},mount_tag=host0,security_model=passthrough,id=host0 \
-device nvme,id=nvme0,serial=a,zoned.zasl=5 \
-drive file=${znsimg},id=nvmezns0,format=raw,if=none \
-device nvme-ns,drive=nvmezns0,bus=nvme0,zoned=on \
-device nvme,id=nvme1,serial=b \
-drive file=${znsmdimg},id=nvmerw0,format=raw,if=none \
-device nvme-ns,drive=nvmerw0,bus=nvme1,uuid=67105595-1873-4779-b90c-b7758a008e49 \
-device nvme,id=nvme2,serial=c \
-drive file=${rwimg},id=nvmerw1,format=raw,if=none \
-device nvme-ns,drive=nvmerw1,bus=nvme2,uuid=6e1e92da-f121-4d4f-a635-0de5df6c8246 \
-device nvme,id=nvme3,serial=d \
-drive file=${rwmdimg},id=nvmerw2,format=raw,if=none \
-device nvme-ns,drive=nvmerw2,bus=nvme3

