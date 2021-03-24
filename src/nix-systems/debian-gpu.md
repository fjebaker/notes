# Using GPUs on Debian
Overview of graphics and shader development on Debian.

<!--BEGIN TOC-->
## Table of Contents
1. [Graphics card installation](#toc-sub-tag-0)
	1. [PCI wattage](#toc-sub-tag-1)
	2. [nVidia](#toc-sub-tag-2)
2. [CUDA and cuDNN](#toc-sub-tag-3)
3. [Troubleshooting](#toc-sub-tag-4)
<!--END TOC-->

## Graphics card installation <a name="toc-sub-tag-0"></a>
The official [Debian wiki](https://wiki.debian.org/GraphicsCard) has a great overview of graphic driver installations depending on the hardware you are using.

### PCI wattage <a name="toc-sub-tag-1"></a>
The power ratings of graphics cards is discussed in detail on [the graphics card hub](https://graphicscardhub.com/graphics-card-pcie-power-connectors/). In brief

- PCI provides 75 watts
- 8-pin connector 150 watts 
- 6-pin connector 75 watts

### nVidia <a name="toc-sub-tag-2"></a>
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

## CUDA and cuDNN <a name="toc-sub-tag-3"></a>
Installing CUDA is directed in the [wiki](https://wiki.debian.org/NvidiaGraphicsDrivers#CUDA). In short, we can install CUDA 10 with backports
```bash
sudo apt -t buster-backports install nvidia-cuda-dev nvidia-cuda-toolkit
```
which will install `nvcc` for `gcc >5.3.1`.

For cuDNN, we need to create a development account on the [nVidia website](https://developer.nvidia.com/rdp/cudnn-archive)

The full installation process is documented [on the nVidia site](https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#overview).


## Troubleshooting <a name="toc-sub-tag-4"></a>
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
