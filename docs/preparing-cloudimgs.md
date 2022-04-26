# Preparing cloud-imgs 

I continually forget how to do this. Since this is something that needs to happen every
time I switch to a new machine, it's probably useful that I write down the instructions

1. Acquire a cloud-img. Go to [https://cloud-images.ubuntu.com/](https://cloud-images.ubuntu.com/)
and get an image of your choosing. Most of the time, I'll try to use the latest version, unless
there's a future incompatibility not realized

Fetching an image:

```
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
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

(As an aside, the virtio is necessary for both entries. Neglecting to add it leads to 
the server not being able to boot.)


