# Software installation

Guides to installing various softwares on different operating systems.

<!--BEGIN TOC-->
## Table of Contents
1. [Installing operating systems](#installing-operating-systems)
    1. [Installing without ethernet](#installing-without-ethernet)
2. [Debian](#debian)
    1. [`sudo`](#sudo)
    2. [Docker](#docker)
    3. [Docker-compose](#docker-compose)
    4. [VSCode](#vscode)
    5. [Python](#python)
    6. [OpenJDK](#openjdk)

<!--END TOC-->

## Installing operating systems

### Installing without ethernet

When installing a \*nix system without an ethernet connection, it can be generally quite difficult to ensure the right drivers are at hand for the wifi hardware. Sometimes using just the non-free firmware versions of e.g. Debian can be enough to allow the system to enable the hardware, but at other times, you'll have to install the firmware through `apt`, which won't be available without an internet connection.

The solution to this is, if you own an android phone, use **USB tethering** to add a network interface so you can complete the installation and find the necessary firmware.


## Debian

### `sudo`
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

### Docker
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

### Docker-compose
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

### VSCode
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

### Python
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

### OpenJDK
On the differences between the JRE and JDK, see [this SO answer](https://stackoverflow.com/a/1906642).

Download the latest ready-for-use JDK from [jdk.java.net](https://jdk.java.net/), and un-archive with
```bash
tar xzf openjdk-16.0.1_linux-x64_bin.tar.gz
```

The JVM is usually installed into `/usr/lib/jvm`, and installing java through `apt` will install it to this location. We'll also move the directory to this location and change the ownership
```bash
sudo mv jdk-16.0.1 /usr/lib/jvm/ && sudo chown root:root -R /usr/lib/jvm/jdk-16.0.1
```

Finally, we configure the paths for the user: in an environment startup file, include
```bash
# .zshenv

# append java bin to path
PATH="$PATH:/usr/lib/jvm/jdk-16.0.1/bin"
# set JAVA_HOME if not set
JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/jdk-16.0.1}"
```