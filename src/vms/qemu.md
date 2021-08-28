# QEMU

<!--BEGIN TOC-->
## Table of Contents
1. [Useful flags](#useful-flags)
2. [Creating snapshots from a fresh `.iso`](#creating-snapshots-from-a-fresh--iso)
3. [Drive formats](#drive-formats)
<!--END TOC-->

## Useful flags

- `-nic none` to disable networking
- `-accel [type]`: use either `hvf` (OSX) or `kvm` (Linux). Note that KVM requires its own setup, see {doc}`./kvm`.


## Creating snapshots from a fresh `.iso`
To create a persistent VM, we first need to create a virtual hard drive to install the OS on. There are many formats available, including QEMU's *create on write* (`qcow`), which grows dynamically as data is written to the disk.

Create a drive to install the operating system on, in this case, a 64 GB `qcow2` image:
```bash
qemu-img create -f qcow2 base-disk.img.qcow2 64G
```

Install the operating system by running QEMU with the disk mounted: for example
```bash
qemu-system-x86_64 \
    -cdrom os.iso \
    -drive "file=base-disk.img.qcow2,format=qcow2" \
    -m 2G \
    -smp 4
```

Snapshots are then incrementally created to reduce space. Snapshots are created from a base disk, and are used in conjunction with the base disk, meaning file paths (and names) must be preserved in order for the snapshot hierarchy to be resolved. If the name of the base disk is changed, or its location altered, the snapshot will be incomplete and cannot be used.

A snapshot is created with
```bash
qemu-img create \
    -F qcow2 -b base-disk.img.qcow2 \
    -f qcow2 snapshot_01.snapshot.qcow2
```
Note that `-F` is the format of the base, and `-f` is the format of the output.

## Drive formats
For an extensive list, [see this wiki entry](https://computernewb.com/wiki/How_to_create_a_disk_image_in_QEMU#File_formats).

Particularly notable are
- `qcow2`, QEMU's *create on write* dynamic filesystem, with some speed and memory overhead
- `raw`, directly reserve memory on disk; consequently the fastest options
- `vdi`, Oracle VirtualBox compatible format
