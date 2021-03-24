# The Linux Disk and Filesystem

<!--BEGIN TOC-->
## Table of Contents
1. [Disks and mounting](#toc-sub-tag-0)
	1. [Listing disks](#toc-sub-tag-1)
	2. [File system checks](#toc-sub-tag-2)
	3. [Recovering files](#toc-sub-tag-3)
	4. [Formatting](#toc-sub-tag-4)
	5. [Automount with `/etc/fstab`](#toc-sub-tag-5)
	6. [Burning CDs and DVDs](#toc-sub-tag-6)
	7. [Mounting a filesystem with SSH](#toc-sub-tag-7)
	8. [Mounting HFS/HFS+ on Linux](#toc-sub-tag-8)
2. [`rsync`](#toc-sub-tag-9)
	1. [Merging file trees](#toc-sub-tag-10)
3. [On storing binaries](#toc-sub-tag-11)
4. [On `.desktop` files](#toc-sub-tag-12)
5. [On securely erasing disks](#toc-sub-tag-13)
<!--END TOC-->

## Disks and mounting <a name="toc-sub-tag-0"></a>
This section covers all things related to disks, disks drives, mounts, and anything else loosely `/dev/s*`.

### Listing disks <a name="toc-sub-tag-1"></a>
You can list the disks and block devices in a variety of ways depending on the information you are trying to ascertain:

- listing block devices
```bash
lsblk
```
will show the mount point and disk size. For non-formatted partitions
```bash
lsblk -f
```

- listing `/dev/sd*` partitions
```bash
sudo fdisk -l
```

- disk system space usage
```bash
df -h
```
The `-h` prints in human readable form.

- overview of all mounts and usage
```bash
findmnt [path]
```
You do not need to specify a path if you want to list all devices. This program is a repertoire for printing mount points and disk devices, and even has `--json` output. Another useful flag is `--df` for disk usage.

- general mount info
```bash
mount
```
Will tell you the disks mounted, and the options applied.

A full discussion can be seen in [this SO answer](https://askubuntu.com/questions/583909/how-do-i-check-where-devices-are-mounted).

To list the UUIDs and PTUUIDs, use
```bash
sudo blkid
```

### File system checks <a name="toc-sub-tag-2"></a>
Using [`fsck`](https://www.howtogeek.com/282374/what-is-the-lostfound-folder-on-linux-and-macos/).

`fsck` will run pretty much out-of-the-box, and can perform some (irreversible) file system repairs also.

Another good tool to use is `dumpe2fs` for printing filesystem information and rudimentary diagnostics. It is useful for obtaining block size information, when the drive was last used, when it was created, and so forth.

### Recovering files <a name="toc-sub-tag-3"></a>
There are multiple recovery tools available; two which I frequently use are:

- `testdisk`, which ships with `photorec`, is an open source tool for file system checks and file recovery.

`photorec` is an incredible tool by [CGSecurity](https://www.cgsecurity.org/wiki/PhotoRec), which runs in terminal curses, and is fairly self explanatory. The `testdisk` suite is also able to perform file system checks and repairs, however I have not yet explored it enough to document its usage. Once I am more familiar with the tool, I will endeavour to include notes.

- outdated, but still useful in certain circles, `scalpel`

### Formatting <a name="toc-sub-tag-4"></a>

From [devconnected](https://devconnected.com/how-to-format-disk-partitions-on-linux/), you can format a partition/disk with a specific journal using
```bash
sudo mkfs -t [journal] /dev/sda1
```
Linux commonly uses `ext4`, apple has `adfs`, and windows `fat32`/`vfat`, `ntfs` or `msdos`. **NB:** is some cases, mostly windows, the journal must be written in all caps.

To format a drive to Linux `ext4`, we can use `fdisk` to create a partition of type `83` (Linux), and then run
```
sudo mkfs.ext4 /dev/sd[...]
```
on the intended partition. Note, this can also be used on the whole disk `/dev/sd*`.

### Automount with `/etc/fstab` <a name="toc-sub-tag-5"></a>
Following [this guide](https://www.techrepublic.com/article/how-to-properly-automount-a-drive-in-ubuntu-linux/), we can configure a drive to automount by adding it to `/etc/fstab`. For this, we require the UUID of the device, which we can obtain with
```bash
sudo blkid
```
Change the ownership of the desired mount directory to the user's group, and then add
```
UUID=[your uuid]    /mnt/point    [format/auto]  nosuid,nodev,nofail 0   0
```
to `fstab`. A few comments
> `nosuid` - specifies that the filesystem cannot contain set userid files. This prevents root escalation and other security issues.

> `nodev` - specifies that the filesystem cannot contain special devices (to prevent access to random device hardware).

You can test the mount point configuration is okay with
```bash
sudo mount -a
```
See [here](https://linoxide.com/file-system/example-linux-nfs-mount-entry-in-fstab-etcfstab/) for a network mount example. See [here](https://help.ubuntu.com/community/Fstab) for the ubuntu documentation on `fstab`.

### Burning CDs and DVDs <a name="toc-sub-tag-6"></a>
An overview of Debian r/w CDs and DVDs can be found [here](https://wiki.debian.org/CDDVD).

- CDs

For this, it is easy to use `wodim` in [Disk-At-Once mode](https://en.wikipedia.org/wiki/Optical_disc_recording_modes). The command template is
```bash
wodim -v dev=/dev/rs0 -dao /path/to/my.iso
```

- DVDs

The standard disk formatting is [`ISO9660`](https://wiki.osdev.org/ISO_9660) for `.iso` files.

Following from the [Debian wiki](https://wiki.debian.org/BurnCd), the easiest (and probably best way) to burn disks with Debian is to use a tool like `growisofs`. A recipe for **burning dvds** is then
```bash
growisofs -dvd-compat -speed=8 -Z /dev/sr0=my.iso
```
You can also mount the disk into the file system with
```bash
sudo mount /dev/sr0 /mnt/cdrom
```
though personally I have encountered many errors in doing so (you're best of ripping the cd/dvd with `dd`). The above mount command may also require `-t iso9660` to specify the format.

There is a short discussion in [this arch linux forum](https://bbs.archlinux.org/viewtopic.php?id=131299) on mounting disks.


### Mounting a filesystem with SSH <a name="toc-sub-tag-7"></a>
For ease of development on a remote platform, tools like `sshfs` can mount directories on the local file-system as if they were a disk. On **OSX**, you'll require `osxfuse` for Linux filesystems also. Both tools can easily be installed with brew:

```bash
brew install osxfuse

brew install sshfs
```

Make a mount point and mount with
```bash
sshfs -o allow_other,default_permissions [USER]@[ADDRESS]:/ /path/to/mnt
```

and unmount with
```bash
umount /path/to/mnt
```
or, on OSX,
```bash
diskutil unmountDisk /path/to/mnt
```

### Mounting HFS/HFS+ on Linux <a name="toc-sub-tag-8"></a>
By default, linux will mount Apple HFS/HFS+ journaled filesystems as read-only. To cirumvent this, without having to disable journaling, we can use `hfsprogs`
```bash
sudo apt-get install hfsprogs
```

We then force `rw` permissions on the mount:
```
sudo mount -t hfsplus -o rw,force /dev/sdx /path/to/mnt
```
The specific type may vary.

To enable others, you still need to pass `gid/uid` or `umask`.

## `rsync` <a name="toc-sub-tag-9"></a>
`rsync` is an alternative to `cp` or `mv` with much extended as useful functionality. I will include some common recipes here for it.

`rsync` does not not ship by default on many linux distributions, but can easily be installed with a package manager.

Later version of `rsync` drive all of the operations over SSH, thus can be used inplace of `scp`.

### Merging file trees <a name="toc-sub-tag-10"></a>
To merge a directory `dir1` into `dir2` in such a way as to skip duplicate files, and ensure the tree structure of `dir1` is replicated in `dir2` we can use the archive command
```bash
rsync -av dir1/* dir2
```

Note, from the manual:
> Note  that  -a does not preserve hardlinks, because finding multiply-linked files is ex‐
pensive.  You must separately specify -H.


## On storing binaries <a name="toc-sub-tag-11"></a>
There are multiple different locations for binaries on Linux, however there is [an etiquette](https://unix.stackexchange.com/a/8658) which ought to be abided by. In general, the prefix `s` denotes system, and thus is for binaries and executables managed by the system for root (i.e. not for ordinary users).

- `/bin` (and `/sbin`) is for programs required on the `/` partition, prior to mounting other partitions; e.g. shells and disk commands.
- `/usr/bin` (and `/usr/sbin`) is for distro-managed user programs.
- `/usr/local/bin` (and `/usr/local/sbin`) is for normal programs not managed by the distro. 
- `/opt` is for non-distro packages that do not behave well on the chosen distro. It is usually reserved for large poorly behaved packages.

`/usr/local/bin` is where you would want to store and link your own executables to.

## On `.desktop` files <a name="toc-sub-tag-12"></a>
Link for the single user to
```
~/.local/share/applications/
```

or globally in
```
/usr/share/applications/
```

## On securely erasing disks <a name="toc-sub-tag-13"></a>
Shredding SSDs can be more involved, and a method is usually provided by the manufacturer. For HDDs, we can use `shred`, included with most Linux distributions.

A common use is
```bash 
shred -uvz [file]
```
with `-u` for deallocation and removing, `-v` for verbose, and `-z` to overwrite the memory location with zeros. By default, `shred` will overwrite the file with random data three times, followed by the fourth swipe with zeroes.

You can set the number of overwrite sweeps with `-n [num]`.

On [journaled](https://en.wikipedia.org/wiki/Journaling_file_system) filesystems, such as ext3 and ext4, `shred` is not necessarily guaranteed to *permanetly* delete the files. For such problems, the `secure-delete` tool exists, installable with most package managers.

This tool will scrub the data with a whole series of overwrites and passes, including techniques described by [Peter Gutmann](https://www.cs.auckland.ac.nz/~pgut001/pubs/secure_del.html).

`secure-delete` ships with four commands:

- `srm` for secure `rm`, for erasing, deleteing, and scrubbing
```bash
srm -vz [file]
```
with the flags having similar meaning to `shred`.

- `sfill` for filling and overwritting free space on a filesystem

This is to be used in conjunction with `srm`; afer filling memory with random data, `sfill` will then release the diskspace. This command accepts many of the same flags as `srm`.

- `sswap` for overwriting swap space partitions
- `sdmem` for wiping RAM

