\*nix system administration cookbook
====================================

Recipes and writeups of solutions from problems on different \*nix operating systems.

<!--BEGIN TOC-->
## Table of Contents
1. [Users and groups](#toc-sub-tag-0)
2. [Debian network configuration](#toc-sub-tag-1)
	1. [Controlling interfaces](#toc-sub-tag-2)
	2. [Configuring interfaces](#toc-sub-tag-3)
		1. [DHCP](#toc-sub-tag-4)
		2. [Static IP](#toc-sub-tag-5)
3. [Installing `sudo`](#toc-sub-tag-6)
4. [Sound Configuration](#toc-sub-tag-7)
	1. [ALSA](#toc-sub-tag-8)
		1. [CMUS with ALSA](#toc-sub-tag-9)
	2. [Hardware specifications](#toc-sub-tag-10)
<!--END TOC-->

## Users and groups <a name="toc-sub-tag-0"></a>
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

## Debian network configuration <a name="toc-sub-tag-1"></a>
Whilst installing Debian 9 on an old machine, which had a faulty NIC, I learned a few things about network configurations on that specific OS, most of which is documented [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html).

The legacy `ifconfig` is being replaced with the newer `ip` suite, and an overview of the translation can be quickly seen in this post by [ComputingForGeeks](https://computingforgeeks.com/ifconfig-vs-ip-usage-guide-on-linux/). Two very useful commands I use a lot for debugging are
```bash
ip a 	# output similar to the standard ifconfig

ip -s link show [interface]	# outputs interface statistics
```


### Controlling interfaces <a name="toc-sub-tag-2"></a>
Toggling specific interface states can be done using either `ip`
```bash
ip link set [interface] up
```
or `ifup`/`ifdown`
```bash
ifup [interface]
ifdown [interface]
```

The whole network interface may be interacted with using the `init.d` service
```bash
sudo /etc/init.d/networking [start, stop, restart, status]
```
or with `systemd` using
```bash
sudo systemctl [start, stop, restart, status] networking
```


### Configuring interfaces <a name="toc-sub-tag-3"></a>
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

#### DHCP <a name="toc-sub-tag-4"></a>
For a DHCP interface, we can use a simple configuration such as
```
auto eth0
iface eth0 inet dhcp
```

#### Static IP <a name="toc-sub-tag-5"></a>
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


## Installing `sudo` <a name="toc-sub-tag-6"></a>
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

## Sound Configuration <a name="toc-sub-tag-7"></a>
Especially on headless installations of \*nix, some sound device configuration is required.

**NB:** In most cases, the user wont succeed in configuring the sound unless they are also part of the `audio` group.

### ALSA <a name="toc-sub-tag-8"></a>
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

#### CMUS with ALSA <a name="toc-sub-tag-9"></a>
To get CMUS to use ALSA, we edit the `~/.cmus/Autosave` file and change the configuration to
```
dsp.alsa.device=default
mixer.alsa.device=default
mixer.alsa.channel=PCM
output_plugin=alsa
```

### Hardware specifications <a name="toc-sub-tag-10"></a>
As stated in the [Debian wiki](https://wiki.debian.org/ALSA#Troubleshooting), the assigned indexes to sound cards can be found with
```bash
cat /proc/asound/cards
```

To see the hardware device names, you can also use
```bash
lspci -nn |grep -i audio
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