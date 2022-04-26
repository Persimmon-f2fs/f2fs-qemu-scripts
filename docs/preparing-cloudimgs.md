# Preparing cloud-imgs 

I continually forget how to do this. Since this is something that needs to happen every
time I switch to a new machine, it's probably useful that I write down the instructions

1. Acquire a cloud-img. Go to [https://cloud-images.ubuntu.com/](https://cloud-images.ubuntu.com/)
and get an image of your choosing. The filesystem was implemented using kernel v5.11 on a
hirsute cloud iamge

Fetching an image:

```
wget https://cloud-images.ubuntu.com/releases/hirsute/release/ubuntu-21.04-server-cloudimg-amd64.img
```

Note that the links may change somewhat frequently, so be weary of that.

2. Prepare a secondary user-data img, setting the password for the `ubuntu` user as necessary

```
cat > user-data <<EOF
#cloud-config
password: Password1
chpasswd: { expire: False }
ssh_pwauth: True
EOF
```

3. Afterward, install `cloud-image-utils`

```
sudo apt-get install cloud-image-utils
```

Or

```
sudo pacman -S cloud-image-utils
```

And then

```
cloud-localds user-data.img user-data
```

4. Finally, run qemu with the following

```
qemu-system-x86_64 \
-drive file=jammy-server-cloudimg-amd64.img,format=qcow2,if=virtio \
-drive file=user-data.img,format=raw,if=virtio
```

5. Resize the image

I've found that the default size defined by ubuntu is inadequate for cloning the filesystem 
repository. Resize it via: (replace ${IMAGE} with relevant image filename)

```
qemu-img resize ${IMAGE} 50G
```

After doing a full reboot of the cloudimg, the root filesystem *should* resize to the full
drive size.

Afterward, the cloudimg should be capable of login with ubuntu as the username and the 
password set by the user-data image. It's recommended to change this once you log into the
cloudimg.

(As an aside, the virtio is necessary for both entries. Neglecting to add it leads to 
the server not being able to boot.)

