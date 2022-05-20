#!/usr/bin/bash

# Use this script for configuring the cloud image easily

function usage() {
	echo "init-img.sh <directory>"
	exit 1
}

function main() {
	[ -z "$1" ] && usage

	target_dir=$1

	# check that the target_dir is a directory
	if ! [[ -d "$target_dir" ]]; then
		echo "$target_dir does not exist or is not a directory"
		exit 1
	fi

	prep_cloudimg
	prep_userdata
	run_qemu
}

function prep_cloudimg() {
	# 1. download the image

	if [[ -f "$target_dir/ubuntu.img" ]]; then
		echo "==> Cloud image exists, skipping"
		return 0
	fi

	echo "==> Downloading cloud image"

	wget -O $target_dir/ubuntu.img https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
	if ! [ $? -eq 0 ]; then
		echo "Failed to download cloud image."
		exit 1
	fi

	echo "==> Resizing image"
	
	qemu-img resize $target_dir/ubuntu.img 50G
}

function prep_userdata() {
	# 2. prepare user-data image
	if [[ -f "$target_dir/user-data.img" ]]; then
		echo "==> User data image exists, skipping"
		return 0
	fi

	echo "==> Preparing user data image"

	# get user password
	echo -n "Enter a password: "
	read -s password1
	echo

	# get repeat
	echo -n "Repeat password: "
	read -s password2
	echo

	# ensure equality
	if ! [[ "$password1" == "$password2" ]]; then
		echo "Passwords do not match."
		exit 1
	fi

	user_data_file=$target_dir/user-data
cat > "$user_data_file" <<EOF
#cloud-config
password: $password1
chpasswd: { expire: False }
ssh_pwauth: True
runcmd:
 - [ poweroff ]
EOF
	cat "$user_data_file"

	# write the target
	cloud-localds $target_dir/user-data.img $user_data_file
	if ! [ $? -eq 0 ]; then
		echo "Failed to prepare user-data image."
		exit 1
	fi

	rm "$user_data_file"
}

function run_qemu() {
	# 3. run the initial image
	echo "==> Initializing the system"

	printf "Login details:\n"
	printf "\tUsername: ubuntu\n"
	echo "Press return to continue..."
	read _
	
	sudo qemu-system-x86_64 \
		-machine pc-q35-5.2,accel=kvm \
		-enable-kvm \
		-drive if=virtio,format=qcow2,file=$target_dir/ubuntu.img \
		-drive if=virtio,format=raw,file=$target_dir/user-data.img \
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
		-netdev user,id=net0,hostfwd=tcp::2222-:22

	rm $target_dir/user-data.img
}

main $1
