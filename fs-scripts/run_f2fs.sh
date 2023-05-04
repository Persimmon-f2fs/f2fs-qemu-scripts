#!/usr/bin/bash

PWD="/store/fs-experiments/fs-scripts"

zns0_img="$PWD/../backing-files/f2fs/zns0.raw"
zns0_meta_img="$PWD/../backing-files/f2fs/zns0-metadata.raw"
zns1_img="$PWD/../backing-files/f2fs/zns1.raw"
zns1_meta_img="$PWD/../backing-files/f2fs/zns1-metadata.raw"
zns2_img="$PWD/../backing-files/f2fs/zns2.raw"
zns2_meta_img="$PWD/../backing-files/f2fs/zns2-metadata.raw"
zns3_img="$PWD/../backing-files/f2fs/zns3.raw"
zns3_meta_img="$PWD/../backing-files/f2fs/zns3-metadata.raw"
zns4_img="$PWD/../backing-files/f2fs/zns4.raw"
zns4_meta_img="$PWD/../backing-files/f2fs/zns4-metadata.raw"
zns5_img="$PWD/../backing-files/f2fs/zns5.raw"
zns5_meta_img="$PWD/../backing-files/f2fs/zns5-metadata.raw"

ubuntu_img="$PWD/../backing-files/f2fs/ubuntu.img"
kernel_img="$PWD/../backing-files/f2fs/kernel/arch/x86/boot/bzImage"
shared_dir="$PWD/../share"

# execute the machine
sudo qemu-system-x86_64 \
-nographic \
-machine pc-q35-5.2,accel=kvm \
-enable-kvm \
-kernel ${kernel_img} \
-append "console=ttyS0 root=/dev/vda1" \
-drive if=virtio,format=qcow2,file=${ubuntu_img} \
-m 4G \
-smp 8,sockets=8,cores=1,threads=1 \
-rtc base=utc,driftfix=slew \
-no-hpet \
-global ICH9-LPC.disable_s3=1 \
-global ICH9-LPC.disable_s4=1 \
-boot strict=on \
-audiodev none,id=noaudio \
-object rng-random,id=objrng0,filename=/dev/urandom \
-msg timestamp=on \
-device virtio-net-pci,netdev=net0 \
-netdev user,id=net0,hostfwd=tcp::2222-:22 \
-virtfs local,path=$shared_dir,mount_tag=host0,security_model=passthrough,id=host0 \
-device nvme,id=nvme0,serial=a,zoned.zasl=5 \
-drive file=${zns0_img},id=nvmezns0,format=raw,if=none \
-device nvme-ns,drive=nvmezns0,bus=nvme0,logical_block_size=4096,physical_block_size=4096,zoned=on,zoned.zone_size=2048M,zoned.zone_capacity=1024M \
-drive file=${zns0_meta_img},id=nvmereg0,format=raw,if=none \
-device nvme-ns,drive=nvmereg0,bus=nvme0,logical_block_size=4096,physical_block_size=4096 \
\
-device nvme,id=nvme1,serial=b,zoned.zasl=5 \
-drive file=${zns1_img},id=nvmezns1,format=raw,if=none \
-device nvme-ns,drive=nvmezns1,bus=nvme1,zoned=on \
-drive file=${zns1_meta_img},id=nvmereg1,format=raw,if=none \
-device nvme-ns,drive=nvmereg1,bus=nvme1 \
\
-device nvme,id=nvme2,serial=c,zoned.zasl=5 \
-drive file=${zns2_img},id=nvmezns2,format=raw,if=none \
-device nvme-ns,drive=nvmezns2,bus=nvme2,zoned=on \
-drive file=${zns2_meta_img},id=nvmereg2,format=raw,if=none \
-device nvme-ns,drive=nvmereg2,bus=nvme2 \
\
-device nvme,id=nvme3,serial=d,zoned.zasl=5 \
-drive file=${zns3_img},id=nvmezns3,format=raw,if=none \
-device nvme-ns,drive=nvmezns3,bus=nvme3,zoned=on \
-drive file=${zns3_meta_img},id=nvmereg3,format=raw,if=none \
-device nvme-ns,drive=nvmereg3,bus=nvme3 \
\
-device nvme,id=nvme4,serial=e,zoned.zasl=5 \
-drive file=${zns4_img},id=nvmezns4,format=raw,if=none \
-device nvme-ns,drive=nvmezns4,bus=nvme4,zoned=on \
-drive file=${zns4_meta_img},id=nvmereg4,format=raw,if=none \
-device nvme-ns,drive=nvmereg4,bus=nvme4 \
\
-device nvme,id=nvme5,serial=f,zoned.zasl=5 \
-drive file=${zns5_img},id=nvmezns5,format=raw,if=none \
-device nvme-ns,drive=nvmezns5,bus=nvme5,zoned=on \
-drive file=${zns5_meta_img},id=nvmereg5,format=raw,if=none \
-device nvme-ns,drive=nvmereg5,bus=nvme5 \

