# \*nix system administration cookbook

Recipes and writeups of solutions from problems on different \*nix operating systems.

<!--BEGIN TOC-->
## Table of Contents
1. [General tricks and tips](#general-tricks-and-tips)
    1. [Installing without ethernet](#installing-without-ethernet)
2. [Users and groups](#users-and-groups)
    1. [Shells](#shells)
    2. [`bindkey`](#bindkey)
3. [Debian network configuration](#debian-network-configuration)
    1. [Controlling interfaces](#controlling-interfaces)
    2. [Configuring interfaces](#configuring-interfaces)
        1. [DHCP](#dhcp)
        2. [Static IP](#static-ip)
    3. [Debugging networks](#debugging-networks)
    4. [Proxies](#proxies)
4. [SSH Overview](#ssh-overview)
5. [Installing `sudo`](#installing-sudo)
6. [System introspection](#system-introspection)
7. [Hardware](#hardware)
    1. [Graphics cards](#graphics-cards)
    2. [Sound cards](#sound-cards)
8. [Useful commands](#useful-commands)
    1. [`STOP` and `CONT` a process](#stop-and-cont-a-process)
    2. [SSL with `curl`](#ssl-with-curl)
    3. [`curl` proxies](#curl-proxies)
9. [Installing Docker on Debian](#installing-docker-on-debian)
    1. [docker-compose](#docker-compose)
10. [Package management](#package-management)
11. [Python installations](#python-installations)
12. [Path alternatives](#path-alternatives)
13. [Versions](#versions)
    1. [Debian](#debian)
14. [Installing VSCode on Debian](#installing-vscode-on-debian)
15. [Modifying keymaps with `xmodmap`](#modifying-keymaps-with-xmodmap)
16. [Other:](#other)

<!--END TOC-->

## General tricks and tips
Here are some general ideas that I think are vitally important to remember when handling \*nix systems.

### Installing without ethernet
When installing a \*nix system without an ethernet connection, it can be generally quite difficult to ensure the right drivers are at hand for the wifi hardware. Sometimes using just the non-free firmware versions of e.g. Debian can be enough to allow the system to enable the hardware, but at other times, you'll have to install the firmware through `apt`, which won't be available without an internet connection.

The solution to this is, if you own an android phone, use **USB tethering** to add a network interface so you can complete the installation and find the necessary firmware.

## Users and groups
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

### Shells
You can discover what shell your terminal is currently running by examining the `$SHELL` environment variable.

To see the available shells on your machine, use
```bash
cat /etc/shells
```

You can then change the default shell using
```bash
chsh
```
ran as the user you wish to change the shell for, or, alternatively
```bash
sudo chsh -s /bin/zsh someUser
```
to change the shell of `someUser` to `zsh`.

### `bindkey`
Bindkey controls how keyboard shortcuts on the terminal are mapped. This can be set in the relevant shell `~/.*rc` file. Common mappings are
```bash
bindkey -v
```
for vi-like map, and
```bash
bindkey -e
```
for emacs mapping.

**NB**: new and alternative shells may be installed via the relevant package managers.

## Debian network configuration
Whilst installing Debian 9 on an old machine, which had a faulty NIC, I learned a few things about network configurations on that specific OS, most of which is documented [in the manual](https://www.debian.org/doc/manuals/debian-reference/ch05.en.html).

The legacy `ifconfig` is being replaced with the newer `ip` suite, and an overview of the translation can be quickly seen in this post by [ComputingForGeeks](https://computingforgeeks.com/ifconfig-vs-ip-usage-guide-on-linux/). Two very useful commands I use a lot for debugging are
```bash
ip a 	# output similar to the standard ifconfig

ip -s link show [interface]	# outputs interface statistics
```


### Controlling interfaces
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


### Configuring interfaces
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

#### DHCP
For a DHCP interface, we can use a simple configuration such as
```
auto eth0
iface eth0 inet dhcp
```

#### Static IP
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

### Debugging networks
See [this guide on port overviews](https://linuxize.com/post/check-listening-ports-linux/).

### Proxies

To configure proxies for the currently running shell, simply define the environment variables
```bash
export http_proxy=""
export https_proxy=""
```
These are read by most common command line programs, such as `curl`, or `wget`.

*NB:* other environment variables include `ftp_proxy`, `socks_proxy`, or `all_proxy`. The format for the url is
```
protocol://user:password@host:port
```

## SSH Overview
Useful commands are

Copy login key to remote:

```bash
ssh-copy-id user@host
```
Remove host key from chain:
```bash
ssh-keygen -R host
```

## Installing `sudo`
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

## System introspection

Useful tools
- `neofetch` for graphical system overview

The default tool for printing system information is `uname`. The most common use is probably for printing the machine hardware name (similar to `arch`)
```bash
uname -m
# x86_64
```
Another flag to remember is `-a`, which prints all information.

## Hardware
Listing all of the PCI devices can be achieved with
```bash
lspci
```
You may need to update the PCI database
```bash
update-pciids
```

On [HowToGeek](https://www.howtogeek.com/508993/how-to-check-which-gpu-is-installed-on-linux/) is a Ubuntu overview for listing hardware.

### Graphics cards
For graphics cards on Debian, I have created [separate notes](https://github.com/Dustpancake/Dust-Notes/blob/master/nix-systems/debian-gpu.md).

### Sound cards
For sound cards on Debian, I have created [separate notes](https://github.com/Dustpancake/Dust-Notes/blob/master/nix-systems/debian-soundcards.md)

## Useful commands
In this section I will document useful commands, which, for brevity, don't merit a full chapter of their own.

### `STOP` and `CONT` a process
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

### SSL with `curl`
https://stackoverflow.com/questions/10079707/https-connection-using-curl-from-command-line

### `curl` proxies
You can either set the environment variables
```
export http_proxy="http://uname:pw@addr:port"
export https_proxy="https://uname:pw@addr:port"
```
which `curl` automatically uses, or, pass in the flag `-x http://uname:pw@addr:port`.

## Installing Docker on Debian
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

### docker-compose
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

## Package management
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

## Python installations
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

## Path alternatives
You can adjust the priority of conflicting program versions, commonly [python3 vs python2](https://exitcode0.net/changing-the-default-python-version-in-debian/) using the `update-alternatives` command. The program linked with the highest priority will become the default
```bash
update-alternatives --install /usr/bin/python python /usr/bin/python3.8 2

update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1
```
You can check the configuration with
```bash
update-alternatives --config python
```

## Versions
All sorts of valuable version information can be obtained with different commands, most of which are listed on [linuxconfig](https://linuxconfig.org/check-what-debian-version-you-are-running-on-your-linux-system).

### Debian
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

## Installing VSCode on Debian
From a [Linuxize](https://linuxize.com/post/how-to-install-visual-studio-code-on-debian-10/) tutorial:

Provided you have already
```bash
sudo apt install software-properties-common apt-transport-https curl
```
we add the Microsoft GPG keys
```bash
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
```
and the relevant repository
```bash
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
```

We can now update the index and install VSCode
```bash
sudo apt update && sudo apt install code
```

## Modifying keymaps with `xmodmap`
I don't like specific default [dead keys](https://en.wikipedia.org/wiki/Dead_key), such as the backtick symbol. To modify the behaviour of keys, we use `xmodmap`.

For my case, first identify the keycode using
```bash
xmodmap -pke | grep grave
```
and look for the output like 
```
keycode  21 = dead_circumflex dead_grave equal plus dead_tilde dead_ogonek dead_cedilla dead_ogonek
```
This will commonly be 21 or 49, depending on the nationality of your Keyboard.

We then copy the line, remove the `dead_` prefix from `grave`, and configure the mapping with 
```bash
xmodmap -e 'keycode  21 = dead_circumflex grave equal plus dead_tilde dead_ogonek dead_cedilla dead_ogonek'
``` 

To make this change permanent, we create a `~/.Xmodmap` dotfile with our modifications. Alternatively, to save an entire configuration, use
```bash
xmodmap -pke >> ~/.Xmodmap
```

We load the changes with
```bash
xmodmap ~/.Xmodmap
```

or to ensure the changes are ran when the X server inits, use
```bash
echo 'xmodmap ~/.Xmodmap' >> ~/.xinitrc
```

To undo a keyboard mapping, use
```bash
setxkbmap -option
```


## Other:
CPU temperature:
```
/sys/class/thermal/thermal_zone0/temp
```
