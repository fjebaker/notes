# \*nix system administration cookbook

Recipes and writeups of solutions from problems on different \*nix operating systems.

<!--BEGIN TOC-->
## Table of Contents
1. [General tricks and tips](#toc-sub-tag-0)
	1. [Installing without ethernet](#toc-sub-tag-1)
2. [Users and groups](#toc-sub-tag-2)
3. [Debian network configuration](#toc-sub-tag-3)
	1. [Controlling interfaces](#toc-sub-tag-4)
	2. [Configuring interfaces](#toc-sub-tag-5)
		1. [DHCP](#toc-sub-tag-6)
		2. [Static IP](#toc-sub-tag-7)
	3. [Debugging networks](#toc-sub-tag-8)
4. [SSH Overview](#toc-sub-tag-9)
5. [Installing `sudo`](#toc-sub-tag-10)
6. [Hardware](#toc-sub-tag-11)
	1. [Graphics cards](#toc-sub-tag-12)
7. [Sound Configuration](#toc-sub-tag-13)
	1. [ALSA](#toc-sub-tag-14)
		1. [CMUS with ALSA](#toc-sub-tag-15)
	2. [Hardware specifications](#toc-sub-tag-16)
8. [Useful commands](#toc-sub-tag-17)
	1. [`STOP` and `CONT` a process](#toc-sub-tag-18)
	2. [SSL with `curl`](#toc-sub-tag-19)
9. [Disks and mounting](#toc-sub-tag-20)
	1. [Listing disks](#toc-sub-tag-21)
	2. [File system checks](#toc-sub-tag-22)
	3. [Recovering files](#toc-sub-tag-23)
	4. [Formating](#toc-sub-tag-24)
	5. [Automount with `/etc/fstab`](#toc-sub-tag-25)
	6. [Burning CDs and DVDs](#toc-sub-tag-26)
	7. [Mounting a filesystem with SSH](#toc-sub-tag-27)
10. [Installing Docker on Debian](#toc-sub-tag-28)
	1. [docker-compose](#toc-sub-tag-29)
11. [Package management](#toc-sub-tag-30)
12. [Python installations](#toc-sub-tag-31)
13. [Path alternatives](#toc-sub-tag-32)
14. [Versions](#toc-sub-tag-33)
	1. [Debian](#toc-sub-tag-34)
<!--END TOC-->

## General tricks and tips <a name="toc-sub-tag-0"></a>
Here are some general ideas that I think are vitally important to remember when handling \*nix systems.

### Installing without ethernet <a name="toc-sub-tag-1"></a>
When installing a \*nix system without an ethernet connection, it can be generally quite difficult to ensure the right drivers are at hand for the wifi hardware. Sometimes using just the non-free firmware versions of e.g. Debian can be enough to allow the system to enable the hardware, but at other times, you'll have to install the firmware through `apt`, which won't be available without an internet connection.

The solution to this is, if you own an android phone, use **USB tethering** to add a network interface so you can complete the installation and find the necessary firmware.

## Users and groups <a name="toc-sub-tag-2"></a>
Creating a **new user**, managing startup shell and directory
```bash
sudo useradd -d /home/[homedir] [username]
# -u for custom user id

sudo passwd [username]
# to change the password

sudo chsh -s /bin/bash [username]
# set startup shell
```
**NB:** The whole user creation process is also streamlined with the
```bash
sudo adduser [username]
```
interactive program.

For managing **primary groups**
```bash
sudo usermod -g [groupname] [username]
```

For managing **secondary groups**
```bash
sudo usermod -a -G [group1],[group2],[...] [username]
```

Removing a user from a group
```bash
sudo gpasswd -d user group
```

Deleting users
```bash
sudo userdel -r [username]
# -r removes home directory aswell
```

## Debian network configuration <a name="toc-sub-tag-3"></a>
Whilst installing Debian 9 on an old machine, which had a faulty NIC, I learned a few things about network configurations on that specific OS, most of which is documented [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html).

The legacy `ifconfig` is being replaced with the newer `ip` suite, and an overview of the translation can be quickly seen in this post by [ComputingForGeeks](https://computingforgeeks.com/ifconfig-vs-ip-usage-guide-on-linux/). Two very useful commands I use a lot for debugging are
```bash
ip a 	# output similar to the standard ifconfig

ip -s link show [interface]	# outputs interface statistics
```


### Controlling interfaces <a name="toc-sub-tag-4"></a>
Toggling specific interface states can be done using either `ip`
```bash
ip link set [interface] up
```
or `ifup`/`ifdown`
```bash
ifup [interface]
ifdown [interface]
```
**NB:** `ifup` and `ifdown` can only interact with interfaces defined in `/etc/network/interfaces`. Add a simple configuration, such as
```
iface [enoXYZ] inet dhcp
```
More detail on this in the next section.

The whole network interface may be interacted with using the `init.d` service
```bash
sudo /etc/init.d/networking [start, stop, restart, status]
```
or with `systemd` using
```bash
sudo systemctl [start, stop, restart, status] networking
```


### Configuring interfaces <a name="toc-sub-tag-5"></a>
A post on [nixCraft](https://www.cyberciti.biz/faq/howto-configuring-network-interface-cards-on-debian/) provides a good overview of Debian network configuration, and the configuration syntax can be seen [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_basic_syntax_of_etc_network_interfaces).

The main interfaces configuration can be edited in
```bash
/etc/network/interfaces
```
and typically includes just a necessary (?) local configuration
```
auto lo
iface lo inet loopback
```

#### DHCP <a name="toc-sub-tag-6"></a>
For a DHCP interface, we can use a simple configuration such as
```
auto eth0
iface eth0 inet dhcp
```

#### Static IP <a name="toc-sub-tag-7"></a>
Static IP addresses can be assigned with
```
auto eth0
iface eth0 inet static
	address 192.168.xxx.yyy
	netmask 255.255.255.0
	gateway 192.168.1.1
	# dns-domain example.com
	# dns-nameserver 192.168.1.1
```
As pointed out [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_network_interface_with_the_static_ip), if `resolvconf` package is not installed, the DNS configuration is done by editing the `/etc/resolv.conf` file with, for example
```
nameserver 192.168.1.1
domain example.com
```

**NB:** The modern `systemd` configuration is considerably more elegant, and also documented [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html#_the_modern_network_configuration_without_gui).

### Debugging networks <a name="toc-sub-tag-8"></a>
See [this guide on port overviews](https://linuxize.com/post/check-listening-ports-linux/).

## SSH Overview <a name="toc-sub-tag-9"></a>
Useful commands are

Copy login key to remote:

```bash
ssh-copy-id user@host
```
Remove host key from chain:
```bash
ssh-keygen -R host
```

## Installing `sudo` <a name="toc-sub-tag-10"></a>
Some distributions, such as lightweight Debian, do not include `sudo` by default. We can install it with root privileges
```bash
su -
apt-get install sudo -y
```
and allow a user to act as `sudo` by adding them to the relevant group and sudoers file, as documented on the [Debian wiki](https://wiki.debian.org/sudo)
```bash
usermod -aG sudo [name]
```
followed by
```bash
visudo
```
which needs to include the line
```
%sudo   ALL=(ALL:ALL) ALL
```
to allow members of group sudo to execute any command.

To commit changes, a reboot is required.

## Hardware <a name="toc-sub-tag-11"></a>
Listing all of the PCI devices can be achieved with
```bash
lspci
```
You may need to update the PCI database
```bash
update-pciids
```

On [HowToGeek](https://www.howtogeek.com/508993/how-to-check-which-gpu-is-installed-on-linux/) is a Ubuntu overview for listing hardware.

### Graphics cards <a name="toc-sub-tag-12"></a>
For graphics cards on Debian, I have created [separate notes](https://github.com/Dustpancake/Dust-Notes/blob/master/hardware/debian-gpu.md) as a how-to.

## Sound Configuration <a name="toc-sub-tag-13"></a>
Especially on headless installations of \*nix, some sound device configuration is required.

**NB:** In most cases, the user wont succeed in configuring the sound unless they are also part of the `audio` group.

### ALSA <a name="toc-sub-tag-14"></a>
[Advanced Linux Sound Architecture](https://wiki.archlinux.org/index.php/Advanced_Linux_Sound_Architecture) replaces the original Open Sound System (OSS) on \*nix.

There are conflicting methods for the installation on different \*nix systems, but I had personal success on Debian with
```bash
sudo apt-get install libasound2 alsa-utils alsa-oss
```

The seemingly magic configuration step that is missed out in a lot of guides is to create the file
```
/etc/modprobe.d/default.conf
```
with contents
```
options snd_hda_intel index=1
```
There is some information as to how this works in [this wiki entry](https://docs.slackware.com/howtos:hardware:audio_and_snd-hda-intel).

You'll probably also need to add
```
pcm.!default {
type hw
card 1
}

ctl.!default {
type hw
card 1
}
```
to `~/.asoundrc`, at least I did on Buster.

#### CMUS with ALSA <a name="toc-sub-tag-15"></a>
To get CMUS to use ALSA, we edit the `~/.cmus/autosave` file and change the configuration to
```
set dsp.alsa.device=default
set mixer.alsa.device=default
set mixer.alsa.channel=PCM
set output_plugin=alsa
```

If it fails to start, add the line
```
set output_plugin=alsa
```
in (a file which you'll probably have to create) `.cmus/rc`.


### Hardware specifications <a name="toc-sub-tag-16"></a>
As stated in the [Debian wiki](https://wiki.debian.org/ALSA#Troubleshooting), the assigned indexes to sound cards can be found with
```bash
cat /proc/asound/cards
```

To see the hardware device names, you can also use
```bash
lspci -nn | grep -i audio
```
Also useful is
```bash
lsmod | grep snd
```
to see the kernel sound modules.

With ALSA installed, you can also identify the sound devices using
```bash
aplay -l
```

## Useful commands <a name="toc-sub-tag-17"></a>
In this section I will document useful commands, which, for brevity, don't merit a full chapter of their own.

### `STOP` and `CONT` a process <a name="toc-sub-tag-18"></a>
As an example, consider you wanted to use Wireshark to capture packets of a specific program, however other programs were being very chatty, and working out exactly what Wireshark filter to craft is proving tedious. A quick and dirty solution to this is just to halt the execution of the chatty program

- find the `pid`:
We can find the process ID of any program using
```bash
ps aux | grep [name]
```

- send a `STOP` signal
Interrupt and halt the program using
```bash
kill -STOP [pid]
```

- resume with a `CONT` signal
Using a very similar command, we run
```bash
kill -CONT [pid]
```

### SSL with `curl` <a name="toc-sub-tag-19"></a>
https://stackoverflow.com/questions/10079707/https-connection-using-curl-from-command-line

## Disks and mounting <a name="toc-sub-tag-20"></a>
This section covers all things related to disks, disks drives, mounts, and anything else loosely `/dev/s*`.

### Listing disks <a name="toc-sub-tag-21"></a>
You can list the disks and block devices in a variety of ways depending on the information you are trying to ascertain:

- listing block devices
```bash
lsblk
```
will show the mount point and disk size. For non-formatted partitions
```bash
lsblk -f
```

- listing `/dev/sd*` partitions
```bash
sudo fdisk -l
```

- disk system space usage
```bash
df -h
```
The `-h` prints in human readable form.

- overview of all mounts and usage
```bash
findmnt [path]
```
You do not need to specify a path if you want to list all devices. This program is a repertoire for printing mount points and disk devices, and even has `--json` output. Another useful flag is `--df` for disk usage.

- general mount info
```bash
mount
```
Will tell you the disks mounted, and the options applied.

A full discussion can be seen in [this SO answer](https://askubuntu.com/questions/583909/how-do-i-check-where-devices-are-mounted).

To list the UUIDs and PTUUIDs, use
```bash
sudo blkid
```

### File system checks <a name="toc-sub-tag-22"></a>
Using [`fsck`](https://www.howtogeek.com/282374/what-is-the-lostfound-folder-on-linux-and-macos/).

`fsck` will run pretty much out-of-the-box, and can perform some (irreversible) file system repairs also.

Another good tool to use is `dumpe2fs` for printing filesystem information and rudimentary diagnostics. It is useful for obtaining block size information, when the drive was last used, when it was created, and so forth.

### Recovering files <a name="toc-sub-tag-23"></a>
There are multiple recovery tools available; two which I frequently use are:

- `testdisk`, which ships with `photorec`, is an open source tool for file system checks and file recovery.

`photorec` is an incredible tool by [CGSecurity](https://www.cgsecurity.org/wiki/PhotoRec), which runs in terminal curses, and is fairly self explanatory. The `testdisk` suite is also able to perform file system checks and repairs, however I have not yet explored it enough to document its usage. Once I am more familiar with the tool, I will endeavour to include notes. 

- outdated, but still useful in certain circles, `scalpel`

### Formating <a name="toc-sub-tag-24"></a>
From [devconnected](https://devconnected.com/how-to-format-disk-partitions-on-linux/), you can format a partition/disk with a specific journal using
```bash
sudo mkfs -t [journal] /dev/sda1
```
Linux commonly uses `ext4`, apple has `adfs`, and windows `fat32`/`vfat`, `ntfs` or `msdos`. **NB:** is some cases, mostly windows, the journal must be written in all caps.

To format a drive to Linux `ext4`, we can use `fdisk` to create a partition of type `83` (Linux), and then run
```
sudo mkfs.ext4 /dev/sd[...]
```
on the intended partition. Note, this can also be used on the whole disk `/dev/sd*`.

### Automount with `/etc/fstab` <a name="toc-sub-tag-25"></a>
Following [this guide](https://www.techrepublic.com/article/how-to-properly-automount-a-drive-in-ubuntu-linux/), we can configure a drive to automount by adding it to `/etc/fstab`. For this, we require the UUID of the device, which we can obtain with
```bash
sudo blkid
```
Change the ownership of the desired mount directory to the user's group, and then add
```
UUID=[your uuid]    /mnt/point    [format/auto]  nosuid,nodev,nofail 0   0
```
to `fstab`. A few comments
> `nosuid` - specifies that the filesystem cannot contain set userid files. This prevents root escalation and other security issues.

> `nodev` - specifies that the filesystem cannot contain special devices (to prevent access to random device hardware).

You can test the mount point configuration is okay with
```bash
sudo mount -a
```
See [here](https://linoxide.com/file-system/example-linux-nfs-mount-entry-in-fstab-etcfstab/) for a network mount example.

### Burning CDs and DVDs <a name="toc-sub-tag-26"></a>
An overview of Debian r/w CDs and DVDs can be found [here](https://wiki.debian.org/CDDVD).

- CDs

For this, it is easy to use `wodim` in [Disk-At-Once mode](https://en.wikipedia.org/wiki/Optical_disc_recording_modes). The command template is
```bash
wodim -v dev=/dev/rs0 -dao /path/to/my.iso
```

- DVDs

The standard disk formatting is [`ISO9660`](https://wiki.osdev.org/ISO_9660) for `.iso` files.

Following from the [Debian wiki](https://wiki.debian.org/BurnCd), the easiest (and probably best way) to burn disks with Debian is to use a tool like `growisofs`. A recipe for **burning dvds** is then
```bash
growisofs -dvd-compat -speed=8 -Z /dev/sr0=my.iso
```
You can also mount the disk into the file system with
```bash
sudo mount /dev/sr0 /mnt/cdrom
```
though personally I have encountered many errors in doing so (you're best of ripping the cd/dvd with `dd`). The above mount command may also require `-t iso9660` to specify the format.

There is a short discussion in [this arch linux forum](https://bbs.archlinux.org/viewtopic.php?id=131299) on mounting disks.


### Mounting a filesystem with SSH <a name="toc-sub-tag-27"></a>
For ease of development on a remote platform, tools like `sshfs` can mount directories on the local file-system as if they were a disk. On **OSX**, you'll require `osxfuse` for Linux filesystems also. Both tools can easily be installed with brew:

```bash
brew install osxfuse

brew install sshfs
```

Make a mount point and mount with
```bash
sshfs -o allow_other,default_permissions [USER]@[ADDRESS]:/ /path/to/mnt
```

and unmount with
```bash
umount /path/to/mnt
```
or, on OSX,
```bash
diskutil unmountDisk /path/to/mnt
```

## Installing Docker on Debian <a name="toc-sub-tag-28"></a>
Following from the [official install scripts](https://docs.docker.com/engine/install/debian/):
```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```
Add the GPG key
```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
```
at tme of writing this keys is `9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88` which can be verified with
```bash
sudo apt-key fingerprint 0EBFCD88
```
Depending on your architecture, this command may change, but for my use case (amd64) I run
```bash
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
```

We can now install the docker engine by updating the package index and fetching the requirements
```bash
sudo apt-get update
```
followed by
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
Verify the installation with
```bash
sudo docker run hello-world
```

### docker-compose <a name="toc-sub-tag-29"></a>
Following this guide:

We first get the stable release
```bash
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```
and then adjust permissions
```bash
sudo chmod +x /usr/local/bin/docker-compose
```
and finally link into the path
```bash
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

## Package management <a name="toc-sub-tag-30"></a>
With `dpkg`, you can install with
```bash
dpkg -i [package].deb
```
list installations with
```bash
dpkg -l | grep [package_name]
```

Uninstall
```bash
dpkg -r [package_name]
```
and purge with `-P` instead of `-r`. Purge will also delete all configuration files.

## Python installations <a name="toc-sub-tag-31"></a>
Following from [this guide](https://linuxize.com/post/how-to-install-python-3-8-on-debian-10/).

First, we grab the dependencies
```bash
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev
```
then we grab the tar (use the latest version found [here](https://www.python.org/downloads/source/))
```bash
curl -O https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tar.xz
```
extract
```bash
tar -xf Python-3.8.5.tar.xz && cd Python-3.8.5
```
configure the installation
```bash
./configure --enable-optimizations
```
and install with
```bash
make -j $(nproc)
```

To install the binaries into their respective location, use
```bash
sudo make altinstall
```
and validate with
```bash
python3.8 --version
```

## Path alternatives <a name="toc-sub-tag-32"></a>
You can adjust the priority of conflicting program versions, commonly [python3 vs python2](https://exitcode0.net/changing-the-default-python-version-in-debian/) using the `update-alternatives` command. The program linked with the highest priority will become the default
```bash
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 2

update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
```
You can check the configuration with
```bash
update-alternatives --config python
```

## Versions <a name="toc-sub-tag-33"></a>
All sorts of valuable version information can be obtained with different commands, most of which are listed on [linuxconfig](https://linuxconfig.org/check-what-debian-version-you-are-running-on-your-linux-system).

### Debian <a name="toc-sub-tag-34"></a>
```bash
lsb_release -cs
# buster
```

```bash
cat /etc/issue
# Debian GNU/Linux 10 \n \l
```

```bash
cat /etc/os-release
# PRETTY_NAME="Debian GNU/Linux 10 (buster)"
# NAME="Debian GNU/Linux"
# VERSION_ID="10"
# VERSION="10 (buster)"
# VERSION_CODENAME=buster
# ID=debian
# HOME_URL="https://www.debian.org/"
# SUPPORT_URL="https://www.debian.org/support"
# BUG_REPORT_URL="https://bugs.debian.org/"
```
