# Kernel-based Virtual Machine

[Kernel-based Virtual Machine (KVM)](http://linux-kvm.org/) is open source software that allows the Linux kernel to act as a virtual machine hypervisor -- in other words, it allows the kernel to emulate other *guest* machines, itself acting as the *host* machine.

KVM provides full virtualisation at near native performance on a given architecture, but is only supported by certain processor types which allow for virtualistion extensions (Intel VT or AMD-V).

<!--BEGIN TOC-->
## Table of Contents
1. [KVM details](#kvm-details)

<!--END TOC-->

## KVM details
The KVM provides a kernel module `kvm.ko` for the virtualisation infrastructure, and a different kernel module `kvm-intel.ko` (*vmx*, virtual machine extensions) or `kvm-amd.ko` (*svm*, secure virtual machine) specific to the processor.

The userspace of KVM is [QEMU](https://www.qemu.org/), which leverages `libkvm` to `/dev/kvm` through an `ioctl` interface.
