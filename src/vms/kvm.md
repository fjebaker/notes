# Kernel-based Virtual Machine

[Kernel-based Virtual Machine (KVM)](http://linux-kvm.org/) is open source software that allows the Linux kernel to act as a virtual machine hypervisor -- in other words, it allows the kernel to emulate other *guest* machines, itself acting as the *host* machine.

KVM provides full virtualisation at near native performance on a given architecture, but is only supported by certain processor types which allow for virtualistion extensions (Intel VT or AMD-V).

<!--BEGIN TOC-->
## Table of Contents
1. [KVM details](#kvm-details)
    1. [Intel VT](#intel-vt)
    2. [AMD-V](#amd-v)
2. [Installing KVM](#installing-kvm)
3. [Using KVM](#using-kvm)
4. [Other applications](#other-applications)
    1. [](#)
    2. [Android Virtual Device](#android-virtual-device)

<!--END TOC-->

## KVM details
The KVM provides a kernel module `kvm.ko` for the virtualisation infrastructure, and a different kernel module `kvm-intel.ko` (*vmx*, virtual machine extensions) or `kvm-amd.ko` (*svm*, secure virtual machine) specific to the processor.

Once your have enabled BIOS virtualisation extensions, either Intel VT or AMD-V, you should be able to check your processor's flags to see if your machine is able to run KVM
```bash
cat /proc/cpuinfo | grep --color -E "(vmx|svm)"
```

The userspace of KVM is [QEMU](https://www.qemu.org/), which leverages `libkvm` to `/dev/kvm` through an `ioctl` interface.

### Intel VT
An overview of Intel Virtualisation Technology (VT) can be found on the [Intel Website](https://www.intel.com/content/www/us/en/virtualization/virtualization-technology/intel-virtualization-technology.html). At it's most basic, it provides a suite of tools for allowing multiple systems to run on the same hardware, with minimal overhead. The VT is enacted through both hardware and software, and at its minimum covers
- CPU abstraction to virtual machines, with zero overhead
- memory abstraction, allowing isolation and host monitoring per virtual machine 
- I/O virtualisation, from networks to physical devices
- GPU abstraction, allowing virtual machines to have full or shared access to GPUs

Most of the advanced features are targeted at enterprise use of servers, where multiple, potentially very different machines, are running on the same server. An application of this could be, for example, a remote desktop cluster.

At the machine level, the Intel VT introduces 10 new virtualisation CPU instructions. Recent processors also benefit from Extended Page Tables, which allows each virtual machine to keep track of its own memory address table (before address translation would have to be performed).

The Intel VT can be thought of as providing a BIOS to each virtual machine.

### AMD-V
This section I will fill in if I ever find the time or need.

## Installing KVM
```bash
sudo apt install qemu-kvm bridge-utils 
```
`bridge-utils` installs tools for creating and managing ethernet and network bridges.


## Using KVM

## Other applications

###

### Android Virtual Device
