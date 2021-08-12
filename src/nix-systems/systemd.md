# `systemd` and `journald` 

<!--BEGIN TOC-->
## Table of Contents
1. [Overview of Linux Logging](#overview-of-linux-logging)
2. [Recipes](#recipes)
    1. [Using service files with mounts](#using-service-files-with-mounts)
    2. [Listing services](#listing-services)

<!--END TOC-->

## Overview of Linux Logging
`journald` is a replacement for `syslog`; it stores logs in a compressed format instead of plain text, provides highly configurable logging size and time limits (`/etc/systemd/journald.conf`), and partially authenticates logs.

`syslog` collects messages from services and the kernel and stored them in various logging files in `/var/log`, and indeed many logs are still written to this location. For example, `/var/log/messages` stores non-debug, non-critial messages -- in many cases, it duplicates messages stored by `journald`. By contrast, `/var/log/syslog` logs everything apart from authentication messages, which are written seperately to `/var/log/auth.log`.

`dmesg` is a tool for viewing the kernel ring buffer. The ring buffer is the log location where kernel messages are written to, before they are collected by `syslog` or `journald` -- this way, kernel logs written before the services are started can still be collected. `dmesg` on some systems just reads `/var/log/kern.log`. The kenrnel messages are not persitent between boots. 

A list of all common linux log files in `/var/log` can be found in [this SuperUser answer](https://superuser.com/a/734328).

## Recipes
### Using service files with mounts
In order to ensure a service file is executed after a file system has been mounted with e.g. `fstab`, we need to find the relevant `*.mount` service genereated.

After adding the filesystem to `/etc/fstab`, generate the configuration with
```bash
sudo mount -a
```

and then find the service with
```bash
systemctl list-units | grep '/path/to/mnt'
```

We then add this `*.mount` file to our service file under
```
[Unit]
Requires=path-to-mnt.mount
After=path-to-mnt.mount
```

The `Requires` ensures that the service file fails elegantly if the filesystem encountered a problem during mount.

### Listing services
Examples
```bash
systemctl list-units --type=service --state=running
```
For all services
```bash
systemctl list-units --type=service --all
```