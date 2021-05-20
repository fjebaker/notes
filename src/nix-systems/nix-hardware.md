# Hardware

<!--BEGIN TOC-->
## Table of Contents
1. [Graphics card installation](#graphics-card-installation)
    1. [PCI wattage](#pci-wattage)
    2. [nVidia](#nvidia)
2. [CUDA and cuDNN](#cuda-and-cudnn)
    1. [Troubleshooting](#troubleshooting)
3. [Sound Configuration](#sound-configuration)
    1. [ALSA](#alsa)
        1. [ALSA auto-configuration](#alsa-auto-configuration)
        2. [CMUS with ALSA](#cmus-with-alsa)
    2. [Hardware specifications](#hardware-specifications)
<!--END TOC-->


## Graphics card installation
The official [Debian wiki](https://wiki.debian.org/GraphicsCard) has a great overview of graphic driver installations depending on the hardware you are using.

### PCI wattage
The power ratings of graphics cards is discussed in detail on [the graphics card hub](https://graphicscardhub.com/graphics-card-pcie-power-connectors/). In brief

- PCI provides 75 watts
- 8-pin connector 150 watts 
- 6-pin connector 75 watts

### nVidia
List of compatible hardware is [here](http://us.download.nvidia.com/XFree86/Linux-x86_64/440.100/README/supportedchips.html).
The [nVidia installation](https://wiki.debian.org/NvidiaGraphicsDrivers#CUDA) follows the following process:

Identify hardware:
```bash
lspci -nn | egrep -i "3d|display|vga"
```

Fetch the Kernel headers (amd64):
```bash
sudo apt install linux-headers-amd64
```

The process varies depending on which Debian version you are using. Since I am using Debian 10.5 Buster, I will first add the buster-backports to my `apt` sources:

In `/etc/apt/sources.list` we add
```bash
# buster-backports
deb http://deb.debian.org/debian buster-backports main contrib non-free
```

we then install the packages with 
```bash
sudo apt update && sudo apt install -t buster-backports nvidia-driver
```
This performs upstream device detection to fetch the correct driver for your card. Finally, **reboot your system**to complete the installation.

## CUDA and cuDNN
Installing CUDA is directed in the [wiki](https://wiki.debian.org/NvidiaGraphicsDrivers#CUDA). In short, we can install CUDA 10 with backports
```bash
sudo apt -t buster-backports install nvidia-cuda-dev nvidia-cuda-toolkit
```
which will install `nvcc` for `gcc >5.3.1`.

For cuDNN, we need to create a development account on the [nVidia website](https://developer.nvidia.com/rdp/cudnn-archive)

The full installation process is documented [on the nVidia site](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#overview).


### Troubleshooting
When installing the `nvidia-driver`, I encountered this issue
```bash
sudo apt install -t buster-backports nvidia-driver
```
which outputted
```
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Some packages could not be installed. This may mean that you have
requested an impossible situation or if you are using the unstable
distribution that some required packages have not yet been created
or been moved out of Incoming.
The following information may help to resolve the situation:

The following packages have unmet dependencies:
 nvidia-driver : Depends: nvidia-kernel-dkms (= 440.100-1~bpo10+1) but it is not going to be installed or
                          nvidia-kernel-440.100
                 Recommends: nvidia-persistenced but it is not installable
E: Unable to correct problems, you have held broken packages.
```
My fix was to ensure consistency in the `/etc/apt/sources.list`; e.g.
```
deb http://ftp.ch.debian.org/debian/ buster main contrib non-free
deb http://ftp.ch.debian.org/debian/ buster-backports main contrib non-free
```
I have `buster` and `buster-backports` both configured as `main` and `non-free`.


## Sound Configuration
Especially on headless installations of \*nix, some sound device configuration is required.

**NB:** In most cases, the user wont succeed in configuring the sound unless they are also part of the `audio` group.

### ALSA
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

#### ALSA auto-configuration
If the above did not work, or if you altered your sound hardware, a quick-fix for a lot of ALSA related issues is to run the init command:
```bash
sudo alsactl init
```
From the manual:
> init  tries to initialize all devices to a default state. If device is not known, error code 99 is returned.


#### CMUS with ALSA
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


### Hardware specifications
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