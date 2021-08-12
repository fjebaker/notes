# Virtual Box (OSX)

Using [Oracle VirtualBox](https://www.virtualbox.org/), installed using brew with extensions:

```bash
brew cask install virtualbox  virtualbox-extension-pack
```

<!--BEGIN TOC-->
## Table of Contents
1. [Host reconnaissance](#host-reconnaissance)
2. [Linux guest images](#linux-guest-images)
    1. [Guest Extensions](#guest-extensions)

<!--END TOC-->

## Host reconnaissance
Discover the chip instructions set with
```bash
uname -a 
```
to distinguish between `amd`, `arm`, and 32 and 64 bit operating systems.

## Linux guest images
In general, setting up a Linux VM is relatively configuration-free -- following the regular method for creating a new image, unless a fairly unknown distribution of Linux is being used, VirtualBox already configures most of the settings for you.

There is however a slight exception at time of writing (23 September 2020), and that is that with OSX hosts, the new Audio Driver causes the machine to crash (my investigation of this is about a week old and I have lost the logs and research since -- this will be updated when I inevitably recreate the problem in the future).

The problem is as follows
- after installation is complete, during reboot the image will crash showing status *aborted*
- subsequent boot attempts recreate the above

The prescription is simple:
- in Settings/Audio, uncheck Enable Audio, *or*
- use a different audio driver on the Host


### Guest Extensions

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
<<<<<<< Updated upstream
The output should list the `vboxguest` extension if all went to plan.
=======
The output should list the `vboxguest` extension if all went to plan.
>>>>>>> Stashed changes
