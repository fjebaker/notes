# Installing Guest Extensions on Linux Images
Following a guide from [Linuxsize](https://linuxize.com/post/how-to-install-virtualbox-guest-additions-on-debian-10/).

1. Update the guest machine repositories
You can do this with a simple 
```bash
sudo apt update
```

2. Fetch dependencies
```bash
sudo apt install build-essentials dkms linux-headers-$(uname -r)
```

3. Insert the 'Guest Additions CD Image', and mount with
```bash
sudo mkdir /mnt && sudo mount /dev/cdrom /mnt 
```

4. Install the Guest Additions
```bash
cd /mnt && sudo sh ./VBoxLinuxAdditions.run --nox11
```
The `--nox11` tells the installer not to open an X11 window.

5. Reboot and validate
```bash
sudo reboot 
```
and check the installation with
```bash
lsmod | grep vboxguest
```
The output should list the `vboxguest` extension if all went to plan.
