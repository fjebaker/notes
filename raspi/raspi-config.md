# Configuring a Raspberry Pi from fresh install
I recently bought a new SD card for my years-old pi, and wanted to reformat and configure the thing properly. I first attempted to copy the existing OS onto the disk, and then expand the partition but apparently NOOBS prevents this from being a straight forward task. Even attempts using `fdisk` just seemed to fragment the partitions, so instead I just created a fresh install. Here are my notes for how I achieved this.

<!--BEGIN TOC-->
## Table of Contents
1. [Formatting an SD card for Raspbian](#toc-sub-tag-0)
	1. [OSX: using `diskutil`](#toc-sub-tag-1)
2. [Backing up disk images](#toc-sub-tag-2)
3. [Some quality of life tips](#toc-sub-tag-3)
	1. [Setting an SSH banner](#toc-sub-tag-4)
	2. [Changing the hostname](#toc-sub-tag-5)
<!--END TOC-->

## Formatting an SD card for Raspbian <a name="toc-sub-tag-0"></a>
If the SD card is >32 GB, it can be necessary to use a special formatting tool; the pi can only use FAT8, FAT16 or FAT32 file formats (OSX: that's MS-DOS, **not** ExDOS). Since I mainly work on OSX, the following guide will follow the steps for my OS (I may write up guides for other OSs later).

### OSX: using `diskutil` <a name="toc-sub-tag-1"></a>
After plugging in the desired SD card to use in the Raspberry Pi, we need to identify the device associated
```bash
diskutil list
```
If the SD is recognized, you'll probably see something like
```
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *15.9 GB    disk2
   1:             Windows_FAT_16 RECOVERY                1.7 GB     disk2s1
   2:                      Linux                         33.6 MB    disk2s5
   3:             Windows_FAT_32 boot                    69.2 MB    disk2s6
   4:                      Linux                         14.1 GB    disk2s7
```
for an external disk. If this is a pre-existing OS you want to backup, see the section on backing up disk images. From this output we can identify the correct device as `/dev/disk2`; we'll unmount it so we can start tampering with the configuration
```bash
diskutil unmountDisk /dev/disk2
```
The first thing we'll want to do is erase the SD card and reformat it with FAT32; we can achieve this all in one step with
```bash
diskutil eraseDisk MS-DOS [NAME] /dev/disk2
```
This will create essentially a single volume on the SD card, spanning the full storage. Next, we'll grab our operating system image from either the [official repository](https://www.raspberrypi.org/downloads/raspbian/), or some other source. We then flash the `.img` onto the SD card using `dd`; we set a few parameters to ensure the block size is `1M` and that the input is padded to the buffer size using `sync`; for my case, the command looked like this
```bash
sudo dd bs=1m if=2020-02-13-raspbian-buster-lite.img of=/dev/rdisk2 conv=sync
```
Note that the identifier is preceded with an `r` in `/dev/rdisk2`; this is the raw partition, allowing us to write one byte at a time (the other being the block device for regular IO).

Unfortunately, `dd` doesn't provide a status bar or indication text, but recent versions of GNU do include a `status=progress` verb to be used at the end of the command. I don't believe OSX supports this function however, so personally I track the progress using a detail I found in the man page

>If dd receives a SIGINFO (see the status argument for stty(1)) signal, the current input and output
>block counts will be written to the standard error output in the same format as the standard com-
>pletion message.  If dd receives a SIGINT signal, the current input and output block counts will be
>written to the standard error output in the same format as the standard completion message and dd
>will exit.

So, on OSX we can output the status by pinging
```bash
sudo kill -INFO pid
```
where `pid` is the process ID of `dd`.

Once this copy has completed, the SD card is ready to be used with the Pi.

## Backing up disk images <a name="toc-sub-tag-2"></a>
If you want to create a disk image from a given SD card, once you have identified the associated device, doing so is trivial
```
sudo dd if=/dev/diskID of=DISK_IMAGE_NAME.img
```

## Some quality of life tips <a name="toc-sub-tag-3"></a>
I like to have my Pi's feel different from other machines, so I tend to tweak the same settings over and over; here are my notes for how I do that.

### Getting Docker
Docker is installed with a one-liner:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
```

Add a non-root user to the docker group, e.g. the default pi user
```bash
sudo usermod -aG docker pi
```
and you're away! Test it all with
```bash
docker run hello-world
```

### Enabling WiFi before boot
You can configure the pi to connect to a wifi router before you boot the device; mount the SD card, and in the `boot` volume, create a new file with the contents:
```
country=gb
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
ssid="SSID"
scan_ssid=1
psk="WIFI_PASSWORD"
}
```
The country codes follow Alpha-2 ISO 3166 format.

That's it; use `arp -a` or `nmap -sn` to scan for the pi once it connects!

### Enabling WiFi after boot
This is as simple as using the interactive `sudo raspi-config`, and navigating to the Network Options.

### SSH enable in headless mode
Simply navigate to the `boot` directory, and create an empty `ssh` file; e.g.:
```bash
touch Volumes/boot/ssh
```
and then (re)boot the device.

### Setting an SSH banner <a name="toc-sub-tag-4"></a>
The 'standard' banner file (though you can create your own anywhere, just ensure read priveledges) is `/etc/issue.net`; paste whatever you want your banner to be in this file. Then we just need to configure the SSH server to present the banner -- to do this, edit
```
/etc/ssh/sshd_config
```
and add the line
```
Banner /etc/issue.net
```
changing the file path to the relevant file for you.

### Changing the hostname <a name="toc-sub-tag-5"></a>
The hostname is located in a few different locations, so we want to edit the files
```
/etc/hostname
/etc/hosts
```
and change, presumably, `raspberrypi` to whatever you'd like the hostname to be, and then reboot. Note, you may also need to run `hostname` upon reboot, but I have only read this, and did not personally need to.

### Disabling unneeded hardware
In `/boot/config.txt` you can set a variety of different parameters that control how the raspi boots up. For example, to disable WiFi and Bluetooth completely, add the line:
```
dtoverlay=disable-wifi
dtoverlay=disable-bt
```
These are use-case specific, and more can be seen [here](https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README).
