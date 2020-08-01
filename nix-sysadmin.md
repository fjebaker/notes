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