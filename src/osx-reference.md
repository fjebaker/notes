
# OSX Reference

Notes, recipes, and useful snippets relating to all things OSX.

<!--BEGIN TOC-->
## Table of Contents
1. [Mounting Linux filesystems](#mounting-linux-filesystems)
2. [Changing hostnames:](#changing-hostnames)

<!--END TOC-->

## Mounting Linux filesystems
[MacFUSE](https://osxfuse.github.io/), previously OSXFUSE, provides third party support for linux file systems. 

To mount an ext4 filesystems on mac, we first install
```bash
brew install macfuse ext4fuse
```

Installing `ext4fuse` may be disabled, as per [this SO answer](https://stackoverflow.com/a/68091613). The solution is to edit the formula location
```bash
brew formula ext4fuse
```
and comment out the lines
```
  # on_macos do                                                                 
  #   disable! date: "2021-04-08", because: "requires FUSE"                     
  # end
```

*NB:* for ext2, or other, search in brew for the FUSE support.

We can then mount the drive with
```bash
sudo ext4fuse -o allow_other /dev/disk2s2 /path/to/mnt
```

The drive may be unmounted again with
```bash
diskutil unmountDisk /dev/disk2
```
or 
```bash
sudo umount /path/to/mnt
```

## Changing hostnames:
Use `scutil`, a program from managing system configuration parameters.

To change primary hostname
```bash
sudo scutil --set HostName [hostname]
```
Bonjour hostname:
```bash
sudo scutil --set LocalHostName [hostname]
```
Computer name
```bash
sudo scutil --set ComputerName [hostname]
```

Then flush the DNS cache with
```bash
dscacheutil -flushcache
```

and reboot.