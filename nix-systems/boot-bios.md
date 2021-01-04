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




