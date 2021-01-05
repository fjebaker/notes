# Notes on Boots, Boot Loaders and BIOS control
Loose collection of notes and predominantly case studies for solutions to problems that develop before the operating system starts.

## Creating a Windows bootable USB drive
The Windows ISOs can be downloaded from the [Microsoft homepage](https://www.microsoft.com/en-us/software-download/windows10ISO), and are language specific. The ISOs are just under 6 GB, with seemingly no net-install or lighter ISO available.

### Using `dd`
Unmount the drive you wish to make bootable, e.g. a USB stick under `/dev/sdd`
```bash
sudo umount /dev/sdd
```
and format the drive as either FAT or NTFS. On linux distros, this can be done with the `mkfs` tool
```bash
sudo mkfs.vfat -I /dev/sdd
```
where the `-I` flag is to mitigate some errors with fixed disk devices.

Now we can copy our ISO onto the device
```bash
sudo dd if=path/to/windows.iso of=/dev/sdd bs=1M conv=sync status=progress
```
we throw in `conv=sync` for padding to ibs-size, and on newer versions of GNU `dd` (`gdd`) the `status=progress` will print how much data has been written to the device.

A few things to note:

- as is stated in the [UEFI Wikipedia article](https://en.wikipedia.org/wiki/UEFI#Disk_device_compatibility)

> The UEFI specification explicitly requires support for FAT32 for system partitions, and FAT12/FAT16 for removable media; specific implementations may support other file systems.

It is up to the manufacturer of the motherboard to include specific NTFS boot support. So far, in my own cases, I have been pretty lucky, however if you are unable to boot, this may be why.

- FAT32 formatting supports a **maximum individual file size of 4GB**, thus Win10 ISOs may not fit in FAT32.

If your UEFI is preventing NTFS boot, you may require a crossover tool for UEFI-NTFS.

- tools such as [Rufus](http://rufus.akeo.ie/) allow for UEFI boots from NTFS, however this is something I am personally yet to try.

### Graphically
There are tools such as [`gparted`](https://gparted.org/), or [`woeusb`](https://askubuntu.com/a/1129184) which can automate some of this process.

But there is a tried and tested method which works using default GNOME linux tools. Open `Disks`, and select the drive you want to make bootable.

Unmount and format the partition for Windows (commonly NTFS), and remount the drive.

Open Nautilus (File Explorer), right click on your ISO and select `Open With Disk Image Mounter`, which will create a mounted volume on your file system with the contents of the ISO. From here, copy in the conventional sense (either drag and drop or using `cp`, etc.) the files from the ISO mount to the device mount.

This *may* be able to mitigate FAT32 restrictions, but I am unsure as I have not personally tested this.

## Booting/Installing with UEFI
Provided you are able to boot from an ISO loaded on your device, the next step is to install the operating system.

There are now some issues that may arrise relating to the destination drive's partition table.

The format of prexisting partitions doesn't matter, as most installers will provide reformatting and partitioning tools. However, the drive's partition scheme label does make a difference.

If you are using BIOS *Legacy Mode*, Master Boot Record (MBR) and GUID Partition Table (GPT) partitions schemes are supported, however UEFI can only install on GPT.

The easiest way to check and change your partition label is with `fdisk` and `parted` (`sudo apt-get install parted`). We can view our drives with
```bash
sudo fdisk -l
```
and will see something like
```
Disk /dev/sdb: 465.8 GiB, 500107862016 bytes, 976773168 sectors
Disk model: ST3500418AS     
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 0495045D-8196-419B-B4F5-5EDF681E3D27
```

Here, we see in the second to last line the `Disklabel type` is GPT. If this were something else, e.g. MS-DOS, we would need to use `parted` to update the label.

**NB:** changing the label *is a very easy way* to "lose" all your data on the disk. Backup first.

```bash
sudo parted /dev/sdb mklabel gpt
```

Changing the label *will also* clear the partition table.

## Updating GRUB

In the [GRUB documentation](https://www.gnu.org/software/grub/manual/grub/) are listed a few ways to edit the GRUB settings manually, including by editing the `grub.d` configuration files.

Another method, slightly more automated, is to mount the partitions containing the alternative OS on your linux host, somewhere on `/`, and then use
```bash
sudo os-prober
```
to see if the OS is detected.

Then use
```bash
sudo update-grub
```
in order to add the detected OSs into the GRUB menu.

Note that the EFI boot may not be on the same partition as the OS itself, which I, at first, found a little perplexing.